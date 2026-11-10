///|
pub(all) enum FrameError {
  InvalidHeader
  MissingLength
  DuplicateLength
  InvalidLength
  HeaderTooLarge
  BodyTooLarge
  TruncatedFrame
} derive(Eq, Debug)

///|
pub extend FrameError with Eq::{not_equal, equal}

///|
pub extend FrameError with @debug.Debug::{to_repr}

///|
pub(all) struct Batch {
  frames : Array[Bytes]
  error : FrameError?
}

///|
struct Decoder {
  max_header : Int32
  max_body : Int32
  line : Array[Byte]
  body : Array[Byte]
  mut header_size : Int32
  mut saw_cr : Bool
  mut saw_header : Bool
  mut content_length : Int32?
  mut remaining : Int32
  mut failed : FrameError?
}

///|
pub fn Decoder::new(
  max_header~ : Int32 = 8192,
  max_body~ : Int32 = 8388608,
) -> Decoder {
  {
    max_header: max_header.max(1),
    max_body: max_body.max(1),
    line: [],
    body: [],
    header_size: 0,
    saw_cr: false,
    saw_header: false,
    content_length: None,
    remaining: 0,
    failed: None,
  }
}

///|
fn is_space(b : Byte) -> Bool {
  b == b' ' || b == b'\t'
}

///|
fn is_token(b : Byte) -> Bool {
  (b >= b'a' && b <= b'z') ||
  (b >= b'A' && b <= b'Z') ||
  (b >= b'0' && b <= b'9') ||
  b"!#$%&'*+-.^_`|~".iter().any(c => c == b)
}

///|
fn Decoder::parse_line(self : Decoder) -> FrameError? {
  let line = self.line
  let mut colon = 0
  while colon < line.length() && line[colon] != b':' {
    if !is_token(line[colon]) {
      return Some(InvalidHeader)
    }
    colon += 1
  }
  guard colon > 0 && colon < line.length() else { return Some(InvalidHeader) }
  for i in (colon + 1)..<line.length() {
    let b = line[i]
    if b != b'\t' && (b < b' ' || b > 126) {
      return Some(InvalidHeader)
    }
  }
  let mut is_length = colon == 14
  if is_length {
    for i in 0..<colon {
      let b = line[i]
      let lower = if b >= b'A' && b <= b'Z' { b + 32 } else { b }
      if lower != b"content-length"[i] {
        is_length = false
        break
      }
    }
  }
  if !is_length {
    return None
  }
  guard self.content_length is None else { return Some(DuplicateLength) }
  let mut first = colon + 1
  let mut last = line.length()
  while first < last && is_space(line[first]) {
    first += 1
  }
  while last > first && is_space(line[last - 1]) {
    last -= 1
  }
  let mut length = 0
  for i in first..<last {
    let b = line[i]
    guard b >= b'0' && b <= b'9' else { return Some(InvalidLength) }
    let digit = (b - b'0').to_int()
    if length > self.max_body / 10 ||
      (length == self.max_body / 10 && digit > self.max_body % 10) {
      return Some(BodyTooLarge)
    }
    length = length * 10 + digit
  }
  guard length > 0 else { return Some(InvalidLength) }
  self.content_length = Some(length)
  None
}

///|
fn Decoder::header_byte(self : Decoder, byte : Byte) -> FrameError? {
  guard self.header_size < self.max_header else { return Some(HeaderTooLarge) }
  self.header_size += 1
  if self.saw_cr {
    guard byte == b'\n' else { return Some(InvalidHeader) }
    self.saw_cr = false
    if self.line.is_empty() {
      if self.saw_header {
        guard self.content_length is Some(length) else {
          return Some(MissingLength)
        }
        self.remaining = length
        self.header_size = 0
        self.saw_header = false
        self.content_length = None
      }
    } else {
      self.saw_header = true
      let error = self.parse_line()
      self.line.clear()
      return error
    }
  } else if byte == b'\r' {
    self.saw_cr = true
  } else if byte == b'\n' {
    return Some(InvalidHeader)
  } else {
    self.line.push(byte)
  }
  None
}

///|
/// 输入任意切分的字节。错误与其前面已经完整的帧可同时返回。
pub fn Decoder::feed(self : Decoder, chunk : BytesView) -> Batch {
  let frames = []
  if self.failed is None {
    for byte in chunk {
      if self.remaining > 0 {
        self.body.push(byte)
        self.remaining -= 1
        if self.remaining == 0 {
          frames.push(Bytes::from_array(self.body[:]))
          self.body.clear()
        }
      } else if self.header_byte(byte) is Some(error) {
        self.failed = Some(error)
        break
      }
    }
  }
  { frames, error: self.failed, }
}

///|
pub fn Decoder::finish(self : Decoder) -> FrameError? {
  match self.failed {
    Some(_) => self.failed
    None =>
      if self.remaining > 0 ||
        self.saw_cr ||
        self.saw_header ||
        !self.line.is_empty() {
        Some(TruncatedFrame)
      } else {
        None
      }
  }
}

///|
pub fn encode(body : Bytes) -> Bytes {
  @utf8.encode("Content-Length: \{body.length()}\r\n\r\n") + body
}
