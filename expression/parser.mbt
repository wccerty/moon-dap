///|
pub(all) enum Selector {
  Field(String)
  Index(Int32)
}

///|
priv enum Node {
  Literal(Json)
  Name(String)
  Member(Node, String)
  Element(Node, Node)
  Unary(String, Node)
  Binary(String, Node, Node)
}

///|
struct Expression {
  node : Node
}

///|
priv struct Parser {
  lexer : Lexer
  mut token : Token
  mut nodes : Int32
}

///|
fn Parser::take(self : Parser) -> Token raise ExpressionError {
  let current = self.token
  self.token = self.lexer.next()
  current
}

///|
fn Parser::count_node(self : Parser) -> Unit raise ExpressionError {
  guard self.nodes < 256 else {
    raise InvalidSyntax(self.token.offset, "表达式节点数量超过限制")
  }
  self.nodes += 1
}

///|
fn precedence(op : String) -> Int32 {
  match op {
    "||" => 1
    "&&" => 2
    "==" | "!=" => 3
    "<" | "<=" | ">" | ">=" => 4
    "+" | "-" => 5
    "*" | "/" => 6
    _ => 0
  }
}

///|
fn Parser::primary(self : Parser, depth : Int32) -> Node raise ExpressionError {
  guard depth < 64 else {
    raise InvalidSyntax(self.token.offset, "表达式嵌套超过限制")
  }
  self.count_node()
  let token = self.take()
  match token.kind {
    Literal(value) => Literal(value)
    Identifier(name) => Name(name)
    Operator(op) if op == "!" || op == "-" => Unary(op, self.prefix(depth + 1))
    OpenParen => {
      let value = self.binary(1, depth + 1)
      guard self.token.kind is CloseParen else {
        raise InvalidSyntax(self.token.offset, "缺少右括号")
      }
      ignore(self.take())
      value
    }
    _ => raise InvalidSyntax(token.offset, "需要表达式")
  }
}

///|
fn Parser::prefix(self : Parser, depth : Int32) -> Node raise ExpressionError {
  let mut value = self.primary(depth)
  while true {
    match self.token.kind {
      Dot => {
        self.count_node()
        ignore(self.take())
        let field = self.take()
        guard field.kind is Identifier(name) else {
          raise InvalidSyntax(field.offset, "点号后需要字段名")
        }
        value = Member(value, name)
      }
      OpenBracket => {
        self.count_node()
        ignore(self.take())
        let index = self.binary(1, depth + 1)
        guard self.token.kind is CloseBracket else {
          raise InvalidSyntax(self.token.offset, "缺少右方括号")
        }
        ignore(self.take())
        value = Element(value, index)
      }
      _ => break
    }
  }
  value
}

///|
fn Parser::binary(
  self : Parser,
  minimum : Int32,
  depth : Int32,
) -> Node raise ExpressionError {
  let mut left = self.prefix(depth)
  while self.token.kind is Operator(op) && precedence(op) >= minimum {
    self.count_node()
    ignore(self.take())
    let right = self.binary(precedence(op) + 1, depth + 1)
    left = Binary(op, left, right)
  }
  left
}

///|
pub fn Expression::parse(text : String) -> Expression raise ExpressionError {
  guard text.length() <= 8192 else {
    raise InvalidSyntax(0, "表达式长度超过限制")
  }
  let lexer = Lexer::{ text, cursor: 0, }
  let parser = Parser::{ lexer, token: lexer.next(), nodes: 0, }
  let node = parser.binary(1, 0)
  guard parser.token.kind is End else {
    raise InvalidSyntax(parser.token.offset, "表达式后有多余内容")
  }
  { node, }
}

///|
fn Node::selection(
  self : Node,
  resolve : (String) -> Json?,
  selectors : Array[Selector],
) -> String raise ExpressionError {
  match self {
    Name(name) => name
    Member(base, field) => {
      let root = base.selection(resolve, selectors)
      selectors.push(Field(field))
      root
    }
    Element(base, index) => {
      let root = base.selection(resolve, selectors)
      selectors.push(selector(index.evaluate(resolve)))
      root
    }
    _ => raise InvalidValue("赋值左侧需要变量或可访问的子项")
  }
}

///|
/// 支持形如 record.field 或 list[index] 的可写路径。
pub fn Expression::selection(
  self : Expression,
  resolve : (String) -> Json?,
) -> (String, Array[Selector]) raise ExpressionError {
  let selectors = []
  let root = self.node.selection(resolve, selectors)
  (root, selectors)
}
