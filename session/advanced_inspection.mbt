///|
fn Session::encode_value(
  self : Session,
  value : Variable,
  key : String,
) -> Map[String, Json] raise TargetError {
  let reference = match value.children {
    Some(handle) => self.variable_refs.id(handle)
    None => 0
  }
  let fields : Map[String, Json] = {
    "variablesReference": @json.to_json(reference),
  }
  fields.set(key, Json::string(value.value))
  if self.variable_types && value.type_name is Some(name) {
    fields.set("type", Json::string(name))
  }
  if self.variable_paging {
    if value.named_count is Some(count) {
      fields.set("namedVariables", count_to_json(count.to_int64()))
    }
    if value.indexed_count is Some(count) {
      fields.set("indexedVariables", count_to_json(count.to_int64()))
    }
  }
  fields
}

///|
fn Session::assign_variable(
  self : Session,
  req : @protocol.Request,
) -> Json raise {
  guard self.inspection.assign_variable is Some(provider) else {
    raise RequestFailure("notSupported", "目标不支持修改变量")
  }
  self.require_stopped()
  let args : @protocol.SetVariableArguments = arguments(req)
  let update = provider({
    container: self.variable_refs.handle(args.variables_reference),
    name: args.name,
    expression: args.value,
  })
  self.assignment_reply(req, update)
}

///|
fn Session::assign_expression(
  self : Session,
  req : @protocol.Request,
) -> Json raise {
  guard self.inspection.assign_expression is Some(provider) else {
    raise RequestFailure("notSupported", "目标不支持表达式赋值")
  }
  self.require_stopped()
  let args : @protocol.SetExpressionArguments = arguments(req)
  let update = provider({
    frame: args.frame_id.map(id => self.frame_refs.handle(id)),
    expression: args.expression,
    value: args.value,
  })
  self.assignment_reply(req, update)
}

///|
fn Session::assignment_reply(
  self : Session,
  req : @protocol.Request,
  update : VariableUpdate,
) -> Json raise {
  for handle in update.invalidated {
    self.variable_refs.forget(handle)
  }
  self.reply(req, body=Json::object(self.encode_value(update.value, "value")))
}

///|
fn Session::complete(self : Session, req : @protocol.Request) -> Json raise {
  guard self.inspection.complete is Some(provider) else {
    raise RequestFailure("notSupported", "目标不支持表达式补全")
  }
  self.require_stopped()
  let args : @protocol.CompletionsArguments = arguments(req)
  let (lines_at_one, columns_at_one) = self.coordinates()
  let candidates = provider({
    frame: args.frame_id.map(id => self.frame_refs.handle(id)),
    text: args.text,
    line: args.line
    .map(line => incoming_position(line, lines_at_one))
    .unwrap_or(1L),
    column: incoming_position(args.column, columns_at_one),
  })
  let column_base = if columns_at_one { 1L } else { 0L }
  let targets : Array[@protocol.CompletionItem] = candidates.map(candidate => {
    let start = candidate.start.map(offset => {
      guard offset >= 0L && offset <= 4294967295L - column_base else {
        raise TargetError("补全替换起点超出协议范围")
      }
      offset + column_base
    })
    {
      label: candidate.label,
      text: candidate.replacement,
      sort_text: None,
      detail: candidate.detail,
      type_: None,
      start,
      length: candidate.length,
      selection_start: None,
      selection_length: None,
    }
  })
  let response : @protocol.CompletionsResponseBody = { targets, }
  self.reply(req, body=response.to_json())
}

///|
fn Session::exception_info(
  self : Session,
  req : @protocol.Request,
) -> Json raise {
  guard self.inspection.exception_info is Some(provider) else {
    raise RequestFailure("notSupported", "目标不提供异常快照")
  }
  self.require_stopped()
  let args : @protocol.ExceptionInfoArguments = arguments(req)
  self.require_thread(args.thread_id)
  guard provider(args.thread_id) is Some(snapshot) else {
    raise RequestFailure("invalidState", "当前线程没有异常快照")
  }
  let response : @protocol.ExceptionInfoResponseBody = {
    exception_id: snapshot.id,
    description: snapshot.description,
    break_mode: if snapshot.handled {
      Always
    } else {
      Unhandled
    },
    details: Some({
      message: snapshot.description,
      type_name: Some(snapshot.id),
      full_type_name: None,
      evaluate_name: None,
      stack_trace: snapshot.stack_trace,
      inner_exception: None,
    }),
  }
  self.reply(req, body=response.to_json())
}
