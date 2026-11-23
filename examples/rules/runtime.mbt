///|
priv struct Frame {
  id : Int32
  rule : Rule
  locals : Map[String, Json]
  result_binding : String?
  mut cursor : Int32
  mut entered : Bool
}

///|
priv struct Runtime {
  program : Program
  stack : Array[Frame]
  mut next_frame_id : Int32
  mut instructions : Int32
}

///|
priv enum Execution {
  Advanced
  Printed(String)
  Finished(Json)
}

///|
fn Runtime::new(program : Program) -> Runtime {
  let entry : Frame = {
    id: 1,
    rule: program.entry,
    locals: Map([(program.entry.parameter, program.input)]),
    result_binding: None,
    cursor: 0,
    entered: false,
  }
  { program, stack: [entry], next_frame_id: 2, instructions: 0, }
}

///|
fn Runtime::frame(
  self : Runtime,
  id : Int32?,
) -> Frame raise @session.TargetError {
  let found = match id {
    Some(handle) => self.stack.iter().find_first(frame => frame.id == handle)
    None => self.stack.last()
  }
  guard found is Some(frame) else {
    raise @session.TargetError("找不到调用帧")
  }
  frame
}

///|
fn Frame::eval(
  self : Frame,
  expression : @expression.Expression,
) -> Json raise @session.TargetError {
  expression.evaluate(name => self.locals.get(name)) catch {
    error => raise @session.TargetError(error.message())
  }
}

///|
fn Frame::predicate(
  self : Frame,
  expression : @expression.Expression,
) -> Bool raise @session.TargetError {
  let value = self.eval(expression)
  @expression.require_bool(value) catch {
    error => raise @session.TargetError(error.message())
  }
}

///|
fn Frame::jump(self : Frame, label : String) -> Unit raise @session.TargetError {
  guard self.rule.labels.get(label) is Some(address) else {
    raise @session.TargetError("找不到标签 \{label}")
  }
  self.cursor = address
}

///|
fn Runtime::enter(
  self : Runtime,
  name : String,
  argument : Json,
  result_binding : String,
) -> Unit raise @session.TargetError {
  guard self.stack.length() < 128 else {
    raise @session.TargetError("规则调用深度超出限制")
  }
  guard self.program.rules.get(name) is Some(rule) else {
    raise @session.TargetError("规则不存在 \{name}")
  }
  self.stack.push({
    id: self.next_frame_id,
    rule,
    locals: Map([(rule.parameter, argument)]),
    result_binding: Some(result_binding),
    cursor: 0,
    entered: false,
  })
  self.next_frame_id += 1
}

///|
fn Runtime::leave(self : Runtime, frame : Frame, result : Json) -> Execution {
  ignore(self.stack.pop())
  match (self.stack.last(), frame.result_binding) {
    (Some(caller), Some(binding)) => {
      caller.locals.set(binding, result)
      Advanced
    }
    _ => Finished(result)
  }
}

///|
fn Runtime::execute(self : Runtime) -> Execution raise @session.TargetError {
  guard self.instructions < 100000 else {
    raise @session.TargetError("规则执行步数超出限制")
  }
  let current = self.frame(None)
  guard current.rule.code.get(current.cursor) is Some(instruction) else {
    return self.leave(current, Json::null())
  }
  self.instructions += 1
  let next = current.cursor + 1
  match instruction.operation {
    Bind(name, expr) => current.locals.set(name, current.eval(expr))
    Load(name, value) => current.locals.set(name, value)
    Call(binding, name, argument) =>
      self.enter(name, current.eval(argument), binding)
    Return(expr) => return self.leave(current, current.eval(expr))
    Emit(expr) => {
      let output = current.eval(expr).stringify()
      current.cursor = next
      return Printed(output)
    }
    Jump(label) => {
      current.jump(label)
      return Advanced
    }
    Branch(expr, label) if current.predicate(expr) => {
      current.jump(label)
      return Advanced
    }
    Branch(_, _) => ()
    Assert(expr) => {
      guard current.predicate(expr) else {
        raise @session.TargetError("规则断言失败")
      }
    }
  }
  current.cursor = next
  Advanced
}

///|
fn Frame::position(self : Frame, caller : Bool) -> @session.SourceLocation? {
  let index = if caller { self.cursor - 1 } else { self.cursor }
  self.rule.code
  .get(index)
  .map(instruction => {
    path: self.rule.source.path,
    line: instruction.line,
    column: Some(1L),
  })
}
