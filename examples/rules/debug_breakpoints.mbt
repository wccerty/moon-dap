///|
priv enum HitCondition {
  Equal(Int64)
  AtLeast(Int64)
  Every(Int64)
}

///|
fn HitCondition::parse(
  text : String,
) -> HitCondition raise @session.TargetError {
  let raw = text.trim()
  let (kind, count) = if raw.strip_prefix(">=") is Some(count) {
    (1, count)
  } else if raw.strip_prefix("%") is Some(count) {
    (2, count)
  } else {
    (0, raw.strip_prefix("==").unwrap_or(raw))
  }
  let value = @string.parse_int64(count.trim()) catch {
    _ => raise @session.TargetError("命中次数需要 N、==N、>=N 或 %N")
  }
  guard value > 0L else {
    raise @session.TargetError("命中次数必须为正数")
  }
  match kind {
    1 => AtLeast(value)
    2 => Every(value)
    _ => Equal(value)
  }
}

///|
fn HitCondition::matches(self : HitCondition, count : Int64) -> Bool {
  match self {
    Equal(value) => count == value
    AtLeast(value) => count >= value
    Every(value) => count % value == 0L
  }
}

///|
priv enum LogPart {
  Text(String)
  Value(@expression.Expression)
}

///|
fn parse_log(text : String) -> Array[LogPart] raise @session.TargetError {
  guard text.length() <= 4096 else {
    raise @session.TargetError("日志断点模板过长")
  }
  let parts = []
  let mut rest = text[:]
  while rest.split_once("{") is Some((prefix, template)) {
    if !prefix.is_empty() {
      parts.push(Text(prefix.to_owned()))
    }
    if template.strip_prefix("{") is Some(suffix) {
      parts.push(Text("{"))
      rest = suffix
      continue
    }
    guard template.split_once("}") is Some((expr, suffix)) else {
      raise @session.TargetError("日志断点模板缺少 }")
    }
    parts.push(Value(parse_expression(expr)))
    rest = suffix
  }
  if !rest.is_empty() {
    parts.push(Text(rest.to_owned()))
  }
  parts
}

///|
fn render_log(
  parts : Array[LogPart],
  frame : Frame,
) -> String raise @session.TargetError {
  let text = StringBuilder()
  for part in parts {
    match part {
      Text(literal) => text.write_string(literal)
      Value(expression) => text.write_string(frame.eval(expression).stringify())
    }
  }
  text.to_string()
}

///|
priv struct RuleBreakpoint {
  id : Int32
  line : Int64
  condition : @expression.Expression?
  hit_condition : HitCondition?
  log : Array[LogPart]?
  mut encounters : Int64
}

///|
priv struct BreakpointBook {
  lines : Map[String, Map[Int64, Array[RuleBreakpoint]]]
  mut functions : Map[String, Array[RuleBreakpoint]]
  mut next_id : Int32
}

///|
fn BreakpointBook::new() -> BreakpointBook {
  { lines: Map([]), functions: Map([]), next_id: 1, }
}

///|
fn BreakpointBook::compile(
  self : BreakpointBook,
  line : Int64,
  condition : String?,
  hit_condition : String?,
  log : String?,
) -> RuleBreakpoint raise @session.TargetError {
  let condition = condition.map(text => parse_expression(text[:]))
  let hit_condition = hit_condition.map(HitCondition::parse)
  let log = log.map(parse_log)
  guard self.next_id < 2147483647 else {
    raise @session.TargetError("断点 ID 空间已用尽")
  }
  let point = {
    id: self.next_id,
    line,
    condition,
    hit_condition,
    log,
    encounters: 0L,
  }
  self.next_id += 1
  point
}

///|
fn unverified(line : Int64?, reason : String) -> @session.BreakpointResult {
  { id: None, verified: false, line, column: None, message: Some(reason), }
}

///|
fn RuleBreakpoint::result(self : RuleBreakpoint) -> @session.BreakpointResult {
  {
    id: Some(self.id),
    verified: true,
    line: Some(self.line),
    column: Some(1L),
    message: None,
  }
}

