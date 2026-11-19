///|
priv struct DeadlineTarget {
  mut disconnects : Int32
  mut cleanup_finished : Bool
}

///|
impl @session.DebugTarget for DeadlineTarget with fn prepare(_, _, _, _) {
  ()
}

///|
impl @session.DebugTarget for DeadlineTarget with fn start(_) {
  ()
}

///|
impl @session.DebugTarget for DeadlineTarget with fn set_breakpoints(_, _, _) {
  []
}

///|
impl @session.DebugTarget for DeadlineTarget with fn resume_execution(_, _, _) {
  ()
}

///|
impl @session.DebugTarget for DeadlineTarget with fn pause(_, _) {
  ()
}

///|
impl @session.DebugTarget for DeadlineTarget with fn threads(_) {
  []
}

///|
impl @session.DebugTarget for DeadlineTarget with fn stack_trace(_, _, _) {
  { frames: [], total: 0L, }
}

///|
impl @session.DebugTarget for DeadlineTarget with fn scopes(_, _) {
  []
}

///|
impl @session.DebugTarget for DeadlineTarget with fn variables(_, _, _) {
  []
}

///|
impl @session.DebugTarget for DeadlineTarget with fn poll(_) {
  raise @session.TargetError("运行时轮询失败")
}

///|
impl @session.DebugTarget for DeadlineTarget with fn disconnect(self, _) {
  self.disconnects += 1
  defer {
    self.cleanup_finished = true
  }
  @async.sleep(60000)
}

///|
priv struct DeadlineWriter {}

///|
impl @io.Writer for DeadlineWriter with fn write_once(_, _, offset~, len~) {
  ignore(offset)
  len
}

///|
async test "轮询失败后的阻塞清理遵守传输超时且只调用一次" {
  let reader = @io.MemoryReader(writer => {
    let messages : Array[Json] = [
      {
        "seq": 1,
        "type": "request",
        "command": "initialize",
        "arguments": { "adapterID": "deadline" },
      },
      { "seq": 2, "type": "request", "command": "launch" },
      { "seq": 3, "type": "request", "command": "configurationDone" },
    ]
    for message in messages {
      writer.write(@framing.encode(@utf8.encode(message.stringify())))
    }
    @async.sleep(60000)
  })
  defer reader.close()
  let target = DeadlineTarget::{ disconnects: 0, cleanup_finished: false, }
  let timed_out = @async.with_timeout_opt(1000, () => {
    try {
      serve(reader, DeadlineWriter::{ }, target, options={
        ..Options::default(),
        request_timeout_ms: 20,
      })
      false
    } catch {
      @async.TimeoutError => true
      error => raise error
    }
  })
  assert_eq(timed_out, Some(true))
  assert_eq(target.disconnects, 1)
  assert_true(target.cleanup_finished)
}
