// 由 scripts/generate_protocol.py 生成，请勿直接修改。
// 来源 Microsoft Debug Adapter Protocol，Copyright (c) Microsoft Corporation.
// 提交 d2387e875a1ec4c2ed9964edea22617c81651cc0，见 vendor/dap/License-code.txt。

///|
pub(all) struct ProtocolMessage {
  seq : Int32
  type_ : String
}

///|
pub impl ToJson for ProtocolMessage with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", @json.to_json(self.type_))
  Json::object(fields)
}

///|
pub extend ProtocolMessage with ToJson::{to_json}

///|
pub impl @json.FromJson for ProtocolMessage with fn from_json(value, path) {
  let fields = object(value, path)
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    type_: required(fields, "type", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ProtocolMessage with @json.FromJson::{from_json}

///|
pub(all) struct Request {
  seq : Int32
  command : String
  arguments : Json?
}

///|
pub impl ToJson for Request with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", @json.to_json(self.command))
  if self.arguments is Some(item) {
    fields.set("arguments", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend Request with ToJson::{to_json}

///|
pub impl @json.FromJson for Request with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    arguments: optional(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend Request with @json.FromJson::{from_json}

///|
pub(all) struct Event {
  seq : Int32
  event : String
  body : Json?
}

///|
pub impl ToJson for Event with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("event"))
  fields.set("event", @json.to_json(self.event))
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend Event with ToJson::{to_json}

///|
pub impl @json.FromJson for Event with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => literal(value, path, "event"))
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    event: required(fields, "event", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend Event with @json.FromJson::{from_json}

///|
pub(all) struct Response {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Json?
}

///|
pub impl ToJson for Response with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend Response with ToJson::{to_json}

///|
pub impl @json.FromJson for Response with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend Response with @json.FromJson::{from_json}

///|
pub(all) struct ErrorResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : ErrorResponseBody
}

///|
pub impl ToJson for ErrorResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend ErrorResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for ErrorResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ErrorResponse with @json.FromJson::{from_json}

///|
pub(all) struct CancelRequest {
  seq : Int32
  arguments : CancelArguments?
}

///|
pub impl ToJson for CancelRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("cancel"))
  if self.arguments is Some(item) {
    fields.set("arguments", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend CancelRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for CancelRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "cancel")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: optional(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend CancelRequest with @json.FromJson::{from_json}

///|
pub(all) struct CancelArguments {
  request_id : Int32?
  progress_id : String?
}

///|
pub impl ToJson for CancelArguments with fn to_json(self) {
  let fields = Map([])
  if self.request_id is Some(item) {
    fields.set("requestId", @json.to_json(item))
  }
  if self.progress_id is Some(item) {
    fields.set("progressId", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend CancelArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for CancelArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    request_id: optional(fields, "requestId", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    progress_id: optional(fields, "progressId", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend CancelArguments with @json.FromJson::{from_json}

///|
pub(all) struct CancelResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Json?
}

///|
pub impl ToJson for CancelResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend CancelResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for CancelResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend CancelResponse with @json.FromJson::{from_json}

///|
pub(all) struct InitializedEvent {
  seq : Int32
  body : Json?
}

///|
pub impl ToJson for InitializedEvent with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("event"))
  fields.set("event", Json::string("initialized"))
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend InitializedEvent with ToJson::{to_json}

///|
pub impl @json.FromJson for InitializedEvent with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => literal(value, path, "event"))
  required(fields, "event", path, (value, path) => {
    literal(value, path, "initialized")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend InitializedEvent with @json.FromJson::{from_json}

///|
pub(all) struct StoppedEvent {
  seq : Int32
  body : StoppedEventBody
}

///|
pub impl ToJson for StoppedEvent with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("event"))
  fields.set("event", Json::string("stopped"))
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend StoppedEvent with ToJson::{to_json}

///|
pub impl @json.FromJson for StoppedEvent with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => literal(value, path, "event"))
  required(fields, "event", path, (value, path) => {
    literal(value, path, "stopped")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StoppedEvent with @json.FromJson::{from_json}

///|
pub(all) struct ContinuedEvent {
  seq : Int32
  body : ContinuedEventBody
}

///|
pub impl ToJson for ContinuedEvent with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("event"))
  fields.set("event", Json::string("continued"))
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend ContinuedEvent with ToJson::{to_json}

///|
pub impl @json.FromJson for ContinuedEvent with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => literal(value, path, "event"))
  required(fields, "event", path, (value, path) => {
    literal(value, path, "continued")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ContinuedEvent with @json.FromJson::{from_json}

///|
pub(all) struct ExitedEvent {
  seq : Int32
  body : ExitedEventBody
}

///|
pub impl ToJson for ExitedEvent with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("event"))
  fields.set("event", Json::string("exited"))
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend ExitedEvent with ToJson::{to_json}

///|
pub impl @json.FromJson for ExitedEvent with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => literal(value, path, "event"))
  required(fields, "event", path, (value, path) => {
    literal(value, path, "exited")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ExitedEvent with @json.FromJson::{from_json}

///|
pub(all) struct TerminatedEvent {
  seq : Int32
  body : TerminatedEventBody?
}

///|
pub impl ToJson for TerminatedEvent with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("event"))
  fields.set("event", Json::string("terminated"))
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend TerminatedEvent with ToJson::{to_json}

///|
pub impl @json.FromJson for TerminatedEvent with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => literal(value, path, "event"))
  required(fields, "event", path, (value, path) => {
    literal(value, path, "terminated")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend TerminatedEvent with @json.FromJson::{from_json}

///|
pub(all) struct ThreadEvent {
  seq : Int32
  body : ThreadEventBody
}

///|
pub impl ToJson for ThreadEvent with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("event"))
  fields.set("event", Json::string("thread"))
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend ThreadEvent with ToJson::{to_json}

///|
pub impl @json.FromJson for ThreadEvent with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => literal(value, path, "event"))
  required(fields, "event", path, (value, path) => {
    literal(value, path, "thread")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ThreadEvent with @json.FromJson::{from_json}

///|
pub(all) struct OutputEvent {
  seq : Int32
  body : OutputEventBody
}

///|
pub impl ToJson for OutputEvent with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("event"))
  fields.set("event", Json::string("output"))
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend OutputEvent with ToJson::{to_json}

///|
pub impl @json.FromJson for OutputEvent with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => literal(value, path, "event"))
  required(fields, "event", path, (value, path) => {
    literal(value, path, "output")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend OutputEvent with @json.FromJson::{from_json}

///|
pub(all) struct BreakpointEvent {
  seq : Int32
  body : BreakpointEventBody
}

///|
pub impl ToJson for BreakpointEvent with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("event"))
  fields.set("event", Json::string("breakpoint"))
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend BreakpointEvent with ToJson::{to_json}

///|
pub impl @json.FromJson for BreakpointEvent with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => literal(value, path, "event"))
  required(fields, "event", path, (value, path) => {
    literal(value, path, "breakpoint")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend BreakpointEvent with @json.FromJson::{from_json}

///|
pub(all) struct ModuleEvent {
  seq : Int32
  body : ModuleEventBody
}

///|
pub impl ToJson for ModuleEvent with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("event"))
  fields.set("event", Json::string("module"))
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend ModuleEvent with ToJson::{to_json}

///|
pub impl @json.FromJson for ModuleEvent with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => literal(value, path, "event"))
  required(fields, "event", path, (value, path) => {
    literal(value, path, "module")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ModuleEvent with @json.FromJson::{from_json}

///|
pub(all) struct LoadedSourceEvent {
  seq : Int32
  body : LoadedSourceEventBody
}

///|
pub impl ToJson for LoadedSourceEvent with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("event"))
  fields.set("event", Json::string("loadedSource"))
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend LoadedSourceEvent with ToJson::{to_json}

///|
pub impl @json.FromJson for LoadedSourceEvent with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => literal(value, path, "event"))
  required(fields, "event", path, (value, path) => {
    literal(value, path, "loadedSource")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend LoadedSourceEvent with @json.FromJson::{from_json}

///|
pub(all) struct ProcessEvent {
  seq : Int32
  body : ProcessEventBody
}

///|
pub impl ToJson for ProcessEvent with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("event"))
  fields.set("event", Json::string("process"))
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend ProcessEvent with ToJson::{to_json}

///|
pub impl @json.FromJson for ProcessEvent with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => literal(value, path, "event"))
  required(fields, "event", path, (value, path) => {
    literal(value, path, "process")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ProcessEvent with @json.FromJson::{from_json}

///|
pub(all) struct CapabilitiesEvent {
  seq : Int32
  body : CapabilitiesEventBody
}

///|
pub impl ToJson for CapabilitiesEvent with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("event"))
  fields.set("event", Json::string("capabilities"))
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend CapabilitiesEvent with ToJson::{to_json}

///|
pub impl @json.FromJson for CapabilitiesEvent with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => literal(value, path, "event"))
  required(fields, "event", path, (value, path) => {
    literal(value, path, "capabilities")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend CapabilitiesEvent with @json.FromJson::{from_json}

///|
pub(all) struct ProgressStartEvent {
  seq : Int32
  body : ProgressStartEventBody
}

///|
pub impl ToJson for ProgressStartEvent with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("event"))
  fields.set("event", Json::string("progressStart"))
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend ProgressStartEvent with ToJson::{to_json}

///|
pub impl @json.FromJson for ProgressStartEvent with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => literal(value, path, "event"))
  required(fields, "event", path, (value, path) => {
    literal(value, path, "progressStart")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ProgressStartEvent with @json.FromJson::{from_json}

///|
pub(all) struct ProgressUpdateEvent {
  seq : Int32
  body : ProgressUpdateEventBody
}

///|
pub impl ToJson for ProgressUpdateEvent with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("event"))
  fields.set("event", Json::string("progressUpdate"))
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend ProgressUpdateEvent with ToJson::{to_json}

///|
pub impl @json.FromJson for ProgressUpdateEvent with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => literal(value, path, "event"))
  required(fields, "event", path, (value, path) => {
    literal(value, path, "progressUpdate")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ProgressUpdateEvent with @json.FromJson::{from_json}

///|
pub(all) struct ProgressEndEvent {
  seq : Int32
  body : ProgressEndEventBody
}

///|
pub impl ToJson for ProgressEndEvent with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("event"))
  fields.set("event", Json::string("progressEnd"))
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend ProgressEndEvent with ToJson::{to_json}

///|
pub impl @json.FromJson for ProgressEndEvent with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => literal(value, path, "event"))
  required(fields, "event", path, (value, path) => {
    literal(value, path, "progressEnd")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ProgressEndEvent with @json.FromJson::{from_json}

///|
pub(all) struct InvalidatedEvent {
  seq : Int32
  body : InvalidatedEventBody
}

///|
pub impl ToJson for InvalidatedEvent with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("event"))
  fields.set("event", Json::string("invalidated"))
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend InvalidatedEvent with ToJson::{to_json}

///|
pub impl @json.FromJson for InvalidatedEvent with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => literal(value, path, "event"))
  required(fields, "event", path, (value, path) => {
    literal(value, path, "invalidated")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend InvalidatedEvent with @json.FromJson::{from_json}

///|
pub(all) struct MemoryEvent {
  seq : Int32
  body : MemoryEventBody
}

///|
pub impl ToJson for MemoryEvent with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("event"))
  fields.set("event", Json::string("memory"))
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend MemoryEvent with ToJson::{to_json}

///|
pub impl @json.FromJson for MemoryEvent with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => literal(value, path, "event"))
  required(fields, "event", path, (value, path) => {
    literal(value, path, "memory")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend MemoryEvent with @json.FromJson::{from_json}

///|
pub(all) struct RunInTerminalRequest {
  seq : Int32
  arguments : RunInTerminalRequestArguments
}

///|
pub impl ToJson for RunInTerminalRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("runInTerminal"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend RunInTerminalRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for RunInTerminalRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "runInTerminal")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend RunInTerminalRequest with @json.FromJson::{from_json}

///|
pub(all) struct RunInTerminalRequestArguments {
  kind : RunInTerminalRequestArgumentsKind?
  title : String?
  cwd : String
  args : Array[String]
  env : Map[String, RunInTerminalRequestArgumentsEnvValue]?
  args_can_be_interpreted_by_shell : Bool?
}

///|
pub impl ToJson for RunInTerminalRequestArguments with fn to_json(self) {
  let fields = Map([])
  if self.kind is Some(item) {
    fields.set("kind", @json.to_json(item))
  }
  if self.title is Some(item) {
    fields.set("title", @json.to_json(item))
  }
  fields.set("cwd", @json.to_json(self.cwd))
  fields.set("args", Json::array(self.args.map(item => @json.to_json(item))))
  if self.env is Some(item) {
    fields.set("env", map_to_json(item, item => @json.to_json(item)))
  }
  if self.args_can_be_interpreted_by_shell is Some(item) {
    fields.set("argsCanBeInterpretedByShell", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend RunInTerminalRequestArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for RunInTerminalRequestArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    kind: optional(fields, "kind", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    title: optional(fields, "title", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    cwd: required(fields, "cwd", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    args: required(fields, "args", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
    env: optional(fields, "env", path, (value, path) => {
      map_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
    args_can_be_interpreted_by_shell: optional(
      fields,
      "argsCanBeInterpretedByShell",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
  }
}

///|
pub extend RunInTerminalRequestArguments with @json.FromJson::{from_json}

///|
pub(all) struct RunInTerminalResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : RunInTerminalResponseBody
}

///|
pub impl ToJson for RunInTerminalResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend RunInTerminalResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for RunInTerminalResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend RunInTerminalResponse with @json.FromJson::{from_json}

///|
pub(all) struct StartDebuggingRequest {
  seq : Int32
  arguments : StartDebuggingRequestArguments
}

///|
pub impl ToJson for StartDebuggingRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("startDebugging"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend StartDebuggingRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for StartDebuggingRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "startDebugging")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StartDebuggingRequest with @json.FromJson::{from_json}

///|
pub(all) struct StartDebuggingRequestArguments {
  configuration : Map[String, Json]
  output_presentation : StartDebuggingRequestArgumentsOutputPresentation?
  request : StartDebuggingRequestArgumentsRequest
}

///|
pub impl ToJson for StartDebuggingRequestArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("configuration", @json.to_json(self.configuration))
  if self.output_presentation is Some(item) {
    fields.set("outputPresentation", @json.to_json(item))
  }
  fields.set("request", @json.to_json(self.request))
  Json::object(fields)
}

///|
pub extend StartDebuggingRequestArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for StartDebuggingRequestArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    configuration: required(fields, "configuration", path, (value, path) => {
      object(value, path)
    }),
    output_presentation: optional(fields, "outputPresentation", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
    request: required(fields, "request", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StartDebuggingRequestArguments with @json.FromJson::{from_json}

///|
pub(all) struct StartDebuggingResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Json?
}

///|
pub impl ToJson for StartDebuggingResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend StartDebuggingResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for StartDebuggingResponse with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StartDebuggingResponse with @json.FromJson::{from_json}

///|
pub(all) struct InitializeRequest {
  seq : Int32
  arguments : InitializeRequestArguments
}

///|
pub impl ToJson for InitializeRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("initialize"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend InitializeRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for InitializeRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "initialize")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend InitializeRequest with @json.FromJson::{from_json}

///|
pub(all) struct InitializeRequestArguments {
  client_id : String?
  client_name : String?
  adapter_id : String
  locale : String?
  lines_start_at1 : Bool?
  columns_start_at1 : Bool?
  path_format : String?
  supports_variable_type : Bool?
  supports_variable_paging : Bool?
  supports_run_in_terminal_request : Bool?
  supports_memory_references : Bool?
  supports_progress_reporting : Bool?
  supports_invalidated_event : Bool?
  supports_memory_event : Bool?
  supports_args_can_be_interpreted_by_shell : Bool?
  supports_start_debugging_request : Bool?
  supports_ansi_styling : Bool?
}

///|
pub impl ToJson for InitializeRequestArguments with fn to_json(self) {
  let fields = Map([])
  if self.client_id is Some(item) {
    fields.set("clientID", @json.to_json(item))
  }
  if self.client_name is Some(item) {
    fields.set("clientName", @json.to_json(item))
  }
  fields.set("adapterID", @json.to_json(self.adapter_id))
  if self.locale is Some(item) {
    fields.set("locale", @json.to_json(item))
  }
  if self.lines_start_at1 is Some(item) {
    fields.set("linesStartAt1", @json.to_json(item))
  }
  if self.columns_start_at1 is Some(item) {
    fields.set("columnsStartAt1", @json.to_json(item))
  }
  if self.path_format is Some(item) {
    fields.set("pathFormat", @json.to_json(item))
  }
  if self.supports_variable_type is Some(item) {
    fields.set("supportsVariableType", @json.to_json(item))
  }
  if self.supports_variable_paging is Some(item) {
    fields.set("supportsVariablePaging", @json.to_json(item))
  }
  if self.supports_run_in_terminal_request is Some(item) {
    fields.set("supportsRunInTerminalRequest", @json.to_json(item))
  }
  if self.supports_memory_references is Some(item) {
    fields.set("supportsMemoryReferences", @json.to_json(item))
  }
  if self.supports_progress_reporting is Some(item) {
    fields.set("supportsProgressReporting", @json.to_json(item))
  }
  if self.supports_invalidated_event is Some(item) {
    fields.set("supportsInvalidatedEvent", @json.to_json(item))
  }
  if self.supports_memory_event is Some(item) {
    fields.set("supportsMemoryEvent", @json.to_json(item))
  }
  if self.supports_args_can_be_interpreted_by_shell is Some(item) {
    fields.set("supportsArgsCanBeInterpretedByShell", @json.to_json(item))
  }
  if self.supports_start_debugging_request is Some(item) {
    fields.set("supportsStartDebuggingRequest", @json.to_json(item))
  }
  if self.supports_ansi_styling is Some(item) {
    fields.set("supportsANSIStyling", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend InitializeRequestArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for InitializeRequestArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    client_id: optional(fields, "clientID", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    client_name: optional(fields, "clientName", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    adapter_id: required(fields, "adapterID", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    locale: optional(fields, "locale", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    lines_start_at1: optional(fields, "linesStartAt1", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    columns_start_at1: optional(fields, "columnsStartAt1", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    path_format: optional(fields, "pathFormat", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    supports_variable_type: optional(fields, "supportsVariableType", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
    supports_variable_paging: optional(fields, "supportsVariablePaging", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
    supports_run_in_terminal_request: optional(
      fields,
      "supportsRunInTerminalRequest",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_memory_references: optional(
      fields,
      "supportsMemoryReferences",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_progress_reporting: optional(
      fields,
      "supportsProgressReporting",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_invalidated_event: optional(
      fields,
      "supportsInvalidatedEvent",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_memory_event: optional(fields, "supportsMemoryEvent", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
    supports_args_can_be_interpreted_by_shell: optional(
      fields,
      "supportsArgsCanBeInterpretedByShell",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_start_debugging_request: optional(
      fields,
      "supportsStartDebuggingRequest",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_ansi_styling: optional(fields, "supportsANSIStyling", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
  }
}

///|
pub extend InitializeRequestArguments with @json.FromJson::{from_json}

///|
pub(all) struct InitializeResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Capabilities?
}

///|
pub impl ToJson for InitializeResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend InitializeResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for InitializeResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend InitializeResponse with @json.FromJson::{from_json}

///|
pub(all) struct ConfigurationDoneRequest {
  seq : Int32
  arguments : ConfigurationDoneArguments?
}

///|
pub impl ToJson for ConfigurationDoneRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("configurationDone"))
  if self.arguments is Some(item) {
    fields.set("arguments", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend ConfigurationDoneRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for ConfigurationDoneRequest with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "configurationDone")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: optional(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ConfigurationDoneRequest with @json.FromJson::{from_json}

///|
pub(all) struct ConfigurationDoneArguments {
  additional : Map[String, Json]
}

///|
pub impl ToJson for ConfigurationDoneArguments with fn to_json(self) {
  let fields = extras(self.additional, [])
  Json::object(fields)
}

///|
pub extend ConfigurationDoneArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for ConfigurationDoneArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  { additional: extras(fields, []), }
}

///|
pub extend ConfigurationDoneArguments with @json.FromJson::{from_json}

///|
pub(all) struct ConfigurationDoneResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Json?
}

///|
pub impl ToJson for ConfigurationDoneResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend ConfigurationDoneResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for ConfigurationDoneResponse with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ConfigurationDoneResponse with @json.FromJson::{from_json}

///|
pub(all) struct LaunchRequest {
  seq : Int32
  arguments : LaunchRequestArguments
}

///|
pub impl ToJson for LaunchRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("launch"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend LaunchRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for LaunchRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "launch")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend LaunchRequest with @json.FromJson::{from_json}

///|
pub(all) struct LaunchRequestArguments {
  no_debug : Bool?
  private_restart : Json?
  additional : Map[String, Json]
}

///|
pub impl ToJson for LaunchRequestArguments with fn to_json(self) {
  let fields = extras(self.additional, ["noDebug", "__restart"])
  if self.no_debug is Some(item) {
    fields.set("noDebug", @json.to_json(item))
  }
  if self.private_restart is Some(item) {
    fields.set("__restart", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend LaunchRequestArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for LaunchRequestArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    no_debug: optional(fields, "noDebug", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    private_restart: optional(fields, "__restart", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    additional: extras(fields, ["noDebug", "__restart"]),
  }
}

///|
pub extend LaunchRequestArguments with @json.FromJson::{from_json}

///|
pub(all) struct LaunchResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Json?
}

///|
pub impl ToJson for LaunchResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend LaunchResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for LaunchResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend LaunchResponse with @json.FromJson::{from_json}

///|
pub(all) struct AttachRequest {
  seq : Int32
  arguments : AttachRequestArguments
}

///|
pub impl ToJson for AttachRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("attach"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend AttachRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for AttachRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "attach")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend AttachRequest with @json.FromJson::{from_json}

///|
pub(all) struct AttachRequestArguments {
  private_restart : Json?
  additional : Map[String, Json]
}

///|
pub impl ToJson for AttachRequestArguments with fn to_json(self) {
  let fields = extras(self.additional, ["__restart"])
  if self.private_restart is Some(item) {
    fields.set("__restart", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend AttachRequestArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for AttachRequestArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    private_restart: optional(fields, "__restart", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    additional: extras(fields, ["__restart"]),
  }
}

///|
pub extend AttachRequestArguments with @json.FromJson::{from_json}

///|
pub(all) struct AttachResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Json?
}

///|
pub impl ToJson for AttachResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend AttachResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for AttachResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend AttachResponse with @json.FromJson::{from_json}

///|
pub(all) struct RestartRequest {
  seq : Int32
  arguments : RestartArguments?
}

///|
pub impl ToJson for RestartRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("restart"))
  if self.arguments is Some(item) {
    fields.set("arguments", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend RestartRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for RestartRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "restart")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: optional(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend RestartRequest with @json.FromJson::{from_json}

///|
pub(all) struct RestartArguments {
  arguments : RestartArgumentsArguments?
}

///|
pub impl ToJson for RestartArguments with fn to_json(self) {
  let fields = Map([])
  if self.arguments is Some(item) {
    fields.set("arguments", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend RestartArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for RestartArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    arguments: optional(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend RestartArguments with @json.FromJson::{from_json}

///|
pub(all) struct RestartResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Json?
}

///|
pub impl ToJson for RestartResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend RestartResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for RestartResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend RestartResponse with @json.FromJson::{from_json}

///|
pub(all) struct DisconnectRequest {
  seq : Int32
  arguments : DisconnectArguments?
}

///|
pub impl ToJson for DisconnectRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("disconnect"))
  if self.arguments is Some(item) {
    fields.set("arguments", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend DisconnectRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for DisconnectRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "disconnect")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: optional(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend DisconnectRequest with @json.FromJson::{from_json}

///|
pub(all) struct DisconnectArguments {
  restart : Bool?
  terminate_debuggee : Bool?
  suspend_debuggee : Bool?
}

///|
pub impl ToJson for DisconnectArguments with fn to_json(self) {
  let fields = Map([])
  if self.restart is Some(item) {
    fields.set("restart", @json.to_json(item))
  }
  if self.terminate_debuggee is Some(item) {
    fields.set("terminateDebuggee", @json.to_json(item))
  }
  if self.suspend_debuggee is Some(item) {
    fields.set("suspendDebuggee", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend DisconnectArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for DisconnectArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    restart: optional(fields, "restart", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    terminate_debuggee: optional(fields, "terminateDebuggee", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
    suspend_debuggee: optional(fields, "suspendDebuggee", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend DisconnectArguments with @json.FromJson::{from_json}

///|
pub(all) struct DisconnectResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Json?
}

///|
pub impl ToJson for DisconnectResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend DisconnectResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for DisconnectResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend DisconnectResponse with @json.FromJson::{from_json}

///|
pub(all) struct TerminateRequest {
  seq : Int32
  arguments : TerminateArguments?
}

///|
pub impl ToJson for TerminateRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("terminate"))
  if self.arguments is Some(item) {
    fields.set("arguments", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend TerminateRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for TerminateRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "terminate")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: optional(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend TerminateRequest with @json.FromJson::{from_json}

///|
pub(all) struct TerminateArguments {
  restart : Bool?
}

///|
pub impl ToJson for TerminateArguments with fn to_json(self) {
  let fields = Map([])
  if self.restart is Some(item) {
    fields.set("restart", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend TerminateArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for TerminateArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    restart: optional(fields, "restart", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend TerminateArguments with @json.FromJson::{from_json}

///|
pub(all) struct TerminateResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Json?
}

///|
pub impl ToJson for TerminateResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend TerminateResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for TerminateResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend TerminateResponse with @json.FromJson::{from_json}

///|
pub(all) struct BreakpointLocationsRequest {
  seq : Int32
  arguments : BreakpointLocationsArguments?
}

///|
pub impl ToJson for BreakpointLocationsRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("breakpointLocations"))
  if self.arguments is Some(item) {
    fields.set("arguments", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend BreakpointLocationsRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for BreakpointLocationsRequest with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "breakpointLocations")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: optional(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend BreakpointLocationsRequest with @json.FromJson::{from_json}

///|
pub(all) struct BreakpointLocationsArguments {
  source : Source
  line : Int64
  column : Int64?
  end_line : Int64?
  end_column : Int64?
}

///|
pub impl ToJson for BreakpointLocationsArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("source", @json.to_json(self.source))
  fields.set("line", wide_json(self.line))
  if self.column is Some(item) {
    fields.set("column", wide_json(item))
  }
  if self.end_line is Some(item) {
    fields.set("endLine", wide_json(item))
  }
  if self.end_column is Some(item) {
    fields.set("endColumn", wide_json(item))
  }
  Json::object(fields)
}

///|
pub extend BreakpointLocationsArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for BreakpointLocationsArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    source: required(fields, "source", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    line: required(fields, "line", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    column: optional(fields, "column", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    end_line: optional(fields, "endLine", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    end_column: optional(fields, "endColumn", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
  }
}

///|
pub extend BreakpointLocationsArguments with @json.FromJson::{from_json}

///|
pub(all) struct BreakpointLocationsResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : BreakpointLocationsResponseBody
}

///|
pub impl ToJson for BreakpointLocationsResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend BreakpointLocationsResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for BreakpointLocationsResponse with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend BreakpointLocationsResponse with @json.FromJson::{from_json}

///|
pub(all) struct SetBreakpointsRequest {
  seq : Int32
  arguments : SetBreakpointsArguments
}

///|
pub impl ToJson for SetBreakpointsRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("setBreakpoints"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend SetBreakpointsRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for SetBreakpointsRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "setBreakpoints")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SetBreakpointsRequest with @json.FromJson::{from_json}

///|
pub(all) struct SetBreakpointsArguments {
  source : Source
  breakpoints : Array[SourceBreakpoint]?
  lines : Array[Int64]?
  source_modified : Bool?
}

///|
pub impl ToJson for SetBreakpointsArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("source", @json.to_json(self.source))
  if self.breakpoints is Some(item) {
    fields.set(
      "breakpoints",
      Json::array(item.map(item => @json.to_json(item))),
    )
  }
  if self.lines is Some(item) {
    fields.set("lines", Json::array(item.map(item => wide_json(item))))
  }
  if self.source_modified is Some(item) {
    fields.set("sourceModified", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend SetBreakpointsArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for SetBreakpointsArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    source: required(fields, "source", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    breakpoints: optional(fields, "breakpoints", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
    lines: optional(fields, "lines", path, (value, path) => {
      array_of(value, path, (value, path) => {
        integer(value, path, 0L, 9007199254740991L)
      })
    }),
    source_modified: optional(fields, "sourceModified", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SetBreakpointsArguments with @json.FromJson::{from_json}

///|
pub(all) struct SetBreakpointsResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : SetBreakpointsResponseBody
}

///|
pub impl ToJson for SetBreakpointsResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend SetBreakpointsResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for SetBreakpointsResponse with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SetBreakpointsResponse with @json.FromJson::{from_json}

///|
pub(all) struct SetFunctionBreakpointsRequest {
  seq : Int32
  arguments : SetFunctionBreakpointsArguments
}

///|
pub impl ToJson for SetFunctionBreakpointsRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("setFunctionBreakpoints"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend SetFunctionBreakpointsRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for SetFunctionBreakpointsRequest with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "setFunctionBreakpoints")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SetFunctionBreakpointsRequest with @json.FromJson::{from_json}

///|
pub(all) struct SetFunctionBreakpointsArguments {
  breakpoints : Array[FunctionBreakpoint]
}

///|
pub impl ToJson for SetFunctionBreakpointsArguments with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "breakpoints",
    Json::array(self.breakpoints.map(item => @json.to_json(item))),
  )
  Json::object(fields)
}

///|
pub extend SetFunctionBreakpointsArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for SetFunctionBreakpointsArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    breakpoints: required(fields, "breakpoints", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend SetFunctionBreakpointsArguments with @json.FromJson::{from_json}

///|
pub(all) struct SetFunctionBreakpointsResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : SetFunctionBreakpointsResponseBody
}

///|
pub impl ToJson for SetFunctionBreakpointsResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend SetFunctionBreakpointsResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for SetFunctionBreakpointsResponse with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SetFunctionBreakpointsResponse with @json.FromJson::{from_json}

///|
pub(all) struct SetExceptionBreakpointsRequest {
  seq : Int32
  arguments : SetExceptionBreakpointsArguments
}

///|
pub impl ToJson for SetExceptionBreakpointsRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("setExceptionBreakpoints"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend SetExceptionBreakpointsRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for SetExceptionBreakpointsRequest with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "setExceptionBreakpoints")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SetExceptionBreakpointsRequest with @json.FromJson::{from_json}

///|
pub(all) struct SetExceptionBreakpointsArguments {
  filters : Array[String]
  filter_options : Array[ExceptionFilterOptions]?
  exception_options : Array[ExceptionOptions]?
}

///|
pub impl ToJson for SetExceptionBreakpointsArguments with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "filters",
    Json::array(self.filters.map(item => @json.to_json(item))),
  )
  if self.filter_options is Some(item) {
    fields.set(
      "filterOptions",
      Json::array(item.map(item => @json.to_json(item))),
    )
  }
  if self.exception_options is Some(item) {
    fields.set(
      "exceptionOptions",
      Json::array(item.map(item => @json.to_json(item))),
    )
  }
  Json::object(fields)
}

///|
pub extend SetExceptionBreakpointsArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for SetExceptionBreakpointsArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    filters: required(fields, "filters", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
    filter_options: optional(fields, "filterOptions", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
    exception_options: optional(fields, "exceptionOptions", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend SetExceptionBreakpointsArguments with @json.FromJson::{from_json}

///|
pub(all) struct SetExceptionBreakpointsResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : SetExceptionBreakpointsResponseBody?
}

///|
pub impl ToJson for SetExceptionBreakpointsResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend SetExceptionBreakpointsResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for SetExceptionBreakpointsResponse with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SetExceptionBreakpointsResponse with @json.FromJson::{from_json}

///|
pub(all) struct DataBreakpointInfoRequest {
  seq : Int32
  arguments : DataBreakpointInfoArguments
}

///|
pub impl ToJson for DataBreakpointInfoRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("dataBreakpointInfo"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend DataBreakpointInfoRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for DataBreakpointInfoRequest with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "dataBreakpointInfo")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend DataBreakpointInfoRequest with @json.FromJson::{from_json}

///|
pub(all) struct DataBreakpointInfoArguments {
  variables_reference : Int32?
  name : String
  frame_id : Int32?
  bytes : Int64?
  as_address : Bool?
  mode : String?
}

///|
pub impl ToJson for DataBreakpointInfoArguments with fn to_json(self) {
  let fields = Map([])
  if self.variables_reference is Some(item) {
    fields.set("variablesReference", @json.to_json(item))
  }
  fields.set("name", @json.to_json(self.name))
  if self.frame_id is Some(item) {
    fields.set("frameId", @json.to_json(item))
  }
  if self.bytes is Some(item) {
    fields.set("bytes", wide_json(item))
  }
  if self.as_address is Some(item) {
    fields.set("asAddress", @json.to_json(item))
  }
  if self.mode is Some(item) {
    fields.set("mode", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend DataBreakpointInfoArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for DataBreakpointInfoArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    variables_reference: optional(fields, "variablesReference", path, (
      value,
      path,
    ) => integer(value, path, 0L, 2147483647L).to_int()),
    name: required(fields, "name", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    frame_id: optional(fields, "frameId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    bytes: optional(fields, "bytes", path, (value, path) => {
      integer(value, path, 0L, 4294967295L)
    }),
    as_address: optional(fields, "asAddress", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    mode: optional(fields, "mode", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend DataBreakpointInfoArguments with @json.FromJson::{from_json}

///|
pub(all) struct DataBreakpointInfoResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : DataBreakpointInfoResponseBody
}

///|
pub impl ToJson for DataBreakpointInfoResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend DataBreakpointInfoResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for DataBreakpointInfoResponse with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend DataBreakpointInfoResponse with @json.FromJson::{from_json}

///|
pub(all) struct SetDataBreakpointsRequest {
  seq : Int32
  arguments : SetDataBreakpointsArguments
}

///|
pub impl ToJson for SetDataBreakpointsRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("setDataBreakpoints"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend SetDataBreakpointsRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for SetDataBreakpointsRequest with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "setDataBreakpoints")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SetDataBreakpointsRequest with @json.FromJson::{from_json}

///|
pub(all) struct SetDataBreakpointsArguments {
  breakpoints : Array[DataBreakpoint]
}

///|
pub impl ToJson for SetDataBreakpointsArguments with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "breakpoints",
    Json::array(self.breakpoints.map(item => @json.to_json(item))),
  )
  Json::object(fields)
}

///|
pub extend SetDataBreakpointsArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for SetDataBreakpointsArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    breakpoints: required(fields, "breakpoints", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend SetDataBreakpointsArguments with @json.FromJson::{from_json}

///|
pub(all) struct SetDataBreakpointsResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : SetDataBreakpointsResponseBody
}

///|
pub impl ToJson for SetDataBreakpointsResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend SetDataBreakpointsResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for SetDataBreakpointsResponse with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SetDataBreakpointsResponse with @json.FromJson::{from_json}

///|
pub(all) struct SetInstructionBreakpointsRequest {
  seq : Int32
  arguments : SetInstructionBreakpointsArguments
}

///|
pub impl ToJson for SetInstructionBreakpointsRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("setInstructionBreakpoints"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend SetInstructionBreakpointsRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for SetInstructionBreakpointsRequest with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "setInstructionBreakpoints")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SetInstructionBreakpointsRequest with @json.FromJson::{from_json}

///|
pub(all) struct SetInstructionBreakpointsArguments {
  breakpoints : Array[InstructionBreakpoint]
}

///|
pub impl ToJson for SetInstructionBreakpointsArguments with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "breakpoints",
    Json::array(self.breakpoints.map(item => @json.to_json(item))),
  )
  Json::object(fields)
}

///|
pub extend SetInstructionBreakpointsArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for SetInstructionBreakpointsArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    breakpoints: required(fields, "breakpoints", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend SetInstructionBreakpointsArguments with @json.FromJson::{from_json}

///|
pub(all) struct SetInstructionBreakpointsResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : SetInstructionBreakpointsResponseBody
}

///|
pub impl ToJson for SetInstructionBreakpointsResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend SetInstructionBreakpointsResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for SetInstructionBreakpointsResponse with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SetInstructionBreakpointsResponse with @json.FromJson::{from_json}

///|
pub(all) struct ContinueRequest {
  seq : Int32
  arguments : ContinueArguments
}

///|
pub impl ToJson for ContinueRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("continue"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend ContinueRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for ContinueRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "continue")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ContinueRequest with @json.FromJson::{from_json}

///|
pub(all) struct ContinueArguments {
  thread_id : Int32
  single_thread : Bool?
}

///|
pub impl ToJson for ContinueArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("threadId", @json.to_json(self.thread_id))
  if self.single_thread is Some(item) {
    fields.set("singleThread", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend ContinueArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for ContinueArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    thread_id: required(fields, "threadId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    single_thread: optional(fields, "singleThread", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ContinueArguments with @json.FromJson::{from_json}

///|
pub(all) struct ContinueResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : ContinueResponseBody
}

///|
pub impl ToJson for ContinueResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend ContinueResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for ContinueResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ContinueResponse with @json.FromJson::{from_json}

///|
pub(all) struct NextRequest {
  seq : Int32
  arguments : NextArguments
}

///|
pub impl ToJson for NextRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("next"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend NextRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for NextRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "next")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend NextRequest with @json.FromJson::{from_json}

///|
pub(all) struct NextArguments {
  thread_id : Int32
  single_thread : Bool?
  granularity : SteppingGranularity?
}

///|
pub impl ToJson for NextArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("threadId", @json.to_json(self.thread_id))
  if self.single_thread is Some(item) {
    fields.set("singleThread", @json.to_json(item))
  }
  if self.granularity is Some(item) {
    fields.set("granularity", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend NextArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for NextArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    thread_id: required(fields, "threadId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    single_thread: optional(fields, "singleThread", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    granularity: optional(fields, "granularity", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend NextArguments with @json.FromJson::{from_json}

///|
pub(all) struct NextResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Json?
}

///|
pub impl ToJson for NextResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend NextResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for NextResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend NextResponse with @json.FromJson::{from_json}

///|
pub(all) struct StepInRequest {
  seq : Int32
  arguments : StepInArguments
}

///|
pub impl ToJson for StepInRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("stepIn"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend StepInRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for StepInRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "stepIn")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StepInRequest with @json.FromJson::{from_json}

///|
pub(all) struct StepInArguments {
  thread_id : Int32
  single_thread : Bool?
  target_id : Int32?
  granularity : SteppingGranularity?
}

///|
pub impl ToJson for StepInArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("threadId", @json.to_json(self.thread_id))
  if self.single_thread is Some(item) {
    fields.set("singleThread", @json.to_json(item))
  }
  if self.target_id is Some(item) {
    fields.set("targetId", @json.to_json(item))
  }
  if self.granularity is Some(item) {
    fields.set("granularity", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend StepInArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for StepInArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    thread_id: required(fields, "threadId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    single_thread: optional(fields, "singleThread", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    target_id: optional(fields, "targetId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    granularity: optional(fields, "granularity", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StepInArguments with @json.FromJson::{from_json}

///|
pub(all) struct StepInResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Json?
}

///|
pub impl ToJson for StepInResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend StepInResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for StepInResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StepInResponse with @json.FromJson::{from_json}

///|
pub(all) struct StepOutRequest {
  seq : Int32
  arguments : StepOutArguments
}

///|
pub impl ToJson for StepOutRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("stepOut"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend StepOutRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for StepOutRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "stepOut")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StepOutRequest with @json.FromJson::{from_json}

///|
pub(all) struct StepOutArguments {
  thread_id : Int32
  single_thread : Bool?
  granularity : SteppingGranularity?
}

///|
pub impl ToJson for StepOutArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("threadId", @json.to_json(self.thread_id))
  if self.single_thread is Some(item) {
    fields.set("singleThread", @json.to_json(item))
  }
  if self.granularity is Some(item) {
    fields.set("granularity", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend StepOutArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for StepOutArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    thread_id: required(fields, "threadId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    single_thread: optional(fields, "singleThread", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    granularity: optional(fields, "granularity", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StepOutArguments with @json.FromJson::{from_json}

///|
pub(all) struct StepOutResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Json?
}

///|
pub impl ToJson for StepOutResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend StepOutResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for StepOutResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StepOutResponse with @json.FromJson::{from_json}

///|
pub(all) struct StepBackRequest {
  seq : Int32
  arguments : StepBackArguments
}

///|
pub impl ToJson for StepBackRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("stepBack"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend StepBackRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for StepBackRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "stepBack")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StepBackRequest with @json.FromJson::{from_json}

///|
pub(all) struct StepBackArguments {
  thread_id : Int32
  single_thread : Bool?
  granularity : SteppingGranularity?
}

///|
pub impl ToJson for StepBackArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("threadId", @json.to_json(self.thread_id))
  if self.single_thread is Some(item) {
    fields.set("singleThread", @json.to_json(item))
  }
  if self.granularity is Some(item) {
    fields.set("granularity", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend StepBackArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for StepBackArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    thread_id: required(fields, "threadId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    single_thread: optional(fields, "singleThread", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    granularity: optional(fields, "granularity", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StepBackArguments with @json.FromJson::{from_json}

///|
pub(all) struct StepBackResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Json?
}

///|
pub impl ToJson for StepBackResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend StepBackResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for StepBackResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StepBackResponse with @json.FromJson::{from_json}

///|
pub(all) struct ReverseContinueRequest {
  seq : Int32
  arguments : ReverseContinueArguments
}

///|
pub impl ToJson for ReverseContinueRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("reverseContinue"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend ReverseContinueRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for ReverseContinueRequest with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "reverseContinue")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ReverseContinueRequest with @json.FromJson::{from_json}

///|
pub(all) struct ReverseContinueArguments {
  thread_id : Int32
  single_thread : Bool?
}

///|
pub impl ToJson for ReverseContinueArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("threadId", @json.to_json(self.thread_id))
  if self.single_thread is Some(item) {
    fields.set("singleThread", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend ReverseContinueArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for ReverseContinueArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    thread_id: required(fields, "threadId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    single_thread: optional(fields, "singleThread", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ReverseContinueArguments with @json.FromJson::{from_json}

///|
pub(all) struct ReverseContinueResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Json?
}

///|
pub impl ToJson for ReverseContinueResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend ReverseContinueResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for ReverseContinueResponse with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ReverseContinueResponse with @json.FromJson::{from_json}

///|
pub(all) struct RestartFrameRequest {
  seq : Int32
  arguments : RestartFrameArguments
}

///|
pub impl ToJson for RestartFrameRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("restartFrame"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend RestartFrameRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for RestartFrameRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "restartFrame")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend RestartFrameRequest with @json.FromJson::{from_json}

///|
pub(all) struct RestartFrameArguments {
  frame_id : Int32
}

///|
pub impl ToJson for RestartFrameArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("frameId", @json.to_json(self.frame_id))
  Json::object(fields)
}

///|
pub extend RestartFrameArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for RestartFrameArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    frame_id: required(fields, "frameId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
  }
}

///|
pub extend RestartFrameArguments with @json.FromJson::{from_json}

///|
pub(all) struct RestartFrameResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Json?
}

///|
pub impl ToJson for RestartFrameResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend RestartFrameResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for RestartFrameResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend RestartFrameResponse with @json.FromJson::{from_json}

///|
pub(all) struct GotoRequest {
  seq : Int32
  arguments : GotoArguments
}

///|
pub impl ToJson for GotoRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("goto"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend GotoRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for GotoRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "goto")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend GotoRequest with @json.FromJson::{from_json}

///|
pub(all) struct GotoArguments {
  thread_id : Int32
  target_id : Int32
}

///|
pub impl ToJson for GotoArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("threadId", @json.to_json(self.thread_id))
  fields.set("targetId", @json.to_json(self.target_id))
  Json::object(fields)
}

///|
pub extend GotoArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for GotoArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    thread_id: required(fields, "threadId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    target_id: required(fields, "targetId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
  }
}

///|
pub extend GotoArguments with @json.FromJson::{from_json}

///|
pub(all) struct GotoResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Json?
}

///|
pub impl ToJson for GotoResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend GotoResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for GotoResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend GotoResponse with @json.FromJson::{from_json}

///|
pub(all) struct PauseRequest {
  seq : Int32
  arguments : PauseArguments
}

///|
pub impl ToJson for PauseRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("pause"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend PauseRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for PauseRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "pause")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend PauseRequest with @json.FromJson::{from_json}

///|
pub(all) struct PauseArguments {
  thread_id : Int32
}

///|
pub impl ToJson for PauseArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("threadId", @json.to_json(self.thread_id))
  Json::object(fields)
}

///|
pub extend PauseArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for PauseArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    thread_id: required(fields, "threadId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
  }
}

///|
pub extend PauseArguments with @json.FromJson::{from_json}

///|
pub(all) struct PauseResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Json?
}

///|
pub impl ToJson for PauseResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend PauseResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for PauseResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend PauseResponse with @json.FromJson::{from_json}

///|
pub(all) struct StackTraceRequest {
  seq : Int32
  arguments : StackTraceArguments
}

///|
pub impl ToJson for StackTraceRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("stackTrace"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend StackTraceRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for StackTraceRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "stackTrace")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StackTraceRequest with @json.FromJson::{from_json}

///|
pub(all) struct StackTraceArguments {
  thread_id : Int32
  start_frame : Int64?
  levels : Int64?
  format : StackFrameFormat?
}

///|
pub impl ToJson for StackTraceArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("threadId", @json.to_json(self.thread_id))
  if self.start_frame is Some(item) {
    fields.set("startFrame", wide_json(item))
  }
  if self.levels is Some(item) {
    fields.set("levels", wide_json(item))
  }
  if self.format is Some(item) {
    fields.set("format", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend StackTraceArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for StackTraceArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    thread_id: required(fields, "threadId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    start_frame: optional(fields, "startFrame", path, (value, path) => {
      integer(value, path, 0L, 4294967295L)
    }),
    levels: optional(fields, "levels", path, (value, path) => {
      integer(value, path, 0L, 4294967295L)
    }),
    format: optional(fields, "format", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StackTraceArguments with @json.FromJson::{from_json}

///|
pub(all) struct StackTraceResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : StackTraceResponseBody
}

///|
pub impl ToJson for StackTraceResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend StackTraceResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for StackTraceResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StackTraceResponse with @json.FromJson::{from_json}

///|
pub(all) struct ScopesRequest {
  seq : Int32
  arguments : ScopesArguments
}

///|
pub impl ToJson for ScopesRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("scopes"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend ScopesRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for ScopesRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "scopes")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ScopesRequest with @json.FromJson::{from_json}

///|
pub(all) struct ScopesArguments {
  frame_id : Int32
}

///|
pub impl ToJson for ScopesArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("frameId", @json.to_json(self.frame_id))
  Json::object(fields)
}

///|
pub extend ScopesArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for ScopesArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    frame_id: required(fields, "frameId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
  }
}

///|
pub extend ScopesArguments with @json.FromJson::{from_json}

///|
pub(all) struct ScopesResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : ScopesResponseBody
}

///|
pub impl ToJson for ScopesResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend ScopesResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for ScopesResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ScopesResponse with @json.FromJson::{from_json}

///|
pub(all) struct VariablesRequest {
  seq : Int32
  arguments : VariablesArguments
}

///|
pub impl ToJson for VariablesRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("variables"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend VariablesRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for VariablesRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "variables")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend VariablesRequest with @json.FromJson::{from_json}

///|
pub(all) struct VariablesArguments {
  variables_reference : Int32
  filter : VariablesArgumentsFilter?
  start : Int64?
  count : Int64?
  format : ValueFormat?
}

///|
pub impl ToJson for VariablesArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("variablesReference", @json.to_json(self.variables_reference))
  if self.filter is Some(item) {
    fields.set("filter", @json.to_json(item))
  }
  if self.start is Some(item) {
    fields.set("start", wide_json(item))
  }
  if self.count is Some(item) {
    fields.set("count", wide_json(item))
  }
  if self.format is Some(item) {
    fields.set("format", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend VariablesArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for VariablesArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    variables_reference: required(fields, "variablesReference", path, (
      value,
      path,
    ) => integer(value, path, 0L, 2147483647L).to_int()),
    filter: optional(fields, "filter", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    start: optional(fields, "start", path, (value, path) => {
      integer(value, path, 0L, 4294967295L)
    }),
    count: optional(fields, "count", path, (value, path) => {
      integer(value, path, 0L, 4294967295L)
    }),
    format: optional(fields, "format", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend VariablesArguments with @json.FromJson::{from_json}

///|
pub(all) struct VariablesResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : VariablesResponseBody
}

///|
pub impl ToJson for VariablesResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend VariablesResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for VariablesResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend VariablesResponse with @json.FromJson::{from_json}

///|
pub(all) struct SetVariableRequest {
  seq : Int32
  arguments : SetVariableArguments
}

///|
pub impl ToJson for SetVariableRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("setVariable"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend SetVariableRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for SetVariableRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "setVariable")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SetVariableRequest with @json.FromJson::{from_json}

///|
pub(all) struct SetVariableArguments {
  variables_reference : Int32
  name : String
  value : String
  format : ValueFormat?
}

///|
pub impl ToJson for SetVariableArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("variablesReference", @json.to_json(self.variables_reference))
  fields.set("name", @json.to_json(self.name))
  fields.set("value", @json.to_json(self.value))
  if self.format is Some(item) {
    fields.set("format", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend SetVariableArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for SetVariableArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    variables_reference: required(fields, "variablesReference", path, (
      value,
      path,
    ) => integer(value, path, 0L, 2147483647L).to_int()),
    name: required(fields, "name", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    value: required(fields, "value", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    format: optional(fields, "format", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SetVariableArguments with @json.FromJson::{from_json}

///|
pub(all) struct SetVariableResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : SetVariableResponseBody
}

///|
pub impl ToJson for SetVariableResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend SetVariableResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for SetVariableResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SetVariableResponse with @json.FromJson::{from_json}

///|
pub(all) struct SourceRequest {
  seq : Int32
  arguments : SourceArguments
}

///|
pub impl ToJson for SourceRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("source"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend SourceRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for SourceRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "source")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SourceRequest with @json.FromJson::{from_json}

///|
pub(all) struct SourceArguments {
  source : Source?
  source_reference : Int32
}

///|
pub impl ToJson for SourceArguments with fn to_json(self) {
  let fields = Map([])
  if self.source is Some(item) {
    fields.set("source", @json.to_json(item))
  }
  fields.set("sourceReference", @json.to_json(self.source_reference))
  Json::object(fields)
}

///|
pub extend SourceArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for SourceArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    source: optional(fields, "source", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    source_reference: required(fields, "sourceReference", path, (value, path) => {
      integer(value, path, 0L, 2147483647L).to_int()
    }),
  }
}

///|
pub extend SourceArguments with @json.FromJson::{from_json}

///|
pub(all) struct SourceResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : SourceResponseBody
}

///|
pub impl ToJson for SourceResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend SourceResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for SourceResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SourceResponse with @json.FromJson::{from_json}

///|
pub(all) struct ThreadsRequest {
  seq : Int32
  arguments : Json?
}

///|
pub impl ToJson for ThreadsRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("threads"))
  if self.arguments is Some(item) {
    fields.set("arguments", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend ThreadsRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for ThreadsRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "threads")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: optional(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ThreadsRequest with @json.FromJson::{from_json}

///|
pub(all) struct ThreadsResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : ThreadsResponseBody
}

///|
pub impl ToJson for ThreadsResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend ThreadsResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for ThreadsResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ThreadsResponse with @json.FromJson::{from_json}

///|
pub(all) struct TerminateThreadsRequest {
  seq : Int32
  arguments : TerminateThreadsArguments
}

///|
pub impl ToJson for TerminateThreadsRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("terminateThreads"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend TerminateThreadsRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for TerminateThreadsRequest with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "terminateThreads")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend TerminateThreadsRequest with @json.FromJson::{from_json}

///|
pub(all) struct TerminateThreadsArguments {
  thread_ids : Array[Int32]?
}

///|
pub impl ToJson for TerminateThreadsArguments with fn to_json(self) {
  let fields = Map([])
  if self.thread_ids is Some(item) {
    fields.set("threadIds", Json::array(item.map(item => @json.to_json(item))))
  }
  Json::object(fields)
}

///|
pub extend TerminateThreadsArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for TerminateThreadsArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    thread_ids: optional(fields, "threadIds", path, (value, path) => {
      array_of(value, path, (value, path) => {
        integer(value, path, -2147483648L, 2147483647L).to_int()
      })
    }),
  }
}

///|
pub extend TerminateThreadsArguments with @json.FromJson::{from_json}

///|
pub(all) struct TerminateThreadsResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : Json?
}

///|
pub impl ToJson for TerminateThreadsResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend TerminateThreadsResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for TerminateThreadsResponse with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend TerminateThreadsResponse with @json.FromJson::{from_json}

///|
pub(all) struct ModulesRequest {
  seq : Int32
  arguments : ModulesArguments
}

///|
pub impl ToJson for ModulesRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("modules"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend ModulesRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for ModulesRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "modules")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ModulesRequest with @json.FromJson::{from_json}

///|
pub(all) struct ModulesArguments {
  start_module : Int32?
  module_count : Int64?
}

///|
pub impl ToJson for ModulesArguments with fn to_json(self) {
  let fields = Map([])
  if self.start_module is Some(item) {
    fields.set("startModule", @json.to_json(item))
  }
  if self.module_count is Some(item) {
    fields.set("moduleCount", wide_json(item))
  }
  Json::object(fields)
}

///|
pub extend ModulesArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for ModulesArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    start_module: optional(fields, "startModule", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    module_count: optional(fields, "moduleCount", path, (value, path) => {
      integer(value, path, 0L, 4294967295L)
    }),
  }
}

///|
pub extend ModulesArguments with @json.FromJson::{from_json}

///|
pub(all) struct ModulesResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : ModulesResponseBody
}

///|
pub impl ToJson for ModulesResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend ModulesResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for ModulesResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ModulesResponse with @json.FromJson::{from_json}

///|
pub(all) struct LoadedSourcesRequest {
  seq : Int32
  arguments : LoadedSourcesArguments?
}

///|
pub impl ToJson for LoadedSourcesRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("loadedSources"))
  if self.arguments is Some(item) {
    fields.set("arguments", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend LoadedSourcesRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for LoadedSourcesRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "loadedSources")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: optional(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend LoadedSourcesRequest with @json.FromJson::{from_json}

///|
pub(all) struct LoadedSourcesArguments {
  additional : Map[String, Json]
}

///|
pub impl ToJson for LoadedSourcesArguments with fn to_json(self) {
  let fields = extras(self.additional, [])
  Json::object(fields)
}

///|
pub extend LoadedSourcesArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for LoadedSourcesArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  { additional: extras(fields, []), }
}

///|
pub extend LoadedSourcesArguments with @json.FromJson::{from_json}

///|
pub(all) struct LoadedSourcesResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : LoadedSourcesResponseBody
}

///|
pub impl ToJson for LoadedSourcesResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend LoadedSourcesResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for LoadedSourcesResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend LoadedSourcesResponse with @json.FromJson::{from_json}

///|
pub(all) struct EvaluateRequest {
  seq : Int32
  arguments : EvaluateArguments
}

///|
pub impl ToJson for EvaluateRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("evaluate"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend EvaluateRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for EvaluateRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "evaluate")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend EvaluateRequest with @json.FromJson::{from_json}

///|
pub(all) struct EvaluateArguments {
  expression : String
  frame_id : Int32?
  line : Int64?
  column : Int64?
  source : Source?
  context : String?
  format : ValueFormat?
}

///|
pub impl ToJson for EvaluateArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("expression", @json.to_json(self.expression))
  if self.frame_id is Some(item) {
    fields.set("frameId", @json.to_json(item))
  }
  if self.line is Some(item) {
    fields.set("line", wide_json(item))
  }
  if self.column is Some(item) {
    fields.set("column", wide_json(item))
  }
  if self.source is Some(item) {
    fields.set("source", @json.to_json(item))
  }
  if self.context is Some(item) {
    fields.set("context", @json.to_json(item))
  }
  if self.format is Some(item) {
    fields.set("format", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend EvaluateArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for EvaluateArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    expression: required(fields, "expression", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    frame_id: optional(fields, "frameId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    line: optional(fields, "line", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    column: optional(fields, "column", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    source: optional(fields, "source", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    context: optional(fields, "context", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    format: optional(fields, "format", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend EvaluateArguments with @json.FromJson::{from_json}

///|
pub(all) struct EvaluateResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : EvaluateResponseBody
}

///|
pub impl ToJson for EvaluateResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend EvaluateResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for EvaluateResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend EvaluateResponse with @json.FromJson::{from_json}

///|
pub(all) struct SetExpressionRequest {
  seq : Int32
  arguments : SetExpressionArguments
}

///|
pub impl ToJson for SetExpressionRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("setExpression"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend SetExpressionRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for SetExpressionRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "setExpression")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SetExpressionRequest with @json.FromJson::{from_json}

///|
pub(all) struct SetExpressionArguments {
  expression : String
  value : String
  frame_id : Int32?
  format : ValueFormat?
}

///|
pub impl ToJson for SetExpressionArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("expression", @json.to_json(self.expression))
  fields.set("value", @json.to_json(self.value))
  if self.frame_id is Some(item) {
    fields.set("frameId", @json.to_json(item))
  }
  if self.format is Some(item) {
    fields.set("format", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend SetExpressionArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for SetExpressionArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    expression: required(fields, "expression", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    value: required(fields, "value", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    frame_id: optional(fields, "frameId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    format: optional(fields, "format", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SetExpressionArguments with @json.FromJson::{from_json}

///|
pub(all) struct SetExpressionResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : SetExpressionResponseBody
}

///|
pub impl ToJson for SetExpressionResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend SetExpressionResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for SetExpressionResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SetExpressionResponse with @json.FromJson::{from_json}

///|
pub(all) struct StepInTargetsRequest {
  seq : Int32
  arguments : StepInTargetsArguments
}

///|
pub impl ToJson for StepInTargetsRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("stepInTargets"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend StepInTargetsRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for StepInTargetsRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "stepInTargets")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StepInTargetsRequest with @json.FromJson::{from_json}

///|
pub(all) struct StepInTargetsArguments {
  frame_id : Int32
}

///|
pub impl ToJson for StepInTargetsArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("frameId", @json.to_json(self.frame_id))
  Json::object(fields)
}

///|
pub extend StepInTargetsArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for StepInTargetsArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    frame_id: required(fields, "frameId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
  }
}

///|
pub extend StepInTargetsArguments with @json.FromJson::{from_json}

///|
pub(all) struct StepInTargetsResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : StepInTargetsResponseBody
}

///|
pub impl ToJson for StepInTargetsResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend StepInTargetsResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for StepInTargetsResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StepInTargetsResponse with @json.FromJson::{from_json}

///|
pub(all) struct GotoTargetsRequest {
  seq : Int32
  arguments : GotoTargetsArguments
}

///|
pub impl ToJson for GotoTargetsRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("gotoTargets"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend GotoTargetsRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for GotoTargetsRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "gotoTargets")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend GotoTargetsRequest with @json.FromJson::{from_json}

///|
pub(all) struct GotoTargetsArguments {
  source : Source
  line : Int64
  column : Int64?
}

///|
pub impl ToJson for GotoTargetsArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("source", @json.to_json(self.source))
  fields.set("line", wide_json(self.line))
  if self.column is Some(item) {
    fields.set("column", wide_json(item))
  }
  Json::object(fields)
}

///|
pub extend GotoTargetsArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for GotoTargetsArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    source: required(fields, "source", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    line: required(fields, "line", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    column: optional(fields, "column", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
  }
}

///|
pub extend GotoTargetsArguments with @json.FromJson::{from_json}

///|
pub(all) struct GotoTargetsResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : GotoTargetsResponseBody
}

///|
pub impl ToJson for GotoTargetsResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend GotoTargetsResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for GotoTargetsResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend GotoTargetsResponse with @json.FromJson::{from_json}

///|
pub(all) struct CompletionsRequest {
  seq : Int32
  arguments : CompletionsArguments
}

///|
pub impl ToJson for CompletionsRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("completions"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend CompletionsRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for CompletionsRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "completions")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend CompletionsRequest with @json.FromJson::{from_json}

///|
pub(all) struct CompletionsArguments {
  frame_id : Int32?
  text : String
  column : Int64
  line : Int64?
}

///|
pub impl ToJson for CompletionsArguments with fn to_json(self) {
  let fields = Map([])
  if self.frame_id is Some(item) {
    fields.set("frameId", @json.to_json(item))
  }
  fields.set("text", @json.to_json(self.text))
  fields.set("column", wide_json(self.column))
  if self.line is Some(item) {
    fields.set("line", wide_json(item))
  }
  Json::object(fields)
}

///|
pub extend CompletionsArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for CompletionsArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    frame_id: optional(fields, "frameId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    text: required(fields, "text", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    column: required(fields, "column", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    line: optional(fields, "line", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
  }
}

///|
pub extend CompletionsArguments with @json.FromJson::{from_json}

///|
pub(all) struct CompletionsResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : CompletionsResponseBody
}

///|
pub impl ToJson for CompletionsResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend CompletionsResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for CompletionsResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend CompletionsResponse with @json.FromJson::{from_json}

///|
pub(all) struct ExceptionInfoRequest {
  seq : Int32
  arguments : ExceptionInfoArguments
}

///|
pub impl ToJson for ExceptionInfoRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("exceptionInfo"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend ExceptionInfoRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for ExceptionInfoRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "exceptionInfo")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ExceptionInfoRequest with @json.FromJson::{from_json}

///|
pub(all) struct ExceptionInfoArguments {
  thread_id : Int32
}

///|
pub impl ToJson for ExceptionInfoArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("threadId", @json.to_json(self.thread_id))
  Json::object(fields)
}

///|
pub extend ExceptionInfoArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for ExceptionInfoArguments with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    thread_id: required(fields, "threadId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
  }
}

///|
pub extend ExceptionInfoArguments with @json.FromJson::{from_json}

///|
pub(all) struct ExceptionInfoResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : ExceptionInfoResponseBody
}

///|
pub impl ToJson for ExceptionInfoResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  fields.set("body", @json.to_json(self.body))
  Json::object(fields)
}

///|
pub extend ExceptionInfoResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for ExceptionInfoResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: required(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ExceptionInfoResponse with @json.FromJson::{from_json}

///|
pub(all) struct ReadMemoryRequest {
  seq : Int32
  arguments : ReadMemoryArguments
}

///|
pub impl ToJson for ReadMemoryRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("readMemory"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend ReadMemoryRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for ReadMemoryRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "readMemory")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ReadMemoryRequest with @json.FromJson::{from_json}

///|
pub(all) struct ReadMemoryArguments {
  memory_reference : String
  offset : Int64?
  count : Int64
}

///|
pub impl ToJson for ReadMemoryArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("memoryReference", @json.to_json(self.memory_reference))
  if self.offset is Some(item) {
    fields.set("offset", wide_json(item))
  }
  fields.set("count", wide_json(self.count))
  Json::object(fields)
}

///|
pub extend ReadMemoryArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for ReadMemoryArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    memory_reference: required(fields, "memoryReference", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    offset: optional(fields, "offset", path, (value, path) => {
      integer(value, path, -9007199254740991L, 9007199254740991L)
    }),
    count: required(fields, "count", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
  }
}

///|
pub extend ReadMemoryArguments with @json.FromJson::{from_json}

///|
pub(all) struct ReadMemoryResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : ReadMemoryResponseBody?
}

///|
pub impl ToJson for ReadMemoryResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend ReadMemoryResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for ReadMemoryResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ReadMemoryResponse with @json.FromJson::{from_json}

///|
pub(all) struct WriteMemoryRequest {
  seq : Int32
  arguments : WriteMemoryArguments
}

///|
pub impl ToJson for WriteMemoryRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("writeMemory"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend WriteMemoryRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for WriteMemoryRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "writeMemory")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend WriteMemoryRequest with @json.FromJson::{from_json}

///|
pub(all) struct WriteMemoryArguments {
  memory_reference : String
  offset : Int64?
  allow_partial : Bool?
  data : String
}

///|
pub impl ToJson for WriteMemoryArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("memoryReference", @json.to_json(self.memory_reference))
  if self.offset is Some(item) {
    fields.set("offset", wide_json(item))
  }
  if self.allow_partial is Some(item) {
    fields.set("allowPartial", @json.to_json(item))
  }
  fields.set("data", @json.to_json(self.data))
  Json::object(fields)
}

///|
pub extend WriteMemoryArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for WriteMemoryArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    memory_reference: required(fields, "memoryReference", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    offset: optional(fields, "offset", path, (value, path) => {
      integer(value, path, -9007199254740991L, 9007199254740991L)
    }),
    allow_partial: optional(fields, "allowPartial", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    data: required(fields, "data", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend WriteMemoryArguments with @json.FromJson::{from_json}

///|
pub(all) struct WriteMemoryResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : WriteMemoryResponseBody?
}

///|
pub impl ToJson for WriteMemoryResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend WriteMemoryResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for WriteMemoryResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend WriteMemoryResponse with @json.FromJson::{from_json}

///|
pub(all) struct DisassembleRequest {
  seq : Int32
  arguments : DisassembleArguments
}

///|
pub impl ToJson for DisassembleRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("disassemble"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend DisassembleRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for DisassembleRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "disassemble")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend DisassembleRequest with @json.FromJson::{from_json}

///|
pub(all) struct DisassembleArguments {
  memory_reference : String
  offset : Int64?
  instruction_offset : Int64?
  instruction_count : Int64
  resolve_symbols : Bool?
}

///|
pub impl ToJson for DisassembleArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("memoryReference", @json.to_json(self.memory_reference))
  if self.offset is Some(item) {
    fields.set("offset", wide_json(item))
  }
  if self.instruction_offset is Some(item) {
    fields.set("instructionOffset", wide_json(item))
  }
  fields.set("instructionCount", wide_json(self.instruction_count))
  if self.resolve_symbols is Some(item) {
    fields.set("resolveSymbols", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend DisassembleArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for DisassembleArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    memory_reference: required(fields, "memoryReference", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    offset: optional(fields, "offset", path, (value, path) => {
      integer(value, path, -9007199254740991L, 9007199254740991L)
    }),
    instruction_offset: optional(fields, "instructionOffset", path, (
      value,
      path,
    ) => integer(value, path, -9007199254740991L, 9007199254740991L)),
    instruction_count: required(fields, "instructionCount", path, (value, path) => {
      integer(value, path, 0L, 4294967295L)
    }),
    resolve_symbols: optional(fields, "resolveSymbols", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend DisassembleArguments with @json.FromJson::{from_json}

///|
pub(all) struct DisassembleResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : DisassembleResponseBody?
}

///|
pub impl ToJson for DisassembleResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend DisassembleResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for DisassembleResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend DisassembleResponse with @json.FromJson::{from_json}

///|
pub(all) struct LocationsRequest {
  seq : Int32
  arguments : LocationsArguments
}

///|
pub impl ToJson for LocationsRequest with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("request"))
  fields.set("command", Json::string("locations"))
  fields.set("arguments", @json.to_json(self.arguments))
  Json::object(fields)
}

///|
pub extend LocationsRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for LocationsRequest with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "request")
  })
  required(fields, "command", path, (value, path) => {
    literal(value, path, "locations")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    arguments: required(fields, "arguments", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend LocationsRequest with @json.FromJson::{from_json}

///|
pub(all) struct LocationsArguments {
  location_reference : Int32
}

///|
pub impl ToJson for LocationsArguments with fn to_json(self) {
  let fields = Map([])
  fields.set("locationReference", @json.to_json(self.location_reference))
  Json::object(fields)
}

///|
pub extend LocationsArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for LocationsArguments with fn from_json(value, path) {
  let fields = object(value, path)
  {
    location_reference: required(fields, "locationReference", path, (
      value,
      path,
    ) => integer(value, path, -2147483648L, 2147483647L).to_int()),
  }
}

///|
pub extend LocationsArguments with @json.FromJson::{from_json}

///|
pub(all) struct LocationsResponse {
  seq : Int32
  request_seq : Int32
  success : Bool
  command : String
  message : String?
  body : LocationsResponseBody?
}

///|
pub impl ToJson for LocationsResponse with fn to_json(self) {
  let fields = Map([])
  fields.set("seq", @json.to_json(self.seq))
  fields.set("type", Json::string("response"))
  fields.set("request_seq", @json.to_json(self.request_seq))
  fields.set("success", @json.to_json(self.success))
  fields.set("command", @json.to_json(self.command))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.body is Some(item) {
    fields.set("body", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend LocationsResponse with ToJson::{to_json}

///|
pub impl @json.FromJson for LocationsResponse with fn from_json(value, path) {
  let fields = object(value, path)
  required(fields, "type", path, (value, path) => {
    literal(value, path, "response")
  })
  {
    seq: required(fields, "seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    request_seq: required(fields, "request_seq", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    success: required(fields, "success", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    command: required(fields, "command", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    body: optional(fields, "body", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend LocationsResponse with @json.FromJson::{from_json}

///|
pub(all) struct Capabilities {
  supports_configuration_done_request : Bool?
  supports_function_breakpoints : Bool?
  supports_conditional_breakpoints : Bool?
  supports_hit_conditional_breakpoints : Bool?
  supports_evaluate_for_hovers : Bool?
  exception_breakpoint_filters : Array[ExceptionBreakpointsFilter]?
  supports_step_back : Bool?
  supports_set_variable : Bool?
  supports_restart_frame : Bool?
  supports_goto_targets_request : Bool?
  supports_step_in_targets_request : Bool?
  supports_completions_request : Bool?
  completion_trigger_characters : Array[String]?
  supports_modules_request : Bool?
  additional_module_columns : Array[ColumnDescriptor]?
  supported_checksum_algorithms : Array[ChecksumAlgorithm]?
  supports_restart_request : Bool?
  supports_exception_options : Bool?
  supports_value_formatting_options : Bool?
  supports_exception_info_request : Bool?
  support_terminate_debuggee : Bool?
  support_suspend_debuggee : Bool?
  supports_delayed_stack_trace_loading : Bool?
  supports_loaded_sources_request : Bool?
  supports_log_points : Bool?
  supports_terminate_threads_request : Bool?
  supports_set_expression : Bool?
  supports_terminate_request : Bool?
  supports_data_breakpoints : Bool?
  supports_read_memory_request : Bool?
  supports_write_memory_request : Bool?
  supports_disassemble_request : Bool?
  supports_cancel_request : Bool?
  supports_breakpoint_locations_request : Bool?
  supports_clipboard_context : Bool?
  supports_stepping_granularity : Bool?
  supports_instruction_breakpoints : Bool?
  supports_exception_filter_options : Bool?
  supports_single_thread_execution_requests : Bool?
  supports_data_breakpoint_bytes : Bool?
  breakpoint_modes : Array[BreakpointMode]?
  supports_ansi_styling : Bool?
}

///|
pub impl ToJson for Capabilities with fn to_json(self) {
  let fields = Map([])
  if self.supports_configuration_done_request is Some(item) {
    fields.set("supportsConfigurationDoneRequest", @json.to_json(item))
  }
  if self.supports_function_breakpoints is Some(item) {
    fields.set("supportsFunctionBreakpoints", @json.to_json(item))
  }
  if self.supports_conditional_breakpoints is Some(item) {
    fields.set("supportsConditionalBreakpoints", @json.to_json(item))
  }
  if self.supports_hit_conditional_breakpoints is Some(item) {
    fields.set("supportsHitConditionalBreakpoints", @json.to_json(item))
  }
  if self.supports_evaluate_for_hovers is Some(item) {
    fields.set("supportsEvaluateForHovers", @json.to_json(item))
  }
  if self.exception_breakpoint_filters is Some(item) {
    fields.set(
      "exceptionBreakpointFilters",
      Json::array(item.map(item => @json.to_json(item))),
    )
  }
  if self.supports_step_back is Some(item) {
    fields.set("supportsStepBack", @json.to_json(item))
  }
  if self.supports_set_variable is Some(item) {
    fields.set("supportsSetVariable", @json.to_json(item))
  }
  if self.supports_restart_frame is Some(item) {
    fields.set("supportsRestartFrame", @json.to_json(item))
  }
  if self.supports_goto_targets_request is Some(item) {
    fields.set("supportsGotoTargetsRequest", @json.to_json(item))
  }
  if self.supports_step_in_targets_request is Some(item) {
    fields.set("supportsStepInTargetsRequest", @json.to_json(item))
  }
  if self.supports_completions_request is Some(item) {
    fields.set("supportsCompletionsRequest", @json.to_json(item))
  }
  if self.completion_trigger_characters is Some(item) {
    fields.set(
      "completionTriggerCharacters",
      Json::array(item.map(item => @json.to_json(item))),
    )
  }
  if self.supports_modules_request is Some(item) {
    fields.set("supportsModulesRequest", @json.to_json(item))
  }
  if self.additional_module_columns is Some(item) {
    fields.set(
      "additionalModuleColumns",
      Json::array(item.map(item => @json.to_json(item))),
    )
  }
  if self.supported_checksum_algorithms is Some(item) {
    fields.set(
      "supportedChecksumAlgorithms",
      Json::array(item.map(item => @json.to_json(item))),
    )
  }
  if self.supports_restart_request is Some(item) {
    fields.set("supportsRestartRequest", @json.to_json(item))
  }
  if self.supports_exception_options is Some(item) {
    fields.set("supportsExceptionOptions", @json.to_json(item))
  }
  if self.supports_value_formatting_options is Some(item) {
    fields.set("supportsValueFormattingOptions", @json.to_json(item))
  }
  if self.supports_exception_info_request is Some(item) {
    fields.set("supportsExceptionInfoRequest", @json.to_json(item))
  }
  if self.support_terminate_debuggee is Some(item) {
    fields.set("supportTerminateDebuggee", @json.to_json(item))
  }
  if self.support_suspend_debuggee is Some(item) {
    fields.set("supportSuspendDebuggee", @json.to_json(item))
  }
  if self.supports_delayed_stack_trace_loading is Some(item) {
    fields.set("supportsDelayedStackTraceLoading", @json.to_json(item))
  }
  if self.supports_loaded_sources_request is Some(item) {
    fields.set("supportsLoadedSourcesRequest", @json.to_json(item))
  }
  if self.supports_log_points is Some(item) {
    fields.set("supportsLogPoints", @json.to_json(item))
  }
  if self.supports_terminate_threads_request is Some(item) {
    fields.set("supportsTerminateThreadsRequest", @json.to_json(item))
  }
  if self.supports_set_expression is Some(item) {
    fields.set("supportsSetExpression", @json.to_json(item))
  }
  if self.supports_terminate_request is Some(item) {
    fields.set("supportsTerminateRequest", @json.to_json(item))
  }
  if self.supports_data_breakpoints is Some(item) {
    fields.set("supportsDataBreakpoints", @json.to_json(item))
  }
  if self.supports_read_memory_request is Some(item) {
    fields.set("supportsReadMemoryRequest", @json.to_json(item))
  }
  if self.supports_write_memory_request is Some(item) {
    fields.set("supportsWriteMemoryRequest", @json.to_json(item))
  }
  if self.supports_disassemble_request is Some(item) {
    fields.set("supportsDisassembleRequest", @json.to_json(item))
  }
  if self.supports_cancel_request is Some(item) {
    fields.set("supportsCancelRequest", @json.to_json(item))
  }
  if self.supports_breakpoint_locations_request is Some(item) {
    fields.set("supportsBreakpointLocationsRequest", @json.to_json(item))
  }
  if self.supports_clipboard_context is Some(item) {
    fields.set("supportsClipboardContext", @json.to_json(item))
  }
  if self.supports_stepping_granularity is Some(item) {
    fields.set("supportsSteppingGranularity", @json.to_json(item))
  }
  if self.supports_instruction_breakpoints is Some(item) {
    fields.set("supportsInstructionBreakpoints", @json.to_json(item))
  }
  if self.supports_exception_filter_options is Some(item) {
    fields.set("supportsExceptionFilterOptions", @json.to_json(item))
  }
  if self.supports_single_thread_execution_requests is Some(item) {
    fields.set("supportsSingleThreadExecutionRequests", @json.to_json(item))
  }
  if self.supports_data_breakpoint_bytes is Some(item) {
    fields.set("supportsDataBreakpointBytes", @json.to_json(item))
  }
  if self.breakpoint_modes is Some(item) {
    fields.set(
      "breakpointModes",
      Json::array(item.map(item => @json.to_json(item))),
    )
  }
  if self.supports_ansi_styling is Some(item) {
    fields.set("supportsANSIStyling", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend Capabilities with ToJson::{to_json}

///|
pub impl @json.FromJson for Capabilities with fn from_json(value, path) {
  let fields = object(value, path)
  {
    supports_configuration_done_request: optional(
      fields,
      "supportsConfigurationDoneRequest",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_function_breakpoints: optional(
      fields,
      "supportsFunctionBreakpoints",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_conditional_breakpoints: optional(
      fields,
      "supportsConditionalBreakpoints",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_hit_conditional_breakpoints: optional(
      fields,
      "supportsHitConditionalBreakpoints",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_evaluate_for_hovers: optional(
      fields,
      "supportsEvaluateForHovers",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    exception_breakpoint_filters: optional(
      fields,
      "exceptionBreakpointFilters",
      path,
      (value, path) => {
        array_of(value, path, (value, path) => @json.from_json(value, path~))
      },
    ),
    supports_step_back: optional(fields, "supportsStepBack", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    supports_set_variable: optional(fields, "supportsSetVariable", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
    supports_restart_frame: optional(fields, "supportsRestartFrame", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
    supports_goto_targets_request: optional(
      fields,
      "supportsGotoTargetsRequest",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_step_in_targets_request: optional(
      fields,
      "supportsStepInTargetsRequest",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_completions_request: optional(
      fields,
      "supportsCompletionsRequest",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    completion_trigger_characters: optional(
      fields,
      "completionTriggerCharacters",
      path,
      (value, path) => {
        array_of(value, path, (value, path) => @json.from_json(value, path~))
      },
    ),
    supports_modules_request: optional(fields, "supportsModulesRequest", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
    additional_module_columns: optional(
      fields,
      "additionalModuleColumns",
      path,
      (value, path) => {
        array_of(value, path, (value, path) => @json.from_json(value, path~))
      },
    ),
    supported_checksum_algorithms: optional(
      fields,
      "supportedChecksumAlgorithms",
      path,
      (value, path) => {
        array_of(value, path, (value, path) => @json.from_json(value, path~))
      },
    ),
    supports_restart_request: optional(fields, "supportsRestartRequest", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
    supports_exception_options: optional(
      fields,
      "supportsExceptionOptions",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_value_formatting_options: optional(
      fields,
      "supportsValueFormattingOptions",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_exception_info_request: optional(
      fields,
      "supportsExceptionInfoRequest",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    support_terminate_debuggee: optional(
      fields,
      "supportTerminateDebuggee",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    support_suspend_debuggee: optional(fields, "supportSuspendDebuggee", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
    supports_delayed_stack_trace_loading: optional(
      fields,
      "supportsDelayedStackTraceLoading",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_loaded_sources_request: optional(
      fields,
      "supportsLoadedSourcesRequest",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_log_points: optional(fields, "supportsLogPoints", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
    supports_terminate_threads_request: optional(
      fields,
      "supportsTerminateThreadsRequest",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_set_expression: optional(fields, "supportsSetExpression", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
    supports_terminate_request: optional(
      fields,
      "supportsTerminateRequest",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_data_breakpoints: optional(
      fields,
      "supportsDataBreakpoints",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_read_memory_request: optional(
      fields,
      "supportsReadMemoryRequest",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_write_memory_request: optional(
      fields,
      "supportsWriteMemoryRequest",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_disassemble_request: optional(
      fields,
      "supportsDisassembleRequest",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_cancel_request: optional(fields, "supportsCancelRequest", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
    supports_breakpoint_locations_request: optional(
      fields,
      "supportsBreakpointLocationsRequest",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_clipboard_context: optional(
      fields,
      "supportsClipboardContext",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_stepping_granularity: optional(
      fields,
      "supportsSteppingGranularity",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_instruction_breakpoints: optional(
      fields,
      "supportsInstructionBreakpoints",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_exception_filter_options: optional(
      fields,
      "supportsExceptionFilterOptions",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_single_thread_execution_requests: optional(
      fields,
      "supportsSingleThreadExecutionRequests",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    supports_data_breakpoint_bytes: optional(
      fields,
      "supportsDataBreakpointBytes",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    breakpoint_modes: optional(fields, "breakpointModes", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
    supports_ansi_styling: optional(fields, "supportsANSIStyling", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
  }
}

///|
pub extend Capabilities with @json.FromJson::{from_json}

///|
pub(all) struct ExceptionBreakpointsFilter {
  filter : String
  label : String
  description : String?
  default : Bool?
  supports_condition : Bool?
  condition_description : String?
}

///|
pub impl ToJson for ExceptionBreakpointsFilter with fn to_json(self) {
  let fields = Map([])
  fields.set("filter", @json.to_json(self.filter))
  fields.set("label", @json.to_json(self.label))
  if self.description is Some(item) {
    fields.set("description", @json.to_json(item))
  }
  if self.default is Some(item) {
    fields.set("default", @json.to_json(item))
  }
  if self.supports_condition is Some(item) {
    fields.set("supportsCondition", @json.to_json(item))
  }
  if self.condition_description is Some(item) {
    fields.set("conditionDescription", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend ExceptionBreakpointsFilter with ToJson::{to_json}

///|
pub impl @json.FromJson for ExceptionBreakpointsFilter with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    filter: required(fields, "filter", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    label: required(fields, "label", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    description: optional(fields, "description", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    default: optional(fields, "default", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    supports_condition: optional(fields, "supportsCondition", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
    condition_description: optional(fields, "conditionDescription", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
  }
}

///|
pub extend ExceptionBreakpointsFilter with @json.FromJson::{from_json}

///|
pub(all) struct Message {
  id : Int32
  format : String
  variables : Map[String, String]?
  send_telemetry : Bool?
  show_user : Bool?
  url : String?
  url_label : String?
}

///|
pub impl ToJson for Message with fn to_json(self) {
  let fields = Map([])
  fields.set("id", @json.to_json(self.id))
  fields.set("format", @json.to_json(self.format))
  if self.variables is Some(item) {
    fields.set("variables", map_to_json(item, item => @json.to_json(item)))
  }
  if self.send_telemetry is Some(item) {
    fields.set("sendTelemetry", @json.to_json(item))
  }
  if self.show_user is Some(item) {
    fields.set("showUser", @json.to_json(item))
  }
  if self.url is Some(item) {
    fields.set("url", @json.to_json(item))
  }
  if self.url_label is Some(item) {
    fields.set("urlLabel", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend Message with ToJson::{to_json}

///|
pub impl @json.FromJson for Message with fn from_json(value, path) {
  let fields = object(value, path)
  {
    id: required(fields, "id", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    format: required(fields, "format", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    variables: optional(fields, "variables", path, (value, path) => {
      map_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
    send_telemetry: optional(fields, "sendTelemetry", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    show_user: optional(fields, "showUser", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    url: optional(fields, "url", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    url_label: optional(fields, "urlLabel", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend Message with @json.FromJson::{from_json}

///|
pub(all) struct Module {
  id : ModuleId
  name : String
  path : String?
  is_optimized : Bool?
  is_user_code : Bool?
  version : String?
  symbol_status : String?
  symbol_file_path : String?
  date_time_stamp : String?
  address_range : String?
}

///|
pub impl ToJson for Module with fn to_json(self) {
  let fields = Map([])
  fields.set("id", @json.to_json(self.id))
  fields.set("name", @json.to_json(self.name))
  if self.path is Some(item) {
    fields.set("path", @json.to_json(item))
  }
  if self.is_optimized is Some(item) {
    fields.set("isOptimized", @json.to_json(item))
  }
  if self.is_user_code is Some(item) {
    fields.set("isUserCode", @json.to_json(item))
  }
  if self.version is Some(item) {
    fields.set("version", @json.to_json(item))
  }
  if self.symbol_status is Some(item) {
    fields.set("symbolStatus", @json.to_json(item))
  }
  if self.symbol_file_path is Some(item) {
    fields.set("symbolFilePath", @json.to_json(item))
  }
  if self.date_time_stamp is Some(item) {
    fields.set("dateTimeStamp", @json.to_json(item))
  }
  if self.address_range is Some(item) {
    fields.set("addressRange", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend Module with ToJson::{to_json}

///|
pub impl @json.FromJson for Module with fn from_json(value, path) {
  let fields = object(value, path)
  {
    id: required(fields, "id", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    name: required(fields, "name", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    path: optional(fields, "path", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    is_optimized: optional(fields, "isOptimized", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    is_user_code: optional(fields, "isUserCode", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    version: optional(fields, "version", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    symbol_status: optional(fields, "symbolStatus", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    symbol_file_path: optional(fields, "symbolFilePath", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    date_time_stamp: optional(fields, "dateTimeStamp", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    address_range: optional(fields, "addressRange", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend Module with @json.FromJson::{from_json}

///|
pub(all) struct ColumnDescriptor {
  attribute_name : String
  label : String
  format : String?
  type_ : ColumnDescriptorType?
  width : Int64?
}

///|
pub impl ToJson for ColumnDescriptor with fn to_json(self) {
  let fields = Map([])
  fields.set("attributeName", @json.to_json(self.attribute_name))
  fields.set("label", @json.to_json(self.label))
  if self.format is Some(item) {
    fields.set("format", @json.to_json(item))
  }
  if self.type_ is Some(item) {
    fields.set("type", @json.to_json(item))
  }
  if self.width is Some(item) {
    fields.set("width", wide_json(item))
  }
  Json::object(fields)
}

///|
pub extend ColumnDescriptor with ToJson::{to_json}

///|
pub impl @json.FromJson for ColumnDescriptor with fn from_json(value, path) {
  let fields = object(value, path)
  {
    attribute_name: required(fields, "attributeName", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    label: required(fields, "label", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    format: optional(fields, "format", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    type_: optional(fields, "type", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    width: optional(fields, "width", path, (value, path) => {
      integer(value, path, 0L, 4294967295L)
    }),
  }
}

///|
pub extend ColumnDescriptor with @json.FromJson::{from_json}

///|
pub(all) struct Thread {
  id : Int32
  name : String
}

///|
pub impl ToJson for Thread with fn to_json(self) {
  let fields = Map([])
  fields.set("id", @json.to_json(self.id))
  fields.set("name", @json.to_json(self.name))
  Json::object(fields)
}

///|
pub extend Thread with ToJson::{to_json}

///|
pub impl @json.FromJson for Thread with fn from_json(value, path) {
  let fields = object(value, path)
  {
    id: required(fields, "id", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    name: required(fields, "name", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend Thread with @json.FromJson::{from_json}

///|
pub(all) struct Source {
  name : String?
  path : String?
  source_reference : Int32?
  presentation_hint : SourcePresentationHint?
  origin : String?
  sources : Array[Source]?
  adapter_data : Json?
  checksums : Array[Checksum]?
}

///|
pub impl ToJson for Source with fn to_json(self) {
  let fields = Map([])
  if self.name is Some(item) {
    fields.set("name", @json.to_json(item))
  }
  if self.path is Some(item) {
    fields.set("path", @json.to_json(item))
  }
  if self.source_reference is Some(item) {
    fields.set("sourceReference", @json.to_json(item))
  }
  if self.presentation_hint is Some(item) {
    fields.set("presentationHint", @json.to_json(item))
  }
  if self.origin is Some(item) {
    fields.set("origin", @json.to_json(item))
  }
  if self.sources is Some(item) {
    fields.set("sources", Json::array(item.map(item => @json.to_json(item))))
  }
  if self.adapter_data is Some(item) {
    fields.set("adapterData", @json.to_json(item))
  }
  if self.checksums is Some(item) {
    fields.set("checksums", Json::array(item.map(item => @json.to_json(item))))
  }
  Json::object(fields)
}

///|
pub extend Source with ToJson::{to_json}

///|
pub impl @json.FromJson for Source with fn from_json(value, path) {
  let fields = object(value, path)
  {
    name: optional(fields, "name", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    path: optional(fields, "path", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    source_reference: optional(fields, "sourceReference", path, (value, path) => {
      integer(value, path, 0L, 2147483647L).to_int()
    }),
    presentation_hint: optional(fields, "presentationHint", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    origin: optional(fields, "origin", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    sources: optional(fields, "sources", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
    adapter_data: optional(fields, "adapterData", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    checksums: optional(fields, "checksums", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend Source with @json.FromJson::{from_json}

///|
pub(all) struct StackFrame {
  id : Int32
  name : String
  source : Source?
  line : Int64
  column : Int64
  end_line : Int64?
  end_column : Int64?
  can_restart : Bool?
  instruction_pointer_reference : String?
  module_id : StackFrameModuleId?
  presentation_hint : StackFramePresentationHint?
}

///|
pub impl ToJson for StackFrame with fn to_json(self) {
  let fields = Map([])
  fields.set("id", @json.to_json(self.id))
  fields.set("name", @json.to_json(self.name))
  if self.source is Some(item) {
    fields.set("source", @json.to_json(item))
  }
  fields.set("line", wide_json(self.line))
  fields.set("column", wide_json(self.column))
  if self.end_line is Some(item) {
    fields.set("endLine", wide_json(item))
  }
  if self.end_column is Some(item) {
    fields.set("endColumn", wide_json(item))
  }
  if self.can_restart is Some(item) {
    fields.set("canRestart", @json.to_json(item))
  }
  if self.instruction_pointer_reference is Some(item) {
    fields.set("instructionPointerReference", @json.to_json(item))
  }
  if self.module_id is Some(item) {
    fields.set("moduleId", @json.to_json(item))
  }
  if self.presentation_hint is Some(item) {
    fields.set("presentationHint", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend StackFrame with ToJson::{to_json}

///|
pub impl @json.FromJson for StackFrame with fn from_json(value, path) {
  let fields = object(value, path)
  {
    id: required(fields, "id", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    name: required(fields, "name", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    source: optional(fields, "source", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    line: required(fields, "line", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    column: required(fields, "column", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    end_line: optional(fields, "endLine", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    end_column: optional(fields, "endColumn", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    can_restart: optional(fields, "canRestart", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    instruction_pointer_reference: optional(
      fields,
      "instructionPointerReference",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
    module_id: optional(fields, "moduleId", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    presentation_hint: optional(fields, "presentationHint", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StackFrame with @json.FromJson::{from_json}

///|
pub(all) struct Scope {
  name : String
  presentation_hint : String?
  variables_reference : Int32
  named_variables : Int32?
  indexed_variables : Int32?
  expensive : Bool
  source : Source?
  line : Int64?
  column : Int64?
  end_line : Int64?
  end_column : Int64?
}

///|
pub impl ToJson for Scope with fn to_json(self) {
  let fields = Map([])
  fields.set("name", @json.to_json(self.name))
  if self.presentation_hint is Some(item) {
    fields.set("presentationHint", @json.to_json(item))
  }
  fields.set("variablesReference", @json.to_json(self.variables_reference))
  if self.named_variables is Some(item) {
    fields.set("namedVariables", @json.to_json(item))
  }
  if self.indexed_variables is Some(item) {
    fields.set("indexedVariables", @json.to_json(item))
  }
  fields.set("expensive", @json.to_json(self.expensive))
  if self.source is Some(item) {
    fields.set("source", @json.to_json(item))
  }
  if self.line is Some(item) {
    fields.set("line", wide_json(item))
  }
  if self.column is Some(item) {
    fields.set("column", wide_json(item))
  }
  if self.end_line is Some(item) {
    fields.set("endLine", wide_json(item))
  }
  if self.end_column is Some(item) {
    fields.set("endColumn", wide_json(item))
  }
  Json::object(fields)
}

///|
pub extend Scope with ToJson::{to_json}

///|
pub impl @json.FromJson for Scope with fn from_json(value, path) {
  let fields = object(value, path)
  {
    name: required(fields, "name", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    presentation_hint: optional(fields, "presentationHint", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    variables_reference: required(fields, "variablesReference", path, (
      value,
      path,
    ) => integer(value, path, 0L, 2147483647L).to_int()),
    named_variables: optional(fields, "namedVariables", path, (value, path) => {
      integer(value, path, 0L, 2147483647L).to_int()
    }),
    indexed_variables: optional(fields, "indexedVariables", path, (value, path) => {
      integer(value, path, 0L, 2147483647L).to_int()
    }),
    expensive: required(fields, "expensive", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    source: optional(fields, "source", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    line: optional(fields, "line", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    column: optional(fields, "column", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    end_line: optional(fields, "endLine", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    end_column: optional(fields, "endColumn", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
  }
}

///|
pub extend Scope with @json.FromJson::{from_json}

///|
pub(all) struct Variable {
  name : String
  value : String
  type_ : String?
  presentation_hint : VariablePresentationHint?
  evaluate_name : String?
  variables_reference : Int32
  named_variables : Int32?
  indexed_variables : Int32?
  memory_reference : String?
  declaration_location_reference : Int32?
  value_location_reference : Int32?
}

///|
pub impl ToJson for Variable with fn to_json(self) {
  let fields = Map([])
  fields.set("name", @json.to_json(self.name))
  fields.set("value", @json.to_json(self.value))
  if self.type_ is Some(item) {
    fields.set("type", @json.to_json(item))
  }
  if self.presentation_hint is Some(item) {
    fields.set("presentationHint", @json.to_json(item))
  }
  if self.evaluate_name is Some(item) {
    fields.set("evaluateName", @json.to_json(item))
  }
  fields.set("variablesReference", @json.to_json(self.variables_reference))
  if self.named_variables is Some(item) {
    fields.set("namedVariables", @json.to_json(item))
  }
  if self.indexed_variables is Some(item) {
    fields.set("indexedVariables", @json.to_json(item))
  }
  if self.memory_reference is Some(item) {
    fields.set("memoryReference", @json.to_json(item))
  }
  if self.declaration_location_reference is Some(item) {
    fields.set("declarationLocationReference", @json.to_json(item))
  }
  if self.value_location_reference is Some(item) {
    fields.set("valueLocationReference", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend Variable with ToJson::{to_json}

///|
pub impl @json.FromJson for Variable with fn from_json(value, path) {
  let fields = object(value, path)
  {
    name: required(fields, "name", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    value: required(fields, "value", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    type_: optional(fields, "type", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    presentation_hint: optional(fields, "presentationHint", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    evaluate_name: optional(fields, "evaluateName", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    variables_reference: required(fields, "variablesReference", path, (
      value,
      path,
    ) => integer(value, path, 0L, 2147483647L).to_int()),
    named_variables: optional(fields, "namedVariables", path, (value, path) => {
      integer(value, path, 0L, 2147483647L).to_int()
    }),
    indexed_variables: optional(fields, "indexedVariables", path, (value, path) => {
      integer(value, path, 0L, 2147483647L).to_int()
    }),
    memory_reference: optional(fields, "memoryReference", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    declaration_location_reference: optional(
      fields,
      "declarationLocationReference",
      path,
      (value, path) => integer(value, path, -2147483648L, 2147483647L).to_int(),
    ),
    value_location_reference: optional(fields, "valueLocationReference", path, (
      value,
      path,
    ) => integer(value, path, -2147483648L, 2147483647L).to_int()),
  }
}

///|
pub extend Variable with @json.FromJson::{from_json}

///|
pub(all) struct VariablePresentationHint {
  kind : String?
  attributes : Array[String]?
  visibility : String?
  lazy_ : Bool?
}

///|
pub impl ToJson for VariablePresentationHint with fn to_json(self) {
  let fields = Map([])
  if self.kind is Some(item) {
    fields.set("kind", @json.to_json(item))
  }
  if self.attributes is Some(item) {
    fields.set("attributes", Json::array(item.map(item => @json.to_json(item))))
  }
  if self.visibility is Some(item) {
    fields.set("visibility", @json.to_json(item))
  }
  if self.lazy_ is Some(item) {
    fields.set("lazy", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend VariablePresentationHint with ToJson::{to_json}

///|
pub impl @json.FromJson for VariablePresentationHint with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    kind: optional(fields, "kind", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    attributes: optional(fields, "attributes", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
    visibility: optional(fields, "visibility", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    lazy_: optional(fields, "lazy", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend VariablePresentationHint with @json.FromJson::{from_json}

///|
pub(all) struct BreakpointLocation {
  line : Int64
  column : Int64?
  end_line : Int64?
  end_column : Int64?
}

///|
pub impl ToJson for BreakpointLocation with fn to_json(self) {
  let fields = Map([])
  fields.set("line", wide_json(self.line))
  if self.column is Some(item) {
    fields.set("column", wide_json(item))
  }
  if self.end_line is Some(item) {
    fields.set("endLine", wide_json(item))
  }
  if self.end_column is Some(item) {
    fields.set("endColumn", wide_json(item))
  }
  Json::object(fields)
}

///|
pub extend BreakpointLocation with ToJson::{to_json}

///|
pub impl @json.FromJson for BreakpointLocation with fn from_json(value, path) {
  let fields = object(value, path)
  {
    line: required(fields, "line", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    column: optional(fields, "column", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    end_line: optional(fields, "endLine", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    end_column: optional(fields, "endColumn", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
  }
}

///|
pub extend BreakpointLocation with @json.FromJson::{from_json}

///|
pub(all) struct SourceBreakpoint {
  line : Int64
  column : Int64?
  condition : String?
  hit_condition : String?
  log_message : String?
  mode : String?
}

///|
pub impl ToJson for SourceBreakpoint with fn to_json(self) {
  let fields = Map([])
  fields.set("line", wide_json(self.line))
  if self.column is Some(item) {
    fields.set("column", wide_json(item))
  }
  if self.condition is Some(item) {
    fields.set("condition", @json.to_json(item))
  }
  if self.hit_condition is Some(item) {
    fields.set("hitCondition", @json.to_json(item))
  }
  if self.log_message is Some(item) {
    fields.set("logMessage", @json.to_json(item))
  }
  if self.mode is Some(item) {
    fields.set("mode", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend SourceBreakpoint with ToJson::{to_json}

///|
pub impl @json.FromJson for SourceBreakpoint with fn from_json(value, path) {
  let fields = object(value, path)
  {
    line: required(fields, "line", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    column: optional(fields, "column", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    condition: optional(fields, "condition", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    hit_condition: optional(fields, "hitCondition", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    log_message: optional(fields, "logMessage", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    mode: optional(fields, "mode", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SourceBreakpoint with @json.FromJson::{from_json}

///|
pub(all) struct FunctionBreakpoint {
  name : String
  condition : String?
  hit_condition : String?
}

///|
pub impl ToJson for FunctionBreakpoint with fn to_json(self) {
  let fields = Map([])
  fields.set("name", @json.to_json(self.name))
  if self.condition is Some(item) {
    fields.set("condition", @json.to_json(item))
  }
  if self.hit_condition is Some(item) {
    fields.set("hitCondition", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend FunctionBreakpoint with ToJson::{to_json}

///|
pub impl @json.FromJson for FunctionBreakpoint with fn from_json(value, path) {
  let fields = object(value, path)
  {
    name: required(fields, "name", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    condition: optional(fields, "condition", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    hit_condition: optional(fields, "hitCondition", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend FunctionBreakpoint with @json.FromJson::{from_json}

///|
pub(all) enum DataBreakpointAccessType {
  Read
  Write
  ReadWrite
}

///|
pub impl ToJson for DataBreakpointAccessType with fn to_json(self) {
  match self {
    Read => Json::string("read")
    Write => Json::string("write")
    ReadWrite => Json::string("readWrite")
  }
}

///|
pub extend DataBreakpointAccessType with ToJson::{to_json}

///|
pub impl @json.FromJson for DataBreakpointAccessType with fn from_json(
  value,
  path,
) {
  match value {
    String("read") => Read
    String("write") => Write
    String("readWrite") => ReadWrite
    _ => invalid(path, "未知枚举值")
  }
}

///|
pub extend DataBreakpointAccessType with @json.FromJson::{from_json}

///|
pub(all) struct DataBreakpoint {
  data_id : String
  access_type : DataBreakpointAccessType?
  condition : String?
  hit_condition : String?
}

///|
pub impl ToJson for DataBreakpoint with fn to_json(self) {
  let fields = Map([])
  fields.set("dataId", @json.to_json(self.data_id))
  if self.access_type is Some(item) {
    fields.set("accessType", @json.to_json(item))
  }
  if self.condition is Some(item) {
    fields.set("condition", @json.to_json(item))
  }
  if self.hit_condition is Some(item) {
    fields.set("hitCondition", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend DataBreakpoint with ToJson::{to_json}

///|
pub impl @json.FromJson for DataBreakpoint with fn from_json(value, path) {
  let fields = object(value, path)
  {
    data_id: required(fields, "dataId", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    access_type: optional(fields, "accessType", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    condition: optional(fields, "condition", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    hit_condition: optional(fields, "hitCondition", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend DataBreakpoint with @json.FromJson::{from_json}

///|
pub(all) struct InstructionBreakpoint {
  instruction_reference : String
  offset : Int64?
  condition : String?
  hit_condition : String?
  mode : String?
}

///|
pub impl ToJson for InstructionBreakpoint with fn to_json(self) {
  let fields = Map([])
  fields.set("instructionReference", @json.to_json(self.instruction_reference))
  if self.offset is Some(item) {
    fields.set("offset", wide_json(item))
  }
  if self.condition is Some(item) {
    fields.set("condition", @json.to_json(item))
  }
  if self.hit_condition is Some(item) {
    fields.set("hitCondition", @json.to_json(item))
  }
  if self.mode is Some(item) {
    fields.set("mode", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend InstructionBreakpoint with ToJson::{to_json}

///|
pub impl @json.FromJson for InstructionBreakpoint with fn from_json(value, path) {
  let fields = object(value, path)
  {
    instruction_reference: required(fields, "instructionReference", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
    offset: optional(fields, "offset", path, (value, path) => {
      integer(value, path, -9007199254740991L, 9007199254740991L)
    }),
    condition: optional(fields, "condition", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    hit_condition: optional(fields, "hitCondition", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    mode: optional(fields, "mode", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend InstructionBreakpoint with @json.FromJson::{from_json}

///|
pub(all) struct Breakpoint {
  id : Int32?
  verified : Bool
  message : String?
  source : Source?
  line : Int64?
  column : Int64?
  end_line : Int64?
  end_column : Int64?
  instruction_reference : String?
  offset : Int64?
  reason : BreakpointReason?
}

///|
pub impl ToJson for Breakpoint with fn to_json(self) {
  let fields = Map([])
  if self.id is Some(item) {
    fields.set("id", @json.to_json(item))
  }
  fields.set("verified", @json.to_json(self.verified))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.source is Some(item) {
    fields.set("source", @json.to_json(item))
  }
  if self.line is Some(item) {
    fields.set("line", wide_json(item))
  }
  if self.column is Some(item) {
    fields.set("column", wide_json(item))
  }
  if self.end_line is Some(item) {
    fields.set("endLine", wide_json(item))
  }
  if self.end_column is Some(item) {
    fields.set("endColumn", wide_json(item))
  }
  if self.instruction_reference is Some(item) {
    fields.set("instructionReference", @json.to_json(item))
  }
  if self.offset is Some(item) {
    fields.set("offset", wide_json(item))
  }
  if self.reason is Some(item) {
    fields.set("reason", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend Breakpoint with ToJson::{to_json}

///|
pub impl @json.FromJson for Breakpoint with fn from_json(value, path) {
  let fields = object(value, path)
  {
    id: optional(fields, "id", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    verified: required(fields, "verified", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    source: optional(fields, "source", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    line: optional(fields, "line", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    column: optional(fields, "column", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    end_line: optional(fields, "endLine", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    end_column: optional(fields, "endColumn", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    instruction_reference: optional(fields, "instructionReference", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
    offset: optional(fields, "offset", path, (value, path) => {
      integer(value, path, -9007199254740991L, 9007199254740991L)
    }),
    reason: optional(fields, "reason", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend Breakpoint with @json.FromJson::{from_json}

///|
pub(all) enum SteppingGranularity {
  Statement
  Line
  Instruction
}

///|
pub impl ToJson for SteppingGranularity with fn to_json(self) {
  match self {
    Statement => Json::string("statement")
    Line => Json::string("line")
    Instruction => Json::string("instruction")
  }
}

///|
pub extend SteppingGranularity with ToJson::{to_json}

///|
pub impl @json.FromJson for SteppingGranularity with fn from_json(value, path) {
  match value {
    String("statement") => Statement
    String("line") => Line
    String("instruction") => Instruction
    _ => invalid(path, "未知枚举值")
  }
}

///|
pub extend SteppingGranularity with @json.FromJson::{from_json}

///|
pub(all) struct StepInTarget {
  id : Int32
  label : String
  line : Int64?
  column : Int64?
  end_line : Int64?
  end_column : Int64?
}

///|
pub impl ToJson for StepInTarget with fn to_json(self) {
  let fields = Map([])
  fields.set("id", @json.to_json(self.id))
  fields.set("label", @json.to_json(self.label))
  if self.line is Some(item) {
    fields.set("line", wide_json(item))
  }
  if self.column is Some(item) {
    fields.set("column", wide_json(item))
  }
  if self.end_line is Some(item) {
    fields.set("endLine", wide_json(item))
  }
  if self.end_column is Some(item) {
    fields.set("endColumn", wide_json(item))
  }
  Json::object(fields)
}

///|
pub extend StepInTarget with ToJson::{to_json}

///|
pub impl @json.FromJson for StepInTarget with fn from_json(value, path) {
  let fields = object(value, path)
  {
    id: required(fields, "id", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    label: required(fields, "label", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    line: optional(fields, "line", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    column: optional(fields, "column", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    end_line: optional(fields, "endLine", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    end_column: optional(fields, "endColumn", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
  }
}

///|
pub extend StepInTarget with @json.FromJson::{from_json}

///|
pub(all) struct GotoTarget {
  id : Int32
  label : String
  line : Int64
  column : Int64?
  end_line : Int64?
  end_column : Int64?
  instruction_pointer_reference : String?
}

///|
pub impl ToJson for GotoTarget with fn to_json(self) {
  let fields = Map([])
  fields.set("id", @json.to_json(self.id))
  fields.set("label", @json.to_json(self.label))
  fields.set("line", wide_json(self.line))
  if self.column is Some(item) {
    fields.set("column", wide_json(item))
  }
  if self.end_line is Some(item) {
    fields.set("endLine", wide_json(item))
  }
  if self.end_column is Some(item) {
    fields.set("endColumn", wide_json(item))
  }
  if self.instruction_pointer_reference is Some(item) {
    fields.set("instructionPointerReference", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend GotoTarget with ToJson::{to_json}

///|
pub impl @json.FromJson for GotoTarget with fn from_json(value, path) {
  let fields = object(value, path)
  {
    id: required(fields, "id", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    label: required(fields, "label", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    line: required(fields, "line", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    column: optional(fields, "column", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    end_line: optional(fields, "endLine", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    end_column: optional(fields, "endColumn", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    instruction_pointer_reference: optional(
      fields,
      "instructionPointerReference",
      path,
      (value, path) => @json.from_json(value, path~),
    ),
  }
}

///|
pub extend GotoTarget with @json.FromJson::{from_json}

///|
pub(all) struct CompletionItem {
  label : String
  text : String?
  sort_text : String?
  detail : String?
  type_ : CompletionItemType?
  start : Int64?
  length : Int64?
  selection_start : Int64?
  selection_length : Int64?
}

///|
pub impl ToJson for CompletionItem with fn to_json(self) {
  let fields = Map([])
  fields.set("label", @json.to_json(self.label))
  if self.text is Some(item) {
    fields.set("text", @json.to_json(item))
  }
  if self.sort_text is Some(item) {
    fields.set("sortText", @json.to_json(item))
  }
  if self.detail is Some(item) {
    fields.set("detail", @json.to_json(item))
  }
  if self.type_ is Some(item) {
    fields.set("type", @json.to_json(item))
  }
  if self.start is Some(item) {
    fields.set("start", wide_json(item))
  }
  if self.length is Some(item) {
    fields.set("length", wide_json(item))
  }
  if self.selection_start is Some(item) {
    fields.set("selectionStart", wide_json(item))
  }
  if self.selection_length is Some(item) {
    fields.set("selectionLength", wide_json(item))
  }
  Json::object(fields)
}

///|
pub extend CompletionItem with ToJson::{to_json}

///|
pub impl @json.FromJson for CompletionItem with fn from_json(value, path) {
  let fields = object(value, path)
  {
    label: required(fields, "label", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    text: optional(fields, "text", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    sort_text: optional(fields, "sortText", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    detail: optional(fields, "detail", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    type_: optional(fields, "type", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    start: optional(fields, "start", path, (value, path) => {
      integer(value, path, 0L, 4294967295L)
    }),
    length: optional(fields, "length", path, (value, path) => {
      integer(value, path, 0L, 4294967295L)
    }),
    selection_start: optional(fields, "selectionStart", path, (value, path) => {
      integer(value, path, 0L, 4294967295L)
    }),
    selection_length: optional(fields, "selectionLength", path, (value, path) => {
      integer(value, path, 0L, 4294967295L)
    }),
  }
}

///|
pub extend CompletionItem with @json.FromJson::{from_json}

///|
pub(all) enum CompletionItemType {
  Method
  Function
  Constructor
  Field
  Variable
  Class
  Interface
  Module
  Property
  Unit
  Value
  Enum
  Keyword
  Snippet
  Text
  Color
  File
  Reference
  Customcolor
}

///|
pub impl ToJson for CompletionItemType with fn to_json(self) {
  match self {
    Method => Json::string("method")
    Function => Json::string("function")
    Constructor => Json::string("constructor")
    Field => Json::string("field")
    Variable => Json::string("variable")
    Class => Json::string("class")
    Interface => Json::string("interface")
    Module => Json::string("module")
    Property => Json::string("property")
    Unit => Json::string("unit")
    Value => Json::string("value")
    Enum => Json::string("enum")
    Keyword => Json::string("keyword")
    Snippet => Json::string("snippet")
    Text => Json::string("text")
    Color => Json::string("color")
    File => Json::string("file")
    Reference => Json::string("reference")
    Customcolor => Json::string("customcolor")
  }
}

///|
pub extend CompletionItemType with ToJson::{to_json}

///|
pub impl @json.FromJson for CompletionItemType with fn from_json(value, path) {
  match value {
    String("method") => Method
    String("function") => Function
    String("constructor") => Constructor
    String("field") => Field
    String("variable") => Variable
    String("class") => Class
    String("interface") => Interface
    String("module") => Module
    String("property") => Property
    String("unit") => Unit
    String("value") => Value
    String("enum") => Enum
    String("keyword") => Keyword
    String("snippet") => Snippet
    String("text") => Text
    String("color") => Color
    String("file") => File
    String("reference") => Reference
    String("customcolor") => Customcolor
    _ => invalid(path, "未知枚举值")
  }
}

///|
pub extend CompletionItemType with @json.FromJson::{from_json}

///|
pub(all) enum ChecksumAlgorithm {
  MD5
  SHA1
  SHA256
  Timestamp
}

///|
pub impl ToJson for ChecksumAlgorithm with fn to_json(self) {
  match self {
    MD5 => Json::string("MD5")
    SHA1 => Json::string("SHA1")
    SHA256 => Json::string("SHA256")
    Timestamp => Json::string("timestamp")
  }
}

///|
pub extend ChecksumAlgorithm with ToJson::{to_json}

///|
pub impl @json.FromJson for ChecksumAlgorithm with fn from_json(value, path) {
  match value {
    String("MD5") => MD5
    String("SHA1") => SHA1
    String("SHA256") => SHA256
    String("timestamp") => Timestamp
    _ => invalid(path, "未知枚举值")
  }
}

///|
pub extend ChecksumAlgorithm with @json.FromJson::{from_json}

///|
pub(all) struct Checksum {
  algorithm : ChecksumAlgorithm
  checksum : String
}

///|
pub impl ToJson for Checksum with fn to_json(self) {
  let fields = Map([])
  fields.set("algorithm", @json.to_json(self.algorithm))
  fields.set("checksum", @json.to_json(self.checksum))
  Json::object(fields)
}

///|
pub extend Checksum with ToJson::{to_json}

///|
pub impl @json.FromJson for Checksum with fn from_json(value, path) {
  let fields = object(value, path)
  {
    algorithm: required(fields, "algorithm", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    checksum: required(fields, "checksum", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend Checksum with @json.FromJson::{from_json}

///|
pub(all) struct ValueFormat {
  hex : Bool?
}

///|
pub impl ToJson for ValueFormat with fn to_json(self) {
  let fields = Map([])
  if self.hex is Some(item) {
    fields.set("hex", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend ValueFormat with ToJson::{to_json}

///|
pub impl @json.FromJson for ValueFormat with fn from_json(value, path) {
  let fields = object(value, path)
  {
    hex: optional(fields, "hex", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ValueFormat with @json.FromJson::{from_json}

///|
pub(all) struct StackFrameFormat {
  hex : Bool?
  parameters : Bool?
  parameter_types : Bool?
  parameter_names : Bool?
  parameter_values : Bool?
  line : Bool?
  module_ : Bool?
  include_all : Bool?
}

///|
pub impl ToJson for StackFrameFormat with fn to_json(self) {
  let fields = Map([])
  if self.hex is Some(item) {
    fields.set("hex", @json.to_json(item))
  }
  if self.parameters is Some(item) {
    fields.set("parameters", @json.to_json(item))
  }
  if self.parameter_types is Some(item) {
    fields.set("parameterTypes", @json.to_json(item))
  }
  if self.parameter_names is Some(item) {
    fields.set("parameterNames", @json.to_json(item))
  }
  if self.parameter_values is Some(item) {
    fields.set("parameterValues", @json.to_json(item))
  }
  if self.line is Some(item) {
    fields.set("line", @json.to_json(item))
  }
  if self.module_ is Some(item) {
    fields.set("module", @json.to_json(item))
  }
  if self.include_all is Some(item) {
    fields.set("includeAll", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend StackFrameFormat with ToJson::{to_json}

///|
pub impl @json.FromJson for StackFrameFormat with fn from_json(value, path) {
  let fields = object(value, path)
  {
    hex: optional(fields, "hex", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    parameters: optional(fields, "parameters", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    parameter_types: optional(fields, "parameterTypes", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    parameter_names: optional(fields, "parameterNames", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    parameter_values: optional(fields, "parameterValues", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    line: optional(fields, "line", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    module_: optional(fields, "module", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    include_all: optional(fields, "includeAll", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend StackFrameFormat with @json.FromJson::{from_json}

///|
pub(all) struct ExceptionFilterOptions {
  filter_id : String
  condition : String?
  mode : String?
}

///|
pub impl ToJson for ExceptionFilterOptions with fn to_json(self) {
  let fields = Map([])
  fields.set("filterId", @json.to_json(self.filter_id))
  if self.condition is Some(item) {
    fields.set("condition", @json.to_json(item))
  }
  if self.mode is Some(item) {
    fields.set("mode", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend ExceptionFilterOptions with ToJson::{to_json}

///|
pub impl @json.FromJson for ExceptionFilterOptions with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    filter_id: required(fields, "filterId", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    condition: optional(fields, "condition", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    mode: optional(fields, "mode", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ExceptionFilterOptions with @json.FromJson::{from_json}

///|
pub(all) struct ExceptionOptions {
  path : Array[ExceptionPathSegment]?
  break_mode : ExceptionBreakMode
}

///|
pub impl ToJson for ExceptionOptions with fn to_json(self) {
  let fields = Map([])
  if self.path is Some(item) {
    fields.set("path", Json::array(item.map(item => @json.to_json(item))))
  }
  fields.set("breakMode", @json.to_json(self.break_mode))
  Json::object(fields)
}

///|
pub extend ExceptionOptions with ToJson::{to_json}

///|
pub impl @json.FromJson for ExceptionOptions with fn from_json(value, path) {
  let fields = object(value, path)
  {
    path: optional(fields, "path", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
    break_mode: required(fields, "breakMode", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ExceptionOptions with @json.FromJson::{from_json}

///|
pub(all) enum ExceptionBreakMode {
  Never
  Always
  Unhandled
  UserUnhandled
}

///|
pub impl ToJson for ExceptionBreakMode with fn to_json(self) {
  match self {
    Never => Json::string("never")
    Always => Json::string("always")
    Unhandled => Json::string("unhandled")
    UserUnhandled => Json::string("userUnhandled")
  }
}

///|
pub extend ExceptionBreakMode with ToJson::{to_json}

///|
pub impl @json.FromJson for ExceptionBreakMode with fn from_json(value, path) {
  match value {
    String("never") => Never
    String("always") => Always
    String("unhandled") => Unhandled
    String("userUnhandled") => UserUnhandled
    _ => invalid(path, "未知枚举值")
  }
}

///|
pub extend ExceptionBreakMode with @json.FromJson::{from_json}

///|
pub(all) struct ExceptionPathSegment {
  negate : Bool?
  names : Array[String]
}

///|
pub impl ToJson for ExceptionPathSegment with fn to_json(self) {
  let fields = Map([])
  if self.negate is Some(item) {
    fields.set("negate", @json.to_json(item))
  }
  fields.set("names", Json::array(self.names.map(item => @json.to_json(item))))
  Json::object(fields)
}

///|
pub extend ExceptionPathSegment with ToJson::{to_json}

///|
pub impl @json.FromJson for ExceptionPathSegment with fn from_json(value, path) {
  let fields = object(value, path)
  {
    negate: optional(fields, "negate", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    names: required(fields, "names", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend ExceptionPathSegment with @json.FromJson::{from_json}

///|
pub(all) struct ExceptionDetails {
  message : String?
  type_name : String?
  full_type_name : String?
  evaluate_name : String?
  stack_trace : String?
  inner_exception : Array[ExceptionDetails]?
}

///|
pub impl ToJson for ExceptionDetails with fn to_json(self) {
  let fields = Map([])
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.type_name is Some(item) {
    fields.set("typeName", @json.to_json(item))
  }
  if self.full_type_name is Some(item) {
    fields.set("fullTypeName", @json.to_json(item))
  }
  if self.evaluate_name is Some(item) {
    fields.set("evaluateName", @json.to_json(item))
  }
  if self.stack_trace is Some(item) {
    fields.set("stackTrace", @json.to_json(item))
  }
  if self.inner_exception is Some(item) {
    fields.set(
      "innerException",
      Json::array(item.map(item => @json.to_json(item))),
    )
  }
  Json::object(fields)
}

///|
pub extend ExceptionDetails with ToJson::{to_json}

///|
pub impl @json.FromJson for ExceptionDetails with fn from_json(value, path) {
  let fields = object(value, path)
  {
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    type_name: optional(fields, "typeName", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    full_type_name: optional(fields, "fullTypeName", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    evaluate_name: optional(fields, "evaluateName", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    stack_trace: optional(fields, "stackTrace", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    inner_exception: optional(fields, "innerException", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend ExceptionDetails with @json.FromJson::{from_json}

///|
pub(all) struct DisassembledInstruction {
  address : String
  instruction_bytes : String?
  instruction : String
  symbol : String?
  location : Source?
  line : Int64?
  column : Int64?
  end_line : Int64?
  end_column : Int64?
  presentation_hint : DisassembledInstructionPresentationHint?
}

///|
pub impl ToJson for DisassembledInstruction with fn to_json(self) {
  let fields = Map([])
  fields.set("address", @json.to_json(self.address))
  if self.instruction_bytes is Some(item) {
    fields.set("instructionBytes", @json.to_json(item))
  }
  fields.set("instruction", @json.to_json(self.instruction))
  if self.symbol is Some(item) {
    fields.set("symbol", @json.to_json(item))
  }
  if self.location is Some(item) {
    fields.set("location", @json.to_json(item))
  }
  if self.line is Some(item) {
    fields.set("line", wide_json(item))
  }
  if self.column is Some(item) {
    fields.set("column", wide_json(item))
  }
  if self.end_line is Some(item) {
    fields.set("endLine", wide_json(item))
  }
  if self.end_column is Some(item) {
    fields.set("endColumn", wide_json(item))
  }
  if self.presentation_hint is Some(item) {
    fields.set("presentationHint", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend DisassembledInstruction with ToJson::{to_json}

///|
pub impl @json.FromJson for DisassembledInstruction with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    address: required(fields, "address", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    instruction_bytes: optional(fields, "instructionBytes", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    instruction: required(fields, "instruction", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    symbol: optional(fields, "symbol", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    location: optional(fields, "location", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    line: optional(fields, "line", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    column: optional(fields, "column", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    end_line: optional(fields, "endLine", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    end_column: optional(fields, "endColumn", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    presentation_hint: optional(fields, "presentationHint", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend DisassembledInstruction with @json.FromJson::{from_json}

///|
pub(all) struct InvalidatedAreas {
  value : String
}

///|
pub impl ToJson for InvalidatedAreas with fn to_json(self) {
  Json::string(self.value)
}

///|
pub extend InvalidatedAreas with ToJson::{to_json}

///|
pub impl @json.FromJson for InvalidatedAreas with fn from_json(value, path) {
  { value: @json.from_json(value, path~), }
}

///|
pub extend InvalidatedAreas with @json.FromJson::{from_json}

///|
pub(all) struct BreakpointMode {
  mode : String
  label : String
  description : String?
  applies_to : Array[BreakpointModeApplicability]
}

///|
pub impl ToJson for BreakpointMode with fn to_json(self) {
  let fields = Map([])
  fields.set("mode", @json.to_json(self.mode))
  fields.set("label", @json.to_json(self.label))
  if self.description is Some(item) {
    fields.set("description", @json.to_json(item))
  }
  fields.set(
    "appliesTo",
    Json::array(self.applies_to.map(item => @json.to_json(item))),
  )
  Json::object(fields)
}

///|
pub extend BreakpointMode with ToJson::{to_json}

///|
pub impl @json.FromJson for BreakpointMode with fn from_json(value, path) {
  let fields = object(value, path)
  {
    mode: required(fields, "mode", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    label: required(fields, "label", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    description: optional(fields, "description", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    applies_to: required(fields, "appliesTo", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend BreakpointMode with @json.FromJson::{from_json}

///|
pub(all) struct BreakpointModeApplicability {
  value : String
}

///|
pub impl ToJson for BreakpointModeApplicability with fn to_json(self) {
  Json::string(self.value)
}

///|
pub extend BreakpointModeApplicability with ToJson::{to_json}

///|
pub impl @json.FromJson for BreakpointModeApplicability with fn from_json(
  value,
  path,
) {
  { value: @json.from_json(value, path~), }
}

///|
pub extend BreakpointModeApplicability with @json.FromJson::{from_json}

///|
pub(all) struct ErrorResponseBody {
  error : Message?
}

///|
pub impl ToJson for ErrorResponseBody with fn to_json(self) {
  let fields = Map([])
  if self.error is Some(item) {
    fields.set("error", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend ErrorResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for ErrorResponseBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    error: optional(fields, "error", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ErrorResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct StoppedEventBody {
  reason : String
  description : String?
  thread_id : Int32?
  preserve_focus_hint : Bool?
  text : String?
  all_threads_stopped : Bool?
  hit_breakpoint_ids : Array[Int32]?
}

///|
pub impl ToJson for StoppedEventBody with fn to_json(self) {
  let fields = Map([])
  fields.set("reason", @json.to_json(self.reason))
  if self.description is Some(item) {
    fields.set("description", @json.to_json(item))
  }
  if self.thread_id is Some(item) {
    fields.set("threadId", @json.to_json(item))
  }
  if self.preserve_focus_hint is Some(item) {
    fields.set("preserveFocusHint", @json.to_json(item))
  }
  if self.text is Some(item) {
    fields.set("text", @json.to_json(item))
  }
  if self.all_threads_stopped is Some(item) {
    fields.set("allThreadsStopped", @json.to_json(item))
  }
  if self.hit_breakpoint_ids is Some(item) {
    fields.set(
      "hitBreakpointIds",
      Json::array(item.map(item => @json.to_json(item))),
    )
  }
  Json::object(fields)
}

///|
pub extend StoppedEventBody with ToJson::{to_json}

///|
pub impl @json.FromJson for StoppedEventBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    reason: required(fields, "reason", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    description: optional(fields, "description", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    thread_id: optional(fields, "threadId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    preserve_focus_hint: optional(fields, "preserveFocusHint", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
    text: optional(fields, "text", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    all_threads_stopped: optional(fields, "allThreadsStopped", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
    hit_breakpoint_ids: optional(fields, "hitBreakpointIds", path, (value, path) => {
      array_of(value, path, (value, path) => {
        integer(value, path, -2147483648L, 2147483647L).to_int()
      })
    }),
  }
}

///|
pub extend StoppedEventBody with @json.FromJson::{from_json}

///|
pub(all) struct ContinuedEventBody {
  thread_id : Int32
  all_threads_continued : Bool?
}

///|
pub impl ToJson for ContinuedEventBody with fn to_json(self) {
  let fields = Map([])
  fields.set("threadId", @json.to_json(self.thread_id))
  if self.all_threads_continued is Some(item) {
    fields.set("allThreadsContinued", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend ContinuedEventBody with ToJson::{to_json}

///|
pub impl @json.FromJson for ContinuedEventBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    thread_id: required(fields, "threadId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    all_threads_continued: optional(fields, "allThreadsContinued", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
  }
}

///|
pub extend ContinuedEventBody with @json.FromJson::{from_json}

///|
pub(all) struct ExitedEventBody {
  exit_code : Int32
}

///|
pub impl ToJson for ExitedEventBody with fn to_json(self) {
  let fields = Map([])
  fields.set("exitCode", @json.to_json(self.exit_code))
  Json::object(fields)
}

///|
pub extend ExitedEventBody with ToJson::{to_json}

///|
pub impl @json.FromJson for ExitedEventBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    exit_code: required(fields, "exitCode", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
  }
}

///|
pub extend ExitedEventBody with @json.FromJson::{from_json}

///|
pub(all) struct TerminatedEventBody {
  restart : Json?
}

///|
pub impl ToJson for TerminatedEventBody with fn to_json(self) {
  let fields = Map([])
  if self.restart is Some(item) {
    fields.set("restart", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend TerminatedEventBody with ToJson::{to_json}

///|
pub impl @json.FromJson for TerminatedEventBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    restart: optional(fields, "restart", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend TerminatedEventBody with @json.FromJson::{from_json}

///|
pub(all) struct ThreadEventBody {
  reason : String
  thread_id : Int32
}

///|
pub impl ToJson for ThreadEventBody with fn to_json(self) {
  let fields = Map([])
  fields.set("reason", @json.to_json(self.reason))
  fields.set("threadId", @json.to_json(self.thread_id))
  Json::object(fields)
}

///|
pub extend ThreadEventBody with ToJson::{to_json}

///|
pub impl @json.FromJson for ThreadEventBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    reason: required(fields, "reason", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    thread_id: required(fields, "threadId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
  }
}

///|
pub extend ThreadEventBody with @json.FromJson::{from_json}

///|
pub(all) struct OutputEventBody {
  category : String?
  output : String
  group : OutputEventBodyGroup?
  variables_reference : Int32?
  source : Source?
  line : Int64?
  column : Int64?
  data : Json?
  location_reference : Int32?
}

///|
pub impl ToJson for OutputEventBody with fn to_json(self) {
  let fields = Map([])
  if self.category is Some(item) {
    fields.set("category", @json.to_json(item))
  }
  fields.set("output", @json.to_json(self.output))
  if self.group is Some(item) {
    fields.set("group", @json.to_json(item))
  }
  if self.variables_reference is Some(item) {
    fields.set("variablesReference", @json.to_json(item))
  }
  if self.source is Some(item) {
    fields.set("source", @json.to_json(item))
  }
  if self.line is Some(item) {
    fields.set("line", wide_json(item))
  }
  if self.column is Some(item) {
    fields.set("column", wide_json(item))
  }
  if self.data is Some(item) {
    fields.set("data", @json.to_json(item))
  }
  if self.location_reference is Some(item) {
    fields.set("locationReference", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend OutputEventBody with ToJson::{to_json}

///|
pub impl @json.FromJson for OutputEventBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    category: optional(fields, "category", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    output: required(fields, "output", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    group: optional(fields, "group", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    variables_reference: optional(fields, "variablesReference", path, (
      value,
      path,
    ) => integer(value, path, 0L, 2147483647L).to_int()),
    source: optional(fields, "source", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    line: optional(fields, "line", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    column: optional(fields, "column", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    data: optional(fields, "data", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    location_reference: optional(fields, "locationReference", path, (
      value,
      path,
    ) => integer(value, path, -2147483648L, 2147483647L).to_int()),
  }
}

///|
pub extend OutputEventBody with @json.FromJson::{from_json}

///|
pub(all) struct BreakpointEventBody {
  reason : String
  breakpoint : Breakpoint
}

///|
pub impl ToJson for BreakpointEventBody with fn to_json(self) {
  let fields = Map([])
  fields.set("reason", @json.to_json(self.reason))
  fields.set("breakpoint", @json.to_json(self.breakpoint))
  Json::object(fields)
}

///|
pub extend BreakpointEventBody with ToJson::{to_json}

///|
pub impl @json.FromJson for BreakpointEventBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    reason: required(fields, "reason", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    breakpoint: required(fields, "breakpoint", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend BreakpointEventBody with @json.FromJson::{from_json}

///|
pub(all) struct ModuleEventBody {
  reason : ModuleEventBodyReason
  module_ : Module
}

///|
pub impl ToJson for ModuleEventBody with fn to_json(self) {
  let fields = Map([])
  fields.set("reason", @json.to_json(self.reason))
  fields.set("module", @json.to_json(self.module_))
  Json::object(fields)
}

///|
pub extend ModuleEventBody with ToJson::{to_json}

///|
pub impl @json.FromJson for ModuleEventBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    reason: required(fields, "reason", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    module_: required(fields, "module", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ModuleEventBody with @json.FromJson::{from_json}

///|
pub(all) struct LoadedSourceEventBody {
  reason : LoadedSourceEventBodyReason
  source : Source
}

///|
pub impl ToJson for LoadedSourceEventBody with fn to_json(self) {
  let fields = Map([])
  fields.set("reason", @json.to_json(self.reason))
  fields.set("source", @json.to_json(self.source))
  Json::object(fields)
}

///|
pub extend LoadedSourceEventBody with ToJson::{to_json}

///|
pub impl @json.FromJson for LoadedSourceEventBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    reason: required(fields, "reason", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    source: required(fields, "source", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend LoadedSourceEventBody with @json.FromJson::{from_json}

///|
pub(all) struct ProcessEventBody {
  name : String
  system_process_id : Int32?
  is_local_process : Bool?
  start_method : ProcessEventBodyStartMethod?
  pointer_size : Int64?
}

///|
pub impl ToJson for ProcessEventBody with fn to_json(self) {
  let fields = Map([])
  fields.set("name", @json.to_json(self.name))
  if self.system_process_id is Some(item) {
    fields.set("systemProcessId", @json.to_json(item))
  }
  if self.is_local_process is Some(item) {
    fields.set("isLocalProcess", @json.to_json(item))
  }
  if self.start_method is Some(item) {
    fields.set("startMethod", @json.to_json(item))
  }
  if self.pointer_size is Some(item) {
    fields.set("pointerSize", wide_json(item))
  }
  Json::object(fields)
}

///|
pub extend ProcessEventBody with ToJson::{to_json}

///|
pub impl @json.FromJson for ProcessEventBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    name: required(fields, "name", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    system_process_id: optional(fields, "systemProcessId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    is_local_process: optional(fields, "isLocalProcess", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    start_method: optional(fields, "startMethod", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    pointer_size: optional(fields, "pointerSize", path, (value, path) => {
      integer(value, path, 0L, 4294967295L)
    }),
  }
}

///|
pub extend ProcessEventBody with @json.FromJson::{from_json}

///|
pub(all) struct CapabilitiesEventBody {
  capabilities : Capabilities
}

///|
pub impl ToJson for CapabilitiesEventBody with fn to_json(self) {
  let fields = Map([])
  fields.set("capabilities", @json.to_json(self.capabilities))
  Json::object(fields)
}

///|
pub extend CapabilitiesEventBody with ToJson::{to_json}

///|
pub impl @json.FromJson for CapabilitiesEventBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    capabilities: required(fields, "capabilities", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend CapabilitiesEventBody with @json.FromJson::{from_json}

///|
pub(all) struct ProgressStartEventBody {
  progress_id : String
  title : String
  request_id : Int32?
  cancellable : Bool?
  message : String?
  percentage : Double?
}

///|
pub impl ToJson for ProgressStartEventBody with fn to_json(self) {
  let fields = Map([])
  fields.set("progressId", @json.to_json(self.progress_id))
  fields.set("title", @json.to_json(self.title))
  if self.request_id is Some(item) {
    fields.set("requestId", @json.to_json(item))
  }
  if self.cancellable is Some(item) {
    fields.set("cancellable", @json.to_json(item))
  }
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.percentage is Some(item) {
    fields.set("percentage", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend ProgressStartEventBody with ToJson::{to_json}

///|
pub impl @json.FromJson for ProgressStartEventBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    progress_id: required(fields, "progressId", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    title: required(fields, "title", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    request_id: optional(fields, "requestId", path, (value, path) => {
      integer(value, path, 1L, 2147483647L).to_int()
    }),
    cancellable: optional(fields, "cancellable", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    percentage: optional(fields, "percentage", path, (value, path) => {
      number(value, path)
    }),
  }
}

///|
pub extend ProgressStartEventBody with @json.FromJson::{from_json}

///|
pub(all) struct ProgressUpdateEventBody {
  progress_id : String
  message : String?
  percentage : Double?
}

///|
pub impl ToJson for ProgressUpdateEventBody with fn to_json(self) {
  let fields = Map([])
  fields.set("progressId", @json.to_json(self.progress_id))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  if self.percentage is Some(item) {
    fields.set("percentage", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend ProgressUpdateEventBody with ToJson::{to_json}

///|
pub impl @json.FromJson for ProgressUpdateEventBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    progress_id: required(fields, "progressId", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    percentage: optional(fields, "percentage", path, (value, path) => {
      number(value, path)
    }),
  }
}

///|
pub extend ProgressUpdateEventBody with @json.FromJson::{from_json}

///|
pub(all) struct ProgressEndEventBody {
  progress_id : String
  message : String?
}

///|
pub impl ToJson for ProgressEndEventBody with fn to_json(self) {
  let fields = Map([])
  fields.set("progressId", @json.to_json(self.progress_id))
  if self.message is Some(item) {
    fields.set("message", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend ProgressEndEventBody with ToJson::{to_json}

///|
pub impl @json.FromJson for ProgressEndEventBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    progress_id: required(fields, "progressId", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    message: optional(fields, "message", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ProgressEndEventBody with @json.FromJson::{from_json}

///|
pub(all) struct InvalidatedEventBody {
  areas : Array[InvalidatedAreas]?
  thread_id : Int32?
  stack_frame_id : Int32?
}

///|
pub impl ToJson for InvalidatedEventBody with fn to_json(self) {
  let fields = Map([])
  if self.areas is Some(item) {
    fields.set("areas", Json::array(item.map(item => @json.to_json(item))))
  }
  if self.thread_id is Some(item) {
    fields.set("threadId", @json.to_json(item))
  }
  if self.stack_frame_id is Some(item) {
    fields.set("stackFrameId", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend InvalidatedEventBody with ToJson::{to_json}

///|
pub impl @json.FromJson for InvalidatedEventBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    areas: optional(fields, "areas", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
    thread_id: optional(fields, "threadId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    stack_frame_id: optional(fields, "stackFrameId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
  }
}

///|
pub extend InvalidatedEventBody with @json.FromJson::{from_json}

///|
pub(all) struct MemoryEventBody {
  memory_reference : String
  offset : Int64
  count : Int64
}

///|
pub impl ToJson for MemoryEventBody with fn to_json(self) {
  let fields = Map([])
  fields.set("memoryReference", @json.to_json(self.memory_reference))
  fields.set("offset", wide_json(self.offset))
  fields.set("count", wide_json(self.count))
  Json::object(fields)
}

///|
pub extend MemoryEventBody with ToJson::{to_json}

///|
pub impl @json.FromJson for MemoryEventBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    memory_reference: required(fields, "memoryReference", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    offset: required(fields, "offset", path, (value, path) => {
      integer(value, path, -9007199254740991L, 9007199254740991L)
    }),
    count: required(fields, "count", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
  }
}

///|
pub extend MemoryEventBody with @json.FromJson::{from_json}

///|
pub(all) enum RunInTerminalRequestArgumentsKind {
  Integrated
  External
}

///|
pub impl ToJson for RunInTerminalRequestArgumentsKind with fn to_json(self) {
  match self {
    Integrated => Json::string("integrated")
    External => Json::string("external")
  }
}

///|
pub extend RunInTerminalRequestArgumentsKind with ToJson::{to_json}

///|
pub impl @json.FromJson for RunInTerminalRequestArgumentsKind with fn from_json(
  value,
  path,
) {
  match value {
    String("integrated") => Integrated
    String("external") => External
    _ => invalid(path, "未知枚举值")
  }
}

///|
pub extend RunInTerminalRequestArgumentsKind with @json.FromJson::{from_json}

///|
pub(all) enum RunInTerminalRequestArgumentsEnvValue {
  Text(String)
  NullValue
}

///|
pub impl ToJson for RunInTerminalRequestArgumentsEnvValue with fn to_json(self) {
  match self {
    Text(item) => Json::string(item)
    NullValue => Json::null()
  }
}

///|
pub extend RunInTerminalRequestArgumentsEnvValue with ToJson::{to_json}

///|
pub impl @json.FromJson for RunInTerminalRequestArgumentsEnvValue with fn from_json(
  value,
  path,
) {
  match value {
    String(item) => Text(item)
    Null => NullValue
    _ => invalid(path, "需要字符串或 null")
  }
}

///|
pub extend RunInTerminalRequestArgumentsEnvValue with @json.FromJson::{
  from_json,
}

///|
pub(all) struct RunInTerminalResponseBody {
  process_id : Int32?
  shell_process_id : Int32?
}

///|
pub impl ToJson for RunInTerminalResponseBody with fn to_json(self) {
  let fields = Map([])
  if self.process_id is Some(item) {
    fields.set("processId", @json.to_json(item))
  }
  if self.shell_process_id is Some(item) {
    fields.set("shellProcessId", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend RunInTerminalResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for RunInTerminalResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    process_id: optional(fields, "processId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
    shell_process_id: optional(fields, "shellProcessId", path, (value, path) => {
      integer(value, path, -2147483648L, 2147483647L).to_int()
    }),
  }
}

///|
pub extend RunInTerminalResponseBody with @json.FromJson::{from_json}

///|
pub(all) enum StartDebuggingRequestArgumentsOutputPresentation {
  Separate
  MergeWithParent
}

///|
pub impl ToJson for StartDebuggingRequestArgumentsOutputPresentation with fn to_json(
  self,
) {
  match self {
    Separate => Json::string("separate")
    MergeWithParent => Json::string("mergeWithParent")
  }
}

///|
pub extend StartDebuggingRequestArgumentsOutputPresentation with ToJson::{
  to_json,
}

///|
pub impl @json.FromJson for StartDebuggingRequestArgumentsOutputPresentation with fn from_json(
  value,
  path,
) {
  match value {
    String("separate") => Separate
    String("mergeWithParent") => MergeWithParent
    _ => invalid(path, "未知枚举值")
  }
}

///|
pub extend StartDebuggingRequestArgumentsOutputPresentation with @json.FromJson::{
  from_json,
}

///|
pub(all) enum StartDebuggingRequestArgumentsRequest {
  Launch
  Attach
}

///|
pub impl ToJson for StartDebuggingRequestArgumentsRequest with fn to_json(self) {
  match self {
    Launch => Json::string("launch")
    Attach => Json::string("attach")
  }
}

///|
pub extend StartDebuggingRequestArgumentsRequest with ToJson::{to_json}

///|
pub impl @json.FromJson for StartDebuggingRequestArgumentsRequest with fn from_json(
  value,
  path,
) {
  match value {
    String("launch") => Launch
    String("attach") => Attach
    _ => invalid(path, "未知枚举值")
  }
}

///|
pub extend StartDebuggingRequestArgumentsRequest with @json.FromJson::{
  from_json,
}

///|
pub(all) enum RestartArgumentsArguments {
  First(LaunchRequestArguments)
  Second(AttachRequestArguments)
}

///|
pub impl ToJson for RestartArgumentsArguments with fn to_json(self) {
  match self {
    First(item) => @json.to_json(item)
    Second(item) => @json.to_json(item)
  }
}

///|
pub extend RestartArgumentsArguments with ToJson::{to_json}

///|
pub impl @json.FromJson for RestartArgumentsArguments with fn from_json(
  value,
  path,
) {
  let first : LaunchRequestArguments? = Some(@json.from_json(value, path~)) catch {
    _ => None
  }
  let second : AttachRequestArguments? = Some(@json.from_json(value, path~)) catch {
    _ => None
  }
  match (first, second) {
    (Some(item), None) => First(item)
    (None, Some(item)) => Second(item)
    _ => invalid(path, "oneOf 必须恰好匹配一个分支")
  }
}

///|
pub extend RestartArgumentsArguments with @json.FromJson::{from_json}

///|
pub(all) struct BreakpointLocationsResponseBody {
  breakpoints : Array[BreakpointLocation]
}

///|
pub impl ToJson for BreakpointLocationsResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "breakpoints",
    Json::array(self.breakpoints.map(item => @json.to_json(item))),
  )
  Json::object(fields)
}

///|
pub extend BreakpointLocationsResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for BreakpointLocationsResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    breakpoints: required(fields, "breakpoints", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend BreakpointLocationsResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct SetBreakpointsResponseBody {
  breakpoints : Array[Breakpoint]
}

///|
pub impl ToJson for SetBreakpointsResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "breakpoints",
    Json::array(self.breakpoints.map(item => @json.to_json(item))),
  )
  Json::object(fields)
}

///|
pub extend SetBreakpointsResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for SetBreakpointsResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    breakpoints: required(fields, "breakpoints", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend SetBreakpointsResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct SetFunctionBreakpointsResponseBody {
  breakpoints : Array[Breakpoint]
}

///|
pub impl ToJson for SetFunctionBreakpointsResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "breakpoints",
    Json::array(self.breakpoints.map(item => @json.to_json(item))),
  )
  Json::object(fields)
}

///|
pub extend SetFunctionBreakpointsResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for SetFunctionBreakpointsResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    breakpoints: required(fields, "breakpoints", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend SetFunctionBreakpointsResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct SetExceptionBreakpointsResponseBody {
  breakpoints : Array[Breakpoint]?
}

///|
pub impl ToJson for SetExceptionBreakpointsResponseBody with fn to_json(self) {
  let fields = Map([])
  if self.breakpoints is Some(item) {
    fields.set(
      "breakpoints",
      Json::array(item.map(item => @json.to_json(item))),
    )
  }
  Json::object(fields)
}

///|
pub extend SetExceptionBreakpointsResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for SetExceptionBreakpointsResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    breakpoints: optional(fields, "breakpoints", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend SetExceptionBreakpointsResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct DataBreakpointInfoResponseBody {
  data_id : DataBreakpointInfoResponseBodyDataId
  description : String
  access_types : Array[DataBreakpointAccessType]?
  can_persist : Bool?
}

///|
pub impl ToJson for DataBreakpointInfoResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set("dataId", @json.to_json(self.data_id))
  fields.set("description", @json.to_json(self.description))
  if self.access_types is Some(item) {
    fields.set(
      "accessTypes",
      Json::array(item.map(item => @json.to_json(item))),
    )
  }
  if self.can_persist is Some(item) {
    fields.set("canPersist", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend DataBreakpointInfoResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for DataBreakpointInfoResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    data_id: required(fields, "dataId", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    description: required(fields, "description", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    access_types: optional(fields, "accessTypes", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
    can_persist: optional(fields, "canPersist", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend DataBreakpointInfoResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct SetDataBreakpointsResponseBody {
  breakpoints : Array[Breakpoint]
}

///|
pub impl ToJson for SetDataBreakpointsResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "breakpoints",
    Json::array(self.breakpoints.map(item => @json.to_json(item))),
  )
  Json::object(fields)
}

///|
pub extend SetDataBreakpointsResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for SetDataBreakpointsResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    breakpoints: required(fields, "breakpoints", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend SetDataBreakpointsResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct SetInstructionBreakpointsResponseBody {
  breakpoints : Array[Breakpoint]
}

///|
pub impl ToJson for SetInstructionBreakpointsResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "breakpoints",
    Json::array(self.breakpoints.map(item => @json.to_json(item))),
  )
  Json::object(fields)
}

///|
pub extend SetInstructionBreakpointsResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for SetInstructionBreakpointsResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    breakpoints: required(fields, "breakpoints", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend SetInstructionBreakpointsResponseBody with @json.FromJson::{
  from_json,
}

///|
pub(all) struct ContinueResponseBody {
  all_threads_continued : Bool?
}

///|
pub impl ToJson for ContinueResponseBody with fn to_json(self) {
  let fields = Map([])
  if self.all_threads_continued is Some(item) {
    fields.set("allThreadsContinued", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend ContinueResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for ContinueResponseBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    all_threads_continued: optional(fields, "allThreadsContinued", path, (
      value,
      path,
    ) => @json.from_json(value, path~)),
  }
}

///|
pub extend ContinueResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct StackTraceResponseBody {
  stack_frames : Array[StackFrame]
  total_frames : Int64?
}

///|
pub impl ToJson for StackTraceResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "stackFrames",
    Json::array(self.stack_frames.map(item => @json.to_json(item))),
  )
  if self.total_frames is Some(item) {
    fields.set("totalFrames", wide_json(item))
  }
  Json::object(fields)
}

///|
pub extend StackTraceResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for StackTraceResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    stack_frames: required(fields, "stackFrames", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
    total_frames: optional(fields, "totalFrames", path, (value, path) => {
      integer(value, path, 0L, 4294967295L)
    }),
  }
}

///|
pub extend StackTraceResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct ScopesResponseBody {
  scopes : Array[Scope]
}

///|
pub impl ToJson for ScopesResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "scopes",
    Json::array(self.scopes.map(item => @json.to_json(item))),
  )
  Json::object(fields)
}

///|
pub extend ScopesResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for ScopesResponseBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    scopes: required(fields, "scopes", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend ScopesResponseBody with @json.FromJson::{from_json}

///|
pub(all) enum VariablesArgumentsFilter {
  Indexed
  Named
}

///|
pub impl ToJson for VariablesArgumentsFilter with fn to_json(self) {
  match self {
    Indexed => Json::string("indexed")
    Named => Json::string("named")
  }
}

///|
pub extend VariablesArgumentsFilter with ToJson::{to_json}

///|
pub impl @json.FromJson for VariablesArgumentsFilter with fn from_json(
  value,
  path,
) {
  match value {
    String("indexed") => Indexed
    String("named") => Named
    _ => invalid(path, "未知枚举值")
  }
}

///|
pub extend VariablesArgumentsFilter with @json.FromJson::{from_json}

///|
pub(all) struct VariablesResponseBody {
  variables : Array[Variable]
}

///|
pub impl ToJson for VariablesResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "variables",
    Json::array(self.variables.map(item => @json.to_json(item))),
  )
  Json::object(fields)
}

///|
pub extend VariablesResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for VariablesResponseBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    variables: required(fields, "variables", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend VariablesResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct SetVariableResponseBody {
  value : String
  type_ : String?
  variables_reference : Int32?
  named_variables : Int32?
  indexed_variables : Int32?
  memory_reference : String?
  value_location_reference : Int32?
}

///|
pub impl ToJson for SetVariableResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set("value", @json.to_json(self.value))
  if self.type_ is Some(item) {
    fields.set("type", @json.to_json(item))
  }
  if self.variables_reference is Some(item) {
    fields.set("variablesReference", @json.to_json(item))
  }
  if self.named_variables is Some(item) {
    fields.set("namedVariables", @json.to_json(item))
  }
  if self.indexed_variables is Some(item) {
    fields.set("indexedVariables", @json.to_json(item))
  }
  if self.memory_reference is Some(item) {
    fields.set("memoryReference", @json.to_json(item))
  }
  if self.value_location_reference is Some(item) {
    fields.set("valueLocationReference", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend SetVariableResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for SetVariableResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    value: required(fields, "value", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    type_: optional(fields, "type", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    variables_reference: optional(fields, "variablesReference", path, (
      value,
      path,
    ) => integer(value, path, 0L, 2147483647L).to_int()),
    named_variables: optional(fields, "namedVariables", path, (value, path) => {
      integer(value, path, 0L, 2147483647L).to_int()
    }),
    indexed_variables: optional(fields, "indexedVariables", path, (value, path) => {
      integer(value, path, 0L, 2147483647L).to_int()
    }),
    memory_reference: optional(fields, "memoryReference", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    value_location_reference: optional(fields, "valueLocationReference", path, (
      value,
      path,
    ) => integer(value, path, -2147483648L, 2147483647L).to_int()),
  }
}

///|
pub extend SetVariableResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct SourceResponseBody {
  content : String
  mime_type : String?
}

///|
pub impl ToJson for SourceResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set("content", @json.to_json(self.content))
  if self.mime_type is Some(item) {
    fields.set("mimeType", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend SourceResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for SourceResponseBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    content: required(fields, "content", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    mime_type: optional(fields, "mimeType", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend SourceResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct ThreadsResponseBody {
  threads : Array[Thread]
}

///|
pub impl ToJson for ThreadsResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "threads",
    Json::array(self.threads.map(item => @json.to_json(item))),
  )
  Json::object(fields)
}

///|
pub extend ThreadsResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for ThreadsResponseBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    threads: required(fields, "threads", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend ThreadsResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct ModulesResponseBody {
  modules : Array[Module]
  total_modules : Int64?
}

///|
pub impl ToJson for ModulesResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "modules",
    Json::array(self.modules.map(item => @json.to_json(item))),
  )
  if self.total_modules is Some(item) {
    fields.set("totalModules", wide_json(item))
  }
  Json::object(fields)
}

///|
pub extend ModulesResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for ModulesResponseBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    modules: required(fields, "modules", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
    total_modules: optional(fields, "totalModules", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
  }
}

///|
pub extend ModulesResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct LoadedSourcesResponseBody {
  sources : Array[Source]
}

///|
pub impl ToJson for LoadedSourcesResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "sources",
    Json::array(self.sources.map(item => @json.to_json(item))),
  )
  Json::object(fields)
}

///|
pub extend LoadedSourcesResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for LoadedSourcesResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    sources: required(fields, "sources", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend LoadedSourcesResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct EvaluateResponseBody {
  result : String
  type_ : String?
  presentation_hint : VariablePresentationHint?
  variables_reference : Int32
  named_variables : Int32?
  indexed_variables : Int32?
  memory_reference : String?
  value_location_reference : Int32?
}

///|
pub impl ToJson for EvaluateResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set("result", @json.to_json(self.result))
  if self.type_ is Some(item) {
    fields.set("type", @json.to_json(item))
  }
  if self.presentation_hint is Some(item) {
    fields.set("presentationHint", @json.to_json(item))
  }
  fields.set("variablesReference", @json.to_json(self.variables_reference))
  if self.named_variables is Some(item) {
    fields.set("namedVariables", @json.to_json(item))
  }
  if self.indexed_variables is Some(item) {
    fields.set("indexedVariables", @json.to_json(item))
  }
  if self.memory_reference is Some(item) {
    fields.set("memoryReference", @json.to_json(item))
  }
  if self.value_location_reference is Some(item) {
    fields.set("valueLocationReference", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend EvaluateResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for EvaluateResponseBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    result: required(fields, "result", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    type_: optional(fields, "type", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    presentation_hint: optional(fields, "presentationHint", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    variables_reference: required(fields, "variablesReference", path, (
      value,
      path,
    ) => integer(value, path, 0L, 2147483647L).to_int()),
    named_variables: optional(fields, "namedVariables", path, (value, path) => {
      integer(value, path, 0L, 2147483647L).to_int()
    }),
    indexed_variables: optional(fields, "indexedVariables", path, (value, path) => {
      integer(value, path, 0L, 2147483647L).to_int()
    }),
    memory_reference: optional(fields, "memoryReference", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    value_location_reference: optional(fields, "valueLocationReference", path, (
      value,
      path,
    ) => integer(value, path, -2147483648L, 2147483647L).to_int()),
  }
}

///|
pub extend EvaluateResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct SetExpressionResponseBody {
  value : String
  type_ : String?
  presentation_hint : VariablePresentationHint?
  variables_reference : Int32?
  named_variables : Int32?
  indexed_variables : Int32?
  memory_reference : String?
  value_location_reference : Int32?
}

///|
pub impl ToJson for SetExpressionResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set("value", @json.to_json(self.value))
  if self.type_ is Some(item) {
    fields.set("type", @json.to_json(item))
  }
  if self.presentation_hint is Some(item) {
    fields.set("presentationHint", @json.to_json(item))
  }
  if self.variables_reference is Some(item) {
    fields.set("variablesReference", @json.to_json(item))
  }
  if self.named_variables is Some(item) {
    fields.set("namedVariables", @json.to_json(item))
  }
  if self.indexed_variables is Some(item) {
    fields.set("indexedVariables", @json.to_json(item))
  }
  if self.memory_reference is Some(item) {
    fields.set("memoryReference", @json.to_json(item))
  }
  if self.value_location_reference is Some(item) {
    fields.set("valueLocationReference", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend SetExpressionResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for SetExpressionResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    value: required(fields, "value", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    type_: optional(fields, "type", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    presentation_hint: optional(fields, "presentationHint", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    variables_reference: optional(fields, "variablesReference", path, (
      value,
      path,
    ) => integer(value, path, 0L, 2147483647L).to_int()),
    named_variables: optional(fields, "namedVariables", path, (value, path) => {
      integer(value, path, 0L, 2147483647L).to_int()
    }),
    indexed_variables: optional(fields, "indexedVariables", path, (value, path) => {
      integer(value, path, 0L, 2147483647L).to_int()
    }),
    memory_reference: optional(fields, "memoryReference", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    value_location_reference: optional(fields, "valueLocationReference", path, (
      value,
      path,
    ) => integer(value, path, -2147483648L, 2147483647L).to_int()),
  }
}

///|
pub extend SetExpressionResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct StepInTargetsResponseBody {
  targets : Array[StepInTarget]
}

///|
pub impl ToJson for StepInTargetsResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "targets",
    Json::array(self.targets.map(item => @json.to_json(item))),
  )
  Json::object(fields)
}

///|
pub extend StepInTargetsResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for StepInTargetsResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    targets: required(fields, "targets", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend StepInTargetsResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct GotoTargetsResponseBody {
  targets : Array[GotoTarget]
}

///|
pub impl ToJson for GotoTargetsResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "targets",
    Json::array(self.targets.map(item => @json.to_json(item))),
  )
  Json::object(fields)
}

///|
pub extend GotoTargetsResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for GotoTargetsResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    targets: required(fields, "targets", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend GotoTargetsResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct CompletionsResponseBody {
  targets : Array[CompletionItem]
}

///|
pub impl ToJson for CompletionsResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "targets",
    Json::array(self.targets.map(item => @json.to_json(item))),
  )
  Json::object(fields)
}

///|
pub extend CompletionsResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for CompletionsResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    targets: required(fields, "targets", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend CompletionsResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct ExceptionInfoResponseBody {
  exception_id : String
  description : String?
  break_mode : ExceptionBreakMode
  details : ExceptionDetails?
}

///|
pub impl ToJson for ExceptionInfoResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set("exceptionId", @json.to_json(self.exception_id))
  if self.description is Some(item) {
    fields.set("description", @json.to_json(item))
  }
  fields.set("breakMode", @json.to_json(self.break_mode))
  if self.details is Some(item) {
    fields.set("details", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend ExceptionInfoResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for ExceptionInfoResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    exception_id: required(fields, "exceptionId", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    description: optional(fields, "description", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    break_mode: required(fields, "breakMode", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    details: optional(fields, "details", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ExceptionInfoResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct ReadMemoryResponseBody {
  address : String
  unreadable_bytes : Int64?
  data : String?
}

///|
pub impl ToJson for ReadMemoryResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set("address", @json.to_json(self.address))
  if self.unreadable_bytes is Some(item) {
    fields.set("unreadableBytes", wide_json(item))
  }
  if self.data is Some(item) {
    fields.set("data", @json.to_json(item))
  }
  Json::object(fields)
}

///|
pub extend ReadMemoryResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for ReadMemoryResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    address: required(fields, "address", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    unreadable_bytes: optional(fields, "unreadableBytes", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    data: optional(fields, "data", path, (value, path) => {
      @json.from_json(value, path~)
    }),
  }
}

///|
pub extend ReadMemoryResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct WriteMemoryResponseBody {
  offset : Int64?
  bytes_written : Int64?
}

///|
pub impl ToJson for WriteMemoryResponseBody with fn to_json(self) {
  let fields = Map([])
  if self.offset is Some(item) {
    fields.set("offset", wide_json(item))
  }
  if self.bytes_written is Some(item) {
    fields.set("bytesWritten", wide_json(item))
  }
  Json::object(fields)
}

///|
pub extend WriteMemoryResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for WriteMemoryResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    offset: optional(fields, "offset", path, (value, path) => {
      integer(value, path, -9007199254740991L, 9007199254740991L)
    }),
    bytes_written: optional(fields, "bytesWritten", path, (value, path) => {
      integer(value, path, 0L, 4294967295L)
    }),
  }
}

///|
pub extend WriteMemoryResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct DisassembleResponseBody {
  instructions : Array[DisassembledInstruction]
}

///|
pub impl ToJson for DisassembleResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set(
    "instructions",
    Json::array(self.instructions.map(item => @json.to_json(item))),
  )
  Json::object(fields)
}

///|
pub extend DisassembleResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for DisassembleResponseBody with fn from_json(
  value,
  path,
) {
  let fields = object(value, path)
  {
    instructions: required(fields, "instructions", path, (value, path) => {
      array_of(value, path, (value, path) => @json.from_json(value, path~))
    }),
  }
}

///|
pub extend DisassembleResponseBody with @json.FromJson::{from_json}

///|
pub(all) struct LocationsResponseBody {
  source : Source
  line : Int64
  column : Int64?
  end_line : Int64?
  end_column : Int64?
}

///|
pub impl ToJson for LocationsResponseBody with fn to_json(self) {
  let fields = Map([])
  fields.set("source", @json.to_json(self.source))
  fields.set("line", wide_json(self.line))
  if self.column is Some(item) {
    fields.set("column", wide_json(item))
  }
  if self.end_line is Some(item) {
    fields.set("endLine", wide_json(item))
  }
  if self.end_column is Some(item) {
    fields.set("endColumn", wide_json(item))
  }
  Json::object(fields)
}

///|
pub extend LocationsResponseBody with ToJson::{to_json}

///|
pub impl @json.FromJson for LocationsResponseBody with fn from_json(value, path) {
  let fields = object(value, path)
  {
    source: required(fields, "source", path, (value, path) => {
      @json.from_json(value, path~)
    }),
    line: required(fields, "line", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    column: optional(fields, "column", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    end_line: optional(fields, "endLine", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
    end_column: optional(fields, "endColumn", path, (value, path) => {
      integer(value, path, 0L, 9007199254740991L)
    }),
  }
}

///|
pub extend LocationsResponseBody with @json.FromJson::{from_json}

///|
pub(all) enum ModuleId {
  Text(String)
  Integer(Int64)
}

///|
pub impl ToJson for ModuleId with fn to_json(self) {
  match self {
    Text(item) => Json::string(item)
    Integer(item) => wide_json(item)
  }
}

///|
pub extend ModuleId with ToJson::{to_json}

///|
pub impl @json.FromJson for ModuleId with fn from_json(value, path) {
  match value {
    String(item) => Text(item)
    _ => Integer(integer(value, path, -9007199254740991L, 9007199254740991L))
  }
}

///|
pub extend ModuleId with @json.FromJson::{from_json}

///|
pub(all) enum ColumnDescriptorType {
  String
  Number
  Boolean
  UnixTimestampUTC
}

///|
pub impl ToJson for ColumnDescriptorType with fn to_json(self) {
  match self {
    String => Json::string("string")
    Number => Json::string("number")
    Boolean => Json::string("boolean")
    UnixTimestampUTC => Json::string("unixTimestampUTC")
  }
}

///|
pub extend ColumnDescriptorType with ToJson::{to_json}

///|
pub impl @json.FromJson for ColumnDescriptorType with fn from_json(value, path) {
  match value {
    String("string") => String
    String("number") => Number
    String("boolean") => Boolean
    String("unixTimestampUTC") => UnixTimestampUTC
    _ => invalid(path, "未知枚举值")
  }
}

///|
pub extend ColumnDescriptorType with @json.FromJson::{from_json}

///|
pub(all) enum SourcePresentationHint {
  Normal
  Emphasize
  Deemphasize
}

///|
pub impl ToJson for SourcePresentationHint with fn to_json(self) {
  match self {
    Normal => Json::string("normal")
    Emphasize => Json::string("emphasize")
    Deemphasize => Json::string("deemphasize")
  }
}

///|
pub extend SourcePresentationHint with ToJson::{to_json}

///|
pub impl @json.FromJson for SourcePresentationHint with fn from_json(
  value,
  path,
) {
  match value {
    String("normal") => Normal
    String("emphasize") => Emphasize
    String("deemphasize") => Deemphasize
    _ => invalid(path, "未知枚举值")
  }
}

///|
pub extend SourcePresentationHint with @json.FromJson::{from_json}

///|
pub(all) enum StackFrameModuleId {
  Text(String)
  Integer(Int64)
}

///|
pub impl ToJson for StackFrameModuleId with fn to_json(self) {
  match self {
    Text(item) => Json::string(item)
    Integer(item) => wide_json(item)
  }
}

///|
pub extend StackFrameModuleId with ToJson::{to_json}

///|
pub impl @json.FromJson for StackFrameModuleId with fn from_json(value, path) {
  match value {
    String(item) => Text(item)
    _ => Integer(integer(value, path, -9007199254740991L, 9007199254740991L))
  }
}

///|
pub extend StackFrameModuleId with @json.FromJson::{from_json}

///|
pub(all) enum StackFramePresentationHint {
  Normal
  Label
  Subtle
}

///|
pub impl ToJson for StackFramePresentationHint with fn to_json(self) {
  match self {
    Normal => Json::string("normal")
    Label => Json::string("label")
    Subtle => Json::string("subtle")
  }
}

///|
pub extend StackFramePresentationHint with ToJson::{to_json}

///|
pub impl @json.FromJson for StackFramePresentationHint with fn from_json(
  value,
  path,
) {
  match value {
    String("normal") => Normal
    String("label") => Label
    String("subtle") => Subtle
    _ => invalid(path, "未知枚举值")
  }
}

///|
pub extend StackFramePresentationHint with @json.FromJson::{from_json}

///|
pub(all) enum BreakpointReason {
  Pending
  Failed
}

///|
pub impl ToJson for BreakpointReason with fn to_json(self) {
  match self {
    Pending => Json::string("pending")
    Failed => Json::string("failed")
  }
}

///|
pub extend BreakpointReason with ToJson::{to_json}

///|
pub impl @json.FromJson for BreakpointReason with fn from_json(value, path) {
  match value {
    String("pending") => Pending
    String("failed") => Failed
    _ => invalid(path, "未知枚举值")
  }
}

///|
pub extend BreakpointReason with @json.FromJson::{from_json}

///|
pub(all) enum DisassembledInstructionPresentationHint {
  Normal
  Invalid
}

///|
pub impl ToJson for DisassembledInstructionPresentationHint with fn to_json(
  self,
) {
  match self {
    Normal => Json::string("normal")
    Invalid => Json::string("invalid")
  }
}

///|
pub extend DisassembledInstructionPresentationHint with ToJson::{to_json}

///|
pub impl @json.FromJson for DisassembledInstructionPresentationHint with fn from_json(
  value,
  path,
) {
  match value {
    String("normal") => Normal
    String("invalid") => Invalid
    _ => invalid(path, "未知枚举值")
  }
}

///|
pub extend DisassembledInstructionPresentationHint with @json.FromJson::{
  from_json,
}

///|
pub(all) enum OutputEventBodyGroup {
  Start
  StartCollapsed
  End
}

///|
pub impl ToJson for OutputEventBodyGroup with fn to_json(self) {
  match self {
    Start => Json::string("start")
    StartCollapsed => Json::string("startCollapsed")
    End => Json::string("end")
  }
}

///|
pub extend OutputEventBodyGroup with ToJson::{to_json}

///|
pub impl @json.FromJson for OutputEventBodyGroup with fn from_json(value, path) {
  match value {
    String("start") => Start
    String("startCollapsed") => StartCollapsed
    String("end") => End
    _ => invalid(path, "未知枚举值")
  }
}

///|
pub extend OutputEventBodyGroup with @json.FromJson::{from_json}

///|
pub(all) enum ModuleEventBodyReason {
  New
  Changed
  Removed
}

///|
pub impl ToJson for ModuleEventBodyReason with fn to_json(self) {
  match self {
    New => Json::string("new")
    Changed => Json::string("changed")
    Removed => Json::string("removed")
  }
}

///|
pub extend ModuleEventBodyReason with ToJson::{to_json}

///|
pub impl @json.FromJson for ModuleEventBodyReason with fn from_json(value, path) {
  match value {
    String("new") => New
    String("changed") => Changed
    String("removed") => Removed
    _ => invalid(path, "未知枚举值")
  }
}

///|
pub extend ModuleEventBodyReason with @json.FromJson::{from_json}

///|
pub(all) enum LoadedSourceEventBodyReason {
  New
  Changed
  Removed
}

///|
pub impl ToJson for LoadedSourceEventBodyReason with fn to_json(self) {
  match self {
    New => Json::string("new")
    Changed => Json::string("changed")
    Removed => Json::string("removed")
  }
}

///|
pub extend LoadedSourceEventBodyReason with ToJson::{to_json}

///|
pub impl @json.FromJson for LoadedSourceEventBodyReason with fn from_json(
  value,
  path,
) {
  match value {
    String("new") => New
    String("changed") => Changed
    String("removed") => Removed
    _ => invalid(path, "未知枚举值")
  }
}

///|
pub extend LoadedSourceEventBodyReason with @json.FromJson::{from_json}

///|
pub(all) enum ProcessEventBodyStartMethod {
  Launch
  Attach
  AttachForSuspendedLaunch
}

///|
pub impl ToJson for ProcessEventBodyStartMethod with fn to_json(self) {
  match self {
    Launch => Json::string("launch")
    Attach => Json::string("attach")
    AttachForSuspendedLaunch => Json::string("attachForSuspendedLaunch")
  }
}

///|
pub extend ProcessEventBodyStartMethod with ToJson::{to_json}

///|
pub impl @json.FromJson for ProcessEventBodyStartMethod with fn from_json(
  value,
  path,
) {
  match value {
    String("launch") => Launch
    String("attach") => Attach
    String("attachForSuspendedLaunch") => AttachForSuspendedLaunch
    _ => invalid(path, "未知枚举值")
  }
}

///|
pub extend ProcessEventBodyStartMethod with @json.FromJson::{from_json}

///|
pub(all) enum DataBreakpointInfoResponseBodyDataId {
  Text(String)
  NullValue
}

///|
pub impl ToJson for DataBreakpointInfoResponseBodyDataId with fn to_json(self) {
  match self {
    Text(item) => Json::string(item)
    NullValue => Json::null()
  }
}

///|
pub extend DataBreakpointInfoResponseBodyDataId with ToJson::{to_json}

///|
pub impl @json.FromJson for DataBreakpointInfoResponseBodyDataId with fn from_json(
  value,
  path,
) {
  match value {
    String(item) => Text(item)
    Null => NullValue
    _ => invalid(path, "需要字符串或 null")
  }
}

///|
pub extend DataBreakpointInfoResponseBodyDataId with @json.FromJson::{from_json}
