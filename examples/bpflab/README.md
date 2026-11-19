# MoonBpfLab 外部运行时接入

本例使用独立发布的用户态虚拟机 `btlqql/moon_bpflab@0.2.0`。示例模块通过 `moon.work` 依赖当前 moon-dap 源码，从 Mooncakes 加载 MoonBpfLab。上游采用 Apache-2.0。运行时、指令执行和寄存器状态由上游实现，示例只提供适配代码和一个计数程序。[上游项目](https://github.com/btlqql/moon-bpflab) · [固定依赖版本](https://mooncakes.io/docs/btlqql/moon_bpflab@0.2.0)

## 接入成本与分工

该案例包含 **311 行非空、非注释 MoonBit**，按适配文件与辅助程序文件计数。调试适配、入口及源行映射共 252 行，指令文本读取与寄存器表达式解析 59 行。这个数字是本例的实现规模，接入其他运行时所需的代码取决于其已有接口。

| 接入点 | 适配代码承担的工作 | moon-dap 提供的基础 |
| --- | --- | --- |
| 启动与执行 | 加载测试程序，用 `Machine::new_default` 创建 VM。每次轮询最多调用一次 `Machine::step`。 | stdio 通信、启动与配置握手、执行状态和终止事件。 |
| 条件断点 | 将源码行映射到程序计数器，在执行指令前检查真实寄存器。 | 协商能力、转发条件文本、管理断点替换请求和结果映射。 |
| 状态与求值 | 读取 VM 快照，将寄存器展示为变量，支持 `rN` 和 `rN == 无符号十进制整数`。 | 虚拟线程和帧的协议封装、暂停期引用、`evaluate` 请求及错误响应。 |

示例支持单线程、一个指令帧、源码行断点、暂停、继续、步入与步过。程序使用四条计数指令和本地文本行映射。表达式只读，支持 `r0` 至 `r10`。案例覆盖这个范围，编译器生成的 ELF 源码映射、完整 BPF 调用栈和步出留待单独扩展。

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

脚本共运行 3 项测试。除完整调试会话外，还验证条件断点的整组替换与清除、`uint64` 最大值条件，以及启动参数错误、非法指令文件和文件缺失后在同一连接重新启动。`stopOnEntry` 省略时默认为 `false`，显式设置时必须为布尔值，类型错误返回 `targetError` 并保留重试机会。

```text
MoonBpfLab 外部 VM：条件断点命中 r0=2，单步后 r0=3，继续运行返回 r0=4
```

测试可作为无界面的端到端复现。[测试脚本](../../scripts/test_bpflab.py)
