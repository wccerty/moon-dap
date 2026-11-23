///|
priv struct FakeTarget {
  mut sink : EventSink?
  mut breakpoints : Array[BreakpointSpec]
  mut disconnected : DisconnectMode?
  mut fail_prepare : Bool
  mut fail_start : Bool
  mut start_stopped : Bool
  mut source_test_provider : SourceProvider?
  mut inspection_test_providers : InspectionProviders
  mut breakpoint_test_providers : BreakpointProviders
}

///|
fn FakeTarget::new() -> FakeTarget {
  {
    sink: None,
    breakpoints: [],
    disconnected: None,
    fail_prepare: false,
    fail_start: false,
    start_stopped: false,
    source_test_provider: None,
    inspection_test_providers: InspectionProviders::new(),
    breakpoint_test_providers: BreakpointProviders::new(),
  }
}

///|
impl DebugTarget for FakeTarget with fn source_provider(self) {
  self.source_test_provider
}

///|
impl DebugTarget for FakeTarget with fn inspection_providers(self) {
  self.inspection_test_providers
}

///|
impl DebugTarget for FakeTarget with fn breakpoint_providers(self) {
  self.breakpoint_test_providers
}

///|
fn FakeTarget::emit(
  self : FakeTarget,
  event : TargetEvent,
) -> Unit raise TargetError {
  if self.sink is Some(sink) {
    sink.emit(event)
  }
}

///|
impl DebugTarget for FakeTarget with fn prepare(self, _, _, sink) {
  self.sink = Some(sink)
  if self.fail_prepare {
    raise TargetError("准备失败")
  }
}

///|
impl DebugTarget for FakeTarget with fn start(self) {
  if self.fail_start {
    raise TargetError("启动失败")
  }
  if self.start_stopped {
    self.emit(
      Stopped({
        reason: Entry,
        thread_id: 1,
        description: None,
        breakpoint_ids: [],
      }),
    )
  }
}

///|
impl DebugTarget for FakeTarget with fn set_breakpoints(self, _, points) {
  self.breakpoints = points
  points.map(point => {
    id: Some(12),
    verified: true,
    line: Some(point.line),
    column: point.column,
    message: None,
  })
}

///|
impl DebugTarget for FakeTarget with fn resume_execution(_, _, _) {
  ()
}

///|
impl DebugTarget for FakeTarget with fn pause(self, thread_id) {
  self.emit(
    Stopped({ reason: Pause, thread_id, description: None, breakpoint_ids: [], }),
  )
}

///|
impl DebugTarget for FakeTarget with fn threads(_) {
  [{ id: 1, name: "main", }]
}

///|
impl DebugTarget for FakeTarget with fn stack_trace(_, _, page) {
  let frames : Array[Frame] = [
    {
      handle: 70,
      name: "inner",
      location: Some({ path: "demo", line: 9L, column: Some(1L), }),
    },
    { handle: 71, name: "main", location: None, },
  ]
  { frames: page.slice(frames), total: frames.length().to_int64(), }
}

///|
impl DebugTarget for FakeTarget with fn scopes(_, handle) {
  [{ name: "locals", handle, expensive: false, }]
}

///|
impl DebugTarget for FakeTarget with fn variables(_, handle, query) {
  let values : Array[Variable] = if handle == 70 {
    [
      {
        name: "record",
        value: "{value}",
        type_name: Some("record"),
        children: Some(99),
        named_count: Some(1),
        indexed_count: None,
      },
    ]
  } else {
    [
      {
        name: "value",
        value: "42",
        type_name: Some("int"),
        children: None,
        named_count: None,
        indexed_count: None,
      },
    ]
  }
  if query.filter is Indexed {
    []
  } else {
    query.page.slice(values)
  }
}

///|
impl DebugTarget for FakeTarget with fn poll(_) {
  ()
}

///|
impl DebugTarget for FakeTarget with fn disconnect(self, mode) {
  self.disconnected = Some(mode)
}

///|
async fn initialize_test(session : Session) -> Unit {
  ignore(session.handle(request(1, "initialize", args={ "adapterID": "demo" })))
}

