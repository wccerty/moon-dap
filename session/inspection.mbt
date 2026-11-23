///|
fn count_to_json(n : Int64) -> Json raise TargetError {
  guard n >= 0L && n <= 9007199254740991L else {
    raise TargetError("目标返回了无效的数量")
  }
  Json::number(n.to_double())
}

///|
fn Session::threads(self : Session, req : @protocol.Request) -> Json raise {
  guard self.active() || self.phase == Terminated else {
    raise RequestFailure("invalidState", "目标尚未启动")
  }
  let threads : Array[@protocol.Thread] = if self.phase == Terminated {
    []
  } else {
    self.target.threads().map(thread => { id: thread.id, name: thread.name, })
  }
  self.reply(req, body={ "threads": @json.to_json(threads) })
}

///|
fn Session::stack_trace(self : Session, req : @protocol.Request) -> Json raise {
  self.require_stopped()
  let args : @protocol.StackTraceArguments = arguments(req)
  self.require_thread(args.thread_id)
  let stack = self.target.stack_trace(args.thread_id, {
    start: args.start_frame.unwrap_or(0L),
    count: args.levels,
  })
  let frames : Array[Json] = []
  let sources = self.virtual_sources()
  let (lines_at_one, columns_at_one) = self.coordinates()
  for frame in stack.frames {
    let fields : Map[String, Json] = {
      "id": @json.to_json(self.frame_refs.id(frame.handle)),
      "name": Json::string(frame.name),
      "line": @json.to_json(0),
      "column": @json.to_json(0),
    }
    if frame.location is Some(loc) {
      let source = self.source_for_path(sources, loc.path)
      fields.set("source", source)
      fields.set("line", outgoing_position(loc.line, lines_at_one))
      if loc.column is Some(column) {
        fields.set("column", outgoing_position(column, columns_at_one))
      }
    }
    frames.push(Json::object(fields))
  }
  self.reply(req, body={
    "stackFrames": Json::array(frames),
    "totalFrames": count_to_json(stack.total),
  })
}

///|
fn Session::scopes(self : Session, req : @protocol.Request) -> Json raise {
  self.require_stopped()
  let args : @protocol.ScopesArguments = arguments(req)
  let scopes : Array[Json] = self.target
    .scopes(self.frame_refs.handle(args.frame_id))
    .map(scope => {
      "name": scope.name,
      "variablesReference": self.variable_refs.id(scope.handle),
      "expensive": scope.expensive,
    })
  self.reply(req, body={ "scopes": Json::array(scopes) })
}

///|
fn Session::variables(self : Session, req : @protocol.Request) -> Json raise {
  self.require_stopped()
  let args : @protocol.VariablesArguments = arguments(req)
  let values = self.target.variables(
    self.variable_refs.handle(args.variables_reference),
    {
      page: { start: args.start.unwrap_or(0L), count: args.count, },
      filter: match args.filter {
        Some(Indexed) => Indexed
        Some(Named) => Named
        None => All
      },
    },
  )
  let variables : Array[Json] = []
  for value in values {
    let fields = self.encode_value(value, "value")
    fields.set("name", Json::string(value.name))
    variables.push(Json::object(fields))
  }
  self.reply(req, body={ "variables": Json::array(variables) })
}

///|
fn Session::evaluate(self : Session, req : @protocol.Request) -> Json raise {
  guard self.evaluate_provider is Some(_) || self.inspection.evaluate is Some(_) else {
    raise RequestFailure("notSupported", "目标不支持表达式求值")
  }
  self.require_stopped()
  let args : @protocol.EvaluateArguments = arguments(req)
  let frame = args.frame_id.map(id => self.frame_refs.handle(id))
  if self.inspection.evaluate is Some(provider) {
    let value = provider({
      frame,
      expression: args.expression,
      context: args.context,
    })
    return self.reply(
      req,
      body=Json::object(self.encode_value(value, "result")),
    )
  }
  guard! self.evaluate_provider is Some(provider)
  let value = provider(frame, args.expression)
  self.reply(req, body={ "result": value, "variablesReference": 0 })
}
