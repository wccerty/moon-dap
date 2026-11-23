///|
fn bundle(
  main : String,
  helpers? : String,
  input~ : Json = Json::null(),
) -> Json {
  let sources : Array[Json] = [{ "name": "main", "text": main }]
  if helpers is Some(text) {
    sources.push({ "name": "helpers", "text": text })
  }
  { "entry": "main", "input": input, "sources": Json::array(sources) }
}

///|
fn compile_failure(document : Json, message : String) -> Unit raise {
  let parsed : Result[Program, Error] = Ok(Program::parse(document)) catch {
    error => Err(error)
  }
  guard parsed is Err(fault) else { fail("规则包应拒绝输入") }
  let detail = match fault {
    @session.TargetError(detail) => detail
    _ => fault.to_string()
  }
  assert_true(detail.contains(message), msg=detail)
}

///|
test "链接两个内存源码并保留可执行行" {
  let program = Program::parse(
    bundle(
      "# header\nrule main input\n\tcall total = price input\nreturn total\nend\n",
      helpers="rule price value\r\n# comment\r\nreturn value + 2\r\nend\r\n",
      input=@json.to_json(3),
    ),
  )
  assert_eq(program.sources.length(), 2)
  assert_eq(program.sources[0].path, "memory/rules/main.rule")
  assert_eq(program.sources[1].handle, 2)
  assert_eq(program.line_index.get(program.sources[0].path), Some([3L, 4L]))
  assert_eq(program.line_index.get(program.sources[1].path), Some([3L]))
  assert_eq(program.entry.parameter, "input")
  assert_eq(program.entry.code.length(), 2)
  assert_true(program.rules.contains("price"))
}

///|
test "编译器区分空规则、未闭合、重复定义和缺失入口" {
  for
    (source, reason) in [
      ("rule main arg\nend\n", "空规则"),
      ("rule main arg\nreturn arg", "缺少 end"),
      (
        "rule main arg\nreturn arg\nend\nrule main arg\nreturn arg\nend", "重复",
      ),
      ("return 1", "应在 rule / end 内"),
      ("rule other arg\nreturn arg\nend", "入口规则不存在"),
      ("rule main true\nreturn true\nend", "有效的标识符"),
      ("rule main arg\nnoop\nend", "未知指令"),
    ] {
    compile_failure(bundle(source), reason)
  }
}

///|
test "编译器报告跨文件链接错误和精确行号" {
  compile_failure(
    bundle("rule main arg\ncall result = missing arg\nreturn result\nend"),
    "main.rule:2",
  )
  compile_failure(
    bundle(
      "rule main arg\ncall result = helper arg\nreturn result\nend",
      helpers="rule helper arg\ngoto missing\nreturn arg\nend",
    ),
    "helpers.rule:2",
  )
  compile_failure(
    bundle("rule main arg\ngoto finish\nlabel finish\nend"),
    "未指向有效指令",
  )
  compile_failure(
    bundle("rule main arg\nlabel fresh\nlabel fresh\nreturn arg\nend"),
    "标签重复",
  )
}

///|
test "编译器校验规则包结构和资源上限" {
  compile_failure({ "entry": "main", "sources": [], "input": null }, "1 至 32")
  compile_failure(
    {
      "entry": "main",
      "sources": [
        { "name": "a", "text": "rule main arg\nreturn arg\nend" },
        { "name": "a", "text": "rule other arg\nreturn arg\nend" },
      ],
      "input": null,
    },
    "名称无效或重复",
  )
  compile_failure(
    {
      "entry": "main",
      "sources": [{ "name": "../outside", "text": "" }],
      "input": null,
    },
    "名称无效",
  )
  let huge = StringBuilder()
  for _ in 0..<524289 {
    huge.write_char(' ')
  }
  compile_failure(bundle(huge.to_string()), "大小限制")
}

///|
test "规则运行时隔离局部变量并将被调用规则的值返回给调用方" {
  let runtime = Runtime::new(
    Program::parse(
      bundle(
        "rule main arg\nlet local = 4\ncall result = price arg\nemit result\nreturn result + local\nend",
        helpers="rule price in_value\nlet local = 20\nreturn in_value.amount + local\nend",
        input={ "amount": 3 },
      ),
    ),
  )
  assert_true(runtime.execute() is Advanced)
  assert_true(runtime.execute() is Advanced)
  let callee = runtime.frame(None)
  let caller = runtime.frame(Some(1))
  assert_eq(callee.rule.name, "price")
  assert_eq(callee.position(false).map(loc => loc.line), Some(2L))
  assert_eq(caller.position(true).map(loc => loc.line), Some(3L))
  assert_true(runtime.execute() is Advanced)
  assert_eq(callee.locals.get("local"), Some(@json.to_json(20)))
  assert_eq(caller.locals.get("local"), Some(@json.to_json(4)))
  assert_true(runtime.execute() is Advanced)
  assert_eq(runtime.stack.length(), 1)
  assert_eq(caller.locals.get("result"), Some(@json.to_json(23)))
  assert_true(runtime.execute() is Printed("23"))
  guard runtime.execute() is Finished(value) else { fail("应结束规则") }
  assert_eq(value, @json.to_json(27))
  assert_true(runtime.stack.is_empty())
}

