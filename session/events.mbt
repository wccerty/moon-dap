///|
fn StopReason::wire(self : StopReason) -> String {
  match self {
    Breakpoint => "breakpoint"
    Step => "step"
    Pause => "pause"
    Entry => "entry"
    Exception => "exception"
  }
}

///|
fn Session::terminate(
  self : Session,
  messages : Array[Json],
) -> Unit raise SessionError {
  self.phase = Terminated
  self.clear_references()
  messages.push(self.event("terminated"))
}

///|
fn Session::drain_events(self : Session) -> Array[Json] raise SessionError {
  let messages = []
  if !self.active() {
    return messages
  }
  let events = self.events.copy()
  self.events.clear()
  for event in events {
    guard self.active() else { break }
    match event {
      Stopped(stop) if self.phase == Running => {
        let body : Map[String, Json] = {
          "reason": Json::string(stop.reason.wire()),
          "threadId": @json.to_json(stop.thread_id),
          "allThreadsStopped": Json::boolean(true),
        }
        if stop.description is Some(text) {
          body.set("description", Json::string(text))
        }
        if !stop.breakpoint_ids.is_empty() {
          body.set("hitBreakpointIds", @json.to_json(stop.breakpoint_ids))
        }
        self.phase = Stopped
        messages.push(self.event("stopped", body=Json::object(body)))
      }
      Stopped(_) => ()
      Output(category, text) =>
        messages.push(
          self.event("output", body={ "category": category, "output": text }),
        )
      Exited(code) => {
        messages.push(self.event("exited", body={ "exitCode": code }))
        self.terminate(messages)
      }
      Terminated => self.terminate(messages)
      Continued(thread) if self.phase == Stopped => {
        self.clear_references()
        self.phase = Running
        messages.push(
          self.event("continued", body={
            "threadId": thread,
            "allThreadsContinued": true,
          }),
        )
      }
      Continued(_) => ()
      ThreadStarted(thread) =>
        messages.push(
          self.event("thread", body={ "reason": "started", "threadId": thread }),
        )
      ThreadExited(thread) =>
        messages.push(
          self.event("thread", body={ "reason": "exited", "threadId": thread }),
        )
    }
  }
  messages
}

///|
/// 在没有请求时推动一个有界运行片，并收集运行时通知。
pub async fn Session::poll(self : Session) -> Array[Json] {
  let pending = self.drain_events()
  if !pending.is_empty() || self.phase != Running {
    return pending
  }
  self.target.poll() catch {
    TargetError(detail) => {
      let detail = self.release_after_failure(detail)
      let messages = [
        self.event("output", body={
          "category": "stderr",
          "output": detail + "\n",
        }),
      ]
      self.terminate(messages)
      return messages
    }
  }
  self.drain_events()
}
