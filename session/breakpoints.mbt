///|
fn incoming_position(
  value : Int64,
  one_based : Bool,
) -> Int64 raise RequestFailure {
  guard !one_based || value > 0L else {
    raise RequestFailure(
      "invalidArguments", "源码位置小于约定的起始位置",
    )
  }
  if one_based {
    value
  } else {
    value + 1L
  }
}

///|
fn outgoing_position(value : Int64, one_based : Bool) -> Json raise TargetError {
  let adjusted = if one_based { value } else { value - 1L }
  guard value > 0L && adjusted <= 9007199254740991L else {
    raise TargetError("目标返回了无效的源码位置")
  }
  Json::number(adjusted.to_double())
}

///|
fn Session::breakpoint_locations(
  self : Session,
  req : @protocol.Request,
) -> Json raise {
  guard self.location_provider is Some(provider) else {
    raise RequestFailure("notSupported", "目标不支持查询断点位置")
  }
  self.require_configuration()
  let args : @protocol.BreakpointLocationsArguments = arguments(req)
  guard args.source.path is Some(path) && !path.is_empty() else {
    raise RequestFailure(
      "invalidArguments", "查询断点位置需要本地源码路径",
    )
  }
  let (lines_at_one, columns_at_one) = self.coordinates()
  let range : BreakpointRange = {
    line: incoming_position(args.line, lines_at_one),
    column: args.column
    .map(value => incoming_position(value, columns_at_one))
    .unwrap_or(1L),
    end_line: incoming_position(
      args.end_line.unwrap_or(args.line),
      lines_at_one,
    ),
    end_column: args.end_column.map(value => {
      incoming_position(value, columns_at_one)
    }),
  }
  guard range.end_line >= range.line &&
    (
      range.end_line != range.line ||
      range.end_column.map(end => end >= range.column).unwrap_or(true)
    ) else {
    raise RequestFailure(
      "invalidArguments", "查询范围的终点早于起点",
    )
  }
  let locations : Array[Json] = []
  for position in provider(path, range) {
    let line = outgoing_position(position.line, lines_at_one)
    let column = outgoing_position(
      position.column.unwrap_or(1L),
      columns_at_one,
    )
    if range.contains(position) {
      locations.push({ "line": line, "column": column })
    }
  }
  self.reply(req, body={ "breakpoints": Json::array(locations) })
}

///|
fn Session::set_breakpoints(
  self : Session,
  req : @protocol.Request,
) -> Json raise {
  self.require_configuration()
  let args : @protocol.SetBreakpointsArguments = arguments(req)
  guard args.source.path is Some(path) && !path.is_empty() else {
    raise RequestFailure(
      "invalidArguments", "行断点需要本地源码路径",
    )
  }
  let valid : Array[ConditionalBreakpointSpec] = []
  let skipped = []
  let (lines_at_one, columns_at_one) = self.coordinates()
  match args.breakpoints {
    Some(items) =>
      for bp in items {
        let unsupported = (
            bp.condition is Some(_) && self.condition_provider is None
          ) ||
          bp.hit_condition is Some(_) ||
          bp.log_message is Some(_) ||
          bp.mode is Some(_)
        skipped.push(unsupported)
        if !unsupported {
          valid.push({
            position: {
              line: incoming_position(bp.line, lines_at_one),
              column: bp.column.map(value => {
                incoming_position(value, columns_at_one)
              }),
            },
            condition: bp.condition,
          })
        }
      }
    None =>
      for line in args.lines.unwrap_or([]) {
        skipped.push(false)
        valid.push({
          position: {
            line: incoming_position(line, lines_at_one),
            column: None,
          },
          condition: None,
        })
      }
  }
  let installed = match self.condition_provider {
    Some(provider) => provider(path, valid)
    None => self.target.set_breakpoints(path, valid.map(item => item.position))
  }
  guard installed.length() == valid.length() else {
    raise TargetError("断点结果数与提交的断点数不一致")
  }
  let breakpoints : Array[Json] = []
  let mut next = 0
  for unsupported in skipped {
    if unsupported {
      breakpoints.push({
        "verified": false,
        "message": "不支持该断点选项",
      })
    } else {
      let bp = installed[next]
      next += 1
      let fields : Map[String, Json] = {
        "verified": Json::boolean(bp.verified),
      }
      if bp.id is Some(id) {
        fields.set("id", @json.to_json(id))
      }
      if bp.line is Some(line) {
        fields.set("line", outgoing_position(line, lines_at_one))
      }
      if bp.column is Some(column) {
        fields.set("column", outgoing_position(column, columns_at_one))
      }
      if bp.message is Some(message) {
        fields.set("message", Json::string(message))
      }
      breakpoints.push(Json::object(fields))
    }
  }
  self.reply(req, body={ "breakpoints": Json::array(breakpoints) })
}
