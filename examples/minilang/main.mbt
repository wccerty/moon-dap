///|
async fn main {
  let args = @env.args()
  match args[:] {
    [_] | [_, "--stdio"] => @transport.serve_stdio(MiniTarget::new())
    [_, "--tcp", port] => {
      let listener = @transport.listen_loopback(whole_number(port, 65535))
      @stdio.stderr.write("moon-dap tcp \{listener.addr.port()}\n")
      @transport.serve_tcp(listener, () => MiniTarget::new())
    }
    _ => raise @session.TargetError("用法：minilang [--stdio | --tcp PORT]")
  }
}
