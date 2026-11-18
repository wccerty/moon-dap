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
  mut breakpoints : Array[Watchpoint]
  mut paused : Bool
  mut single_step : Bool
  mut skip_breakpoint : Bool
  mut stop_on_entry : Bool
}

///|
fn BpfTarget::new() -> BpfTarget {
  {
    program: None,
    machine: None,
    sink: None,
    breakpoints: [],
    paused: false,
    single_step: false,
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
  let program = parse_program(path, @fs.read_file(path).text())
  self.program = Some(program)
  self.machine = Some(@bpf.Machine::new_default(program.instructions, []))
  self.sink = Some(sink)
  self.stop_on_entry = options is { "stopOnEntry": True, .. }
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
  guard self.program is Some(program) &&
    path.replace_all(old="\\", new="/") ==
    program.path.replace_all(old="\\", new="/") else {
    return requests.map(item => rejected(item.position.line, "源码未加载"))
  }
  let installed = []
  let results : Array[@session.BreakpointResult] = []
  for index, item in requests {
    let line = item.position.line
    guard program.lines.search_by(candidate => candidate.to_int64() == line)
      is Some(pc) else {
      results.push(rejected(line, "该行没有可执行指令"))
      continue
    }
    let predicate = item.condition.map(condition) catch {
      @session.TargetError(message) => {
        results.push(rejected(line, message))
        continue
      }
    }
    let id = index + 1
    installed.push({ id, pc, condition: predicate, })
    results.push({
      id: Some(id),
      verified: true,
      line: Some(line),
      column: None,
      message: None,
    })
  }
  self.breakpoints = installed
  results
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
  Some((_, expression) => {
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
  guard !(mode is StepOut) else {
    raise @session.TargetError("示例仅支持指令步入和步过")
  }
  self.skip_breakpoint = true
  self.single_step = !(mode is Continue)
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
  if !self.skip_breakpoint {
    let hits = self.breakpoints.filter(point => {
      point.pc == machine.pc &&
      (match point.condition {
        Some((reg, expected)) => machine.vm.regs[reg] == expected
        None => true
      })
    })
    if !hits.is_empty() {
      self.stop(Breakpoint, hits.map(point => point.id))
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
    Continue if self.single_step => self.stop(Step, [])
    Continue | BreakpointHit(_) => ()
  }
}

///|
impl @session.DebugTarget for BpfTarget with fn threads(_) {
  [{ id: 1, name: "MoonBpfLab VM", }]
}

///|
impl @session.DebugTarget for BpfTarget with fn stack_trace(self, _, page) {
  let machine = self.runtime()
  guard self.program is Some(program) &&
    program.lines.get(machine.pc) is Some(line) else {
    return { frames: [], total: 0L, }
  }
  let frames : Array[@session.Frame] = [
    {
      handle: 1,
      name: "BPF 指令",
      location: Some({
        path: program.path,
        line: line.to_int64(),
        column: Some(1L),
      }),
    },
  ]
  { frames: page.slice(frames), total: 1L, }
}

///|
impl @session.DebugTarget for BpfTarget with fn scopes(_, _) {
  [{ name: "寄存器", handle: 1, expensive: false, }]
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
  self.breakpoints = []
}

///|
async fn main {
  @transport.serve_stdio(BpfTarget::new())
}
