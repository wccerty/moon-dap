///|
fn[T : ToJson] emit(
  definition : String,
  source : String,
  decode : (Json) -> T raise @json.JsonDecodeError,
) -> Unit raise {
  let expected = @json.parse(source, preserve_number_repr=true)
  let actual = @json.to_json(decode(expected))
  assert_eq(actual, expected)
  let row : Json = { "definition": Json::string(definition), "message": actual }
  println(row.stringify())
}

///|
fn fixtures() -> Unit raise {
  emit(
    "InitializeRequest",
    (
      #|{"seq":1,"type":"request","command":"initialize","arguments":{"adapterID":"moon-dap","pathFormat":"path","linesStartAt1":false}}
    ),
    value => (@json.from_json(value) : @protocol.InitializeRequest),
  )
  emit(
    "InitializeResponse",
    (
      #|{"seq":1,"type":"response","command":"initialize","request_seq":1,"success":true,"body":{"supportsConfigurationDoneRequest":true}}
    ),
    value => (@json.from_json(value) : @protocol.InitializeResponse),
  )
  emit(
    "LaunchRequest",
    (
      #|{"seq":2,"type":"request","command":"launch","arguments":{"program":"月.moon","stopOnEntry":true,"__restart":null}}
    ),
    value => (@json.from_json(value) : @protocol.LaunchRequest),
  )
  emit(
    "InitializedEvent",
    (
      #|{"seq":2,"type":"event","event":"initialized"}
    ),
    value => (@json.from_json(value) : @protocol.InitializedEvent),
  )
  emit(
    "SetBreakpointsRequest",
    (
      #|{"seq":3,"type":"request","command":"setBreakpoints","arguments":{"source":{"path":"test.moon"},"breakpoints":[{"line":9007199254740991,"column":1}]}}
    ),
    value => (@json.from_json(value) : @protocol.SetBreakpointsRequest),
  )
  emit(
    "ErrorResponse",
    (
      #|{"seq":3,"type":"response","command":"scopes","request_seq":6,"success":false,"message":"notStopped","body":{"error":{"id":1,"format":"目标正在运行","showUser":true,"variables":{"name":"测试"}}}}
    ),
    value => (@json.from_json(value) : @protocol.ErrorResponse),
  )
  emit(
    "StoppedEvent",
    (
      #|{"seq":4,"type":"event","event":"stopped","body":{"reason":"vendor-extension","threadId":1,"allThreadsStopped":true}}
    ),
    value => (@json.from_json(value) : @protocol.StoppedEvent),
  )
  emit(
    "StackTraceResponse",
    (
      #|{"seq":5,"type":"response","command":"stackTrace","request_seq":7,"success":true,"body":{"stackFrames":[{"id":1,"name":"entry","line":1,"column":0,"moduleId":15}],"totalFrames":1}}
    ),
    value => (@json.from_json(value) : @protocol.StackTraceResponse),
  )
  emit(
    "VariablesRequest",
    (
      #|{"seq":8,"type":"request","command":"variables","arguments":{"variablesReference":3,"filter":"named","start":0,"count":4294967295}}
    ),
    value => (@json.from_json(value) : @protocol.VariablesRequest),
  )
  emit(
    "DataBreakpointInfoResponse",
    (
      #|{"seq":6,"type":"response","command":"dataBreakpointInfo","request_seq":9,"success":true,"body":{"dataId":null,"description":"无可用地址"}}
    ),
    value => (@json.from_json(value) : @protocol.DataBreakpointInfoResponse),
  )
  emit(
    "RunInTerminalRequest",
    (
      #|{"seq":7,"type":"request","command":"runInTerminal","arguments":{"cwd":".","args":["example"],"env":{"DELETE":null,"KEEP":"value"}}}
    ),
    value => (@json.from_json(value) : @protocol.RunInTerminalRequest),
  )
}

///|
fn main {
  fixtures() catch {
    error => abort(error.to_string())
  }
}