///|
test "条件跳转与循环在一个执行片中只推进一条指令" {
  let source =
    #|rule main input
    #|let count = input
    #|label loop
    #|let count = count + 1
    #|when done count >= 3
    #|goto loop
    #|label done
    #|return count
    #|end
  let runtime = Runtime::new(
    Program::parse(bundle(source, input=@json.to_json(0))),
  )
  let top = runtime.frame(None)
  let executed_lines = []
  while top.position(false) is Some(position) {
    executed_lines.push(position.line)
    match runtime.execute() {
      Advanced => ()
      Finished(value) => {
        assert_eq(value, @json.to_json(3))
        break
      }
      _ => fail("计数规则不应输出")
    }
  }
  assert_eq(executed_lines, [2L, 4L, 5L, 6L, 4L, 5L, 6L, 4L, 5L, 8L])
  assert_eq(runtime.instructions, 10)
}

///|
test "没有显式返回的规则可隐式返回 null" {
  let runtime = Runtime::new(
    Program::parse(
      bundle(
        "rule main x\ncall result = helper x\nreturn result\nend",
        helpers="rule helper x\nlet x = 2\nend",
      ),
    ),
  )
  assert_true(runtime.execute() is Advanced)
  assert_true(runtime.execute() is Advanced)
  assert_true(runtime.execute() is Advanced)
  assert_true(runtime.execute() is Finished(Null))
}

///|
test "断言失败保留调用栈和错误位置供调试" {
  let runtime = Runtime::new(
    Program::parse(
      bundle(
        "rule main x\ncall result = check x\nreturn result\nend",
        helpers="rule check x\nassert x > 10\nreturn 1\nend",
        input=@json.to_json(3),
      ),
    ),
  )
  assert_true(runtime.execute() is Advanced)
  let failure : Result[Execution, @session.TargetError] = Ok(runtime.execute()) catch {
    error => Err(error)
  }
  assert_true(failure is Err(@session.TargetError("规则断言失败")))
  assert_eq(runtime.stack.length(), 2)
  assert_eq(runtime.frame(None).position(false).map(loc => loc.line), Some(2L))
}

///|
test "深递归和无限循环达到预算后返回目标错误" {
  let recursive = Runtime::new(
    Program::parse(
      bundle("rule main x\ncall result = main x\nreturn result\nend"),
    ),
  )
  for _ in 1..<128 {
    assert_true(recursive.execute() is Advanced)
  }
  let depth : Result[Execution, @session.TargetError] = Ok(recursive.execute()) catch {
    error => Err(error)
  }
  assert_true(
    depth is Err(@session.TargetError("规则调用深度超出限制")),
  )
  assert_eq(recursive.stack.length(), 128)

  let repeated = Runtime::new(
    Program::parse(bundle("rule main x\nlabel forever\ngoto forever\nend")),
  )
  for _ in 0..<100000 {
    ignore(repeated.execute())
  }
  let budget : Result[Execution, @session.TargetError] = Ok(repeated.execute()) catch {
    error => Err(error)
  }
  assert_true(
    budget is Err(@session.TargetError("规则执行步数超出限制")),
  )
}

///|
test "命中次数语法不同，计数条件边界明确" {
  let exact = HitCondition::parse(" ==2 ")
  assert_false(exact.matches(1L))
  assert_true(exact.matches(2L))
  assert_false(exact.matches(3L))
  let threshold = HitCondition::parse(">= 2")
  assert_false(threshold.matches(1L))
  assert_true(threshold.matches(2L))
  assert_true(threshold.matches(3L))
  let recurring = HitCondition::parse("%3")
  assert_false(recurring.matches(1L))
  assert_true(recurring.matches(3L))
  assert_false(recurring.matches(5L))
  assert_true(recurring.matches(6L))
  for text in ["0", ">=-1", "%", "text", "999999999999999999999"] {
    let bad : Result[HitCondition, @session.TargetError] = Ok(
      HitCondition::parse(text),
    ) catch {
      error => Err(error)
    }
    assert_true(bad is Err(_))
  }
}

///|
test "日志断点模板插值、转义花括号和不完整表达式" {
  let runtime = Runtime::new(
    Program::parse(
      bundle("rule main input\nreturn input\nend", input={ "value": 7 }),
    ),
  )
  let frame = runtime.frame(None)
  assert_eq(
    render_log(parse_log("{{rule: {input.value + 1}"), frame),
    "{rule: 8",
  )
  for text in ["missing {input", "{input.value +}", "{}"] {
    let invalid : Result[Array[LogPart], @session.TargetError] = Ok(
      parse_log(text),
    ) catch {
      error => Err(error)
    }
    assert_true(invalid is Err(_))
  }
}
