///|
#derive(Eq, Debug)
pub(all) enum Phase {
  New
  Ready
  Configuring
  Running
  Stopped
  Terminated
  Closed
}

///|
pub extend Phase with Eq::{equal, not_equal}

///|
pub extend Phase with @debug.Debug::{to_repr}

///|
#derive(Debug)
pub suberror SessionError {
  SequenceExhausted
  ReusedRequestSequence(Int32)
}

///|
pub extend SessionError with @debug.Debug::{to_repr}

///|
struct Session {
  target : &DebugTarget
  location_provider : ((String, BreakpointRange) -> Array[BreakpointSpec] raise TargetError)?
  condition_provider : ((String, Array[ConditionalBreakpointSpec]) -> Array[
    BreakpointResult,
  ] raise TargetError)?
  evaluate_provider : ((Int32?, String) -> String raise TargetError)?
  events : Array[TargetEvent]
  frame_refs : References
  variable_refs : References
  mut phase : Phase
  mut next_sequence : Int64
  mut last_request : Int32
  mut lines_start_at_one : Bool
  mut columns_start_at_one : Bool
  mut variable_types : Bool
  mut variable_paging : Bool
  mut mode : StartMode?
  mut pending_start : @protocol.Request?
  mut generation : Int64
}

///|
pub fn Session::new(target : &DebugTarget) -> Session {
  {
    target,
    location_provider: target.breakpoint_location_provider(),
    condition_provider: target.conditional_breakpoint_provider(),
    evaluate_provider: target.evaluation_provider(),
    events: [],
    frame_refs: References::new(),
    variable_refs: References::new(),
    phase: New,
    next_sequence: 1L,
    last_request: 0,
    lines_start_at_one: true,
    columns_start_at_one: true,
    variable_types: false,
    variable_paging: false,
    mode: None,
    pending_start: None,
    generation: 0L,
  }
}

///|
pub fn Session::phase(self : Session) -> Phase {
  self.phase
}

///|
pub fn Session::coordinates(self : Session) -> (Bool, Bool) {
  (self.lines_start_at_one, self.columns_start_at_one)
}

///|
fn Session::sequence(self : Session) -> Int32 raise SessionError {
  guard self.next_sequence <= 2147483647L else { raise SequenceExhausted }
  let seq = self.next_sequence.to_int()
  self.next_sequence += 1L
  seq
}

///|
fn Session::reply(
  self : Session,
  req : @protocol.Request,
  body? : Json,
) -> Json raise SessionError {
  let message : @protocol.Response = {
    seq: self.sequence(),
    request_seq: req.seq,
    success: true,
    command: req.command,
    message: None,
    body,
  }
  message.to_json()
}

///|
fn Session::event(
  self : Session,
  event : String,
  body? : Json,
) -> Json raise SessionError {
  let value : @protocol.Event = { seq: self.sequence(), event, body, }
  value.to_json()
}

///|
fn Session::failure(
  self : Session,
  req : @protocol.Request,
  code : String,
  details : String,
) -> Json raise SessionError {
  let message : @protocol.ErrorResponse = {
    seq: self.sequence(),
    request_seq: req.seq,
    success: false,
    command: req.command,
    message: Some(code),
    body: {
      error: Some({
        id: 1,
        format: details,
        variables: None,
        send_telemetry: None,
        show_user: Some(true),
        url: None,
        url_label: None,
      }),
    },
  }
  message.to_json()
}

///|
fn[T : @json.FromJson] arguments(
  req : @protocol.Request,
) -> T raise @json.JsonDecodeError {
  @json.from_json(req.arguments.unwrap_or(Json::empty_object()))
}

///|
fn Session::initialize(self : Session, req : @protocol.Request) -> Json raise {
  if self.phase != New {
    return self.failure(req, "invalidState", "会话已经初始化")
  }
  let args : @protocol.InitializeRequestArguments = arguments(req)
  guard args.path_format.unwrap_or("path") == "path" else {
    return self.failure(
      req, "unsupportedPathFormat", "第一版使用本地文件路径",
    )
  }
  self.lines_start_at_one = args.lines_start_at1.unwrap_or(true)
  self.columns_start_at_one = args.columns_start_at1.unwrap_or(true)
  self.variable_types = args.supports_variable_type.unwrap_or(false)
  self.variable_paging = args.supports_variable_paging.unwrap_or(false)
  self.phase = Ready
  let capabilities = Map([
    ("supportsConfigurationDoneRequest", Json::boolean(true)),
    ("supportsDelayedStackTraceLoading", Json::boolean(true)),
  ])
  if self.location_provider is Some(_) {
    capabilities.set("supportsBreakpointLocationsRequest", Json::boolean(true))
  }
  if self.condition_provider is Some(_) {
    capabilities.set("supportsConditionalBreakpoints", Json::boolean(true))
  }
  if self.evaluate_provider is Some(_) {
    capabilities.set("supportsEvaluateForHovers", Json::boolean(true))
  }
  self.reply(req, body=Json::object(capabilities))
}

///|
/// 处理已解码的 JSON。可识别的请求参数错误会收到协议失败响应。
pub async fn Session::handle(self : Session, value : Json) -> Array[Json] {
  guard self.phase != Closed else { return [] }
  let req : @protocol.Request = @json.from_json(value)
  guard req.seq > self.last_request else {
    raise ReusedRequestSequence(req.seq)
  }
  self.last_request = req.seq
  let messages = self.drain_events()
  let responses = self.dispatch(req) catch {
    @json.JsonDecodeError(_) as error =>
      [self.failure(req, "invalidArguments", error.to_string())]
    RequestFailure(code, detail) => [self.failure(req, code, detail)]
    TargetError(detail) => [self.failure(req, "targetError", detail)]
    error => raise error
  }
  for response in responses {
    messages.push(response)
  }
  for event in self.drain_events() {
    messages.push(event)
  }
  messages
}
