///|
fn evaluate_text(
  text : String,
  locals~ : Map[String, Json] = Map([]),
) -> Json raise ExpressionError {
  Expression::parse(text).evaluate(name => locals.get(name))
}

///|
fn invalid_syntax(text : String, offset : Int32) -> Unit raise {
  let result : Result[Expression, ExpressionError] = Ok(Expression::parse(text)) catch {
    error => Err(error)
  }
  guard result is Err(InvalidSyntax(actual, _)) else {
    fail("预期存在语法错误：" + text)
  }
  assert_eq(actual, offset)
}

///|
fn invalid_value(
  text : String,
  detail : String,
  locals~ : Map[String, Json] = Map([]),
) -> Unit raise {
  let result : Result[Json, ExpressionError] = Ok(evaluate_text(text, locals~)) catch {
    error => Err(error)
  }
  guard result is Err(InvalidValue(actual)) else {
    fail("预期存在求值错误：" + text)
  }
  assert_eq(actual, detail)
}

///|
test "表达式按优先级和左结合顺序计算" {
  let cases : Array[(String, Json)] = [
    ("2 + 3 * 4", 14),
    ("(2 + 3) * 4", 20),
    ("20 / 2 / 2", 5),
    ("10 - 3 - 2", 5),
    ("2 * -3 + 8", 2),
  ]
  for (source, value) in cases {
    assert_eq(evaluate_text(source), value)
  }
  invalid_syntax("-1 + +2", 5)
}

///|
test "比较运算支持相等、数字顺序和字符串顺序" {
  assert_eq(evaluate_text("1 == 1.0"), Json::boolean(true))
  assert_eq(evaluate_text("null != false"), Json::boolean(true))
  assert_eq(evaluate_text("3 < 5 && 5 <= 5 && 6 > 5"), Json::boolean(true))
  assert_eq(evaluate_text("\"青\" >= \"蓝\""), Json::boolean(true))
  invalid_value("1 < \"1\"", "需要有限数字")
}

///|
test "布尔短路不读取缺失变量且保留类型约束" {
  assert_eq(evaluate_text("false && missing"), Json::boolean(false))
  assert_eq(evaluate_text("true || missing"), Json::boolean(true))
  assert_eq(evaluate_text("!false && true || false"), Json::boolean(true))
  invalid_value("true && missing", "找不到变量 missing")
  invalid_value("true && 2", "需要布尔值")
  invalid_value("!null", "需要布尔值")
}

///|
test "十进制、指数与 Unicode 标识符可一起求值" {
  let variables : Map[String, Json] = { "客户2": { "数值": 8 } }
  assert_eq(
    evaluate_text("客户2.数值 - 1.5e+0 - 3E-1", locals=variables),
    Json::number(6.2),
  )
  assert_eq(
    evaluate_text("\"甲\\\"\" + \"乙\\n\""),
    Json::string("甲\"乙\n"),
  )
  assert_true(is_identifier("客户_2"))
  assert_true(is_identifier("_rules"))
  assert_false(is_identifier("9rules"))
  assert_false(is_identifier("foo-bar"))
  assert_false(is_identifier("true"))
  assert_false(is_identifier(""))
}

///|
test "字段、字符串键与表达式下标按值类型读取" {
  let variables : Map[String, Json] = {
    "record": { "limits": [4, 9], "带 空格": true, "null": 3 },
    "idx": 0,
  }
  assert_eq(
    evaluate_text("record.limits[idx + 1]", locals=variables),
    @json.to_json(9),
  )
  assert_eq(
    evaluate_text("record[\"带 空格\"]", locals=variables),
    Json::boolean(true),
  )
  assert_eq(
    evaluate_text("record[\"null\"]", locals=variables),
    @json.to_json(3),
  )
  invalid_value(
    "record.limits[-1]",
    "下标需要非负整数或对象字段名",
    locals=variables,
  )
  invalid_value("record.limits[100]", "数组下标越界", locals=variables)
  invalid_value(
    "record.missing",
    "对象没有字段 missing",
    locals=variables,
  )
  invalid_value("record[1]", "下标与值的类型不匹配", locals=variables)
  invalid_value(
    "record.limits[1.5]",
    "下标需要非负整数或对象字段名",
    locals=variables,
  )
}

