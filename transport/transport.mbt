///|
pub(all) struct Options {
  max_header : Int32
  max_body : Int32
  poll_ms : Int32
  request_timeout_ms : Int32
}

///|
pub fn Options::default() -> Options {
  {
    max_header: 8192,
    max_body: 8388608,
    poll_ms: 2,
    request_timeout_ms: 15000,
  }
}

///|
pub suberror TransportError {
  InvalidFrame(@framing.FrameError)
  OutgoingFrameTooLarge
  InvalidOptions
} derive(Debug)

///|
pub extend TransportError with @debug.Debug::{to_repr}

///|
priv enum Input {
  Frame(Bytes)
  End
  Failed(Error)
}

///|
async fn read_frames(
  reader : &@io.Reader,
  inbox : @async.Queue[Input],
  options : Options,
) -> Unit {
  let decoder = @framing.Decoder::new(
    max_header=options.max_header,
    max_body=options.max_body,
  )
  while reader.read_some(max_len=8192) is Some(chunk) {
    let batch = decoder.feed(chunk[:])
    for frame in batch.frames {
      inbox.put(Frame(frame))
    }
    if batch.error is Some(error) {
      raise InvalidFrame(error)
    }
  }
  if decoder.finish() is Some(error) {
    raise InvalidFrame(error)
  }
  inbox.put(End)
}

///|
async fn send(
  writer : &@io.Writer,
  messages : Array[Json],
  options : Options,
) -> Unit {
  for message in messages {
    let body = @utf8.encode(message.stringify())
    guard body.length() <= options.max_body else { raise OutgoingFrameTooLarge }
    @async.with_timeout(options.request_timeout_ms, () => {
      writer.write(@framing.encode(body))
    })
  }
}

///|
async fn run_session(
  session : @session.Session,
  inbox : @async.Queue[Input],
  writer : &@io.Writer,
  options : Options,
) -> Unit {
  while session.phase() != Closed {
    let wait = match session.phase() {
      Running => @async.with_timeout_opt(options.poll_ms, () => inbox.get())
      Stopped =>
        @async.with_timeout_opt(options.poll_ms.max(20), () => inbox.get())
      _ => Some(inbox.get())
    }
    match wait {
      Some(End) => break
      Some(Failed(error)) => raise error
      Some(Frame(body)) => {
        let raw = @utf8.decode(body[:])
        let message = @json.parse(
          raw,
          reject_duplicate_keys=true,
          preserve_number_repr=true,
        )
        let replies = @async.with_timeout(options.request_timeout_ms, () => {
          session.handle(message)
        })
        send(writer, replies, options)
      }
      None => ()
    }
    send(writer, session.poll(), options)
  }
}

///|
/// 一个字节流对应一个会话。调用者负责关闭其底层流。
pub async fn serve(
  reader : &@io.Reader,
  writer : &@io.Writer,
  target : &@session.DebugTarget,
  options~ : Options = Options::default(),
) -> Unit {
  guard options.max_header > 0 &&
    options.max_body > 0 &&
    options.poll_ms > 0 &&
    options.request_timeout_ms > 0 else {
    raise InvalidOptions
  }
  let session = @session.Session::new(target)
  let fault : Error? = try {
    @async.with_task_group(group => {
      let inbox : @async.Queue[Input] = @async.Queue(kind=Blocking(32))
      let read_task = group.spawn(no_wait=true, () => {
        read_frames(reader, inbox, options) catch {
          error => {
            if @async.is_cancellation_error(error) {
              raise error
            }
            inbox.put(Failed(error))
          }
        }
      })
      defer read_task.cancel()
      run_session(session, inbox, writer, options)
    })
    None
  } catch {
    error => Some(error)
  }
  let cleanup : Error? = @async.protect_from_cancel(
    () => {
      try {
        @async.with_timeout(options.request_timeout_ms, () => session.close())
        None
      } catch {
        error => Some(error)
      }
    },
    resume_on_cancel=false,
  )
  match (fault, cleanup) {
    (Some(error), _) | (None, Some(error)) => raise error
    (None, None) => ()
  }
}

///|
/// 在当前进程的 stdin 和 stdout 上运行一个 DAP 会话。
pub async fn serve_stdio(
  target : &@session.DebugTarget,
  options~ : Options = Options::default(),
) -> Unit {
  serve(@stdio.stdin, @stdio.stdout, target, options~)
}

///|
/// 仅在 IPv4 回环地址监听。端口为 0 时由系统分配。
pub async fn listen_loopback(port : Int32) -> @socket.TcpServer {
  @socket.TcpServer(@socket.Addr::parse("127.0.0.1:\{port}"))
}

///|
/// 每个连接通过 factory 新建一个调试目标，监听器由调用者关闭。
pub async fn serve_tcp(
  listener : @socket.TcpServer,
  factory : () -> &@session.DebugTarget,
  options~ : Options = Options::default(),
  max_connections~ : Int32 = 16,
) -> Unit {
  listener.run_forever(max_connections=max_connections.max(1), (stream, _) => {
    serve(stream, stream, factory(), options~) catch {
      error => {
        if @async.is_cancellation_error(error) {
          raise error
        }
        @stdio.stderr.write(
          @utf8.encode("moon-dap: " + error.to_string() + "\n"),
        )
      }
    }
  })
}
