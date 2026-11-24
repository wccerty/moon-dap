# moon-dap

moon-dap 是面向 MoonBit 解释器、虚拟机和 DSL 的调试适配器协议（DAP）服务端开发包。它处理协议消息、会话和 stdio / TCP 传输。解释器通过 `DebugTarget` 提供源码断点、运行控制、调用栈、作用域和变量。

- 给脚本语言或解释器接入编辑器断点和单步调试。
- 给 MoonBit 虚拟机或模拟器提供单步、栈和寄存器状态查看。
- 给业务 DSL 或规则引擎提供可视化调试，查看规则执行和中间数据。

moondbg 面向 MoonBit 原生程序，通过 `lldb-dap` 执行调试，也包含供 VS Code 连接的前端入口。MoonWren 的调试会话针对其自有 VM。moon-dap 的目标接口可由第三方运行时实现。

[安装与 API](https://mooncakes.io/docs/wccerty/moon-dap@0.2.1) · [版本记录](CHANGELOG.md) · [协议覆盖](docs/coverage.md) · [来源与许可](THIRD_PARTY_NOTICES.md)

## 仓库导航

| 路径 | 作用 |
| --- | --- |
| `framing/`、`protocol/` | 增量字节分帧，以及从固定 DAP Schema 生成的类型和编解码。 |
| `session/`、`transport/` | 会话状态、能力协商和目标接口，以及 native stdio、回环 TCP。 |
| `expression/` | 有界的 JSON 表达式解析、求值及赋值路径。 |
| `examples/` | 迷你解释器、第三方 MoonBpfLab 适配器及多源码规则引擎。 |
| `tests/`、`scripts/` | 测试夹具、真实会话回归、Schema 生成、打包验证和源码统计。 |
| `vendor/dap/`、`docs/` | 固定的上游规范及许可证，以及设计、覆盖范围和验收记录。 |

## 快速开始

在已有 MoonBit 模块中安装 `wccerty/moon-dap`。下文示例使用 native，已验证的编译器版本为 `v0.10.20+65efd5b93`。[Mooncakes 包页面](https://mooncakes.io/docs/wccerty/moon-dap)

```text
moon update
moon add wccerty/moon-dap@0.2.1
moon add moonbitlang/async@0.20.6
```

如需从源码开发，若 `interpreter` 和 `moon-dap` 是同一目录下的两个模块，在它们的父目录创建 `moon.work`。

```text
members = ["interpreter", "moon-dap"]
```

在 `interpreter/moon.mod` 声明依赖，工作区会从本地源码解析 moon-dap。[MoonBit 模块配置](https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html#dependency-management)

```moonbit
import {
  "moonbitlang/async@0.20.6",
  "wccerty/moon-dap@0.2.1",
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
pkgtype(kind: "executable")
```

将下面的最小目标保存为同一包中的 `main.mbt`。它在配置完成后暂停，通过继续或单步执行一条输出语句。接入实际解释器时，用 VM 的调试状态实现查询方法。

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

运行 `moon build --target native`，将 `Artifacts` 中列出的可执行文件设为调试客户端的 stdio 适配器。客户端按顺序发送初始化、启动和配置完成请求后会收到入口暂停事件。完整编辑器配置和可设断点的程序见下方示例。

## 接口

| 接口 | 负责的工作 |
| --- | --- |
| `session.DebugTarget.prepare` / `start` / `disconnect` | 启动或附加、等待配置完成、终止或分离。 |
| `set_breakpoints` | 按路径替换一组行断点，空数组清除，逐项返回实际位置和验证状态。坐标统一为 1 基。 |
| `breakpoint_location_provider` | 可选。为编辑器查询给定源码范围内可设断点的位置。范围包含端点，列号以 UTF-16 代码单元计。 |
| `conditional_breakpoint_provider` | 可选。用目标自己的语法处理条件断点，并返回验证结果。 |
| `evaluation_provider` | 可选。读取暂停状态中的表达式值，支持编辑器监视和悬停。 |
| `source_provider` | 可选。提供会话级内存源码引用，支持列举、读取和下断点。 |
| `breakpoint_providers` | 可选。提供函数断点，并按目标声明启用命中次数和日志断点。 |
| `inspection_providers` | 可选。提供展开式求值、修改变量、表达式赋值、补全和异常快照。 |
| `resume_execution` / `pause` / `poll` | 接受执行命令并推进有界工作，在安全点发送停止事件。 |
| `threads` / `stack_trace` / `scopes` / `variables` | 通过目标句柄提供栈和变量。一次暂停中的句柄须稳定，恢复后由库废弃对外引用。 |
| `session.EventSink.emit` | 发送停止、输出、退出和终止等通知。 |
| `transport.serve_stdio` / `listen_loopback` / `serve_tcp` | 在 native 上驱动会话。TCP 的目标工厂为每个连接创建独立实例。 |
| `transport.serve` | 在已有异步 reader 和 writer 上接入一个会话。 |
| `framing` / `protocol` | 独立的 UTF-8 字节分帧、DAP 类型与 JSON 编解码。 |
| `expression` | 在 JSON 值上执行受限的调试表达式，支持字段、下标和复制后写回。 |

## 示例与覆盖范围

| 示例 | 演示场景 | 验证方式 |
| --- | --- | --- |
| [迷你解释器](https://github.com/wccerty/moon-dap/tree/main/examples/minilang) | 源码断点、函数步进、嵌套变量。 | stdio、TCP 端到端测试及 VS Code 实测。 |
| [MoonBpfLab](https://github.com/wccerty/moon-dap/tree/main/examples/bpflab) | 条件断点、寄存器求值、ELF 源码映射、跨文件断点和调用栈。 | 使用真实第三方 VM，已通过 VS Code 和 Neovim 实测。 |
| [规则引擎](https://github.com/wccerty/moon-dap/tree/main/examples/rules) | 内存源码、函数和日志断点、可写变量、异常栈。 | stdio 测试验证调试时的赋值会改变执行结果。 |

| Schema 项目 | 当前版本覆盖 | 总数 |
| --- | ---: | ---: |
| 请求 | 25，含按目标能力启用的动态源码、函数断点、赋值及补全 | 45 |
| 事件 | 7 | 17 |
| `Capabilities` | 13 | 42 |

完整协议类型从官方 Schema 生成。客户端可以调试本地路径，也可以读取目标公开的内存源码。条件和表达式使用目标定义的语法，赋值只在暂停期间开放。内置传输面向 native，异常筛选留待后续扩展。[协议覆盖](docs/coverage.md) · [验证记录](docs/verification.md) · [路线图](docs/plan.md)

## MoonBit 源码规模

以 `0.2.0` 的发布源码 `6a23ba6` 为基线。有效行估算剔除空行和仅含 `//` 注释的行。

| 手写代码 | 物理行 | 有效行估算 |
| --- | ---: | ---: |
| 核心库 | 2,851 | 2,440 |
| 可运行示例 | 2,560 | 2,251 |
| 测试与夹具 | 1,752 | 1,567 |
| 合计 | 7,163 | 6,258 |

核心库与可运行示例合计 4,691 个有效行。自动生成的协议文件、接口文件和外部依赖另计。克隆仓库后用 `python scripts/measure_source.py` 统计当前提交，或传入提交 ID 复算指定版本。

## 测试与维护

在 GitHub 源码仓库根目录执行以下命令。CI 使用 Linux native，固定 MoonBit `v0.10.20+65efd5b93`，验证构建、格式、Schema、真实会话及归档清单。Windows 如遇 `moonc.cmd` 链接参数超长，在当前 PowerShell 会话设置 `$env:MOONC_OVERRIDE = (Get-Command moonc.exe).Source` 后重试。[验证命令与结果](docs/verification.md)

```text
moon update
python -m pip install -r tests/requirements.txt
npm ci --prefix tests --ignore-scripts --no-audit --no-fund
moon check --target native --deny-warn
moon fmt --check
moon info --target native
git diff --exit-code -- ':(glob)**/pkg.generated.mbti'
python scripts/generate_protocol.py --check
moon test --target native --deny-warn
moon build --target native
python scripts/check_schema.py
python scripts/test_e2e.py
python scripts/test_rules.py
node --test tests/vscode_client.cjs
python scripts/test_bpflab.py
```

Schema 校验读取 MoonBit 生成的往返样本和示例会话中的实际消息，按具体消息定义运行 JSON Schema Draft 4 校验。更新基线时替换 `vendor/dap` 中的固定输入，更新生成脚本中的提交和 SHA-256，运行 `python scripts/generate_protocol.py` 重新生成并审查覆盖表和接口变化。

传输层的 `Options.request_timeout_ms` 分别限制请求、异步轮询、单条消息写入和结束清理。回归测试覆盖轮询失败时的阻塞清理，以及非法头部、UTF-8、JSON、重复键和截断帧对 TCP 连接的隔离。目标的同步 `poll` 方法需要及时返回，以配合异步调度与取消。[验证命令与结果](docs/verification.md)

项目采用 Apache-2.0。上游规范、生成代码、依赖和示例数据的来源与授权范围见 [代码来源与许可](THIRD_PARTY_NOTICES.md)。
