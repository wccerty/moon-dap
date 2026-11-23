///|
#derive(Debug)
pub(all) suberror ExpressionError {
  InvalidSyntax(Int32, String)
  InvalidValue(String)
}

///|
pub extend ExpressionError with @debug.Debug::{to_repr}

///|
pub fn ExpressionError::message(self : ExpressionError) -> String {
  match self {
    InvalidSyntax(offset, detail) => "第 \{offset + 1} 列 \{detail}"
    InvalidValue(detail) => detail
  }
}

///|
priv enum TokenKind {
  Identifier(String)
  Literal(Json)
  Operator(String)
  OpenParen
  CloseParen
  OpenBracket
  CloseBracket
  Dot
  End
}

///|
priv struct Token {
  kind : TokenKind
  offset : Int32
}

///|
priv struct Lexer {
  text : String
  mut cursor : Int32
}

///|
fn is_digit(ch : UInt16) -> Bool {
  ch >= 48 && ch <= 57
}

///|
fn is_space(ch : UInt16) -> Bool {
  ch == 32 || ch == 9 || ch == 10 || ch == 13
}

///|
/// 标识符按 UTF-16 代码单元处理，允许 ASCII 字母、下划线和非 ASCII 字符。
pub fn is_name_start(ch : UInt16) -> Bool {
  ch == 95 || ch >= 128 || (ch >= 65 && ch <= 90) || (ch >= 97 && ch <= 122)
}

///|
pub fn is_name_part(ch : UInt16) -> Bool {
  is_name_start(ch) || is_digit(ch)
}

///|
pub fn is_identifier(text : String) -> Bool {
  guard !text.is_empty() && is_name_start(text.code_unit_at(0)) else {
    return false
  }
  for index in 1..<text.length() {
    if !is_name_part(text.code_unit_at(index)) {
      return false
    }
  }
  text != "true" && text != "false" && text != "null"
}

///|
fn Lexer::look(self : Lexer) -> UInt16 {
  if self.cursor < self.text.length() {
    self.text.code_unit_at(self.cursor)
  } else {
    0
  }
}

///|
fn Lexer::skip_digits(self : Lexer) -> Unit {
  while is_digit(self.look()) {
    self.cursor += 1
  }
}

///|
fn Lexer::number(
  self : Lexer,
  start : Int32,
) -> TokenKind raise ExpressionError {
  self.skip_digits()
  if self.look() == 46 {
    self.cursor += 1
    self.skip_digits()
  }
  if self.look() == 69 || self.look() == 101 {
    self.cursor += 1
    if self.look() == 43 || self.look() == 45 {
      self.cursor += 1
    }
    self.skip_digits()
  }
  let raw = self.text[start:self.cursor]
  let value = @json.parse(raw, preserve_number_repr=true) catch {
    _ => raise InvalidSyntax(start, "无效数字")
  }
  guard value is Number(number, ..) && !number.is_inf() && !number.is_nan() else {
    raise InvalidSyntax(start, "需要有限数字")
  }
  Literal(value)
}

///|
fn Lexer::string(
  self : Lexer,
  start : Int32,
) -> TokenKind raise ExpressionError {
  let mut escaped = false
  while self.cursor < self.text.length() {
    let ch = self.look()
    self.cursor += 1
    if escaped {
      escaped = false
    } else if ch == 92 {
      escaped = true
    } else if ch == 34 {
      let value = @json.parse(self.text[start:self.cursor]) catch {
        _ => raise InvalidSyntax(start, "无效字符串")
      }
      return Literal(value)
    }
  }
  raise InvalidSyntax(start, "字符串未闭合")
}

///|
fn Lexer::identifier(self : Lexer, start : Int32) -> TokenKind {
  while is_name_part(self.look()) {
    self.cursor += 1
  }
  match self.text[start:self.cursor].to_owned() {
    "true" => Literal(Json::boolean(true))
    "false" => Literal(Json::boolean(false))
    "null" => Literal(Json::null())
    name => Identifier(name)
  }
}

///|
fn Lexer::symbol(
  self : Lexer,
  start : Int32,
  ch : UInt16,
) -> TokenKind raise ExpressionError {
  let next = self.look()
  match ch {
    40 => OpenParen
    41 => CloseParen
    91 => OpenBracket
    93 => CloseBracket
    46 => Dot
    43 | 45 | 42 | 47 => Operator(self.text[start:self.cursor].to_owned())
    33 | 60 | 62 => {
      if next == 61 {
        self.cursor += 1
      }
      Operator(self.text[start:self.cursor].to_owned())
    }
    61 | 38 | 124 if next == ch => {
      self.cursor += 1
      Operator(self.text[start:self.cursor].to_owned())
    }
    _ => raise InvalidSyntax(start, "无法识别的符号")
  }
}

///|
fn Lexer::next(self : Lexer) -> Token raise ExpressionError {
  while is_space(self.look()) {
    self.cursor += 1
  }
  let offset = self.cursor
  if offset >= self.text.length() {
    return { kind: End, offset, }
  }
  let ch = self.look()
  self.cursor += 1
  let kind = if is_digit(ch) {
    self.number(offset)
  } else if is_name_start(ch) {
    self.identifier(offset)
  } else if ch == 34 {
    self.string(offset)
  } else {
    self.symbol(offset, ch)
  }
  { kind, offset, }
}
