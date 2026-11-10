///|
fn Session::require_stopped(self : Session) -> Unit raise RequestFailure {
  guard self.phase == Stopped else {
    if self.phase == Running {
      raise RequestFailure("notStopped", "目标尚未暂停")
    }
    raise RequestFailure("invalidState", "目标当前不可检查")
  }
}

///|
fn Session::require_thread(self : Session, id : Int32) -> Unit raise {
  guard self.target.threads().iter().any(thread => thread.id == id) else {
    raise RequestFailure("invalidArguments", "未知线程 \{id}")
  }
}

///|
fn check_stepping(
  single_thread : Bool?,
  granularity : @protocol.SteppingGranularity?,
) -> Unit raise RequestFailure {
  guard !single_thread.unwrap_or(false) && !(granularity is Some(Instruction)) else {
    raise RequestFailure(
      "notSupported", "不支持单线程执行或指令级单步",
    )
  }
}

///|
fn Session::resume_execution(
  self : Session,
  req : @protocol.Request,
  mode : ResumeMode,
) -> Json raise {
  self.require_stopped()
  let thread = match mode {
    Continue => {
      let args : @protocol.ContinueArguments = arguments(req)
      check_stepping(args.single_thread, None)
      args.thread_id
    }
    StepIn => {
      let args : @protocol.StepInArguments = arguments(req)
      check_stepping(args.single_thread, args.granularity)
      guard args.target_id is None else {
        raise RequestFailure("notSupported", "不支持指定步入目标")
      }
      args.thread_id
    }
    StepOver => {
      let args : @protocol.NextArguments = arguments(req)
      check_stepping(args.single_thread, args.granularity)
      args.thread_id
    }
    StepOut => {
      let args : @protocol.StepOutArguments = arguments(req)
      check_stepping(args.single_thread, args.granularity)
      args.thread_id
    }
  }
  self.require_thread(thread)
  self.target.resume_execution(thread, mode)
  self.phase = Running
  match mode {
    Continue => self.reply(req, body={ "allThreadsContinued": true })
    _ => self.reply(req)
  }
}

///|
fn Session::pause(self : Session, req : @protocol.Request) -> Json raise {
  guard self.phase == Running else {
    raise RequestFailure("invalidState", "只有运行中的目标可暂停")
  }
  let args : @protocol.PauseArguments = arguments(req)
  self.require_thread(args.thread_id)
  self.target.pause(args.thread_id)
  self.reply(req)
}
