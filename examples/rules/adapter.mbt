///|
priv struct RuleTarget {
  mut runtime : Runtime?
  mut sink : @session.EventSink?
  mut stop_on_entry : Bool
  mut pause_requested : Bool
  mut resume_mode : @session.ResumeMode
  mut resume_depth : Int32
  mut has_executed : Bool
  mut address_checked : Bool
  mut fault : String?
  mut breakpoints : BreakpointBook
  mut values : ValueStore
}

///|
fn RuleTarget::new() -> RuleTarget {
  {
    runtime: None,
    sink: None,
    stop_on_entry: false,
    pause_requested: false,
    resume_mode: Continue,
    resume_depth: 0,
    has_executed: false,
    address_checked: false,
    fault: None,
    breakpoints: BreakpointBook::new(),
    values: ValueStore::new(),
  }
}

///|
fn RuleTarget::machine(self : RuleTarget) -> Runtime raise @session.TargetError {
  guard self.runtime is Some(machine) else {
    raise @session.TargetError("规则包尚未加载")
  }
  machine
}

///|
fn RuleTarget::emit(
  self : RuleTarget,
  event : @session.TargetEvent,
) -> Unit raise @session.TargetError {
  guard self.sink is Some(sink) else {
    raise @session.TargetError("规则调试会话已结束")
  }
  sink.emit(event)
}

///|
fn RuleTarget::stop(
  self : RuleTarget,
  reason : @session.StopReason,
  ids~ : Array[Int32] = [],
  description? : String,
) -> Unit raise @session.TargetError {
  self.emit(
    Stopped({ reason, thread_id: 1, description, breakpoint_ids: ids, }),
  )
}

///|
async fn read_bundle(options : Json) -> Json {
  match options {
    { "bundle": bundle, .. } => bundle
    { "program": String(path), .. } =>
      @json.parse(
        @fs.read_file(path).text(),
        reject_duplicate_keys=true,
        preserve_number_repr=true,
      )
    _ =>
      raise @session.TargetError(
        "需要 bundle 对象或规则包文件路径 program",
      )
  }
}

///|
impl @session.DebugTarget for RuleTarget with fn prepare(
  self,
  mode,
  options,
  sink,
) {
  guard mode is Launch else {
    raise @session.TargetError("规则示例仅支持 launch")
  }
  let stop_on_entry = match options {
    { "stopOnEntry": True, .. } => true
    { "stopOnEntry": False, .. } => false
    { "stopOnEntry": _, .. } =>
      raise @session.TargetError("stopOnEntry 必须为布尔值")
    _ => false
  }
  let bundle = read_bundle(options)
  self.runtime = Some(Runtime::new(Program::parse(bundle)))
  self.stop_on_entry = stop_on_entry
  self.sink = Some(sink)
}

///|
impl @session.DebugTarget for RuleTarget with fn start(self) {
  if self.stop_on_entry {
    self.stop(Entry)
  }
}

///|
impl @session.DebugTarget for RuleTarget with fn source_provider(self) {
  Some({
    list: () => {
      self.machine().program.sources.map(source => {
        handle: source.handle,
        path: Some(source.path),
        name: source.name,
      })
    },
    read: handle => {
      guard self.machine().program.sources.get(handle - 1) is Some(source) else {
        raise @session.TargetError("规则源码未找到")
      }
      { content: source.text, mime_type: Some("text/plain"), }
    },
  })
}

///|
impl @session.DebugTarget for RuleTarget with fn breakpoint_location_provider(
  self,
) {
  Some((path, range) => {
    let lines = self.machine().program.line_index.get(path).unwrap_or([])
    lines.filter_map(line => {
      let position : @session.BreakpointSpec = { line, column: Some(1L), }
      if range.contains(position) {
        Some(position)
      } else {
        None
      }
    })
  })
}

///|
impl @session.DebugTarget for RuleTarget with fn set_breakpoints(
  self,
  path,
  points,
) {
  self.replace_lines(
    path,
    points.map(position => {
      position,
      condition: None,
      hit_condition: None,
      log_message: None,
    }),
  )
}

