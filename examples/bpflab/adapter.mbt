///|
struct Watchpoint {
  id : Int32
  pc : Int32
  condition : (Int32, UInt64)?
}

///|
struct BpfTarget {
  mut program : Program?
  mut machine : @bpf.Machine?
  mut sink : @session.EventSink?
  breakpoints : Map[String, Array[Watchpoint]]
  mut next_breakpoint_id : Int32
  mut paused : Bool
  mut step_mode : @session.ResumeMode
  mut step_depth : Int32
  mut skip_breakpoint : Bool
  mut stop_on_entry : Bool
}

///|
fn BpfTarget::new() -> BpfTarget {
  {
    program: None,
    machine: None,
    sink: None,
    breakpoints: Map([]),
    next_breakpoint_id: 1,
    paused: false,
    step_mode: Continue,
    step_depth: 0,
    skip_breakpoint: false,
    stop_on_entry: false,
  }
}

///|
fn BpfTarget::runtime(
  self : BpfTarget,
) -> @bpf.Machine raise @session.TargetError {
  guard self.machine is Some(machine) else {
    raise @session.TargetError("虚拟机尚未启动")
  }
  machine
}

///|
fn BpfTarget::emit(
  self : BpfTarget,
  event : @session.TargetEvent,
) -> Unit raise @session.TargetError {
  guard self.sink is Some(sink) else {
    raise @session.TargetError("会话已关闭")
  }
  sink.emit(event)
}

///|
fn BpfTarget::stop(
  self : BpfTarget,
  reason : @session.StopReason,
  ids : Array[Int32],
) -> Unit raise @session.TargetError {
  self.paused = true
  self.emit(
    Stopped({ reason, thread_id: 1, description: None, breakpoint_ids: ids, }),
  )
}

///|
impl @session.DebugTarget for BpfTarget with fn prepare(
  self,
  mode,
  options,
  sink,
) {
  guard mode is Launch && options is { "program": String(path), .. } else {
    raise @session.TargetError(
      "示例仅支持 launch，并需要 program 源码路径",
    )
  }
  let stop_on_entry = match options {
    { "stopOnEntry": True, .. } => true
    { "stopOnEntry": False, .. } => false
    { "stopOnEntry": _, .. } =>
      raise @session.TargetError("stopOnEntry 需要布尔值")
    _ => false
  }
  let program = load_program(path, options)
  self.program = Some(program)
  self.machine = Some(@bpf.Machine::new_default(program.instructions, []))
  self.sink = Some(sink)
  self.stop_on_entry = stop_on_entry
}

///|
impl @session.DebugTarget for BpfTarget with fn start(self) {
  if self.stop_on_entry {
    self.stop(Entry, [])
  }
}

///|
fn rejected(line : Int64, message : String) -> @session.BreakpointResult {
  {
    id: None,
    verified: false,
    line: Some(line),
    column: None,
    message: Some(message),
  }
}

///|
fn BpfTarget::replace_breakpoints(
  self : BpfTarget,
  path : String,
  requests : Array[@session.ConditionalBreakpointSpec],
) -> Array[@session.BreakpointResult] {
  guard self.program is Some(program) else {
    return requests.map(item => rejected(item.position.line, "源码未加载"))
  }
  let key = source_key(path)
  let by_line : Map[Int64, Array[Int32]] = Map([])
  for pc, entry in program.locations {
    if source_key(entry.path) == key {
      let line = entry.line.to_int64()
      let indices = by_line.get(line).unwrap_or([])
      indices.push(pc)
      by_line.set(line, indices)
    }
  }
  let installed = []
  let results : Array[@session.BreakpointResult] = []
  for item in requests {
    let line = item.position.line
    guard by_line.get(line) is Some(indices) else {
      results.push(rejected(line, "该行没有可执行指令"))
      continue
    }
    let predicate = item.condition.map(condition) catch {
      @session.TargetError(message) => {
        results.push(rejected(line, message))
        continue
      }
    }
    let id = self.next_breakpoint_id
    self.next_breakpoint_id += 1
    for pc in indices {
      installed.push({ id, pc, condition: predicate, })
    }
    results.push({
      id: Some(id),
      verified: true,
      line: Some(line),
      column: None,
      message: None,
    })
  }
  if installed.is_empty() {
    self.breakpoints.remove(key)
  } else {
    self.breakpoints.set(key, installed)
  }
  results
}

///|
impl @session.DebugTarget for BpfTarget with fn breakpoint_location_provider(
  self,
) {
  Some((path, range) => {
    let positions = []
    let seen = Map([])
    if self.program is Some(program) {
      let key = source_key(path)
      for _, entry in program.locations {
        let position : @session.BreakpointSpec = {
          line: entry.line.to_int64(),
          column: Some(1L),
        }
        if source_key(entry.path) == key &&
          range.contains(position) &&
          !seen.contains(entry.line) {
          seen.set(entry.line, true)
          positions.push(position)
        }
      }
    }
    positions.sort_by_key(position => position.line)
    positions
  })
}

