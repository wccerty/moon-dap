///|
test "编解码拒绝缺少字段与错误请求标签" {
  let missing : Result[InitializeRequest, @json.JsonDecodeError] = Ok(
    @json.from_json({ "seq": 1, "type": "request", "command": "initialize" }),
  ) catch {
    error => Err(error)
  }
  let wrong_tag : Result[InitializeRequest, @json.JsonDecodeError] = Ok(
    @json.from_json({
      "seq": 1,
      "type": "request",
      "command": "launch",
      "arguments": { "adapterID": "test" },
    }),
  ) catch {
    error => Err(error)
  }
  assert_true(missing is Err(_))
  assert_true(wrong_tag is Err(_))
}

///|
test "编解码拒绝小数序号和越界整数" {
  for seq in [0.0, 1.5, 2147483648.0] {
    let input : Json = {
      "seq": Json::number(seq),
      "type": "request",
      "command": "threads",
    }
    let decoded : Result[Request, @json.JsonDecodeError] = Ok(
      @json.from_json(input),
    ) catch {
      error => Err(error)
    }
    assert_true(decoded is Err(_))
  }
  let out_of_range : Result[VariablesArguments, @json.JsonDecodeError] = Ok(
    @json.from_json({ "variablesReference": 1, "count": 4294967296.0 }),
  ) catch {
    error => Err(error)
  }
  assert_true(out_of_range is Err(_))
}

///|
test "可选值省略与允许显式 null 的字段区分" {
  let args : LaunchRequestArguments = @json.from_json({
    "__restart": null,
    "program": "demo",
  })
  assert_true(args.no_debug is None)
  assert_true(args.private_restart is Some(Null))
  assert_eq(args.to_json(), { "__restart": null, "program": "demo" })
  let invalid_bool : Result[LaunchRequestArguments, @json.JsonDecodeError] = Ok(
    @json.from_json({ "noDebug": null }),
  ) catch {
    error => Err(error)
  }
  assert_true(invalid_bool is Err(_))
}

///|
test "封闭枚举拒绝未知值，开放枚举保留扩展值" {
  let invalid_filter : Result[VariablesArguments, @json.JsonDecodeError] = Ok(
    @json.from_json({ "variablesReference": 1, "filter": "vendor" }),
  ) catch {
    error => Err(error)
  }
  assert_true(invalid_filter is Err(_))
  let stopped : StoppedEventBody = @json.from_json({ "reason": "vendor" })
  assert_eq(stopped.reason, "vendor")
}

///|
test "oneOf 拒绝歧义分支" {
  let ambiguous : Result[RestartArguments, @json.JsonDecodeError] = Ok(
    @json.from_json({ "arguments": { "program": "demo" } }),
  ) catch {
    error => Err(error)
  }
  assert_true(ambiguous is Err(_))
}
