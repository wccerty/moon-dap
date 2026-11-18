# 第一版验证记录

Windows x64 本机使用 Moon CLI `0.1.20261023 (3778465)`、`moonc v0.10.17+d971670cd`、Node.js `v24.19.0`、Python `3.11.4`。传输依赖固定为 `moonbitlang/async@0.20.6`。

| 实际执行的命令 | 结果 |
| --- | --- |
| `moon check --target native --deny-warn`、`moon fmt --check` | 检查和格式校验退出 0。 |
| `python scripts/generate_protocol.py --check` | 核对 192 项官方 Schema 定义和提交的生成文件。 |
| `moon test --target native` | 22 项通过，0 失败。含 7 项分帧、5 项编解码、10 项会话测试。分帧测试中包含 256 组随机切分。 |
| `moon build --target native` | 构建示例解释器与编解码样本程序。README 的最小解释器也在另一个本地 MoonBit 工作区检查并编译。 |
| `python scripts/check_schema.py` | 11 个 MoonBit 编解码往返样本通过 Draft 4 校验。 |
| `python scripts/test_e2e.py` | 4 项通过。stdio、TCP 各驱动 27 条请求，分别校验对应的 38 条响应和事件。还验证了 TCP 连接隔离、配置阶段 EOF 与错误头。 |
| `node --test tests/vscode_client.cjs` | 1 项通过。使用官方 `@vscode/debugadapter-testsupport@1.68.0` 在 TCP 上命中第 4 行，展开变量并步入 `greet`。 |

[实际命令及输出](native-verification.txt)。日志将本地项目绝对路径缩写为 `<仓库>`。Windows 将 `jsonschema` 安装在项目自己的 `.venv`，日志中使用该环境的 Python。首次 native 构建时，依赖的 Windows C 文件发出 `EINVAL` 宏重定义警告，构建和测试退出 0。尝试更新到 `moonbitlang/async@0.22.9` 时，当前编译器缺少其依赖的 `moonbitlang/core/async`，因此为本项目固定了实测版本。

## 编辑器和平台

| 项目 | 状态 |
| --- | --- |
| Windows x64 native stdio 与 TCP | 通过实际进程与套接字验收。 |
| VS Code 1.145.1 | Windows x64 官方便携版通过本体冒烟测试。使用仓库的 `launch.json` 命中第 4 行断点，展开 `config` 并确认 `name = "月兔"`，执行编辑器的步入命令后进入 `greet`。扩展宿主退出码 0。[本体验收命令及输出](vscode-verification.txt) |
| Neovim | 已给出 nvim-dap 配置，本机未安装 Neovim，尚待实测。 |
| Linux native | GitHub Actions 使用 `0.10.17+d971670cd`。检查、格式校验、构建、22 项单元测试、11 个 Draft 4 样本、4 项端到端测试和 1 项官方 DAP 客户端测试均通过。[Linux CI 实测](https://github.com/wccerty/moon-dap/actions/runs/43673914436) |
| macOS native | 尚待实测。 |
| JS 与 Wasm | 第一版的内置 stdio、TCP 面向 native。 |

已安装的 VS Code 在复测时仍持有更新锁。本次使用独立的官方便携版和临时配置。测试宿主无法显示工作区信任对话框，因此只为该测试进程传入 `--disable-workspace-trust`。

## Schema 校验方式

`scripts/check_schema.py` 通过 `moon run --target native tests/codec_fixture` 获取 JSON Lines。每行指定固定规范中的一个具体定义并含有往返后的消息。校验器保留 Schema 根部的 `definitions`，通过 `$ref` 选中该消息的定义。`scripts/test_e2e.py` 使用同一校验函数检查实际请求、成功响应、错误响应及事件，同时断言 `seq`、`request_seq` 和事件顺序。详细步骤见 [README](../README.md)。

## 外部运行时回归

在 Windows x64 使用 MoonBit `v0.10.20+65efd5b93` 复测，检查、格式、生成结果核对及 native 构建通过。共通过 22 项 MoonBit 测试、11 个 Draft 4 样本、5 项迷你解释器端到端测试及 1 项官方 DAP 客户端测试。

`python scripts/test_bpflab.py` 另运行 1 项独立的外部 VM 测试。测试在条件 `r0 == 2` 命中断点，单步得到 3，继续执行后输出 4 并正常退出。Windows 实测使用直接调用 `moonc.exe` 的进程级配置。复现命令与接入边界见 [MoonBpfLab 接入案例](../examples/bpflab/README.md)。
