///|
test "正常帧以 UTF-8 字节计长" {
  let body = @utf8.encode("{\"value\":\"月🌙\"}")
  let frame = encode(body)
  let decoder = Decoder::new()
  let result = decoder.feed(frame[:])
  assert_eq(result.frames, [body])
  assert_eq(result.error, None)
  assert_eq(decoder.finish(), None)
}

///|
test "逐字节输入含头部和正文半包" {
  let body = b"{}"
  let frame = encode(body)
  let decoder = Decoder::new()
  for i in 0..<(frame.length() - 1) {
    let batch = decoder.feed(frame[i:i + 1])
    assert_eq(batch.frames.length(), 0)
    assert_eq(batch.error, None)
    assert_eq(decoder.finish(), Some(TruncatedFrame))
  }
  assert_eq(decoder.feed(frame[frame.length() - 1:]).frames, [body])
}

///|
test "粘包与尾部半帧" {
  let one = encode(b"{}")
  let two = encode(b"[]")
  let three = encode(b"true")
  let chunk = one + two + three[:7].to_owned()
  let decoder = Decoder::new()
  assert_eq(decoder.feed(chunk[:]).frames, [b"{}", b"[]"])
  assert_eq(decoder.finish(), Some(TruncatedFrame))
  assert_eq(decoder.feed(three[7:]).frames, [b"true"])
}

///|
test "额外空白及其他合法头字段" {
  let decoder = Decoder::new()
  let result = decoder.feed(
    b"\r\ncontent-length:\t 4 \t\r\nX-Trace: abc\r\n\r\n {} "[:],
  )
  assert_eq(result.frames, [b" {} "])
  assert_eq(result.error, None)
}

///|
test "错误头与长度限制" {
  let invalid : Array[(Bytes, FrameError)] = [
    (b"Bad\r\n\r\n", InvalidHeader),
    (b"X-Trace: yes\r\n\r\n", MissingLength),
    (b"Content-Length: 1\r\ncontent-length: 1\r\n\r\n", DuplicateLength),
    (b"Content-Length: +1\r\n\r\n", InvalidLength),
    (b"Content-Length: 0\r\n\r\n", InvalidLength),
    (b"Content-Length: 999999999999999999\r\n\r\n", BodyTooLarge),
    (b"Content-Length: 2\n\n{}", InvalidHeader),
  ]
  for item in invalid {
    let (input, error) = item
    let decoder = Decoder::new()
    assert_eq(decoder.feed(input[:]).error, Some(error))
    assert_eq(decoder.feed(b""[:]).error, Some(error))
  }
  assert_eq(
    Decoder::new(max_header=3).feed(b"Long:"[:]).error,
    Some(HeaderTooLarge),
  )
  assert_eq(
    Decoder::new(max_body=1).feed(b"Content-Length: 2\r\n"[:]).error,
    Some(BodyTooLarge),
  )
}

///|
test "后续非法头不会抹去已交付帧" {
  let decoder = Decoder::new()
  let chunk = encode(b"{}") + b"Bad\r\n"
  let batch = decoder.feed(chunk[:])
  assert_eq(batch.frames, [b"{}"])
  assert_eq(batch.error, Some(InvalidHeader))
}

///|
test "属性：固定种子的 256 组随机切分可重组" {
  let bodies = [
    b"{}",
    @utf8.encode("{\"name\":\"春天🌙\"}"),
    b"[true, false]",
    b" null ",
  ]
  let wire = bodies.fold(init=b"", (acc, body) => acc + encode(body))
  for seed in 1..<=256 {
    let mut state = seed
    let mut offset = 0
    let decoder = Decoder::new()
    let actual = []
    while offset < wire.length() {
      state = (state * 25173 + 13849) % 65536
      let end = (offset + state % 23 + 1).min(wire.length())
      let batch = decoder.feed(wire[offset:end])
      assert_eq(batch.error, None)
      for body in batch.frames {
        actual.push(body)
      }
      offset = end
    }
    assert_eq(actual, bodies)
    assert_eq(decoder.finish(), None)
  }
}
