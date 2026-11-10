///|
priv struct References {
  by_handle : Map[Int32, Int32]
  by_id : Map[Int32, Int32]
  mut next : Int64
}

///|
fn References::new() -> References {
  { by_handle: Map([]), by_id: Map([]), next: 1L, }
}

///|
fn References::id(self : References, handle : Int32) -> Int32 raise TargetError {
  if self.by_handle.get(handle) is Some(id) {
    return id
  }
  guard self.next <= 2147483647L else {
    raise TargetError("会话句柄空间已用尽")
  }
  let id = self.next.to_int()
  self.next += 1L
  self.by_handle.set(handle, id)
  self.by_id.set(id, handle)
  id
}

///|
fn References::handle(
  self : References,
  id : Int32,
) -> Int32 raise RequestFailure {
  guard self.by_id.get(id) is Some(handle) else {
    raise RequestFailure(
      "invalidReference",
      "引用 \{id} 不属于当前暂停",
    )
  }
  handle
}

///|
fn References::clear(self : References) -> Unit {
  self.by_handle.clear()
  self.by_id.clear()
}

///|
fn Session::clear_references(self : Session) -> Unit {
  self.frame_refs.clear()
  self.variable_refs.clear()
}
