///|
impl @session.DebugTarget for MiniTarget with fn stack_trace(self, _, page) {
  let frames : Array[@session.Frame] = []
  guard self.program is Some(program) else {
    raise @session.TargetError("未加载程序")
  }
  for offset in 0..<self.stack.length() {
    let frame = self.stack[self.stack.length() - 1 - offset]
    let pc = if offset == 0 { frame.pc } else { frame.pc - 1 }
    let location : @session.SourceLocation? = if pc >= 0 &&
      pc < frame.code.length() {
      Some({ path: program.path, line: frame.code[pc].line, column: Some(1L), })
    } else {
      None
    }
    frames.push({ handle: frame.handle, name: frame.name, location, })
  }
  { frames: page.slice(frames), total: frames.length().to_int64(), }
}

///|
fn MiniTarget::value_handle(
  self : MiniTarget,
  key : String,
  value : Json,
) -> Int32 {
  if self.value_keys.get(key) is Some(id) {
    return id
  }
  let id = self.next_value
  self.next_value += 1
  self.value_keys.set(key, id)
  self.values.set(id, value)
  id
}

///|
impl @session.DebugTarget for MiniTarget with fn scopes(self, frame_id) {
  guard self.stack.iter().find_first(frame => frame.handle == frame_id)
    is Some(frame) else {
    raise @session.TargetError("找不到调用帧")
  }
  let locals = self.value_handle(
    "locals:\{frame_id}",
    Json::object(frame.locals.copy()),
  )
  [{ name: "局部变量", handle: locals, expensive: false, }]
}

///|
fn MiniTarget::variable(
  self : MiniTarget,
  parent : Int32,
  name : String,
  value : Json,
) -> @session.Variable {
  let (display, type_name, named_count, indexed_count) = match value {
    Object(fields) => ("{…}", "record", Some(fields.length()), None)
    Array(items) => ("[\{items.length()}]", "array", None, Some(items.length()))
    String(_) => (value.stringify(), "string", None, None)
    Number(_, ..) => (value.stringify(), "number", None, None)
    True | False => (value.stringify(), "bool", None, None)
    Null => ("null", "null", None, None)
  }
  let children = match value {
    Object(_) | Array(_) =>
      Some(self.value_handle("item:\{parent}:\{name}", value))
    _ => None
  }
  {
    name,
    value: display,
    type_name: Some(type_name),
    children,
    named_count,
    indexed_count,
  }
}

///|
impl @session.DebugTarget for MiniTarget with fn variables(self, handle, query) {
  guard self.values.get(handle) is Some(value) else {
    raise @session.TargetError("找不到变量句柄")
  }
  let items = []
  match value {
    Object(fields) if !(query.filter is Indexed) =>
      for name, item in fields {
        items.push((name, item))
      }
    Array(values) if !(query.filter is Named) =>
      for index, item in values {
        items.push(("[\{index}]", item))
      }
    _ => ()
  }
  query.page
  .slice(items)
  .map(item => {
    let (name, value) = item
    self.variable(handle, name, value)
  })
}
