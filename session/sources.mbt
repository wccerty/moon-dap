///|
fn Session::virtual_sources(
  self : Session,
) -> Array[VirtualSource] raise TargetError {
  guard self.source_provider is Some(provider) else { return [] }
  let sources = (provider.list)()
  let handles = Map([])
  let paths = Map([])
  for source in sources {
    guard !source.name.is_empty() && !handles.contains(source.handle) else {
      raise TargetError("动态源码名称为空或句柄重复")
    }
    handles.set(source.handle, true)
    if source.path is Some(path) {
      guard !path.is_empty() && !paths.contains(path) else {
        raise TargetError("动态源码路径为空或重复")
      }
      paths.set(path, true)
    }
  }
  sources
}

///|
fn Session::encode_virtual_source(
  self : Session,
  source : VirtualSource,
) -> Json raise TargetError {
  let fields : Map[String, Json] = {
    "name": Json::string(source.name),
    "sourceReference": @json.to_json(self.source_refs.id(source.handle)),
  }
  if source.path is Some(path) {
    fields.set("path", Json::string(path))
  }
  Json::object(fields)
}

///|
fn Session::source_for_path(
  self : Session,
  sources : Array[VirtualSource],
  path : String,
) -> Json raise TargetError {
  if sources.iter().find_first(source => source.path == Some(path))
    is Some(source) {
    self.encode_virtual_source(source)
  } else {
    { "path": path }
  }
}

///|
fn Session::loaded_sources(
  self : Session,
  req : @protocol.Request,
) -> Json raise {
  guard self.source_provider is Some(_) else {
    raise RequestFailure("notSupported", "目标不提供已加载源码")
  }
  self.require_configuration()
  let _ : @protocol.LoadedSourcesArguments = arguments(req)
  let sources = self
    .virtual_sources()
    .map(source => self.encode_virtual_source(source))
  self.reply(req, body={ "sources": Json::array(sources) })
}

///|
fn Session::source_contents(
  self : Session,
  req : @protocol.Request,
) -> Json raise {
  guard self.source_provider is Some(provider) else {
    raise RequestFailure("notSupported", "目标不提供动态源码")
  }
  self.require_configuration()
  let args : @protocol.SourceArguments = arguments(req)
  let source = self.find_source(args.source_reference)
  if args.source is Some(selected) {
    guard selected.source_reference.unwrap_or(args.source_reference) ==
      args.source_reference &&
      (selected.path is None || selected.path == source.path) else {
      raise RequestFailure(
        "invalidArguments", "源码引用和源码对象不匹配",
      )
    }
  }
  let text = (provider.read)(source.handle)
  let reply : @protocol.SourceResponseBody = {
    content: text.content,
    mime_type: text.mime_type,
  }
  self.reply(req, body=reply.to_json())
}

///|
fn Session::find_source(
  self : Session,
  reference : Int32,
) -> VirtualSource raise {
  guard self.source_refs.lookup(reference) is Some(handle) &&
    self.virtual_sources().iter().find_first(source => source.handle == handle)
    is Some(source) else {
    raise RequestFailure(
      "invalidReference", "源码引用已失效或未分配",
    )
  }
  source
}

///|
fn Session::breakpoint_path(
  self : Session,
  source : @protocol.Source,
) -> String raise {
  if source.source_reference is Some(reference) && reference > 0 {
    let selected = self.find_source(reference)
    guard selected.path is Some(path) else {
      raise RequestFailure(
        "invalidArguments", "此动态源码未提供断点路径",
      )
    }
    guard source.path is None || source.path == Some(path) else {
      raise RequestFailure(
        "invalidArguments", "断点路径和源码引用不匹配",
      )
    }
    return path
  }
  guard source.path is Some(path) && !path.is_empty() else {
    raise RequestFailure(
      "invalidArguments", "断点需要源码路径或引用",
    )
  }
  path
}
