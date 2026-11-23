# MoonBpfLab 外部运行时接入

本例使用独立发布的用户态虚拟机 `btlqql/moon_bpflab@0.2.0`。示例模块通过 `moon.work` 依赖当前 moon-dap 源码，从 Mooncakes 加载 MoonBpfLab。上游采用 Apache-2.0。示例提供调试适配代码、计数程序和跨文件嵌套调用程序，上游源码改动为 0 行。[上游项目](https://github.com/btlqql/moon-bpflab) · [固定依赖版本](https://mooncakes.io/docs/btlqql/moon_bpflab@0.2.0)

## 接入成本与分工

该案例包含 **448 行非空、非注释 MoonBit**。调试适配与入口共 332 行，程序装载、源码映射和表达式解析共 116 行。接入其他运行时所需的代码取决于其已有接口。

| 接入点 | 适配代码承担的工作 | moon-dap 提供的基础 |
| --- | --- | --- |
| 启动与执行 | 加载测试程序，用 `Machine::new_default` 创建 VM。每次轮询最多调用一次 `Machine::step`。 | stdio 通信、启动与配置握手、执行状态和终止事件。 |
| 条件断点 | 将源码行映射到程序计数器，在执行指令前检查真实寄存器。 | 协商能力、转发条件文本、管理断点替换请求和结果映射。 |
| 调用栈和单步 | 从 VM 的返回地址恢复调用点，按真实调用深度执行步过和步出。 | 栈页请求、帧引用、运行与停止状态、断点与步进结果。 |
| 状态与求值 | 读取 VM 快照，将寄存器展示为变量，支持 `rN` 和 `rN == 无符号十进制整数`。 | 虚拟线程和帧的协议封装、暂停期引用、`evaluate` 请求及错误响应。 |

示例支持单线程、跨文件源码断点、栈分页、暂停、继续、步入、步过和步出。最上层栈帧可查看与求值当前寄存器 `r0` 至 `r10`，父帧提供调用点。步进以指令槽和调用深度为粒度，同一源码行对应多个指令槽时，行断点覆盖全部映射位置。

`launch.programFormat` 默认为 `text`。指定 `elf` 时，需要将本地 ELF64 小端 BPF 对象作为 `program`、JSON 映射的路径作为 `sourceMap`。每条映射包含从 0 开始的 `pc` 指令槽、源码绝对路径 `path`、从 1 开始的 `line` 和函数 `name`。支持稀疏映射，无映射的栈帧只显示 PC。示例加载从第一条指令开始且相对调用已解析的 `.text`，DWARF、BTF 和 ELF 重定位留待后续实现。

## 复现

使用 MoonBit `v0.10.20+65efd5b93`。在项目根目录运行以下命令。测试脚本构建独立示例模块，读取构建产物路径，再使用真实 stdio 客户端运行完整 DAP 会话。GitHub Actions 也运行此命令。

```text
moon update
python -m pip install -r tests/requirements.txt
python scripts/test_bpflab.py
```

Windows 环境若由 `moonc.cmd` 转发导致命令行过长，可在当前 PowerShell 进程指向已安装的 `moonc.exe`，随后重跑脚本。

```powershell
$env:MOONC_OVERRIDE = (Get-Command moonc.exe).Source
python scripts/test_bpflab.py
```

操作序列覆盖加载 `counter.bpf`、在第 3 行设置 `r0 == 2`，等条件命中后读取调用帧与寄存器，用监视表达式取得 2，单步后取得 3，并继续执行直到输出 4。测试同时验证无效条件被标为未验证、暂停前的求值失败、无效寄存器被拒绝、恢复后旧帧句柄失效。

脚本共运行 4 项测试，覆盖条件断点、断点替换与清除、无效启动后重试及两文件 ELF 的断点定位、三层栈分页、步出、步过和退出。`stopOnEntry` 省略时默认为 `false`，显式设置时必须为布尔值。

```text
MoonBpfLab 外部 VM：条件断点命中 r0=2，单步后 r0=3，继续运行返回 r0=4
```

## 在编辑器里调试 ELF

从仓库根目录运行准备命令。脚本构建适配器，在指定目录生成 ELF 和源码映射，最后输出三个绝对路径。

```powershell
$settings = python scripts/test_bpflab.py --prepare-example _build/editor-demo | Select-Object -Last 1 | ConvertFrom-Json
$env:MOON_DAP_BPF_ADAPTER = $settings.adapter
$env:MOON_DAP_BPF_PROGRAM = $settings.program
$env:MOON_DAP_BPF_SOURCE_MAP = $settings.sourceMap
```

- VS Code 从同一终端运行 `code --new-window --extensionDevelopmentPath=./examples/bpflab/vscode ./examples/bpflab`。在 `demo/helper.bpf` 第 4 行设置断点，再按 F5 选择「调试 ELF 嵌套调用」。
- Neovim 在已加载 nvim-dap 的配置中运行 `:luafile examples/bpflab/neovim.lua`，打开 `examples/bpflab/demo/helper.bpf`，在第 4 行执行 `:lua require("dap").toggle_breakpoint()`，再执行 `:lua require("dap").continue()`。

两个编辑器都应显示 `add_one → increment → main` 三个调用帧。命中断点时求值 `r0` 得到 1，步出后选中 `increment` 返回指令所在的第 3 行。

断点显示未验证时，先检查映射中的绝对路径和源码行，再查询该行是否有可执行指令槽。如果调试器启动后立即关闭，确认适配器能在当前平台运行，并核对三个环境变量和 `programFormat`。应用的调试输出通过 DAP 事件发送，stdio 保留给协议。

[自动化协议测试](../../scripts/test_bpflab.py) · [验证记录](../../docs/verification.md)