///|
async test "launch 配置响应有序，停止事件在响应之后" {
  let target = FakeTarget::new()
  target.start_stopped = true
  let session = Session::new(target)
  initialize_test(session)
  let initialized = session.handle(request(2, "launch"))
  assert_eq(initialized.length(), 1)
  let event : @protocol.Event = @json.from_json(initialized[0])
  assert_eq(event.event, "initialized")
  assert_eq(event.seq, 2)
  assert_eq(session.phase(), Configuring)
  let configured = session.handle(request(3, "configurationDone"))
  assert_eq(configured.length(), 3)
  let config : @protocol.Response = @json.from_json(configured[0])
  let launch : @protocol.Response = @json.from_json(configured[1])
  let stop : @protocol.Event = @json.from_json(configured[2])
  assert_eq((config.seq, config.request_seq), (3, 3))
  assert_eq((launch.seq, launch.request_seq), (4, 2))
  assert_eq((stop.seq, stop.event), (5, "stopped"))
  assert_eq(session.phase(), Stopped)
  ignore(session.handle(request(4, "disconnect")))
  assert_true(target.disconnected is Some(Terminate))
}

///|
async test "配置中断开会结算 attach 并分离目标" {
  let target = FakeTarget::new()
  let session = Session::new(target)
  initialize_test(session)
  ignore(session.handle(request(2, "attach")))
  let messages = session.handle(request(3, "disconnect"))
  let pending : @protocol.Response = @json.from_json(messages[0])
  let reply : @protocol.Response = @json.from_json(messages[1])
  assert_eq(pending.message, Some("cancelled"))
  assert_eq(pending.request_seq, 2)
  assert_eq(reply.request_seq, 3)
  assert_true(target.disconnected is Some(Detach))
  assert_eq(session.phase(), Closed)
}

///|
async test "断点替换和清除，兼容零基坐标" {
  let target = FakeTarget::new()
  let session = Session::new(target)
  ignore(
    session.handle(
      request(1, "initialize", args={
        "adapterID": "demo",
        "linesStartAt1": false,
      }),
    ),
  )
  ignore(session.handle(request(2, "launch")))
  let messages = session.handle(
    request(3, "setBreakpoints", args={
      "source": { "path": "demo" },
      "breakpoints": [{ "line": 0 }, { "line": 1, "condition": "x" }],
    }),
  )
  let reply : @protocol.SetBreakpointsResponse = @json.from_json(messages[0])
  assert_eq(reply.body.breakpoints[0].line, Some(0L))
  assert_false(reply.body.breakpoints[1].verified)
  assert_eq(target.breakpoints[0].line, 1L)
  ignore(
    session.handle(
      request(4, "setBreakpoints", args={
        "source": { "path": "demo" },
        "breakpoints": [],
      }),
    ),
  )
  assert_true(target.breakpoints.is_empty())
}

///|
async test "配置失败清理目标并结算两条请求" {
  let target = FakeTarget::new()
  let session = Session::new(target)
  initialize_test(session)
  target.fail_prepare = true
  let failed : @protocol.Response = @json.from_json(
    session.handle(request(2, "launch"))[0],
  )
  assert_false(failed.success)
  assert_true(target.disconnected is Some(Terminate))
  assert_eq(session.phase(), Ready)
  target.fail_prepare = false
  target.fail_start = true
  ignore(session.handle(request(3, "launch")))
  let messages = session.handle(request(4, "configurationDone"))
  assert_eq(messages.length(), 3)
  let cfg : @protocol.Response = @json.from_json(messages[0])
  let launch : @protocol.Response = @json.from_json(messages[1])
  assert_false(cfg.success)
  assert_false(launch.success)
  assert_eq(launch.request_seq, 3)
  assert_eq(session.phase(), Terminated)
}

///|
async test "暂停、恢复与终止事件" {
  let target = FakeTarget::new()
  let session = Session::new(target)
  initialize_test(session)
  ignore(session.handle(request(2, "launch")))
  ignore(session.handle(request(3, "configurationDone")))
  let pause = session.handle(request(4, "pause", args={ "threadId": 1 }))
  assert_eq(pause.length(), 2)
  assert_eq(session.phase(), Stopped)
  let resumed = session.handle(request(5, "next", args={ "threadId": 1 }))
  assert_eq(resumed.length(), 1)
  assert_eq(session.phase(), Running)
  target.emit(Output("stdout", "月"))
  target.emit(Exited(0))
  target.emit(Terminated)
  let events = session.poll()
  assert_eq(events.length(), 3)
  let exited : @protocol.Event = @json.from_json(events[1])
  let terminated : @protocol.Event = @json.from_json(events[2])
  assert_eq((exited.event, terminated.event), ("exited", "terminated"))
  assert_true(session.poll().is_empty())
}
