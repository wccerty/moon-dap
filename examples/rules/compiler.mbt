///|
#derive(FromJson)
priv struct BundleSource {
  name : String
  text : String
}

///|
#derive(FromJson)
priv struct Bundle {
  entry : String
  sources : Array[BundleSource]
  input : Json
}

///|
priv struct RuleSource {
  handle : Int32
  name : String
  path : String
  text : String
}

///|
priv enum Operation {
  Bind(String, @expression.Expression)
  Load(String, Json)
  Call(String, String, @expression.Expression)
  Return(@expression.Expression)
  Emit(@expression.Expression)
  Jump(String)
  Branch(@expression.Expression, String)
  Assert(@expression.Expression)
}

///|
priv struct Instruction {
  line : Int64
  operation : Operation
}

///|
priv struct Rule {
  name : String
  parameter : String
  source : RuleSource
  code : Array[Instruction]
  labels : Map[String, Int32]
}

///|
priv struct Program {
  entry : Rule
  input : Json
  sources : Array[RuleSource]
  rules : Map[String, Rule]
  line_index : Map[String, Array[Int64]]
}

///|
fn words(text : StringView) -> (String, StringView) {
  let text = text.trim()
  for index in 0..<text.length() {
    if text.code_unit_at(index) == 32 || text.code_unit_at(index) == 9 {
      return (text[:index].to_owned(), text[index:].trim())
    }
  }
  (text.to_owned(), "")
}

///|
fn identifier(text : StringView) -> String raise @session.TargetError {
  let name = text.trim().to_owned()
  guard @expression.is_identifier(name) else {
    raise @session.TargetError("需要有效的标识符")
  }
  name
}

///|
fn parse_expression(
  text : StringView,
) -> @expression.Expression raise @session.TargetError {
  @expression.Expression::parse(text.to_owned()) catch {
    error => raise @session.TargetError(error.message())
  }
}

///|
fn binding(
  rest : StringView,
) -> (String, StringView) raise @session.TargetError {
  guard rest.split_once("=") is Some((left, right)) && !right.trim().is_empty() else {
    raise @session.TargetError("绑定语句需要名称 = 值")
  }
  (identifier(left), right.trim())
}

///|
fn parse_operation(word : String, rest : StringView) -> Operation raise {
  match word {
    "let" => {
      let (name, expression) = binding(rest)
      Bind(name, parse_expression(expression))
    }
    "json" => {
      let (name, text) = binding(rest)
      Load(
        name,
        @json.parse(text, reject_duplicate_keys=true, preserve_number_repr=true),
      )
    }
    "call" => {
      let (dest, rhs) = binding(rest)
      let (name, argument) = words(rhs)
      Call(dest, identifier(name[:]), parse_expression(argument))
    }
    "return" => Return(parse_expression(rest))
    "emit" => Emit(parse_expression(rest))
    "goto" => Jump(identifier(rest))
    "when" => {
      let (label, expression) = words(rest)
      Branch(parse_expression(expression), identifier(label[:]))
    }
    "assert" => Assert(parse_expression(rest))
    _ => raise @session.TargetError("未知指令 \{word}")
  }
}

///|
fn fail_at(
  source : RuleSource,
  line : Int64,
  detail : String,
) -> Unit raise @session.TargetError {
  raise @session.TargetError("\{source.name}:\{line} \{detail}")
}

///|
fn parse_source(
  source : RuleSource,
  rules : Map[String, Rule],
) -> Array[Int64] raise {
  let lines = []
  let mut current : Rule? = None
  let mut line = 0L
  for raw in source.text.split("\n") {
    line += 1L
    let text = raw.trim()
    if text.is_empty() || text.has_prefix("#") {
      continue
    }
    let (word, rest) = words(text)
    try {
      if word == "rule" {
        let (name, parameter) = words(rest)
        guard current is None &&
          @expression.is_identifier(name) &&
          !rules.contains(name) else {
          raise @session.TargetError("规则名重复或规则定义无效")
        }
        current = Some({
          name,
          parameter: identifier(parameter),
          source,
          code: [],
          labels: Map([]),
        })
      } else {
        guard current is Some(rule) else {
          raise @session.TargetError("指令应在 rule / end 内")
        }
        match word {
          "end" => {
            guard rest.is_empty() && !rule.code.is_empty() else {
              raise @session.TargetError("空规则或无效的 end")
            }
            rules.set(rule.name, rule)
            current = None
          }
          "label" => {
            let name = identifier(rest)
            guard !rule.labels.contains(name) else {
              raise @session.TargetError("标签重复")
            }
            rule.labels.set(name, rule.code.length())
          }
          _ => {
            let operation = parse_operation(word, rest)
            rule.code.push({ line, operation, })
            lines.push(line)
          }
        }
      }
    } catch {
      @session.TargetError(detail) => fail_at(source, line, detail)
      error => fail_at(source, line, error.to_string())
    }
  }
  guard current is None else {
    raise @session.TargetError("\{source.name} 中的规则缺少 end")
  }
  lines
}

///|
fn validate_rules(rules : Map[String, Rule]) -> Unit raise @session.TargetError {
  for _, rule in rules {
    for instruction in rule.code {
      match instruction.operation {
        Call(_, name, _) if !rules.contains(name) =>
          fail_at(
            rule.source,
            instruction.line,
            "调用目标规则不存在 \{name}",
          )
        Jump(label) | Branch(_, label) => {
          guard rule.labels.get(label) is Some(pc) && pc < rule.code.length() else {
            fail_at(
              rule.source,
              instruction.line,
              "标签未指向有效指令 \{label}",
            )
          }
        }
        _ => ()
      }
    }
  }
}

///|
fn Program::parse(document : Json) -> Program raise {
  let bundle : Bundle = @json.from_json(document)
  guard !bundle.sources.is_empty() && bundle.sources.length() <= 32 else {
    raise @session.TargetError("规则包需要 1 至 32 份源码")
  }
  let sources = []
  let line_index = Map([])
  let names = Map([])
  let rules = Map([])
  let mut total = 0
  for index, file in bundle.sources {
    guard @expression.is_identifier(file.name) && !names.contains(file.name) else {
      raise @session.TargetError("源码名称无效或重复 \{file.name}")
    }
    guard file.text.length() <= 524288 - total else {
      raise @session.TargetError("规则包源码超出大小限制")
    }
    total += file.text.length()
    let source : RuleSource = {
      handle: index + 1,
      name: file.name + ".rule",
      path: "memory/rules/" + file.name + ".rule",
      text: file.text,
    }
    names.set(file.name, true)
    let executable = parse_source(source, rules)
    line_index.set(source.path, executable)
    sources.push(source)
  }
  validate_rules(rules)
  guard rules.get(bundle.entry) is Some(entry) else {
    raise @session.TargetError("入口规则不存在 \{bundle.entry}")
  }
  { entry, input: bundle.input, sources, rules, line_index, }
}