///|
fn RuleTarget::replace_lines(
  self : RuleTarget,
  path : String,
  requests : Array[@session.LineBreakpoint],
) -> Array[@session.BreakpointResult] raise @session.TargetError {
  let program = self.machine().program
  let executable = program.line_index.get(path).unwrap_or([])
  let points : Map[Int64, Array[RuleBreakpoint]] = Map([])
  let results = []
  for request in requests {
    let line = request.position.line
    if !executable.contains(line) || request.position.column.unwrap_or(1L) != 1L {
      results.push(unverified(Some(line), "此位置没有可执行规则"))
      continue
    }
    let point = self.breakpoints.compile(
      line,
      request.condition,
      request.hit_condition,
      request.log_message,
    ) catch {
      @session.TargetError(detail) => {
        results.push(unverified(Some(line), detail))
        continue
      }
    }
    let entries = points.get(line).unwrap_or([])
    entries.push(point)
    points.set(line, entries)
    results.push(point.result())
  }
  if points.is_empty() {
    self.breakpoints.lines.remove(path)
  } else {
    self.breakpoints.lines.set(path, points)
  }
  results
}

///|
fn RuleTarget::replace_functions(
  self : RuleTarget,
  requests : Array[@session.FunctionBreakpoint],
) -> Array[@session.FunctionBreakpointResult] raise @session.TargetError {
  let program = self.machine().program
  let points : Map[String, Array[RuleBreakpoint]] = Map([])
  let results : Array[@session.FunctionBreakpointResult] = []
  for request in requests {
    guard program.rules.get(request.name) is Some(rule) else {
      results.push({
        breakpoint: unverified(None, "未找到该规则"),
        source_path: None,
      })
      continue
    }
    let line = rule.code[0].line
    let point = self.breakpoints.compile(
      line,
      request.condition,
      request.hit_condition,
      None,
    ) catch {
      @session.TargetError(detail) => {
        results.push({
          breakpoint: unverified(Some(line), detail),
          source_path: Some(rule.source.path),
        })
        continue
      }
    }
    let entries = points.get(rule.name).unwrap_or([])
    entries.push(point)
    points.set(rule.name, entries)
    results.push({
      breakpoint: point.result(),
      source_path: Some(rule.source.path),
    })
  }
  self.breakpoints.functions = points
  results
}

///|
fn RuleTarget::check_points(
  self : RuleTarget,
  points : Array[RuleBreakpoint],
  frame : Frame,
  hits : Array[Int32],
) -> Unit raise @session.TargetError {
  for point in points {
    let matches = point.condition
      .map(expr => frame.predicate(expr))
      .unwrap_or(true) catch {
        @session.TargetError(detail) => {
          self.emit(
            Output(
              "stderr",
              "断点 \{point.id} 的条件求值失败：\{detail}\n",
            ),
          )
          continue
        }
      }
    if !matches {
      continue
    }
    point.encounters += 1L
    if !point.hit_condition
      .map(cond => cond.matches(point.encounters))
      .unwrap_or(true) {
      continue
    }
    if point.log is Some(parts) {
      let message = render_log(parts, frame) catch {
        @session.TargetError(detail) => {
          self.emit(
            Output(
              "stderr",
              "日志断点 \{point.id} 求值失败：\{detail}\n",
            ),
          )
          continue
        }
      }
      self.emit(Output("console", message + "\n"))
    } else {
      hits.push(point.id)
    }
  }
}

///|
fn RuleTarget::probe(
  self : RuleTarget,
  frame : Frame,
  line : Int64,
) -> Array[Int32] raise @session.TargetError {
  let hits = []
  if self.breakpoints.lines.get(frame.rule.source.path) is Some(lines) &&
    lines.get(line) is Some(points) {
    self.check_points(points, frame, hits)
  }
  if frame.cursor == 0 && !frame.entered {
    frame.entered = true
    if self.breakpoints.functions.get(frame.rule.name) is Some(points) {
      self.check_points(points, frame, hits)
    }
  }
  hits
}
