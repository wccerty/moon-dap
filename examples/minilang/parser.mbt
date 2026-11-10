///|
priv enum Statement {
  Set(String, Json)
  Print(String)
  Call(String)
  Return
  Wait(Int32)
}

///|
priv struct Instruction {
  line : Int64
  statement : Statement
}

///|
priv struct Program {
  path : String
  functions : Map[String, Array[Instruction]]
  lines : Map[Int64, Int32]
}

///|
fn split_word(source : StringView) -> (String, StringView) {
  match source.trim().split_once(" ") {
    Some((word, rest)) => (word.to_owned(), rest.trim())
    None => (source.trim().to_owned(), "")
  }
}

///|
fn whole_number(text : StringView, max : Int32) -> Int32 raise {
  let raw = @json.parse(text)
  guard raw is Number(value, ..) &&
    value >= 0.0 &&
    value <= max.to_double() &&
    value == value.trunc() else {
    raise @session.TargetError("需要范围内的非负整数")
  }
  value.to_int()
}

///|
fn statement(op : String, rest : StringView) -> Statement raise {
  match op {
    "set" => {
      let (name, value) = split_word(rest)
      guard !name.is_empty() && !value.is_empty() else {
        raise @session.TargetError("set 需要变量名和 JSON 值")
      }
      Set(
        name,
        @json.parse(
          value,
          reject_duplicate_keys=true,
          preserve_number_repr=true,
        ),
      )
    }
    "print" if !rest.is_empty() => Print(rest.to_owned())
    "call" if !rest.is_empty() => Call(rest.to_owned())
    "return" if rest.is_empty() => Return
    "wait" => Wait(whole_number(rest, 100000))
    _ => raise @session.TargetError("无效语句 \{op}")
  }
}

///|
fn Program::parse(path : String, text : String) -> Program raise {
  let functions : Map[String, Array[Instruction]] = Map([])
  let lines = Map([])
  let mut current : Array[Instruction]? = None
  let mut number = 0
  for raw in text.split("\n") {
    number += 1
    let line = raw.trim()
    if line.is_empty() || line.has_prefix("#") {
      continue
    }
    let (op, rest) = split_word(line)
    if op == "fn" {
      let name = rest.to_owned()
      guard current is None && !name.is_empty() && !functions.contains(name) else {
        raise @session.TargetError("第 \{number} 行的函数定义无效")
      }
      let body = []
      functions.set(name, body)
      current = Some(body)
    } else if op == "end" {
      guard current is Some(_) && rest.is_empty() else {
        raise @session.TargetError("第 \{number} 行的 end 无效")
      }
      current = None
    } else {
      guard current is Some(body) else {
        raise @session.TargetError("第 \{number} 行应在函数内")
      }
      let item = statement(op, rest) catch {
        error =>
          raise @session.TargetError("第 \{number} 行：" + error.to_string())
      }
      let line = number.to_int64()
      lines.set(line, number)
      body.push({ line, statement: item, })
    }
  }
  guard current is None && functions.contains("main") else {
    raise @session.TargetError("程序需要完整的 fn main / end")
  }
  for _, body in functions {
    for item in body {
      if item.statement is Call(name) && !functions.contains(name) {
        raise @session.TargetError(
          "第 \{item.line} 行调用了未定义的函数 \{name}",
        )
      }
    }
  }
  { path, functions, lines, }
}
