# moon-dap 第一版设计

moon-dap 面向 MoonBit 编写的解释器、虚拟机和 DSL。接入者提供调试目标和运行时事件，库负责 DAP 会话、消息和传输。本页保留第一版设计所依据的协议约定，实施细节见各节。

## 规范基线与许可证

以 Microsoft 官方仓库提交 `d2387e875a1ec4c2ed9964edea22617c81651cc0`（2026-11-03）为基线。该提交的 `debugAdapterProtocol.json` 声明 JSON Schema Draft 4，文件 SHA-256 为 `5dc16664b5cd7a08a769c14dc19be900dc4c3e7d227cd922583780d25480877a`。概览约定消息框架和交互顺序，Schema 提供消息及字段形状。[固定版概览](https://github.com/microsoft/debug-adapter-protocol/blob/d2387e875a1ec4c2ed9964edea22617c81651cc0/overview.md) · [固定版规范](https://github.com/microsoft/debug-adapter-protocol/blob/d2387e875a1ec4c2ed9964edea22617c81651cc0/specification.md) · [固定版 Schema](https://github.com/microsoft/debug-adapter-protocol/blob/d2387e875a1ec4c2ed9964edea22617c81651cc0/debugAdapterProtocol.json)

上游 `License.txt` 区分文档的 CC BY 3.0 US 与代码的 MIT。拟用 Apache-2.0 发布项目原创代码，与 MIT 上游代码和 Apache-2.0 的 `moonbitlang/async` 兼容。后续纳入固定 Schema 时保留上游两份许可文件及 Microsoft 署名，在第三方许可说明中标明原始地址、提交和生成方式。生成文件注明源文件、SHA 和 Microsoft 来源。生成器提取结构，中文文档自行总结规范。若将来引用上游描述，按其文档许可标明出处与改动。[Microsoft 总许可](https://github.com/microsoft/debug-adapter-protocol/blob/d2387e875a1ec4c2ed9964edea22617c81651cc0/License.txt) · [Microsoft 代码许可](https://github.com/microsoft/debug-adapter-protocol/blob/d2387e875a1ec4c2ed9964edea22617c81651cc0/License-code.txt) · [MoonBit 异步库许可证](https://github.com/moonbitlang/async/blob/main/LICENSE)

## 分层

```mermaid
flowchart LR
    E["VS Code / Neovim"] <-->|"stdio 或 TCP"| T["native 传输"]
    T <-->|"字节"| F["增量分帧"]
    F <-->|"UTF-8 JSON"| P["生成的协议类型与编解码"]
    P <-->|"请求 / 响应 / 事件"| S["会话与能力协商"]
    S <-->|"领域命令 / 运行时事件"| D["DebugTarget"]
    D <--> V["解释器 / VM / DSL"]
```

| 层 | 职责 |
| --- | --- |
| `framing` | 按字节解析头部与消息体，独立测试任意切块。 |
| `protocol` | Schema 生成的结构及 JSON 编解码。通用信封可读取未知命令。 |
| `session` | 状态、请求路由、序号、能力、领域数据与协议数据映射。 |
| `target` | 解释器实现的接口、领域类型与事件入口。 |
| `transport` | native 字节流驱动、stdio 和 TCP 包装、连接生命周期。 |

纯协议与会话状态测试不依赖系统 I/O。用可注入的目标接口承接各语言的运行控制。这样传输变化只影响流驱动，增加 DAP 命令也无需变更解释器的现有接入点。独立的生成协议类型会增加包内代码体积，手写部分只保留信封分派、协议策略与领域模型。

## 消息框架

- 正常输出为 ASCII `Content-Length: <字节数>\r\n\r\n`，后接 UTF-8 JSON。长度在编码后计算，JSON 中汉字或 emoji 的字节数与字符数不同。
- 接收器按 `Header → Body(n) → Header` 工作。每次输入可产出零到多帧，保留未完成部分。支持跨块的头部分隔符、多帧与末尾半帧。已完整解析的帧按顺序交付，后续错误单独报告。
- 容忍长度值周围的空格或制表符、头部字段名大小写、帧边界处有限的空行以及 JSON 自身允许的空白。已知长度的正文完全按字节消费。头部使用 CRLF，正文可含换行。
- 单个 `Content-Length` 必填，值须为正的十进制整数。缺失、重复、非数字、溢出、超限、无效头部或 EOF 时半帧均为错误。可跳过格式合法的额外头字段。拟默认限制头部 8 KiB、正文 8 MiB，调用方可调整。头部失去同步时关闭连接。
- UTF-8、JSON、协议字段在分帧后分别校验。正文损坏且无法可靠取得请求编号和命令时，记录诊断并关闭。信封可识别而参数无效时返回该请求的失败响应。

## 消息模型与生成

| 类型 | 公共字段与载荷 |
| --- | --- |
| 请求 `Request` | `seq`、`type=request`、`command`、可选 `arguments`。 |
| 响应 `Response` | `seq`、`type=response`、`request_seq`、`command`、`success`、可选 `message` 与 `body`。 |
| 事件 `Event` | `seq`、`type=event`、`event`、可选 `body`。 |

先解通用信封，再按 `command` 或 `event` 解具体载荷。客户端的扩展字段按其 Schema 处理。开放对象如 `launch` 和 `attach` 的目标私有参数保留原始 JSON。库维护适配器自己的序号，响应和事件共用一个从 1 递增的序列，`request_seq` 回填对应客户端编号。同一请求只结算一次。分配序号由唯一发送路径负责，到协议整数上限时结束会话。

生成器拟用 Python 标准库解析固定 Schema 的 192 项定义，并生成 MoonBit 结构、枚举、联合类型和 JSON 编解码。按 `$ref` 和 `allOf` 解析继承与固定标签，保持必填字段与可选字段的区别。有限的 `enum` 生成封闭集合，`_enum` 保留可扩展字符串。区分允许显式 `null` 的联合类型与缺省字段。按范围选择数值类型，64 位数值保持整数精度并执行 Schema 中的上限。支持当前使用的数组、内联对象、`additionalProperties` 和 `oneOf`。遇到未识别的结构时报告定义路径并失败。任意 JSON 载荷保留为 JSON。

提交生成脚本、固定输入与生成结果。升级时显式更新提交和哈希，重新生成并审阅 API 差异。CI 比较生成结果与仓库内容。测试使用 Python `jsonschema.Draft4Validator`，保留根 `definitions` 并以具体请求、响应或事件定义作为 `$ref` 入口。根 Schema 单独使用只会约束为对象。测试包含结构有效的往返、错误样本，以及序号关联和事件顺序的会话断言。

## 会话状态机

| 状态 | 输入与迁移 |
| --- | --- |
| `New` | 仅接受一次 `initialize`。校验并保存客户端能力和行列坐标约定，发送能力响应，进入 `Ready`。未初始化的 `launch` 等请求收到失败响应。 |
| `Ready` | 接受 `launch` 或 `attach`，由目标准备或绑定运行时。成功后进入 `Configuring`，发送一次 `initialized`。启动请求保留为待响应。准备失败则结算失败，并释放本次已分配资源。 |
| `Configuring` | 接受配置请求，如 `setBreakpoints`。收到 `configurationDone` 后完成目标配置并提交启动，依次发送 `configurationDone` 响应和待响应的 `launch` 或 `attach` 响应，再发目标的初始停止或输出事件。启动失败时结算相关请求并清理。 |
| `Running` | `threads`、`setBreakpoints`、`pause` 可用。目标在真实暂停时发停止事件并进入 `Stopped`。读取暂停快照的请求返回 `notStopped`。 |
| `Stopped` | 提供线程、调用栈、作用域、变量，以及源码断点的更新。继续与三种单步被目标接受后，废弃本次暂停的句柄并进入 `Running`。后续停止由目标事件驱动。 |
| `Terminated` | 正常退出时有退出码才发 `exited`，随后发一次 `terminated`。接受 `disconnect` 做最后清理。 |
| `Closed` | 已结算待处理请求、停止接收和发送、释放会话资源。 |

`disconnect` 在成功初始化后的各阶段均可结束会话。配置阶段退出时结算待响应的 `launch` 或 `attach`，然后回复 `disconnect` 并关闭。默认结束由 `launch` 创建的目标，`attach` 会解除调试绑定并允许目标继续运行。收到 EOF 或写入失败也走清理路径。退出和终止可能来自不同通知，按会话去重。

第一版公布 `supportsConfigurationDoneRequest` 和 `supportsDelayedStackTraceLoading`。目标提供断点位置查询函数时，也公布 `supportsBreakpointLocationsRequest`。空的 `setExceptionBreakpoints` 配置兼容客户端探测，实际异常筛选返回未支持。客户端没有声明行列基数时使用 1，目标接口统一使用 1 基索引。第一版接收 `path` 格式和本地源码路径，收到不支持的路径格式时在初始化响应中报告。纯运行请求 `launch.noDebug: true` 返回未支持。

## 调试目标接口

以下为签名草案，最终 MoonBit 签名和效果标注在实现阶段根据本机编译器验证。会话持有一个目标实例，目标也可以把接口实现为自身调试循环的命令代理。

| 接口 | 契约 |
| --- | --- |
| `prepare(mode, options, sink)` | 解析目标私有配置，准备新实例或绑定已有实例。在配置完成前让目标停在安全点。支持方式由目标实例决定。 |
| `start()` | 完成配置并允许执行，或返回入口暂停结果。运行与停止事件由目标报告。 |
| `set_breakpoints(source, requested)` | 用本次请求替换该文件的全部断点，空列表清除。按请求顺序返回实际位置、是否验证成功及原因。 |
| `conditional_breakpoint_provider()` | 可选，统一接收同一文件的普通和条件断点。目标解析条件并返回逐项验证结果。命中计数和日志断点暂不支持。 |
| `breakpoint_location_provider()` | 可选的只读查询函数。会话将请求转换成 1 基坐标，过滤范围外的位置，再以客户端坐标返回。 |
| `resume_execution(thread, mode)` | `mode` 为继续、步入、步过、步出。目标确认接受后立即返回，等待停止通过事件入口完成。 |
| `pause(thread)` | 在运行时请求暂停。目标在到达安全点时发送停止通知。 |
| `threads()`、`stack_trace(thread, page)` | 单线程目标提供稳定的线程 ID。栈帧按当前调用顺序返回并支持分页。第一版的执行控制作用于整个目标。 |
| `scopes(frame)`、`variables(handle, query)` | 分别提供作用域和子变量。仅叶子对客户端返回 `variablesReference: 0`，作用域与可展开变量使用暂停期句柄，支持按名称或索引筛选与分页。 |
| `evaluation_provider()` | 可选，接收当前暂停的目标帧与原始表达式，返回只读文本结果。会话先校验帧的有效性。 |
| `poll()` | 在运行态推进一个有界工作片。解释器在安全点发出事件，将控制权交给会话以处理编辑器请求。 |
| `disconnect(mode)` | 终止或分离，重复调用安全，清理失败由库记录和上报。 |
| `EventSink` | 发送 `stopped`、`output`、`exited`、`terminated`，也支持 `continued` 和 `thread`。事件不带协议序号。仅在没有先行的恢复请求时发送 `continued`。 |

库为每个暂停代次分配对外的栈帧与变量 ID，映射到目标的私有句柄。恢复或终止时失效，跨代次不复用同一个可见 ID。目标提供文件位置、帧、作用域和变量值，库做行列基数转换、线程 ID 校验和错误映射。示例拟实现调用与返回、赋值、输出和嵌套记录，覆盖三种单步与变量展开。

## 错误与并发

动态源码提供者通过 `SourceProvider` 返回描述和源码正文。会话用独立的引用表分配 `sourceReference`，在恢复执行时保留它，在连接结束后清除。每次读取重新确认源码仍在目标清单中。栈帧和断点的内部路径匹配时，响应携带同一源码引用。目标在运行实例中不得将旧源码句柄分配给不同源码。

`InspectionProviders` 提供结构化求值、赋值和补全。修改目标返回 `VariableUpdate`，列出被替换的值及其子容器的旧句柄。会话在响应前废弃这些引用，帧和未受影响的变量引用保留到下一次恢复。`BreakpointProviders` 接管整组源码或函数断点替换。旧目标的默认回调为空，会话仍按旧接口处理源码行和基础求值。

已知请求信封的错误统一响应 `success: false`，保留原 `command` 和 `request_seq`。暂停状态不满足时用标准短消息 `notStopped`，其他失败用稳定短消息和可读的 `body.error`。未实现或未知命令同样返回规范形状的失败响应。参数、状态和目标错误彼此区分。stdio 诊断只写 stderr，目标输出走 `output` 事件。

每个连接对应一个会话。读任务通过有界输入队列把帧交给会话。会话循环独占状态和写入，串行处理请求和通知，半帧写入时不会混入另一条消息。目标在运行时每次只推进一个有界工作片，让读任务可接收暂停和断开。请求内产生的事件由会话收集，写出响应后再按序发事件。`Options.request_timeout_ms` 分别约束一次请求处理、一次会话轮询、每条消息写入和连接结束清理。会话轮询出错后调用的异步目标清理也受此约束。超时通过协作式取消生效，目标的异步方法应配合取消，同步 `poll` 应及时返回。

输入队列最多缓存 32 帧并实施背压。目标事件队列最多缓存 256 个通知，队满时 `EventSink.emit` 返回错误，目标应分批产生输出并及时让出执行权。超时、取消或断线由连接任务组统一收尾。事件入口绑定目标启动代次，关闭后拒收通知。连接和目标状态相互隔离，示例监听回环地址，每个 TCP 连接新建一个会话。

运行或暂停期间，传输先尝试取出排队请求。队列为空时等待一个轮询间隔，再取队列内的请求。等待本身不从队列读取，以免轮询计时结束与异步出队同时发生时丢失已取出的请求。默认空队列等待在运行态为 2 毫秒，暂停态为 20 毫秒。初始化和配置阶段仍直接等待输入。

## 传输与编辑器验收

第一版用 `moonbitlang/async@0.20.6` 的 `stdio` 与 `socket` 支持 native。JS 与 Wasm 的内置 stdio 和 TCP 不列入第一版，纯分帧与协议层能否跨目标发布由后续编译矩阵决定。实际运行的平台见 [验证记录](verification.md)。[MoonBit 异步文档](https://docs.moonbitlang.com/en/latest/language/async-experimental.html)

VS Code 演示拟使用示例内的本地调试类型声明和 `launch.json` 的 `debugServer` 字段，让编辑器连接回环 TCP。Neovim 用 nvim-dap 配置 TCP server 或 stdio 可执行文件。编辑器验收分别记录环境、配置、运行命令和可见结果。[VS Code 调试适配器开发指南](https://code.visualstudio.com/api/extension-guides/debugger-extension)

验收命令、结果及编辑器验证状态随仓库记录。[验证记录](verification.md)