///|
impl @session.DebugTarget for RuleTarget with fn breakpoint_providers(self) {
  {
    replace_lines: Some((path, points) => self.replace_lines(path, points)),
    replace_functions: Some(points => self.replace_functions(points)),
    hit_conditions: true,
    log_points: true,
  }
}

///|
impl @session.DebugTarget for RuleTarget with fn threads(_) {
  [{ id: 1, name: "规则引擎", }]
}

///|
impl @session.DebugTarget for RuleTarget with fn stack_trace(self, _, page) {
  let stack = self.machine().stack
  let frames : Array[@session.Frame] = []
  for index in 0..<stack.length() {
    let frame = stack[stack.length() - index - 1]
    frames.push({
      handle: frame.id,
      name: frame.rule.name,
      location: frame.position(index > 0),
    })
  }
  { frames: page.slice(frames), total: frames.length().to_int64(), }
}

///|
impl @session.DebugTarget for RuleTarget with fn pause(self, _) {
  self.pause_requested = true
}

///|
impl @session.DebugTarget for RuleTarget with fn resume_execution(self, _, mode) {
  let depth = self.machine().stack.length()
  guard !(mode is StepOut) || depth > 1 else {
    raise @session.TargetError("无法步出入口规则")
  }
  self.values.reset()
  self.resume_mode = mode
  self.resume_depth = depth
  self.has_executed = false
  self.pause_requested = false
}

///|
fn RuleTarget::step_ready(self : RuleTarget, depth : Int32) -> Bool {
  self.has_executed &&
  (match self.resume_mode {
    Continue => false
    StepIn => true
    StepOver => depth <= self.resume_depth
    StepOut => depth < self.resume_depth
  })
}

///|
fn RuleTarget::report_fault(
  self : RuleTarget,
  detail : String,
) -> Unit raise @session.TargetError {
  self.fault = Some(detail)
  self.stop(Exception, description=detail)
}

///|
fn RuleTarget::exception_snapshot(
  self : RuleTarget,
) -> @session.ExceptionSnapshot? raise @session.TargetError {
  guard self.fault is Some(detail) else { return None }
  let stack = self.machine().stack
  let lines = []
  for index in 0..<stack.length() {
    let frame = stack[stack.length() - index - 1]
    let suffix = frame
      .position(index > 0)
      .map(location => " (\{frame.rule.source.name}:\{location.line})")
      .unwrap_or("")
    lines.push(frame.rule.name + suffix)
  }
  Some({
    id: "RuleRuntimeError",
    description: Some(detail),
    stack_trace: Some(lines.join("\n")),
    handled: false,
  })
}

///|
impl @session.DebugTarget for RuleTarget with fn poll(self) {
  if self.fault is Some(detail) {
    self.emit(Output("stderr", detail + "\n"))
    self.emit(Exited(1))
    return
  }
  let runtime = self.machine()
  let frame = runtime.frame(None)
  if self.pause_requested {
    self.pause_requested = false
    self.stop(Pause)
    return
  }
  if !self.address_checked &&
    frame.rule.code.get(frame.cursor) is Some(instruction) {
    let hits = self.probe(frame, instruction.line)
    self.address_checked = true
    if !hits.is_empty() {
      self.stop(Breakpoint, ids=hits)
      return
    }
  }
  if self.step_ready(runtime.stack.length()) &&
    frame.rule.code.get(frame.cursor) is Some(_) {
    self.stop(Step)
    return
  }
  let outcome = runtime.execute() catch {
    @session.TargetError(detail) => {
      self.report_fault(detail)
      return
    }
  }
  self.address_checked = false
  self.has_executed = true
  match outcome {
    Advanced => ()
    Printed(text) => self.emit(Output("stdout", text + "\n"))
    Finished(result) => {
      self.emit(Output("stdout", result.stringify() + "\n"))
      self.emit(Exited(0))
    }
  }
}

///|
impl @session.DebugTarget for RuleTarget with fn disconnect(self, _) {
  self.runtime = None
  self.sink = None
  self.stop_on_entry = false
  self.pause_requested = false
  self.resume_mode = Continue
  self.resume_depth = 0
  self.has_executed = false
  self.address_checked = false
  self.fault = None
  self.breakpoints = BreakpointBook::new()
  self.values = ValueStore::new()
}

///|
async fn main {
  @transport.serve_stdio(RuleTarget::new())
}
