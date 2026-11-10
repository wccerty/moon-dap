///|
async test "调用栈分页与嵌套变量，恢复后旧句柄失效" {
  let target = FakeTarget::new()
  target.start_stopped = true
  let session = Session::new(target)
  ignore(
    session.handle(
      request(1, "initialize", args={
        "adapterID": "demo",
        "linesStartAt1": false,
        "supportsVariableType": true,
        "supportsVariablePaging": true,
      }),
    ),
  )
  ignore(session.handle(request(2, "launch")))
  ignore(session.handle(request(3, "configurationDone")))
  let stack : @protocol.StackTraceResponse = @json.from_json(
    session.handle(
      request(4, "stackTrace", args={ "threadId": 1, "levels": 1 }),
    )[0],
  )
  assert_eq(stack.body.total_frames, Some(2L))
  assert_eq(stack.body.stack_frames.length(), 1)
  let frame = stack.body.stack_frames[0]
  assert_eq(frame.line, 8L)
  let scopes : @protocol.ScopesResponse = @json.from_json(
    session.handle(request(5, "scopes", args={ "frameId": frame.id }))[0],
  )
  let locals = scopes.body.scopes[0].variables_reference
  let parent : @protocol.VariablesResponse = @json.from_json(
    session.handle(
      request(6, "variables", args={
        "variablesReference": locals,
        "filter": "named",
      }),
    )[0],
  )
  let record = parent.body.variables[0]
  assert_eq(record.type_, Some("record"))
  assert_eq(record.named_variables, Some(1))
  let child : @protocol.VariablesResponse = @json.from_json(
    session.handle(
      request(7, "variables", args={
        "variablesReference": record.variables_reference,
      }),
    )[0],
  )
  assert_eq(child.body.variables[0].value, "42")
  assert_eq(child.body.variables[0].variables_reference, 0)
  ignore(session.handle(request(8, "continue", args={ "threadId": 1 })))
  let running : @protocol.Response = @json.from_json(
    session.handle(
      request(9, "variables", args={ "variablesReference": locals }),
    )[0],
  )
  assert_eq(running.message, Some("notStopped"))
  ignore(session.handle(request(10, "pause", args={ "threadId": 1 })))
  let stale : @protocol.Response = @json.from_json(
    session.handle(request(11, "scopes", args={ "frameId": frame.id }))[0],
  )
  assert_eq(stale.message, Some("invalidReference"))
  let later : @protocol.StackTraceResponse = @json.from_json(
    session.handle(request(12, "stackTrace", args={ "threadId": 1 }))[0],
  )
  assert_true(later.body.stack_frames[0].id > frame.id)
}

///|
async test "主动恢复和线程事件保持共享 seq 顺序" {
  let target = FakeTarget::new()
  target.start_stopped = true
  let session = Session::new(target)
  initialize_test(session)
  ignore(session.handle(request(2, "attach")))
  ignore(session.handle(request(3, "configurationDone")))
  target.emit(Continued(1))
  target.emit(ThreadStarted(2))
  target.emit(ThreadExited(2))
  let events = session.poll()
  let resumed : @protocol.Event = @json.from_json(events[0])
  let started : @protocol.Event = @json.from_json(events[1])
  let exited : @protocol.Event = @json.from_json(events[2])
  assert_eq(
    (resumed.event, started.event, exited.event),
    ("continued", "thread", "thread"),
  )
  assert_eq((resumed.seq, started.seq, exited.seq), (6, 7, 8))
  assert_eq(session.phase(), Running)
}