///|
test "畸形符号和闭括号错误包含精确列号" {
  invalid_syntax("a = b", 2)
  invalid_syntax("a & b", 2)
  invalid_syntax("list[1", 6)
  invalid_syntax("(ok", 3)
  invalid_syntax("row.", 4)
  invalid_syntax("\"未结束", 0)
  invalid_syntax("00", 0)
  invalid_syntax("1e+", 0)
  invalid_syntax("1 2", 2)
  invalid_syntax("bad!", 3)
}

///|
test "计算拒绝除零和无穷结果" {
  invalid_value("10 / (2 - 2)", "除数不能为零")
  invalid_value("1e200 * 1e200", "计算结果超出有限数字范围")
  invalid_syntax("1e999", 0)
  invalid_value("\"a\" + 1", "需要有限数字")
}

///|
test "计算属性用固定组合覆盖负数、零和正数" {
  for a in -4..<=4 {
    for b in -4..<=4 {
      let source = "\{a} * (\{b} + 1) - \{b}"
      assert_eq(evaluate_text(source), @json.to_json(a * (b + 1) - b))
    }
  }
}

///|
test "可写路径替换只修改选中的数组元素和对象字段" {
  let original : Json = { "items": [{ "score": 2, "id": "甲" }], "flag": true }
  let locals = Map([("record", original), ("idx", @json.to_json(0))])
  let expression = Expression::parse("record.items[idx].score")
  let (root, path) = expression.selection(name => locals.get(name))
  assert_eq(root, "record")
  assert_eq(path.length(), 3)
  let updated = replace(original, path, @json.to_json(7))
  assert_eq(updated, { "items": [{ "score": 7, "id": "甲" }], "flag": true })
  assert_eq(original, { "items": [{ "score": 2, "id": "甲" }], "flag": true })
  assert_eq(
    expression.evaluate(name => {
      if name == "record" {
        Some(updated)
      } else {
        locals.get(name)
      }
    }),
    @json.to_json(7),
  )
}

///|
test "原子替换在下标越界、字段不存在和不可写表达式时拒绝" {
  let existing : Json = { "items": [0] }
  for
    path in [
      [Selector::Field("items"), Index(1)],
      [Selector::Field("new")],
      [Selector::Field("items"), Field("bad")],
    ] {
    let result : Result[Json, ExpressionError] = Ok(
      replace(existing, path, Json::null()),
    ) catch {
      error => Err(error)
    }
    assert_true(result is Err(InvalidValue(_)))
    assert_eq(existing, { "items": [0] })
  }
  let result : Result[(String, Array[Selector]), ExpressionError] = Ok(
    Expression::parse("x + 1").selection(_ => None),
  ) catch {
    error => Err(error)
  }
  assert_true(result is Err(InvalidValue(_)))
}

///|
test "表达式长度、节点数和嵌套深度有独立限制" {
  let many = StringBuilder()
  for _ in 0..<300 {
    many.write_string("1+")
  }
  many.write_char('1')
  let nested = StringBuilder()
  for _ in 0..<70 {
    nested.write_char('(')
  }
  nested.write_char('1')
  for _ in 0..<70 {
    nested.write_char(')')
  }
  let long = StringBuilder()
  for _ in 0..<8193 {
    long.write_char(' ')
  }
  for input in [many.to_string(), nested.to_string(), long.to_string()] {
    let result : Result[Expression, ExpressionError] = Ok(
      Expression::parse(input),
    ) catch {
      error => Err(error)
    }
    assert_true(result is Err(InvalidSyntax(_, _)))
  }
}
