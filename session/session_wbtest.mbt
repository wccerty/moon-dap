///|
fn request(seq : Int32, command : String, args? : Json) -> Json {
  let req : @protocol.Request = { seq, command, arguments: args, }
  req.to_json()
}

///|
async test "未初始化的 launch 有结构化失败响应" {
  let session = Session::new(FakeTarget::new())
  let result = session.handle(request(1, "launch"))
  let response : @protocol.ErrorResponse = @json.from_json(result[0])
  assert_false(response.success)
  assert_eq(response.request_seq, 1)
  assert_eq(response.command, "launch")
  assert_eq(response.message, Some("invalidState"))
  assert_eq(session.phase(), New)
}

///|
async test "握手协商与重复初始化" {
  let session = Session::new(FakeTarget::new())
  let result = session.handle(
    request(7, "initialize", args={
      "adapterID": "demo",
      "linesStartAt1": false,
      "columnsStartAt1": false,
    }),
  )
  let reply : @protocol.InitializeResponse = @json.from_json(result[0])
  assert_true(reply.success)
  assert_eq(reply.seq, 1)
  assert_eq(reply.request_seq, 7)
  assert_true(
    reply.body is Some(body) &&
    body.supports_configuration_done_request is Some(true) &&
    body.supports_breakpoint_locations_request is None,
  )
  assert_eq(session.coordinates(), (false, false))
  assert_eq(session.phase(), Ready)
  let second : @protocol.Response = @json.from_json(
    session.handle(request(8, "initialize"))[0],
  )
  assert_eq(second.seq, 2)
  assert_eq(second.message, Some("invalidState"))
}

///|
async test "参数无效与未知请求" {
  let session = Session::new(FakeTarget::new())
  let bad : @protocol.Response = @json.from_json(
    session.handle(request(1, "initialize"))[0],
  )
  assert_eq(bad.message, Some("invalidArguments"))
  ignore(session.handle(request(2, "initialize", args={ "adapterID": "demo" })))
  let unknown : @protocol.Response = @json.from_json(
    session.handle(request(3, "customRequest"))[0],
  )
  assert_eq(unknown.request_seq, 3)
  assert_eq(unknown.message, Some("notSupported"))
  let unsupported : @protocol.Response = @json.from_json(
    session.handle(
      request(4, "breakpointLocations", args={
        "source": { "path": "demo" },
        "line": 1,
      }),
    )[0],
  )
  assert_eq(unsupported.message, Some("notSupported"))
  ignore(session.handle(request(5, "disconnect")))
  assert_eq(session.phase(), Closed)
}
