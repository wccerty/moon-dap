///|
priv suberror RequestFailure {
  RequestFailure(String, String)
}

///|
fn Session::sink(self : Session) -> EventSink {
  let generation = self.generation
  {
    publish: event => {
      guard self.generation == generation && self.mode is Some(_) else {
        raise TargetError("调试会话已关闭")
      }
      guard self.events.length() < 256 else {
        raise TargetError("调试事件队列已满")
      }
      self.events.push(event)
    },
  }
}

///|
async fn Session::release(self : Session) -> Unit {
  let mode = self.mode
  self.mode = None
  self.events.clear()
  if mode is Some(mode) {
    self.target.disconnect(
      match mode {
        Launch => Terminate
        Attach => Detach
      },
    )
  }
}

///|
async fn Session::release_after_failure(
  self : Session,
  detail : String,
) -> String {
  self.release() catch {
    error => {
      if @async.is_cancellation_error(error) {
        raise error
      }
      return detail + "\n清理失败：" + error.to_string()
    }
  }
  detail
}

///|
/// 断线后清理。正常 disconnect 已清理时重复调用安全。
pub async fn Session::close(self : Session) -> Unit {
  self.phase = Closed
  self.pending_start = None
  self.release()
}

///|
async fn Session::begin(
  self : Session,
  req : @protocol.Request,
  mode : StartMode,
) -> Array[Json] {
  guard self.phase == Ready else {
    raise RequestFailure(
      "invalidState", "目标只能在准备阶段启动或绑定",
    )
  }
  let options = req.arguments.unwrap_or(Json::empty_object())
  match mode {
    Launch => {
      let args : @protocol.LaunchRequestArguments = @json.from_json(options)
      if args.no_debug.unwrap_or(false) {
        raise RequestFailure("notSupported", "不支持无调试运行")
      }
    }
    Attach => {
      let _ : @protocol.AttachRequestArguments = @json.from_json(options)
    }
  }
  self.generation += 1L
  self.mode = Some(mode)
  self.target.prepare(mode, options, self.sink()) catch {
    error => {
      if @async.is_cancellation_error(error) {
        raise error
      }
      let detail = self.release_after_failure(error.to_string())
      return [self.failure(req, "targetError", detail)]
    }
  }
  self.pending_start = Some(req)
  self.phase = Configuring
  [self.event("initialized")]
}

///|
async fn Session::configuration_done(
  self : Session,
  req : @protocol.Request,
) -> Array[Json] {
  guard self.phase == Configuring && self.pending_start is Some(start) else {
    raise RequestFailure("invalidState", "当前会话未在等待配置完成")
  }
  let _ : @protocol.ConfigurationDoneArguments = arguments(req)
  self.pending_start = None
  self.target.start() catch {
    TargetError(detail) => {
      self.phase = Terminated
      let detail = self.release_after_failure(detail)
      return [
        self.failure(req, "targetError", detail),
        self.failure(start, "targetError", detail),
        self.event("terminated"),
      ]
    }
  }
  self.phase = Running
  [self.reply(req), self.reply(start)]
}

///|
async fn Session::disconnect(
  self : Session,
  req : @protocol.Request,
) -> Array[Json] {
  let _ : @protocol.DisconnectArguments = arguments(req)
  let messages = []
  if self.pending_start is Some(start) {
    messages.push(
      self.failure(start, "cancelled", "调试会话在配置完成前结束"),
    )
  }
  self.close() catch {
    error => {
      if @async.is_cancellation_error(error) {
        raise error
      }
      messages.push(self.failure(req, "targetError", error.to_string()))
      return messages
    }
  }
  messages.push(self.reply(req))
  messages
}

///|
fn Session::active(self : Session) -> Bool {
  self.phase == Running || self.phase == Stopped
}

///|
fn Session::require_configuration(self : Session) -> Unit raise RequestFailure {
  guard self.phase == Configuring || self.active() else {
    raise RequestFailure("invalidState", "目标未准备好接收配置")
  }
}

///|
fn Session::exception_breakpoints(
  self : Session,
  req : @protocol.Request,
) -> Json raise {
  self.require_configuration()
  let args : @protocol.SetExceptionBreakpointsArguments = arguments(req)
  guard args.filters.is_empty() &&
    args.filter_options.unwrap_or([]).is_empty() &&
    args.exception_options.unwrap_or([]).is_empty() else {
    raise RequestFailure("notSupported", "不支持异常断点筛选")
  }
  self.reply(req, body={ "breakpoints": [] })
}

///|
async fn Session::dispatch(
  self : Session,
  req : @protocol.Request,
) -> Array[Json] {
  if req.command == "initialize" {
    return [self.initialize(req)]
  }
  guard self.phase != New else {
    return [self.failure(req, "invalidState", "请先初始化会话")]
  }
  match req.command {
    "launch" => self.begin(req, Launch)
    "attach" => self.begin(req, Attach)
    "configurationDone" => self.configuration_done(req)
    "disconnect" => self.disconnect(req)
    "setBreakpoints" => [self.set_breakpoints(req)]
    "setExceptionBreakpoints" => [self.exception_breakpoints(req)]
    "continue" => [self.resume_execution(req, Continue)]
    "next" => [self.resume_execution(req, StepOver)]
    "stepIn" => [self.resume_execution(req, StepIn)]
    "stepOut" => [self.resume_execution(req, StepOut)]
    "pause" => [self.pause(req)]
    _ => [self.failure(req, "notSupported", "未实现请求 \{req.command}")]
  }
}
