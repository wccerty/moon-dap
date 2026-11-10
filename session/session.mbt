///|
pub(all) enum Phase {
  New
  Ready
  Closed
} derive(Eq, Debug)

///|
pub extend Phase with Eq::{equal, not_equal}

///|
pub extend Phase with @debug.Debug::{to_repr}

///|
pub suberror SessionError {
  SequenceExhausted
  ReusedRequestSequence(Int32)
} derive(Debug)

///|
pub extend SessionError with @debug.Debug::{to_repr}

///|
struct Session {
  mut phase : Phase
  mut next_sequence : Int64
  mut last_request : Int32
  mut lines_start_at_one : Bool
  mut columns_start_at_one : Bool
}

///|
pub fn Session::new() -> Session {
  {
    phase: New,
    next_sequence: 1L,
    last_request: 0,
    lines_start_at_one: true,
    columns_start_at_one: true,
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
  guard self.next_sequence <= 2147483647L else {
    self.phase = Closed
    raise SequenceExhausted
  }
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
  self.phase = Ready
  self.reply(req, body={ "supportsConfigurationDoneRequest": true })
}

///|
/// 处理已解码的 JSON。可识别的请求参数错误会收到协议失败响应。
pub fn Session::handle(self : Session, value : Json) -> Array[Json] raise {
  guard self.phase != Closed else { return [] }
  let req : @protocol.Request = @json.from_json(value)
  guard req.seq > self.last_request else {
    raise ReusedRequestSequence(req.seq)
  }
  self.last_request = req.seq
  if req.command == "initialize" {
    let response = self.initialize(req) catch {
      @json.JsonDecodeError(_) as error =>
        self.failure(req, "invalidArguments", error.to_string())
      error => raise error
    }
    return [response]
  }
  if self.phase == New {
    return [self.failure(req, "invalidState", "请先初始化会话")]
  }
  if req.command == "disconnect" {
    let response = self.reply(req)
    self.phase = Closed
    return [response]
  }
  [self.failure(req, "notSupported", "未实现请求 \{req.command}")]
}
