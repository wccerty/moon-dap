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

## 2026-11-19 可靠性回归

Windows x64 使用 `moonc v0.10.20+65efd5b93`。`moon check --target native --deny-warn`、`moon fmt --check`、生成代码一致性校验及 native 构建均退出 0。完整命令和输出记录在 [本地可靠性验证日志](reliability-verification.txt)。

| 验证项目 | 实际结果 |
| --- | --- |
| `moon test --target native` | 23 项通过，0 失败。新增的传输层测试通过 `serve` 入口触发运行时轮询失败，验证阻塞的异步清理受到 `request_timeout_ms` 限制、取消时执行收尾，并且目标清理只调用一次。 |
| `python scripts/check_schema.py` | 11 个 MoonBit 往返样本通过 Draft 4 校验。 |
| `python scripts/test_e2e.py` | 6 项通过。新增 TCP 回归依次发送非法头部、无效 UTF-8、无效 JSON、重复 JSON 键和截断帧，确认每个异常连接关闭，已有会话仍可响应，监听器仍可接收新会话。 |
| `node --test tests/vscode_client.cjs` | 1 项官方 DAP 客户端测试通过。 |
| `python scripts/test_bpflab.py` | 3 项通过。覆盖完整外部 VM 调试会话、条件断点替换与清除、`uint64` 最大值条件，以及三种启动错误后在原连接重试。 |

两处修复均先通过回归测试复现。修复前，传输测试触发外层保护超时，断言出现 `None != Some(true)`。为会话轮询加上超时后，同一测试收到传输层自身的 `TimeoutError` 并通过。外部案例曾将字符串 `stopOnEntry: "true"` 当作关闭处理，测试收到 `initialized` 事件；修复后返回 `targetError`，随后可用正确参数重新启动。

这里的超时依赖异步方法配合取消。目标的同步 `poll` 仍须执行有界工作并及时返回。本次编辑器相关回归使用官方 DAP 测试客户端，外部 VM 使用 stdio 脚本验收。

## 2026-11-23 注册表发布与外部 VM 验收

Windows x64 使用 `moonc v0.10.20+65efd5b93`。发行版库归档包含四个库包、公共接口与协议生成产物，保留项目及 Microsoft 规范许可证。归档检查拒绝本地材料、编辑器测试和其他发布范围外的目录。[Mooncakes 包](https://mooncakes.io/docs/wccerty/moon-dap)

| 实际执行 | 结果 |
| --- | --- |
| `moon check --target native --deny-warn`、`moon fmt --check`、`moon -C examples/bpflab fmt --check` | 退出 0。 |
| `python scripts/generate_protocol.py --check` | 核对 192 项 Schema 定义。 |
| `moon test --target native`、`moon build --target native` | 23 项测试通过，构建成功。 |
| `python scripts/check_schema.py`、`python scripts/test_e2e.py`、`node --test tests/vscode_client.cjs` | 11 个往返样本、7 项端到端测试、1 项官方客户端测试全部通过。 |
| `python scripts/test_bpflab.py` | 4 项通过。新增用例验证 ELF 的两文件断点、三层栈分页、步过、步出和实际寄存器值。 |
| `moon package --frozen`、`python scripts/verify_release.py --archive <归档路径>` | 校验 34 个归档文件。 |

VS Code 实测发现同一轮询间隔内的计时与请求出队竞争。修复前，暂停期回归收到 `request_seq: 6`，此前发送的 `request_seq: 5` 未收到响应。修复后，测试以错开的间隔发送 64 条栈和线程请求，逐条收到正确响应。[暂停期回归测试](../scripts/test_e2e.py)

在 Windows 上用 `python scripts/test_bpflab.py --prepare-example _build/editor-demo` 构建适配器并生成 ELF，在独立配置中完成两次编辑器验收。环境变量设置见 [外部案例](../examples/bpflab/README.md)。

| 实际命令 | 结果 |
| --- | --- |
| `code --wait --user-data-dir <专用目录> --extensions-dir <专用目录> --disable-workspace-trust --extensionDevelopmentPath=<外部案例/vscode> --extensionTestsPath=<外部案例/vscode/smoke.cjs> <外部案例>` | 使用签名有效的 VS Code 1.147.0 测试副本。命中 `helper.bpf` 第 4 行，断言三个栈帧，求值 `r0` 得 1，通过编辑器步出命令返回 `increment`。扩展宿主与 CLI 均退出 0。 |
| `nvim --headless -u NONE -i NONE -l tests/neovim_bpflab.lua` | Neovim 0.12.6，nvim-dap 固定在 `cfa2d58f4537aca6ca83e2de1a0d9f1491121264`。实际输出「Neovim：ELF 源码断点、三层真实调用栈、寄存器求值和步出通过」，退出 0。 |

归档预检使用 `moon publish --dry-run`，允许解包后的独立目录同步依赖。发布后运行 `moon update` 和 `python scripts/verify_release.py --registry`，从注册表下载库，在不带 `moon.work` 的临时模块中构建外部适配器并跑完整 stdio 调试会话。首次 Windows 编译有异步依赖的 `EINVAL` 宏重定义警告，构建成功。
