///|
priv struct ValuePath {
  frame : Int32
  root : String
  selectors : Array[@expression.Selector]
}

///|
fn ValuePath::child(
  self : ValuePath,
  selector : @expression.Selector,
) -> ValuePath {
  let selectors = self.selectors.copy()
  selectors.push(selector)
  { ..self, selectors, }
}

///|
fn ValuePath::key(self : ValuePath) -> String {
  let keys : Array[Json] = [Json::string(self.root)]
  for step in self.selectors {
    keys.push(
      match step {
        Field(name) => Json::string(name)
        Index(index) => @json.to_json(index)
      },
    )
  }
  "\{self.frame}:" + Json::array(keys).stringify()
}

///|
fn ValuePath::includes(self : ValuePath, other : ValuePath) -> Bool {
  if self.frame != other.frame ||
    self.root != other.root ||
    self.selectors.length() > other.selectors.length() {
    return false
  }
  for index, selector in self.selectors {
    let same = match (selector, other.selectors[index]) {
      (Field(left), Field(right)) => left == right
      (Index(left), Index(right)) => left == right
      _ => false
    }
    if !same {
      return false
    }
  }
  true
}

///|
priv enum Container {
  Locals(Int32)
  Live(ValuePath)
  Snapshot(Json)
}

///|
priv struct ValueStore {
  containers : Map[Int32, Container]
  stable : Map[String, Int32]
  mut next : Int32
}

///|
fn ValueStore::new() -> ValueStore {
  { containers: Map([]), stable: Map([]), next: 1, }
}

///|
fn ValueStore::reset(self : ValueStore) -> Unit {
  self.containers.clear()
  self.stable.clear()
  self.next = 1
}

///|
fn ValueStore::add(
  self : ValueStore,
  item : Container,
) -> Int32 raise @session.TargetError {
  let stable = match item {
    Locals(frame) => Some("locals:\{frame}")
    Live(path) => Some(path.key())
    Snapshot(_) => None
  }
  if stable is Some(key) && self.stable.get(key) is Some(handle) {
    return handle
  }
  guard self.next <= 10000 else {
    raise @session.TargetError("本次暂停的变量容器数量已达上限")
  }
  let handle = self.next
  self.next += 1
  self.containers.set(handle, item)
  if stable is Some(key) {
    self.stable.set(key, handle)
  }
  handle
}

///|
fn ValueStore::get(
  self : ValueStore,
  handle : Int32,
) -> Container raise @session.TargetError {
  guard self.containers.get(handle) is Some(value) else {
    raise @session.TargetError("当前暂停的变量容器无效")
  }
  value
}

///|
fn ValueStore::invalidate(self : ValueStore, path : ValuePath) -> Array[Int32] {
  let invalidated = []
  let keys = []
  for handle, container in self.containers {
    if container is Live(location) && path.includes(location) {
      invalidated.push(handle)
      keys.push(location.key())
    }
  }
  for handle in invalidated {
    self.containers.remove(handle)
  }
  for key in keys {
    self.stable.remove(key)
  }
  invalidated
}

///|
fn ValuePath::read(
  self : ValuePath,
  frame : Frame,
) -> Json raise @session.TargetError {
  guard frame.locals.get(self.root) is Some(root) else {
    raise @session.TargetError("找不到变量 \{self.root}")
  }
  let mut value = root
  for selector in self.selectors {
    value = selector.access(value) catch {
      error => raise @session.TargetError(error.message())
    }
  }
  value
}

///|
fn ValuePath::write(
  self : ValuePath,
  frame : Frame,
  value : Json,
) -> Unit raise @session.TargetError {
  guard frame.locals.get(self.root) is Some(root) else {
    raise @session.TargetError("找不到变量 \{self.root}")
  }
  let updated = @expression.replace(root, self.selectors, value) catch {
    error => raise @session.TargetError(error.message())
  }
  frame.locals.set(self.root, updated)
}

///|
fn describe(value : Json) -> (String, String, Int32?, Int32?) {
  match value {
    Object(fields) => ("{…}", "对象", Some(fields.length()), None)
    Array(items) =>
      ("[\{items.length()}]", "数组", None, Some(items.length()))
    Number(_, ..) => (value.stringify(), "数字", None, None)
    String(_) => (value.stringify(), "字符串", None, None)
    True | False => (value.stringify(), "布尔值", None, None)
    Null => ("null", "空值", None, None)
  }
}

///|
fn RuleTarget::variable(
  self : RuleTarget,
  name : String,
  value : Json,
  location : ValuePath?,
) -> @session.Variable raise @session.TargetError {
  let (display, kind, named_count, indexed_count) = describe(value)
  let children = match value {
    Object(_) | Array(_) => {
      let item = match location {
        Some(path) => Live(path)
        None => Snapshot(value)
      }
      Some(self.values.add(item))
    }
    _ => None
  }
  {
    name,
    value: display,
    type_name: Some(kind),
    children,
    named_count,
    indexed_count,
  }
}

///|
priv struct Member {
  name : String
  selector : @expression.Selector
  value : Json
}

