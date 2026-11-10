///|
priv struct CallFrame {
  name : String
  handle : Int32
  code : Array[Instruction]
  locals : Map[String, Json]
  mut pc : Int32
}

///|
priv struct MiniTarget {
  mut program : Program?
  mut sink : @session.EventSink?
  stack : Array[CallFrame]
  breakpoints : Map[Int64, Int32]
  values : Map[Int32, Json]
  value_keys : Map[String, Int32]
  mut next_frame : Int32
  mut next_value : Int32
  mut stop_on_entry : Bool
  mut pause_requested : Bool
  mut ignore_breakpoint : Bool
  mut waiting : Int32
  mut stepped : Bool
  mut step_depth : Int32
  mut step_mode : @session.ResumeMode
}

///|
fn MiniTarget::new() -> MiniTarget {
  {
    program: None,
    sink: None,
    stack: [],
    breakpoints: Map([]),
    values: Map([]),
    value_keys: Map([]),
    next_frame: 1,
    next_value: 1,
    stop_on_entry: false,
    pause_requested: false,
    ignore_breakpoint: false,
    waiting: 0,
    stepped: false,
    step_depth: 0,
    step_mode: Continue,
  }
}

///|
fn MiniTarget::emit(
  self : MiniTarget,
  event : @session.TargetEvent,
) -> Unit raise @session.TargetError {
  guard self.sink is Some(sink) else {
    raise @session.TargetError("目标未绑定会话")
  }
  sink.emit(event)
}

///|
fn MiniTarget::stop(
  self : MiniTarget,
  reason : @session.StopReason,
  ids~ : Array[Int32] = [],
) -> Unit raise @session.TargetError {
  self.emit(
    Stopped({ reason, thread_id: 1, description: None, breakpoint_ids: ids, }),
  )
}

///|
fn MiniTarget::push_frame(
  self : MiniTarget,
  name : String,
) -> Unit raise @session.TargetError {
  guard self.stack.length() < 1024 else {
    raise @session.TargetError("调用深度超过示例限制")
  }
  guard self.program is Some(program) &&
    program.functions.get(name) is Some(code) else {
    raise @session.TargetError("函数不存在 \{name}")
  }
  self.stack.push({
    name,
    handle: self.next_frame,
    code,
    locals: Map([]),
    pc: 0,
  })
  self.next_frame += 1
}

///|
fn MiniTarget::clear_values(self : MiniTarget) -> Unit {
  self.values.clear()
  self.value_keys.clear()
  self.next_value = 1
}

///|
fn same_path(left : String, right : String) -> Bool {
  if @env.get_env_var("OS") == Some("Windows_NT") {
    left.replace_all(old="\\", new="/").to_lower() ==
    right.replace_all(old="\\", new="/").to_lower()
  } else {
    left == right
  }
}

///|
impl @session.DebugTarget for MiniTarget with fn prepare(
  self,
  mode,
  options,
  sink,
) {
  guard mode is Launch else {
    raise @session.TargetError("示例仅支持 launch")
  }
  guard options is { "program": String(path), .. } && !path.is_empty() else {
    raise @session.TargetError("launch.program 需要源码文件路径")
  }
  self.stop_on_entry = match options {
    { "stopOnEntry": True, .. } => true
    { "stopOnEntry": False, .. } => false
    { "stopOnEntry": _, .. } =>
      raise @session.TargetError("stopOnEntry 需要布尔值")
    _ => false
  }
  self.program = Some(Program::parse(path, @fs.read_file(path).text()))
  self.sink = Some(sink)
}

///|
impl @session.DebugTarget for MiniTarget with fn start(self) {
  self.push_frame("main")
  if self.stop_on_entry {
    self.stop(Entry)
  }
}

///|
impl @session.DebugTarget for MiniTarget with fn set_breakpoints(
  self,
  path,
  points,
) {
  guard self.program is Some(program) else {
    raise @session.TargetError("未加载程序")
  }
  let is_source = same_path(program.path, path)
  if is_source {
    self.breakpoints.clear()
  }
  points.map(point => {
    if is_source && program.lines.get(point.line) is Some(id) {
      self.breakpoints.set(point.line, id)
      {
        id: Some(id),
        verified: true,
        line: Some(point.line),
        column: Some(1L),
        message: None,
      }
    } else {
      {
        id: None,
        verified: false,
        line: Some(point.line),
        column: None,
        message: Some("该行没有可执行语句"),
      }
    }
  })
}

///|
impl @session.DebugTarget for MiniTarget with fn resume_execution(self, _, mode) {
  self.clear_values()
  self.step_mode = mode
  self.step_depth = self.stack.length()
  self.stepped = false
  self.ignore_breakpoint = true
}

///|
impl @session.DebugTarget for MiniTarget with fn pause(self, _) {
  self.pause_requested = true
}

///|
impl @session.DebugTarget for MiniTarget with fn threads(_) {
  [{ id: 1, name: "main", }]
}

///|
fn MiniTarget::step_complete(self : MiniTarget) -> Bool {
  self.stepped &&
  (match self.step_mode {
    Continue => false
    StepIn => true
    StepOver => self.stack.length() <= self.step_depth
    StepOut => self.stack.length() < self.step_depth
  })
}

///|
impl @session.DebugTarget for MiniTarget with fn poll(self) {
  while self.stack.last() is Some(frame) && frame.pc >= frame.code.length() {
    ignore(self.stack.pop())
  }
  guard self.stack.last() is Some(frame) else {
    self.emit(Exited(0))
    return
  }
  let item = frame.code[frame.pc]
  if self.pause_requested {
    self.pause_requested = false
    self.stop(Pause)
    return
  }
  if self.waiting > 0 {
    self.ignore_breakpoint = false
    self.waiting -= 1
    if self.waiting == 0 {
      frame.pc += 1
      self.stepped = true
    }
    return
  }
  let skip = self.ignore_breakpoint
  self.ignore_breakpoint = false
  if !skip && self.breakpoints.get(item.line) is Some(id) {
    self.stop(Breakpoint, ids=[id])
    return
  }
  if self.step_complete() {
    self.stop(Step)
    return
  }
  if item.statement is Wait(ticks) && ticks > 0 {
    self.waiting = ticks
    return
  }
  frame.pc += 1
  self.stepped = true
  match item.statement {
    Set(name, value) => frame.locals.set(name, value)
    Print(name) => {
      let value = frame.locals.get(name).unwrap_or(Json::null())
      self.emit(Output("stdout", value.stringify() + "\n"))
    }
    Call(name) => self.push_frame(name)
    Return => ignore(self.stack.pop())
    Wait(_) => ()
  }
}

///|
impl @session.DebugTarget for MiniTarget with fn disconnect(self, _) {
  self.sink = None
  self.program = None
  self.stack.clear()
  self.breakpoints.clear()
  self.clear_values()
}
