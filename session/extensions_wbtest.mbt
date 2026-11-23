///|
async fn configured_extension_session(
  target : FakeTarget,
  start~ : Bool = true,
  initialize~ : Json = { "adapterID": "extension" },
) -> Session {
  let session = Session::new(target)
  ignore(session.handle(request(1, "initialize", args=initialize)))
  ignore(session.handle(request(2, "launch")))
  if start {
    ignore(session.handle(request(3, "configurationDone")))
  }
  session
}

///|
async fn expect_failure(
  session : Session,
  seq : Int32,
  command : String,
  code : String,
  args? : Json,
) -> Unit {
  let response : @protocol.ErrorResponse = @json.from_json(
    session.handle(request(seq, command, args?))[0],
  )
  assert_false(response.success)
  assert_eq(response.command, command)
  assert_eq(response.request_seq, seq)
  assert_eq(response.message, Some(code))
}

///|
fn test_sources(entries : Array[VirtualSource]) -> SourceProvider {
  {
    list: () => entries,
    read: handle => {
      assert_eq(handle, 11) catch {
        _ => raise TargetError("收到错误的目标源码句柄")
      }
      { content: "rule main\n", mime_type: Some("text/plain"), }
    },
  }
}

///|
async test "动态源码引用可用于列举、读取、调用栈及源码断点" {
  let target = FakeTarget::new()
  target.start_stopped = true
  target.source_test_provider = Some(
    test_sources([
      { handle: 11, name: "demo.rule", path: Some("demo"), },
      { handle: 22, name: "readonly.rule", path: None, },
    ]),
  )
  let session = configured_extension_session(target)
  let list : @protocol.LoadedSourcesResponse = @json.from_json(
    session.handle(request(4, "loadedSources"))[0],
  )
  assert_eq(list.body.sources.length(), 2)
  let reference = list.body.sources[0].source_reference.unwrap()
  assert_true(reference > 0)
  let content : @protocol.SourceResponse = @json.from_json(
    session.handle(request(5, "source", args={ "sourceReference": reference }))[0],
  )
  assert_eq(content.body.content, "rule main\n")
  assert_eq(content.body.mime_type, Some("text/plain"))
  let frames : @protocol.StackTraceResponse = @json.from_json(
    session.handle(request(6, "stackTrace", args={ "threadId": 1 }))[0],
  )
  assert_eq(
    frames.body.stack_frames[0].source.unwrap().source_reference,
    Some(reference),
  )
  let bp : @protocol.SetBreakpointsResponse = @json.from_json(
    session.handle(
      request(7, "setBreakpoints", args={
        "source": { "sourceReference": reference },
        "breakpoints": [{ "line": 9 }],
      }),
    )[0],
  )
  assert_true(bp.body.breakpoints[0].verified)
  assert_eq(target.breakpoints[0].line, 9L)
  expect_failure(session, 8, "setBreakpoints", "invalidArguments", args={
    "source": {
      "sourceReference": list.body.sources[1].source_reference.unwrap(),
    },
    "breakpoints": [{ "line": 1 }],
  })
  expect_failure(session, 9, "source", "invalidArguments", args={
    "sourceReference": reference,
    "source": { "path": "wrong" },
  })
}

///|
async test "源码引用与暂停引用的生命周期不同" {
  let target = FakeTarget::new()
  target.start_stopped = true
  let entries : Array[VirtualSource] = [
    { handle: 11, name: "demo", path: Some("demo"), },
  ]
  target.source_test_provider = Some(test_sources(entries))
  let session = configured_extension_session(target)
  let list : @protocol.LoadedSourcesResponse = @json.from_json(
    session.handle(request(4, "loadedSources"))[0],
  )
  let reference = list.body.sources[0].source_reference.unwrap()
  ignore(session.handle(request(5, "continue", args={ "threadId": 1 })))
  let content : @protocol.SourceResponse = @json.from_json(
    session.handle(request(6, "source", args={ "sourceReference": reference }))[0],
  )
  assert_eq(content.body.content, "rule main\n")
  entries.clear()
  expect_failure(session, 7, "source", "invalidReference", args={
    "sourceReference": reference,
  })
  entries.push({ handle: 22, name: "replacement", path: Some("demo"), })
  let reloaded : @protocol.LoadedSourcesResponse = @json.from_json(
    session.handle(request(8, "loadedSources"))[0],
  )
  assert_true(reloaded.body.sources[0].source_reference.unwrap() > reference)
  expect_failure(session, 9, "source", "invalidReference", args={
    "sourceReference": reference,
  })
}

