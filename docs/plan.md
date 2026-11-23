# moon-dap 实施计划

第一版交付可被 MoonBit 解释器、虚拟机与 DSL 依赖的 DAP 服务端开发包。

增量分帧、生成协议层和会话层处理 DAP。解释器通过调试目标接口提供执行、栈和变量，native 传输负责 stdio 和 TCP。

实现使用 MoonBit、官方异步库和 Python 生成器。验收使用 Draft 4 校验器和 GitHub Actions。

[设计](design.md) · [覆盖计划](coverage.md)

## 初审通过后的交付计划

1. 使用外部 VM 的返回地址栈实现调用栈分页、步入、步过和步出，用嵌套调用验证帧位置和暂停期引用。
2. 接入 ELF 指令和显式源码映射，验证多文件断点、源码位置及错误参数。保留文本指令示例作为快速回归。
3. 将外部示例接入 VS Code 与 Neovim，使用实际编辑器执行断点、栈查询及单步测试。
4. 预检 Mooncakes 归档并检查许可、生成产物和本地材料的排除规则。GitHub CI 通过后以 `wccerty` 发布，并在独立模块中从注册表安装和构建。

## 实施阶段

| 阶段 | 预期成果 | 验收条件 |
| --- | --- | --- |
| 0 · 查重 | 注册表和 GitHub 查询，保存日志并复核近似项目。 | 七条 `moon search`、全量索引和 GitHub 指定关键词都有实际查询记录。找到可接入第三方调试目标的 MoonBit DAP 服务端开发包时暂停。 |
| 1 · 设计 | 固定 Microsoft 规范及许可证，定义接口、状态机、I/O 和覆盖边界。 | 覆盖表与固定 Schema 一致。提交设计供用户审阅，用户确认后开始实现。 |
| 2 · 协议基础 | 建立模块，完成字节分帧、类型生成、错误响应模型。 | 正常、半包、粘包、尾部半帧、坏头和随机切分均有测试。生成产物可重复生成，往返样本通过 Draft 4 校验。 |
| 3 · 会话与目标接口 | 完成启动、配置、执行、查询和清理。 | 伪目标测试覆盖合法状态迁移、错误顺序、序号关联、断点清除、嵌套变量、句柄失效、终止与分离。 |
| 4 · 传输与示例 | 完成 native stdio、回环 TCP 和最小解释器。 | 两种传输分别跑完整会话。示例验证断点、三种单步、调用栈、变量展开、暂停、输出和退出。 |
| 5 · 互操作与交付 | GitHub Actions、中文 README、稳定的示例运行说明和测试记录。 | 在 VS Code 实际检查断点、单步和变量。记录命令、版本、数量和结果，按实测整理平台矩阵。 |

## 提交切分

下面各项是按可验收成果划分的预计提交。每个提交应有独立的功能、测试、集成或文档变更。提交身份使用本仓库配置的 `wccerty`，提交正文不添加共同作者。

1. 固化查重与评审设计，保存协议覆盖边界。
2. 建立 MoonBit 模块、包布局和许可证，固定上游 Schema 与来源说明。
3. 实现增量字节分帧及解析测试，包括固定种子的随机切分属性测试。
4. 实现 Schema 生成器，纳入可重现的 MoonBit 类型和 JSON 编解码产物。
5. 添加编解码往返、Draft 4 外部校验和生成一致性检查。
6. 建立会话握手、初始化能力、序号、错误响应和请求顺序测试。
7. 接入调试目标的启动、绑定、断点与运行控制，覆盖配置完成和断开清理。
8. 接入线程、栈、作用域、变量查询与运行时事件，验证句柄失效和事件顺序。
9. 实现 native 字节流驱动、stdio 和 TCP，并验证连接隔离与收尾。
10. 实现迷你解释器及调试目标，覆盖调用、赋值、嵌套记录和执行事件。
11. 增加编辑器模拟脚本，验收两种传输和完整消息序列。评估官方 `@vscode/debugadapter-testsupport` 的可用性，记录结果。
12. 配置检查、格式、测试和构建的 CI，补全中文 README、本地 VS Code 配置、Neovim 配置与实测记录。

## 验收矩阵

| 项目 | 关键断言与记录 |
| --- | --- |
| 分帧 | 每字节分割、随机切分、UTF-8 多字节、CRLF 跨块、单块多帧、可容忍空白、重复或缺失长度、溢出、超限、截断 EOF。 |
| 类型 | 生成器重复运行一致。关键载荷和边界值往返正确。标准库解析后，对具体 Schema 定义做 Draft 4 校验。无效样本报告字段或定义路径。 |
| 会话 | 初始化前 `launch` 失败，握手后能力正确，配置和启动响应顺序正确，重复请求状态处理清晰。未知命令、运行时读取栈、过期引用及断线各有覆盖。 |
| 端到端 | 客户端脚本分别通过 stdio 和 TCP 发送 `initialize`、`launch`、断点、`configurationDone`、查询、运行控制和 `disconnect`。断言请求关联、事件顺序、断点行、调用层级、嵌套值和退出码。 |
| 编辑器 | VS Code 记录本地调试类型、`launch.json`、适配器命令和断点、单步、变量的实际观察。Neovim 配置也按实际运行情况标注。 |
| CI | 拟使用 `moon check --target native`、`moon fmt --check`、`moon test --target native` 和 `moon build --target native`，加生成一致性与 E2E 校验。当前仅通过 `--help` 核对参数存在。工作流命令以实现后实际运行的版本为准。 |

README 提供约 20–30 行的最小接入示例，并链接完整目标实现。应用场景覆盖脚本解释器的编辑器断点、VM 或模拟器的单步与状态查看，以及业务 DSL 或规则引擎的可视化调试。交付时将验证记录、已知限制、查重结论和路线图随仓库提供。

## 设计检查点记录

第 0 步和第 1 步完成时，提交数和软件测试数均为 0。收到用户确认后进入实现阶段。当前构建、测试和编辑器状态见 [验证记录](verification.md)。

| 本阶段实际执行 | 输出或结果 |
| --- | --- |
| `gh api repos/microsoft/debug-adapter-protocol/commits/main` | 提交 `d2387e875a1ec4c2ed9964edea22617c81651cc0`，提交日期 2026-11-03。 |
| `curl.exe -fLsS -o <临时文件> https://raw.githubusercontent.com/microsoft/debug-adapter-protocol/<固定提交>/<文件名>` | `debugAdapterProtocol.json`、`overview.md`、`specification.md`、`License.txt`、`License-code.txt` 均已获取。 |
| `Get-FileHash <Schema 临时文件> -Algorithm SHA256` | `5DC16664B5CD7A08A769C14DC19BE900DC4C3E7D227CD922583780D25480877A`。 |
| `moon check --help`、`moon fmt --help`、`moon test --help`、`moon build --help` | 查到检查、测试和构建的 `--target`，以及格式检查的 `--check`。 |
| 运行 Python 一次性文档检查 | 覆盖表逐项匹配 Schema 的 45 个请求、17 个事件、42 个能力字段。Schema 哈希一致，4 份 Markdown 文档的 10 个相对链接均可解析，CLI 日志 9 条命令退出码均为 0。 |
| `python -c "import jsonschema"` | 当前 Python 3.11.4 环境未安装 `jsonschema`。实现阶段将其作为测试依赖固定。 |
| `git status --short --branch`、`git remote -v`、`git rev-parse --verify --quiet HEAD` | `No commits yet on master`，`docs/` 为新增文档，未设置 remote，HEAD 无提交。 |
