///|
priv struct CompletionPrefix {
  scope : String?
  prefix : String
  start : Int64
  length : Int32
}

///|
fn completion_prefix(
  text : String,
  line : Int64,
  column : Int64,
) -> CompletionPrefix raise @session.TargetError {
  let lines = text.split("\n").collect()
  guard line >= 1L &&
    line <= lines.length().to_int64() &&
    lines.get((line - 1L).to_int()) is Some(row) &&
    column >= 1L &&
    column - 1L <= row.length().to_int64() else {
    raise @session.TargetError("补全光标超出文本范围")
  }
  let cursor = (column - 1L).to_int()
  if cursor > 0 &&
    cursor < row.length() &&
    row.code_unit_at(cursor) >= 0xdc00 &&
    row.code_unit_at(cursor) <= 0xdfff &&
    row.code_unit_at(cursor - 1) >= 0xd800 &&
    row.code_unit_at(cursor - 1) <= 0xdbff {
    raise @session.TargetError("补全光标不能位于 UTF-16 字符中间")
  }
  let mut start = cursor
  while start > 0 && @expression.is_name_part(row.code_unit_at(start - 1)) {
    start -= 1
  }
  let mut end = cursor
  while end < row.length() && @expression.is_name_part(row.code_unit_at(end)) {
    end += 1
  }
  let scope = if start > 0 && row.code_unit_at(start - 1) == 46 {
    let mut base = start - 1
    while base > 0 &&
          (
            @expression.is_name_part(row.code_unit_at(base - 1)) ||
            row.code_unit_at(base - 1) == 46
          ) {
      base -= 1
    }
    Some(row[base:start - 1].to_owned())
  } else {
    None
  }
  let mut row_start = 0L
  for index in 0..<(line - 1L).to_int() {
    row_start += lines[index].length().to_int64() + 1L
  }
  {
    scope,
    prefix: row[start:cursor].to_owned(),
    start: row_start + start.to_int64(),
    length: end - start,
  }
}

///|
fn RuleTarget::complete(
  self : RuleTarget,
  query : @session.CompletionQuery,
) -> Array[@session.CompletionCandidate] raise @session.TargetError {
  guard query.frame is Some(handle) else { return [] }
  let frame = self.machine().frame(Some(handle))
  let position = completion_prefix(query.text, query.line, query.column)
  let context = match position.scope {
    Some(scope) => frame.eval(parse_expression(scope[:]))
    None => Json::object(frame.locals)
  }
  let candidates : Array[@session.CompletionCandidate] = []
  if context is Object(fields) {
    for name, item in fields {
      if name.has_prefix(position.prefix) && @expression.is_identifier(name) {
        let (_, detail, _, _) = describe(item)
        candidates.push({
          label: name,
          replacement: None,
          detail: Some(detail),
          start: Some(position.start),
          length: Some(position.length.to_int64()),
        })
      }
    }
  }
  candidates.sort_by_key(candidate => candidate.label)
  candidates
}

///|
impl @session.DebugTarget for RuleTarget with fn inspection_providers(self) {
  {
    evaluate: Some(query => self.evaluate(query)),
    assign_variable: Some(query => self.set_variable(query)),
    assign_expression: Some(query => self.set_expression(query)),
    complete: Some(query => self.complete(query)),
    exception_info: Some(_ => self.exception_snapshot()),
  }
}