///|
fn members(value : Json, filter : @session.VariableFilter) -> Array[Member] {
  let result : Array[Member] = []
  match value {
    Object(fields) if !(filter is Indexed) => {
      for key, item in fields {
        result.push({ name: key, selector: Field(key), value: item, })
      }
      result.sort_by_key(item => item.name)
    }
    Array(items) if !(filter is Named) =>
      for index, item in items {
        result.push({ name: "[\{index}]", selector: Index(index), value: item, })
      }
    _ => ()
  }
  result
}

///|
fn RuleTarget::container_value(
  self : RuleTarget,
  container : Container,
) -> Json raise @session.TargetError {
  match container {
    Snapshot(value) => value
    Locals(id) => Json::object(self.machine().frame(Some(id)).locals)
    Live(path) => path.read(self.machine().frame(Some(path.frame)))
  }
}

///|
fn Container::member_path(
  self : Container,
  selector : @expression.Selector,
) -> ValuePath? {
  match (self, selector) {
    (Locals(frame), Field(root)) => Some({ frame, root, selectors: [], })
    (Live(path), _) => Some(path.child(selector))
    _ => None
  }
}

///|
impl @session.DebugTarget for RuleTarget with fn scopes(self, handle) {
  let frame = self.machine().frame(Some(handle))
  let locals = self.values.add(Locals(frame.id))
  [{ name: "规则局部变量", handle: locals, expensive: false, }]
}

///|
impl @session.DebugTarget for RuleTarget with fn variables(self, handle, query) {
  let container = self.values.get(handle)
  let value = self.container_value(container)
  query.page
  .slice(members(value, query.filter))
  .map(item => {
    self.variable(item.name, item.value, container.member_path(item.selector))
  })
}

///|
fn array_index(name : String) -> Int32 raise @session.TargetError {
  guard name.has_prefix("[") && name.has_suffix("]") else {
    raise @session.TargetError("数组元素名称应为 [下标]")
  }
  let number = @string.parse_int(name[1:name.length() - 1]) catch {
    _ => raise @session.TargetError("数组下标无效")
  }
  guard number >= 0 && name == "[\{number}]" else {
    raise @session.TargetError("数组下标无效")
  }
  number
}

///|
fn RuleTarget::set_variable(
  self : RuleTarget,
  assignment : @session.VariableAssignment,
) -> @session.VariableUpdate raise @session.TargetError {
  let container = self.values.get(assignment.container)
  let selector : @expression.Selector = match self.container_value(container) {
    Object(_) => Field(assignment.name)
    Array(_) => Index(array_index(assignment.name))
    _ => raise @session.TargetError("只能修改对象字段或数组元素")
  }
  guard container.member_path(selector) is Some(path) else {
    raise @session.TargetError("此求值结果仅为只读快照")
  }
  let frame = self.machine().frame(Some(path.frame))
  let value = parse_assignment(frame, assignment.expression)
  self.write_value(frame, path, assignment.name, value)
}

///|
fn parse_assignment(
  frame : Frame,
  text : String,
) -> Json raise @session.TargetError {
  // JSON 对象与数组可以整体替换，表达式用于计算或引用现有值。
  let trimmed = text.trim()
  if trimmed.has_prefix("{") || trimmed.has_prefix("[") {
    @json.parse(trimmed, reject_duplicate_keys=true, preserve_number_repr=true) catch {
      error => raise @session.TargetError(error.to_string())
    }
  } else {
    frame.eval(parse_expression(trimmed))
  }
}

///|
fn Frame::selection(
  self : Frame,
  expression : @expression.Expression,
) -> ValuePath raise @session.TargetError {
  let (root, selectors) = expression.selection(name => self.locals.get(name)) catch {
    error => raise @session.TargetError(error.message())
  }
  { frame: self.id, root, selectors, }
}

///|
fn RuleTarget::evaluate(
  self : RuleTarget,
  query : @session.EvaluationQuery,
) -> @session.Variable raise @session.TargetError {
  let expression = parse_expression(query.expression[:])
  guard query.frame is Some(handle) else {
    let value = evaluate_in_scope(expression, _ => None)
    return self.variable(query.expression, value, None)
  }
  let frame = self.machine().frame(Some(handle))
  let value = frame.eval(expression)
  let path = Some(frame.selection(expression)) catch {
    @session.TargetError(_) => None
  }
  self.variable(query.expression, value, path)
}

///|
fn RuleTarget::set_expression(
  self : RuleTarget,
  assignment : @session.ExpressionAssignment,
) -> @session.VariableUpdate raise @session.TargetError {
  guard assignment.frame is Some(handle) else {
    raise @session.TargetError(
      "规则引擎没有可写的全局变量，请指定调用帧",
    )
  }
  let frame = self.machine().frame(Some(handle))
  let path = frame.selection(parse_expression(assignment.expression[:]))
  let value = parse_assignment(frame, assignment.value)
  self.write_value(frame, path, assignment.expression, value)
}

///|
fn RuleTarget::write_value(
  self : RuleTarget,
  frame : Frame,
  path : ValuePath,
  display_name : String,
  value : Json,
) -> @session.VariableUpdate raise @session.TargetError {
  if value is (Object(_) | Array(_)) && self.values.next > 10000 {
    raise @session.TargetError("本次暂停的变量容器数量已达上限")
  }
  path.write(frame, value)
  let invalidated = self.values.invalidate(path)
  { value: self.variable(display_name, value, Some(path)), invalidated, }
}
