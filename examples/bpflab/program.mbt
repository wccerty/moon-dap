///|
struct Program {
  path : String
  instructions : Array[@bpf.Insn]
  lines : Array[Int32]
}

///|
fn parse_program(path : String, source : String) -> Program raise {
  let instructions = []
  let lines = []
  let mut line = 0
  for raw in source.split("\n") {
    line += 1
    let text = raw.trim()
    if text.is_empty() || text.has_prefix("#") {
      continue
    }
    let fields : Array[Int32] = @json.from_json(@json.parse(text)) catch {
      _ => raise @session.TargetError("第 \{line} 行需要整数指令数组")
    }
    guard fields.length() == 5 else {
      raise @session.TargetError(
        "第 \{line} 行需要 opcode、dst、src、offset、imm",
      )
    }
    instructions.push(
      @bpf.insn(fields[0], fields[1], fields[2], fields[3], fields[4]),
    )
    lines.push(line)
  }
  guard !instructions.is_empty() else {
    raise @session.TargetError("程序没有指令")
  }
  { path, instructions, lines, }
}

///|
fn register_index(value : StringView) -> Int32 raise @session.TargetError {
  guard value.strip_prefix("r") is Some(suffix) else {
    raise @session.TargetError("寄存器应为 r0 到 r10")
  }
  let register = @string.parse_int(suffix) catch {
    _ => raise @session.TargetError("寄存器应为 r0 到 r10")
  }
  guard register >= 0 && register <= 10 && suffix == register.to_string() else {
    raise @session.TargetError("寄存器应为 r0 到 r10")
  }
  register
}

///|
fn condition(value : String) -> (Int32, UInt64) raise @session.TargetError {
  guard value.split_once("==") is Some((left, right)) else {
    raise @session.TargetError("条件格式为 rN == 无符号十进制整数")
  }
  let register = register_index(left.trim())
  let literal = right.trim()
  guard !literal.is_empty() && literal.iter().all(ch => ch >= '0' && ch <= '9') else {
    raise @session.TargetError("条件值应为无符号十进制整数")
  }
  let expected = @string.parse_uint64(literal, base=10) catch {
    _ => raise @session.TargetError("条件值超出 uint64 范围")
  }
  (register, expected)
}
