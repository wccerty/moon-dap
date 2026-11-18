# moon-dap

moon-dap 是面向 MoonBit 解释器、虚拟机和 DSL 的调试适配器协议（DAP）服务端开发包。它处理协议消息、会话和 stdio / TCP 传输。解释器通过 `DebugTarget` 提供源码断点、运行控制、调用栈、作用域和变量。

- 给脚本语言或解释器接入编辑器断点和单步调试。
- 给 MoonBit 虚拟机或模拟器提供单步、栈和寄存器状态查看。
- 给业务 DSL 或规则引擎提供可视化调试，查看规则执行和中间数据。

moondbg 面向 MoonBit 原生程序，通过 `lldb-dap` 执行调试，也包含供 VS Code 连接的前端入口。MoonWren 的调试会话针对其自有 VM。moon-dap 的目标接口可由第三方运行时实现。

## 快速开始

当前分发方式是 Git 源码或本地源码。若 `interpreter` 和 `moon-dap` 是同一目录下的两个模块，在它们的父目录创建 `moon.work`。

```text
members = ["interpreter", "moon-dap"]
```

在 `interpreter/moon.mod` 声明依赖，工作区会从本地源码解析 moon-dap。[MoonBit 模块配置](https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html#dependency-management)

```moonbit
import {
  "moonbitlang/async@0.20.6",
  "wccerty/moon-dap@0.1.0",
}
```

在 `interpreter/moon.pkg` 导入三个包，声明 native 入口。

```text
import {
  "moonbitlang/async",
  "wccerty/moon-dap/session",
  "wccerty/moon-dap/transport",
}
supported_targets = "+native"
options("is-main": true)
```

下面是一个单步即执行完的最小解释器。它在配置完成后暂停，通过继续或单步执行一条输出语句。将目标方法的空查询替换为 VM 的调试状态即可扩展。

```moonbit
struct OneLine {
  mut sink : @session.EventSink?
  mut ready : Bool
}

impl @session.DebugTarget for OneLine with fn prepare(self, mode, _, sink) {
  guard mode is Launch else { raise @session.TargetError("需要 launch") }
  self.sink = Some(sink)
}
impl @session.DebugTarget for OneLine with fn start(self) {
  guard self.sink is Some(sink) else { raise @session.TargetError("缺少会话") }
  sink.emit(Stopped({ reason: Entry, thread_id: 1, description: None, breakpoint_ids: [] }))
}
impl @session.DebugTarget for OneLine with fn set_breakpoints(_, _, _) { raise @session.TargetError("没有可配置的源码") }
impl @session.DebugTarget for OneLine with fn resume_execution(self, _, _) { self.ready = true }
impl @session.DebugTarget for OneLine with fn pause(_, _) { () }
impl @session.DebugTarget for OneLine with fn threads(_) { [{ id: 1, name: "主线程" }] }
impl @session.DebugTarget for OneLine with fn stack_trace(_, _, _) { { frames: [], total: 0L } }
impl @session.DebugTarget for OneLine with fn scopes(_, _) { [] }
impl @session.DebugTarget for OneLine with fn variables(_, _, _) { [] }
impl @session.DebugTarget for OneLine with fn disconnect(self, _) { self.sink = None }
impl @session.DebugTarget for OneLine with fn poll(self) {
  if self.ready && self.sink is Some(sink) {
    self.ready = false
    sink.emit(Output("stdout", "hello\n"))
    sink.emit(Exited(0))
  }
}
async fn main { @transport.serve_stdio(OneLine::{ sink: None, ready: false }) }
```

## 接口

| 接口 | 负责的工作 |
| --- | --- |
| `session.DebugTarget.prepare` / `start` / `disconnect` | 启动或附加、等待配置完成、终止或分离。 |
| `set_breakpoints` | 按路径替换一组行断点，空数组清除，逐项返回实际位置和验证状态。坐标统一为 1 基。 |
| `breakpoint_location_provider` | 可选。为编辑器查询给定源码范围内可设断点的位置。范围包含端点，列号以 UTF-16 代码单元计。 |
| `conditional_breakpoint_provider` | 可选。用目标自己的语法处理条件断点，并返回验证结果。 |
| `evaluation_provider` | 可选。读取暂停状态中的表达式值，支持编辑器监视和悬停。 |
| `resume_execution` / `pause` / `poll` | 接受执行命令并推进有界工作，在安全点发送停止事件。 |
| `threads` / `stack_trace` / `scopes` / `variables` | 通过目标句柄提供栈和变量。一次暂停中的句柄须稳定，恢复后由库废弃对外引用。 |
| `session.EventSink.emit` | 发送停止、输出、退出和终止等通知。 |
| `transport.serve_stdio` / `listen_loopback` / `serve_tcp` | 在 native 上驱动会话。TCP 的目标工厂为每个连接创建独立实例。 |
| `transport.serve` | 在已有异步 reader 和 writer 上接入一个会话。 |
| `framing` / `protocol` | 独立的 UTF-8 字节分帧、DAP 类型与 JSON 编解码。 |

## 示例与覆盖范围

第三方接入案例使用从 Mooncakes 获取的 MoonBpfLab 虚拟机。测试会在寄存器达到指定值时命中条件断点，查看表达式结果，单步并校验退出前的寄存器输出。[接入成本、复现命令与范围](examples/bpflab/README.md)

构建 `examples/minilang` 后可通过 stdio 或 TCP 调试 `demo.mdap`。示例包含函数调用、打印、嵌套记录和数组。[VS Code 与 Neovim 演示步骤](examples/minilang/README.md)

| Schema 项目 | 第一版覆盖 | 总数 |
| --- | ---: | ---: |
| 请求 | 18，含按目标能力启用的 `attach`、`breakpointLocations`、`evaluate` 及兼容空筛选的 `setExceptionBreakpoints` | 45 |
| 事件 | 7 | 17 |
| `Capabilities` | 5 | 42 |

完整协议类型从官方 Schema 生成。第一版使用本地文件路径，提供源码行断点和目标级执行控制。条件和只读表达式采用目标定义的语法。内置传输以 native 为目标。后续考虑动态源码和异常筛选。[协议覆盖](docs/coverage.md) · [验证记录](docs/verification.md) · [路线图](docs/plan.md)

## 测试与维护

当前 CI 固定 MoonBit `v0.10.20+65efd5b93`。第一次构建前运行 `moon update`，让 MoonBit 能从本地索引解析所需的 Mooncakes 依赖版本。

```text
moon update
python -m pip install -r tests/requirements.txt
npm ci --prefix tests --ignore-scripts --no-audit --no-fund
moon check --target native --deny-warn
moon fmt --check
python scripts/generate_protocol.py --check
moon test --target native
moon build --target native
python scripts/check_schema.py
python scripts/test_e2e.py
node --test tests/vscode_client.cjs
python scripts/test_bpflab.py
```

Schema 校验读取 MoonBit 生成的往返样本和示例会话中的实际消息，按具体消息定义运行 JSON Schema Draft 4 校验。更新基线时替换 `vendor/dap` 中的固定输入，更新生成脚本中的提交和 SHA-256，运行 `python scripts/generate_protocol.py` 重新生成并审查覆盖表和接口变化。

项目采用 Apache-2.0。上游规范的来源、署名与许可证见 [vendor/dap](vendor/dap/README.md)。