///|
impl @session.DebugTarget for BpfTarget with fn set_breakpoints(
  self,
  path,
  points,
) {
  self.replace_breakpoints(
    path,
    points.map(position => { position, condition: None, }),
  )
}

///|
impl @session.DebugTarget for BpfTarget with fn conditional_breakpoint_provider(
  self,
) {
  Some((path, points) => self.replace_breakpoints(path, points))
}

///|
impl @session.DebugTarget for BpfTarget with fn evaluation_provider(self) {
  Some((frame, expression) => {
    guard frame is None || frame is Some(1) else {
      raise @session.TargetError(
        "只有最上层栈帧可读取当前寄存器",
      )
    }
    let regs = self.runtime().snapshot().regs
    if expression.contains("==") {
      let (register, expected) = condition(expression)
      (regs[register] == expected).to_string()
    } else {
      regs[register_index(expression.trim())].to_string()
    }
  })
}

///|
impl @session.DebugTarget for BpfTarget with fn resume_execution(self, _, mode) {
  let depth = self.runtime().call_stack.length()
  guard !(mode is StepOut) || depth > 0 else {
    raise @session.TargetError("最外层栈帧无法步出")
  }
  self.step_mode = mode
  self.step_depth = depth
  self.paused = false
}

///|
impl @session.DebugTarget for BpfTarget with fn pause(self, _) {
  self.stop(Pause, [])
}

///|
impl @session.DebugTarget for BpfTarget with fn poll(self) {
  if self.paused {
    return
  }
  let machine = self.runtime()
  if !self.skip_breakpoint &&
    self.program is Some(program) &&
    program.locations.get(machine.pc) is Some(entry) &&
    self.breakpoints.get(source_key(entry.path)) is Some(points) {
    let hits = []
    for point in points {
      if point.pc == machine.pc &&
        point.condition
        .map(pair => {
          let (register, expected) = pair
          machine.vm.regs[register] == expected
        })
        .unwrap_or(true) {
        hits.push(point.id)
      }
    }
    if !hits.is_empty() {
      self.skip_breakpoint = true
      self.stop(Breakpoint, hits)
      return
    }
  }
  self.skip_breakpoint = false
  let step = machine.step() catch {
    error => {
      let fault : Error = error
      raise @session.TargetError(fault.to_string())
    }
  }
  match step {
    Halted(result) => {
      self.emit(Output("stdout", "r0 = \{result}\n"))
      self.emit(Exited(0))
    }
    Continue => {
      let depth = machine.call_stack.length()
      let stopped = match self.step_mode {
        Continue => false
        StepIn => true
        StepOver => depth <= self.step_depth
        StepOut => depth < self.step_depth
      }
      if stopped {
        self.stop(Step, [])
      }
    }
    BreakpointHit(_) => ()
  }
}

///|
impl @session.DebugTarget for BpfTarget with fn threads(_) {
  [{ id: 1, name: "MoonBpfLab VM", }]
}

///|
impl @session.DebugTarget for BpfTarget with fn stack_trace(self, _, page) {
  let machine = self.runtime()
  guard self.program is Some(program) else { return { frames: [], total: 0L, } }
  let frames = [program.frame(machine.pc, 1)]
  let depth = machine.call_stack.length()
  for index in 0..<depth {
    let return_pc = machine.call_stack[depth - index - 1]
    frames.push(program.frame(return_pc - 1, index + 2))
  }
  { frames: page.slice(frames), total: frames.length().to_int64(), }
}

///|
fn Program::frame(self : Program, pc : Int32, handle : Int32) -> @session.Frame {
  match self.locations.get(pc) {
    Some(entry) =>
      {
        handle,
        name: entry.name,
        location: Some({
          path: entry.path,
          line: entry.line.to_int64(),
          column: Some(1L),
        }),
      }
    None => { handle, name: "BPF PC \{pc}", location: None, }
  }
}

///|
impl @session.DebugTarget for BpfTarget with fn scopes(_, frame) {
  if frame == 1 {
    [{ name: "寄存器", handle: 1, expensive: false, }]
  } else {
    []
  }
}

///|
impl @session.DebugTarget for BpfTarget with fn variables(self, _, query) {
  if query.filter is Indexed {
    return []
  }
  let values : Array[@session.Variable] = []
  for index, value in self.runtime().snapshot().regs {
    values.push({
      name: "r\{index}",
      value: value.to_string(),
      type_name: Some("uint64"),
      children: None,
      named_count: None,
      indexed_count: None,
    })
  }
  query.page.slice(values)
}

///|
impl @session.DebugTarget for BpfTarget with fn disconnect(self, _) {
  self.sink = None
  self.machine = None
  self.program = None
  self.breakpoints.clear()
}

///|
async fn main {
  @transport.serve_stdio(BpfTarget::new())
}