///|
async test "动态源码校验拒绝重复句柄、重复路径和空名称" {
  let first : VirtualSource = { handle: 11, name: "demo", path: Some("demo"), }
  let entries = [first]
  let target = FakeTarget::new()
  target.source_test_provider = Some(test_sources(entries))
  let session = configured_extension_session(target, start=false)
  for
    index, other in [
      { ..first, path: Some("two"), },
      { ..first, handle: 22, },
      { handle: 22, path: None, name: "", },
    ] {
    entries.push(other)
    expect_failure(session, 3 + index, "loadedSources", "targetError")
    ignore(entries.pop())
  }
  let response : @protocol.LoadedSourcesResponse = @json.from_json(
    session.handle(request(6, "loadedSources"))[0],
  )
  assert_eq(response.body.sources.length(), 1)
}

///|
async test "能力协商只声明目标实际提供的扩展" {
  let target = FakeTarget::new()
  target.source_test_provider = Some(test_sources([]))
  target.inspection_test_providers = {
    ..InspectionProviders::new(),
    assign_variable: Some(_ => raise TargetError("无效变量")),
    complete: Some(_ => []),
  }
  target.breakpoint_test_providers = {
    ..BreakpointProviders::new(),
    hit_conditions: true,
    log_points: true,
    replace_functions: Some(_ => []),
  }
  let session = Session::new(target)
  let response : @protocol.InitializeResponse = @json.from_json(
    session.handle(request(1, "initialize", args={ "adapterID": "test" }))[0],
  )
  let caps = response.body.unwrap()
  assert_eq(caps.supports_loaded_sources_request, Some(true))
  assert_eq(caps.supports_set_variable, Some(true))
  assert_eq(caps.supports_completions_request, Some(true))
  assert_eq(caps.supports_function_breakpoints, Some(true))
  assert_eq(caps.supports_hit_conditional_breakpoints, Some(true))
  assert_eq(caps.supports_log_points, None)
  assert_eq(caps.supports_set_expression, None)
  assert_eq(caps.supports_exception_info_request, None)
  expect_failure(session, 2, "setExpression", "notSupported")
  expect_failure(session, 3, "setVariable", "invalidState")
  expect_failure(session, 4, "loadedSources", "invalidState")
}

///|
async test "函数断点转换到客户端行列并保留混合请求顺序" {
  let point : BreakpointResult = {
    id: Some(34),
    verified: true,
    line: Some(9L),
    column: Some(1L),
    message: None,
  }
  let seen : Array[String] = []
  let target = FakeTarget::new()
  target.source_test_provider = Some(
    test_sources([{ handle: 11, name: "demo", path: Some("demo"), }]),
  )
  target.breakpoint_test_providers = {
    ..BreakpointProviders::new(),
    replace_functions: Some(points => {
      points.map(bp => {
        seen.push(bp.name)
        { breakpoint: point, source_path: Some("demo"), }
      })
    }),
  }
  let session = configured_extension_session(target, start=false, initialize={
    "adapterID": "demo",
    "linesStartAt1": false,
    "columnsStartAt1": false,
  })
  let response : @protocol.SetFunctionBreakpointsResponse = @json.from_json(
    session.handle(
      request(3, "setFunctionBreakpoints", args={
        "breakpoints": [
          { "name": "skip", "hitCondition": "2" },
          { "name": "match", "condition": "value > 0" },
        ],
      }),
    )[0],
  )
  assert_eq(seen, ["match"])
  assert_false(response.body.breakpoints[0].verified)
  let verified = response.body.breakpoints[1]
  assert_true(verified.verified)
  assert_eq(verified.id, Some(34))
  assert_eq(verified.line, Some(8L))
  assert_eq(verified.column, Some(0L))
  assert_true(verified.source.unwrap().source_reference.unwrap() > 0)
}

