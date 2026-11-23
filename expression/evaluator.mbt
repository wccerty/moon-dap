///|
fn json_number(value : Json) -> Double raise ExpressionError {
  guard value is Number(number, ..) && !number.is_inf() && !number.is_nan() else {
    raise InvalidValue("需要有限数字")
  }
  number
}

///|
fn bounded_number(number : Double) -> Json raise ExpressionError {
  guard !number.is_inf() && !number.is_nan() else {
    raise InvalidValue("计算结果超出有限数字范围")
  }
  Json::number(number)
}

///|
pub fn require_bool(value : Json) -> Bool raise ExpressionError {
  match value {
    True => true
    False => false
    _ => raise InvalidValue("需要布尔值")
  }
}

///|
fn selector(value : Json) -> Selector raise ExpressionError {
  if value is String(key) {
    return Field(key)
  }
  let number = json_number(value)
  guard number >= 0.0 && number <= 2147483647.0 && number == number.trunc() else {
    raise InvalidValue("下标需要非负整数或对象字段名")
  }
  Index(number.to_int())
}

///|
pub fn Selector::access(
  self : Selector,
  value : Json,
) -> Json raise ExpressionError {
  match (self, value) {
    (Field(key), Object(fields)) => {
      guard fields.get(key) is Some(item) else {
        raise InvalidValue("对象没有字段 \{key}")
      }
      item
    }
    (Index(index), Array(items)) => {
      guard items.get(index) is Some(item) else {
        raise InvalidValue("数组下标越界")
      }
      item
    }
    _ => raise InvalidValue("下标与值的类型不匹配")
  }
}

///|
/// 只复制可写路径上的对象或数组。任何错误均保留原值。
pub fn replace(
  value : Json,
  path : Array[Selector],
  replacement : Json,
) -> Json raise ExpressionError {
  replace_at(value, path, 0, replacement)
}

///|
fn replace_at(
  value : Json,
  path : Array[Selector],
  depth : Int32,
  replacement : Json,
) -> Json raise ExpressionError {
  if depth == path.length() {
    return replacement
  }
  guard depth < 256 else {
    raise InvalidValue("可写路径超过最大深度")
  }
  let step = path[depth]
  let child = replace_at(step.access(value), path, depth + 1, replacement)
  match (step, value) {
    (Field(key), Object(fields)) => {
      let copy = fields.copy()
      copy.set(key, child)
      Json::object(copy)
    }
    (Index(index), Array(items)) => {
      let copy = items.copy()
      copy[index] = child
      Json::array(copy)
    }
    _ => raise InvalidValue("无法写入该路径")
  }
}

///|
fn comparison(
  op : String,
  left : Json,
  right : Json,
) -> Bool raise ExpressionError {
  let order = match (left, right) {
    (String(a), String(b)) => a.compare(b)
    _ => json_number(left).compare(json_number(right))
  }
  match op {
    "<" => order < 0
    "<=" => order <= 0
    ">" => order > 0
    _ => order >= 0
  }
}

///|
fn calc(op : String, left : Json, right : Json) -> Json raise ExpressionError {
  match op {
    "==" => Json::boolean(left == right)
    "!=" => Json::boolean(left != right)
    "<" | "<=" | ">" | ">=" => Json::boolean(comparison(op, left, right))
    "+" if left is String(a) && right is String(b) => Json::string(a + b)
    "+" => bounded_number(json_number(left) + json_number(right))
    "-" => bounded_number(json_number(left) - json_number(right))
    "*" => bounded_number(json_number(left) * json_number(right))
    "/" => {
      let denominator = json_number(right)
      guard denominator != 0.0 else { raise InvalidValue("除数不能为零") }
      bounded_number(json_number(left) / denominator)
    }
    _ => raise InvalidValue("无效二元操作")
  }
}

///|
fn Node::evaluate(
  self : Node,
  resolve : (String) -> Json?,
) -> Json raise ExpressionError {
  match self {
    Literal(value) => value
    Name(name) => {
      guard resolve(name) is Some(value) else {
        raise InvalidValue("找不到变量 \{name}")
      }
      value
    }
    Member(node, key) => Field(key).access(node.evaluate(resolve))
    Element(node, index) =>
      selector(index.evaluate(resolve)).access(node.evaluate(resolve))
    Unary("!", node) => Json::boolean(!require_bool(node.evaluate(resolve)))
    Unary(_, node) => bounded_number(-json_number(node.evaluate(resolve)))
    Binary("&&", left, right) =>
      Json::boolean(
        require_bool(left.evaluate(resolve)) &&
        require_bool(right.evaluate(resolve)),
      )
    Binary("||", left, right) =>
      Json::boolean(
        require_bool(left.evaluate(resolve)) ||
        require_bool(right.evaluate(resolve)),
      )
    Binary(op, left, right) =>
      calc(op, left.evaluate(resolve), right.evaluate(resolve))
  }
}

///|
pub fn Expression::evaluate(
  self : Expression,
  resolve : (String) -> Json?,
) -> Json raise ExpressionError {
  self.node.evaluate(resolve)
}
