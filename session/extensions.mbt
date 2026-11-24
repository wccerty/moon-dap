///|
/// 动态源码的 handle 由目标分配，在一个运行实例中保持稳定。
/// path 是目标用于断点和调用栈的标识，可省略以表示只读源码。
pub(all) struct VirtualSource {
  handle : Int32
  name : String
  path : String?
}

///|
pub(all) struct SourceText {
  content : String
  mime_type : String?
}

///|
pub(all) struct SourceProvider {
  list : () -> Array[VirtualSource] raise TargetError
  read : (Int32) -> SourceText raise TargetError
}

///|
pub(all) struct EvaluationQuery {
  /// 缺省时在目标的全局作用域求值。
  frame : Int32?
  expression : String
  context : String?
}

///|
pub(all) struct VariableAssignment {
  container : Int32
  name : String
  expression : String
}

///|
pub(all) struct ExpressionAssignment {
  /// 缺省时在目标的全局作用域赋值。
  frame : Int32?
  expression : String
  value : String
}

///|
/// 目标返回新值和被替换容器及其子容器的原有句柄。
pub(all) struct VariableUpdate {
  value : Variable
  invalidated : Array[Int32]
}

///|
/// 行列从 1 开始。列以 UTF-16 代码单元计数。
pub(all) struct CompletionQuery {
  /// 缺省时查询目标的全局作用域。
  frame : Int32?
  text : String
  line : Int64
  column : Int64
}

///|
/// 替换起点为整个输入文本的 0 基偏移，起点和长度以 UTF-16 代码单元计数。
/// 会话按客户端的列基数转换起点。
pub(all) struct CompletionCandidate {
  label : String
  replacement : String?
  detail : String?
  start : Int64?
  length : Int64?
}

///|
pub(all) struct ExceptionSnapshot {
  id : String
  description : String?
  stack_trace : String?
  handled : Bool
}

///|
pub(all) struct InspectionProviders {
  evaluate : ((EvaluationQuery) -> Variable raise TargetError)?
  assign_variable : ((VariableAssignment) -> VariableUpdate raise TargetError)?
  assign_expression : ((ExpressionAssignment) -> VariableUpdate raise TargetError)?
  complete : ((CompletionQuery) -> Array[CompletionCandidate] raise TargetError)?
  exception_info : ((Int32) -> ExceptionSnapshot? raise TargetError)?
}

///|
pub fn InspectionProviders::new() -> InspectionProviders {
  {
    evaluate: None,
    assign_variable: None,
    assign_expression: None,
    complete: None,
    exception_info: None,
  }
}

///|
/// 观察条件、命中次数和日志由目标使用自己的运行时语法解释。
pub(all) struct LineBreakpoint {
  position : BreakpointSpec
  condition : String?
  hit_condition : String?
  log_message : String?
}

///|
pub(all) struct FunctionBreakpoint {
  name : String
  condition : String?
  hit_condition : String?
}

///|
pub(all) struct FunctionBreakpointResult {
  breakpoint : BreakpointResult
  source_path : String?
}

///|
pub(all) struct BreakpointProviders {
  replace_lines : ((String, Array[LineBreakpoint]) -> Array[BreakpointResult] raise TargetError)?
  replace_functions : ((Array[FunctionBreakpoint]) -> Array[
    FunctionBreakpointResult,
  ] raise TargetError)?
  hit_conditions : Bool
  log_points : Bool
}

///|
pub fn BreakpointProviders::new() -> BreakpointProviders {
  {
    replace_lines: None,
    replace_functions: None,
    hit_conditions: false,
    log_points: false,
  }
}

///|
fn Session::add_extension_capabilities(
  self : Session,
  capabilities : Map[String, Json],
) -> Unit {
  let inspection = self.inspection
  let breakpoints = self.breakpoint_providers
  if self.source_provider is Some(_) {
    capabilities.set("supportsLoadedSourcesRequest", Json::boolean(true))
  }
  if inspection.evaluate is Some(_) {
    capabilities.set("supportsEvaluateForHovers", Json::boolean(true))
  }
  if inspection.assign_variable is Some(_) {
    capabilities.set("supportsSetVariable", Json::boolean(true))
  }
  if inspection.assign_expression is Some(_) {
    capabilities.set("supportsSetExpression", Json::boolean(true))
  }
  if inspection.complete is Some(_) {
    capabilities.set("supportsCompletionsRequest", Json::boolean(true))
  }
  if inspection.exception_info is Some(_) {
    capabilities.set("supportsExceptionInfoRequest", Json::boolean(true))
  }
  if breakpoints.replace_functions is Some(_) {
    capabilities.set("supportsFunctionBreakpoints", Json::boolean(true))
  }
  if breakpoints.replace_lines is Some(_) {
    capabilities.set("supportsConditionalBreakpoints", Json::boolean(true))
    if breakpoints.log_points {
      capabilities.set("supportsLogPoints", Json::boolean(true))
    }
  }
  if breakpoints.hit_conditions &&
    (
      breakpoints.replace_lines is Some(_) ||
      breakpoints.replace_functions is Some(_)
    ) {
    capabilities.set("supportsHitConditionalBreakpoints", Json::boolean(true))
  }
}
