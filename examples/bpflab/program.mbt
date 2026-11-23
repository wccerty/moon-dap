///|
struct Program {
  instructions : Array[@bpf.Insn]
  locations : Map[Int32, SourceEntry]
}

///|
#derive(FromJson)
struct SourceEntry {
  pc : Int32
  path : String
  line : Int32
  name : String
}

///|
fn source_key(path : String) -> String {
  if @env.get_env_var("OS") == Some("Windows_NT") {
    path.replace_all(old="\\", new="/").to_lower()
  } else {
    path
  }
}

///|
fn parse_program(path : String, source : String) -> Program raise {
  let instructions = []
  let locations = Map([])
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
    let pc = instructions.length()
    instructions.push(
      @bpf.insn(fields[0], fields[1], fields[2], fields[3], fields[4]),
    )
    locations.set(pc, { pc, path, line, name: "BPF 指令", })
  }
  guard !instructions.is_empty() else {
    raise @session.TargetError("程序没有指令")
  }
  { instructions, locations, }
}

///|
async fn load_program(path : String, options : Json) -> Program {
  let data = @fs.read_file(path)
  let format = match options {
    { "programFormat": String(value), .. } => value
    { "programFormat": _, .. } =>
      raise @session.TargetError("programFormat 需要字符串")
    _ => "text"
  }
  if format == "text" {
    return parse_program(path, data.text())
  }
  guard format == "elf" else {
    raise @session.TargetError("programFormat 可选 text 或 elf")
  }
  guard options is { "sourceMap": String(map_path), .. } && !map_path.is_empty() else {
    raise @session.TargetError("ELF 调试需要 sourceMap 文件路径")
  }
  let bytes = data.binary().iter().map(byte => byte.to_int()).collect()
  let image = @bpf.load_elf(bytes)
  guard image.entry == 0 && !image.text.is_empty() else {
    raise @session.TargetError(
      "示例需要从 .text 的第一条指令开始执行",
    )
  }
  let entries : Array[SourceEntry] = @json.from_json(
    @json.parse(@fs.read_file(map_path).text(), reject_duplicate_keys=true),
  )
  let locations = Map([])
  for entry in entries {
    guard entry.pc >= 0 &&
      entry.pc < image.text.length() &&
      entry.line > 0 &&
      !entry.path.is_empty() &&
      !entry.name.is_empty() &&
      !locations.contains(entry.pc) else {
      raise @session.TargetError(
        "无效或重复的源码映射 PC \{entry.pc}",
      )
    }
    locations.set(entry.pc, entry)
  }
  { instructions: image.text, locations, }
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