///|
async test "断点扩展错误不会返回部分成功结果" {
  let target = FakeTarget::new()
  target.breakpoint_test_providers = {
    ..BreakpointProviders::new(),
    replace_lines: Some((_, _) => []),
    replace_functions: Some(_ => []),
  }
  let session = configured_extension_session(target, start=false)
  expect_failure(session, 3, "setFunctionBreakpoints", "targetError", args={
    "breakpoints": [{ "name": "main" }],
  })
  expect_failure(session, 4, "setBreakpoints", "targetError", args={
    "source": { "path": "demo" },
    "breakpoints": [{ "line": 9 }],
  })
}

///|
async test "扩展求值和修改沿用暂停引用及客户端输出能力" {
  let target = FakeTarget::new()
  target.start_stopped = true
  let value : Variable = {
    name: "record",
    value: "{…}",
    type_name: Some("record"),
    children: Some(70),
    named_count: Some(1),
    indexed_count: None,
  }
  let frames : Array[Int32?] = []
  let containers : Array[Int32] = []
  target.inspection_test_providers = {
    ..InspectionProviders::new(),
    evaluate: Some(query => {
      frames.push(query.frame)
      value
    }),
    assign_variable: Some(query => {
      containers.push(query.container)
      { value, invalidated: [70], }
    }),
    assign_expression: Some(query => {
      frames.push(query.frame)
      { value, invalidated: [], }
    }),
  }
  let session = configured_extension_session(target, initialize={
    "adapterID": "demo",
    "supportsVariableType": true,
    "supportsVariablePaging": true,
  })
  let stack : @protocol.StackTraceResponse = @json.from_json(
    session.handle(request(4, "stackTrace", args={ "threadId": 1 }))[0],
  )
  let frame = stack.body.stack_frames[0].id
  let evaluation : @protocol.EvaluateResponse = @json.from_json(
    session.handle(
      request(5, "evaluate", args={ "expression": "record", "frameId": frame }),
    )[0],
  )
  assert_eq(evaluation.body.type_, Some("record"))
  assert_eq(evaluation.body.named_variables, Some(1))
  let container = evaluation.body.variables_reference
  let changed : @protocol.SetVariableResponse = @json.from_json(
    session.handle(
      request(6, "setVariable", args={
        "variablesReference": container,
        "name": "record",
        "value": "null",
      }),
    )[0],
  )
  let new_container = changed.body.variables_reference.unwrap()
  assert_true(new_container > container)
  assert_eq(containers, [70])
  let assigned : @protocol.SetExpressionResponse = @json.from_json(
    session.handle(
      request(7, "setExpression", args={
        "frameId": frame,
        "expression": "record",
        "value": "null",
      }),
    )[0],
  )
  assert_eq(assigned.body.variables_reference, Some(new_container))
  assert_eq(frames, [Some(70), Some(70)])
  ignore(session.handle(request(8, "continue", args={ "threadId": 1 })))
  ignore(session.handle(request(9, "pause", args={ "threadId": 1 })))
  expect_failure(session, 10, "setVariable", "invalidReference", args={
    "variablesReference": new_container,
    "name": "record",
    "value": "null",
  })
  expect_failure(session, 11, "setExpression", "invalidReference", args={
    "frameId": frame,
    "expression": "record",
    "value": "null",
  })
}

///|
async test "补全输入坐标转换和替换区间遵循不同基数" {
  let target = FakeTarget::new()
  target.start_stopped = true
  let requests : Array[CompletionQuery] = []
  target.inspection_test_providers = {
    ..InspectionProviders::new(),
    complete: Some(query => {
      requests.push(query)
      [
        {
          label: "account",
          replacement: None,
          detail: None,
          start: Some(0L),
          length: Some(3L),
        },
      ]
    }),
  }
  let session = configured_extension_session(target, initialize={
    "adapterID": "demo",
    "linesStartAt1": false,
    "columnsStartAt1": false,
  })
  let response : @protocol.CompletionsResponse = @json.from_json(
    session.handle(
      request(4, "completions", args={ "text": "acc", "line": 0, "column": 3 }),
    )[0],
  )
  assert_eq(requests[0].line, 1L)
  assert_eq(requests[0].column, 4L)
  assert_eq(requests[0].frame, None)
  assert_eq(response.body.targets[0].label, "account")
  assert_eq(response.body.targets[0].start, Some(0L))
  assert_eq(response.body.targets[0].length, Some(3L))
}
