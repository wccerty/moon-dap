///|
pub(all) enum StartMode {
  Launch
  Attach
}

///|
pub(all) enum DisconnectMode {
  Terminate
  Detach
}

///|
pub(all) enum ResumeMode {
  Continue
  StepIn
  StepOver
  StepOut
}

///|
pub(all) enum StopReason {
  Breakpoint
  Step
  Pause
  Entry
  Exception
}

///|
pub(all) struct Stop {
  reason : StopReason
  thread_id : Int32
  description : String?
  breakpoint_ids : Array[Int32]
}

///|
pub(all) enum TargetEvent {
  Stopped(Stop)
  Output(String, String)
  Exited(Int32)
  Terminated
  Continued(Int32)
  ThreadStarted(Int32)
  ThreadExited(Int32)
}

///|
pub(all) suberror TargetError {
  TargetError(String)
} derive(Debug)

///|
pub extend TargetError with @debug.Debug::{to_repr}

///|
struct EventSink {
  publish : (TargetEvent) -> Unit raise TargetError
}

///|
/// 在会话所属的调度器中调用。事件在当前请求的响应之后发送。
pub fn EventSink::emit(
  self : EventSink,
  event : TargetEvent,
) -> Unit raise TargetError {
  (self.publish)(event)
}

///|
pub(all) struct BreakpointSpec {
  line : Int64
  column : Int64?
}

///|
pub(all) struct BreakpointResult {
  id : Int32?
  verified : Bool
  line : Int64?
  column : Int64?
  message : String?
}

///|
pub(all) struct SourceLocation {
  path : String
  line : Int64
  column : Int64?
}

///|
pub(all) struct Thread {
  id : Int32
  name : String
}

///|
pub(all) struct Frame {
  handle : Int32
  name : String
  location : SourceLocation?
}

///|
pub(all) struct Scope {
  name : String
  handle : Int32
  expensive : Bool
}

///|
pub(all) struct Variable {
  name : String
  value : String
  type_name : String?
  children : Int32?
  named_count : Int64?
  indexed_count : Int64?
}

///|
pub(all) struct Page {
  start : Int64
  count : Int64?
}

///|
/// 分页计数省略或为 0 时，取至末尾。
pub fn[T] Page::slice(self : Page, items : Array[T]) -> Array[T] {
  let length = items.length().to_int64()
  let start = self.start.max(0L).min(length)
  let end = match self.count {
    Some(n) if n > 0L => start + n.min(length - start)
    _ => length
  }
  items[start.to_int():end.to_int()].to_owned()
}

///|
pub(all) enum VariableFilter {
  All
  Named
  Indexed
}

///|
pub(all) struct VariableQuery {
  page : Page
  filter : VariableFilter
}

///|
pub(all) struct StackPage {
  frames : Array[Frame]
  total : Int64
}

///|
/// 一个目标实例只服务一个会话。坐标从 1 开始，句柄在本次暂停内有效。
/// prepare 在配置完成前保留目标，poll 每次只推进有界工作并及时返回。
pub(open) trait DebugTarget {
  async fn prepare(Self, StartMode, Json, EventSink) -> Unit
  fn start(Self) -> Unit raise TargetError
  fn set_breakpoints(Self, String, Array[BreakpointSpec]) -> Array[
    BreakpointResult,
  ] raise TargetError
  fn resume_execution(Self, Int32, ResumeMode) -> Unit raise TargetError
  fn pause(Self, Int32) -> Unit raise TargetError
  fn threads(Self) -> Array[Thread] raise TargetError
  fn stack_trace(Self, Int32, Page) -> StackPage raise TargetError
  fn scopes(Self, Int32) -> Array[Scope] raise TargetError
  fn variables(Self, Int32, VariableQuery) -> Array[Variable] raise TargetError
  fn poll(Self) -> Unit raise TargetError
  async fn disconnect(Self, DisconnectMode) -> Unit
}
