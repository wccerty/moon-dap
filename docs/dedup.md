# 第 0 步 · 现有 MoonBit DAP 项目查重

查询于 2026-11-10 14:34–14:39（UTC+08:00）执行。检查范围包括 Mooncakes 公开模块、GitHub 公开仓库索引和源码索引。

在可见结果中未发现可让第三方解释器、虚拟机或 DSL 接入其自有调试目标的 MoonBit DAP 服务端开发包或骨架。发现了两个相近的 MoonBit 实现。moondbg 有供 VS Code 连接的服务端入口，执行固定走 LLDB。MoonWren 有面向自有 VM 的 DAP 风格会话类型。

## 环境

- `Get-ChildItem -Force`、`git rev-parse --show-toplevel` 和 `git status --short --branch` 确认当前目录是独立仓库，开始时仅有 `.git`，提交数 0。 `git remote -v` 无输出。
- 沙盒内 `gh api user` 返回 401。在正常宿主环境重试后确认账号为 `wccerty`。用户授权使用 GitHub 邮箱。账号公开邮箱为空，私有邮箱接口需要额外权限，采用 GitHub 提供的账户 ID 格式地址。仅配置本仓库。`git var GIT_AUTHOR_IDENT` 和 `git var GIT_COMMITTER_IDENT` 均返回 `wccerty <299791384+wccerty@users.noreply.github.com>`。[GitHub 邮箱格式](https://docs.github.com/en/account-and-profile/reference/email-addresses-reference)
- `moon version --all` 返回 Moon CLI `0.1.20261023 (3778465)`、`moonc v0.10.17+d971670cd` 和 `moonrun 0.1.20261023 (3778465)`。

## Mooncakes

以下命令均退出 0。命中数是 CLI 返回的模块数，默认最多 20 个，且会匹配包摘要。保存了包括标准错误在内的[完整 CLI 输出](dedup-logs/moon-cli.txt)。

| 命令 | 模块数 | 相关命中与判断 |
| --- | ---: | --- |
| `moon search dap` | 3 | moondbg 及其子包。另两个是 Ethereum SDK 和 Dapr 相关模块。 |
| `moon search "debug adapter"` | 20 | moondbg、MoonWren 和 Kagura 状态检查层需要区分，详见下文。 |
| `moon search "debug adapter protocol"` | 7 | moondbg 有明确 DAP 包摘要。其他模块涉及 MQTT、应用工具、Morphir 宿主和标准库。 |
| `moon search debugger` | 9 | 除 moondbg 外，有解释器内置调试、DWARF 与源码映射、V8 Inspector 以及状态可视化。 |
| `moon search debug` | 20 | 代表性结果是值格式化与差异比较、PDB/DWARF 解析、可视化和追踪。 |
| `moon search breakpoint` | 10 | moondbg、BPF/VM 自带调试、语言工具及 CSS 断点等词义命中。 |
| `moon search moondap` | 20 | 包含 MoonDark、MoonLDAP、MoonAPI 等近似名称。 |
| `moon view moonbitstack` | 79 | 查到注册表发布列表，无以 DAP 服务端开发包定位的模块。 |

用 `curl.exe --fail --silent --show-error --location --header 'Cache-Control: no-cache' --output <临时文件> https://mooncakes.io/api/v0/modules` 刷新全量索引。HTTP 请求成功，返回 3,696 条记录。对 `name` 和 `description` 拼接后的文本做不区分大小写的子串查找。索引中有 48 个 `moonbitlang/` 模块和 79 个 `moonbitstack/` 模块。

| 子串 | 命中 | 代表结果 |
| --- | ---: | --- |
| `dap` | 54 | 多数来自 `adapter`、`adaptive` 等子串，另有 MoonLDAP 和 Dapr。 |
| `debug` | 19 | DWARF、PDB、日志追踪、值格式化、可视化、BPF 调试及作者名命中。 |
| `debugger` | 1 | `btlqql/moon_bpflab`，BPF 解释器内置调试。 |

[索引 SHA-256 和全部命中行](dedup-logs/mooncakes-matches.txt)。moondbg 的模块描述为空，DAP 关键字来自 CLI 包摘要，因此需要同时查两种来源。

## GitHub

仓库查询通过 `gh api -X GET search/repositories` 执行，查询覆盖 `in:name,description,readme`，没有语言筛选。代码通过 `gh api -X GET search/code` 加 `extension:mbt` 查询。下表为 API 报告的命中数。[查询与结果](dedup-logs/github-search.txt) · [精确名称与分页补查](dedup-logs/github-search-extra.txt)

| 查询词 | 命中 | 说明 |
| --- | ---: | --- |
| `moon-dap` / `moondap` | 466 / 7 | 大量 dApp、配置仓库与拼写相近结果。精确名称查询也返回了 15 个 dApp 名称。 |
| `moonbit dap` | 15 | 重点复核 moondbg、MoonWren、Vibe、Light 等。 |
| `moonbit "debug adapter"` / `moonbit "debug adapter protocol"` | 6 / 4 | 主要为收藏清单、Light 和 FORGENTEX。 |
| `moonbit debugger` | 701 | 已分页。包含 MoonBit 调试示例、语言自身调试器和追踪工具。 |
| `org:moonbitlang dap` / `org:moonbitstack dap` | 0 / 0 | 两个组织分别补查 `"debug adapter"`，均为 0。 |
| `org:moonbitlang debugger` / `org:moonbitstack debugger` | 12 / 8 | 检查了命中的编译器、运行时、日志、ASGI、MCP、RPC 等项目。 |
| `setBreakpoints extension:mbt` | 28 | moondbg、MoonBit CDP、Proton。后两项的命中属于 Chromium 调试。 |
| `configurationDone extension:mbt` | 27 | 仅 moondbg。 |
| `stackTrace extension:mbt` | 71 | 除 moondbg 外，多为运行时栈、浏览器调试及诊断类型。 |
| `"Content-Length" extension:mbt` | 768（首轮） | HTTP、LSP 和其他帧协议大量命中。分页重查的索引计数变为 1,017，API 上限 1,000 条，页面间有重叠。 |
| `"request_seq" extension:mbt` | 56 | moondbg 和其他自有请求编号字段。 |

补查 DAP 关键词组合时触及 GitHub 代码搜索限流，HTTP 403 已记录。上述指定关键词均有成功响应。搜索无法覆盖私有、未索引或未提交的代码。[补充查询及限流记录](dedup-logs/github-targeted.txt)

## 关键项目复核

| 项目 | 观察结果 |
| --- | --- |
| moondbg | Mooncakes 当前结果为 `0.3.1`。GitHub 未归档，默认分支 `master` 在查询时指向 `d07c74bf5bb615bf0f3c7194a6f30b1a01571522`，提交时间为 2026-09-23 14:01:51（UTC+08:00）。最新 GitHub Release 接口返回 404。项目既有连接 LLDB 的 DAP 客户端，也有处理 VS Code 请求的 DAP 服务端入口。该入口只接受读写流，实际执行固定创建 LLDB 的适配器进程。独立的 `DebugBackend` trait 由调试器核心消费，DAP 前端不接收它。moon-dap 的差异是把服务端会话和传输开放给任意第三方调试目标，由目标提供断点、执行和变量数据。[入口源码](https://github.com/Kaida-Amethyst/moondbg/blob/d07c74bf5bb615bf0f3c7194a6f30b1a01571522/dap_frontend/server.mbt) · [后端连接](https://github.com/Kaida-Amethyst/moondbg/blob/d07c74bf5bb615bf0f3c7194a6f30b1a01571522/dap_frontend/live_server.mbt) · [调试器核心接口](https://github.com/Kaida-Amethyst/moondbg/blob/d07c74bf5bb615bf0f3c7194a6f30b1a01571522/debugger/backend.mbt) |
| MoonWren | Mooncakes 查询返回 `0.9.6`。`DebugAdapterSession` 维护断点、预排队的调试命令和停止快照，直接挂到 MoonWren 的 `Vm`，该文件未定义 DAP 线上分帧或请求处理。[适配会话源码](https://github.com/wdgodghl/moonwren/blob/37bb248782a345c89d3dc6e5fed244021557aca5/debug_adapter.mbt) |
| Vibe 和 Light | 分别有专用于各自语言的 JavaScript 和 Python 适配器。[Vibe 适配器](https://github.com/mizchi/vibe-lang/blob/ad389f367738efd837bda8ac1dd23191a6e53b75/clients/js/dap_server.js) · [Light 适配器](https://github.com/skywalk163/light/blob/20ae0b4cc139bd56c308e2c1745060e08fd0fd23/debug-adapter/light_debug_adapter.py) |
| 其他相关结果 | MoonBit WASM Debugger 为 TypeScript 项目。MoonWalk 面向 MoonBit 测试录制与回看。MoonBit CDP 对接 Chromium DevTools，Kagura 的检查层面向游戏状态，MoonPDB 读取调试符号。[源码核对记录](dedup-logs/github-source.txt) · [仓库与目录核对记录](dedup-logs/github-review.txt) |

本阶段未构建或运行软件测试，提交数 0。
