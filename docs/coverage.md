# DAP 协议覆盖计划

基线为 Microsoft DAP 提交 `d2387e875a1ec4c2ed9964edea22617c81651cc0`。按 Schema 枚举所有请求、事件和 `Capabilities` 字段。以下状态表示实现计划。生成的协议类型覆盖完整 Schema，会话行为按表验收。[固定版 Schema](https://github.com/microsoft/debug-adapter-protocol/blob/d2387e875a1ec4c2ed9964edea22617c81651cc0/debugAdapterProtocol.json)

- **第一版支持**的条目列入第一版验收，表中注明目标能力或其他前提。
- **计划支持**的条目在第一版之后评估，当前无交付日期。
- **不支持**的条目在当前路线图范围外。

## 请求（45 项）

| 请求 | 状态 | 范围 |
| --- | --- | --- |
| `cancel` | 计划支持 | 请求级取消。 |
| `runInTerminal` | 不支持 | 适配器到客户端的反向请求。 |
| `startDebugging` | 不支持 | 适配器到客户端的反向请求。 |
| `initialize` | 第一版支持 | 能力交换、坐标和路径约定。 |
| `configurationDone` | 第一版支持 | 提交配置并启动。 |
| `launch` | 第一版支持 | 目标定义启动参数。 |
| `attach` | 第一版支持 | 由实现了绑定操作的目标处理。 |
| `restart` | 计划支持 | 会话内重启。 |
| `disconnect` | 第一版支持 | 依启动方式终止或分离。 |
| `terminate` | 计划支持 | 独立的优雅终止请求。 |
| `breakpointLocations` | 计划支持 | 可设置断点的位置。 |
| `setBreakpoints` | 第一版支持 | 文件中的行断点，整组替换或清除。 |
| `setFunctionBreakpoints` | 计划支持 | 函数入口断点。 |
| `setExceptionBreakpoints` | 第一版支持 | 接受空配置以兼容客户端，异常筛选计划支持。 |
| `dataBreakpointInfo` | 不支持 | 数据断点查询。 |
| `setDataBreakpoints` | 不支持 | 数据断点设置。 |
| `setInstructionBreakpoints` | 不支持 | 指令地址断点。 |
| `continue` | 第一版支持 | 恢复目标。 |
| `next` | 第一版支持 | 语句级步过。 |
| `stepIn` | 第一版支持 | 语句级步入。 |
| `stepOut` | 第一版支持 | 语句级步出。 |
| `stepBack` | 不支持 | 反向单步。 |
| `reverseContinue` | 不支持 | 反向运行。 |
| `restartFrame` | 不支持 | 重启指定栈帧。 |
| `goto` | 不支持 | 修改当前执行位置。 |
| `pause` | 第一版支持 | 请求在安全点暂停。 |
| `stackTrace` | 第一版支持 | 暂停快照与帧分页。 |
| `scopes` | 第一版支持 | 暂停帧的作用域。 |
| `variables` | 第一版支持 | 展开、筛选、分页。 |
| `setVariable` | 计划支持 | 通过目标修改变量。 |
| `source` | 计划支持 | 目标提供动态源码。第一版使用本地路径。 |
| `threads` | 第一版支持 | 含单线程目标。 |
| `terminateThreads` | 不支持 | 单独终止指定线程。 |
| `modules` | 不支持 | 模块及其元数据。 |
| `loadedSources` | 计划支持 | 目标已加载源码清单。 |
| `evaluate` | 计划支持 | 监视与表达式求值。 |
| `setExpression` | 计划支持 | 通过表达式修改值。 |
| `stepInTargets` | 计划支持 | 精确选择步入位置。 |
| `gotoTargets` | 不支持 | 查询可跳转位置。 |
| `completions` | 计划支持 | 调试控制台补全。 |
| `exceptionInfo` | 计划支持 | 当前异常详情。 |
| `readMemory` | 不支持 | 读内存。 |
| `writeMemory` | 不支持 | 写内存。 |
| `disassemble` | 不支持 | 反汇编。 |
| `locations` | 计划支持 | 查询值或声明的源码位置。 |

## 事件（17 项）

| 事件 | 状态 | 范围 |
| --- | --- | --- |
| `initialized` | 第一版支持 | 可接收配置时发送。 |
| `stopped` | 第一版支持 | 断点、单步、入口与暂停。 |
| `continued` | 第一版支持 | 目标主动恢复时发送。 |
| `exited` | 第一版支持 | 目标退出并提供退出码时发送。 |
| `terminated` | 第一版支持 | 调试会话结束时发送一次。 |
| `thread` | 第一版支持 | 目标通知线程创建或退出。 |
| `output` | 第一版支持 | 调试控制台文本。 |
| `breakpoint` | 计划支持 | 已登记断点异步变更。 |
| `module` | 不支持 | 模块变更。 |
| `loadedSource` | 计划支持 | 源码变更。 |
| `process` | 计划支持 | 调试目标进程元数据。 |
| `capabilities` | 计划支持 | 会话中的能力更新。 |
| `progressStart` | 计划支持 | 可报告的长任务开始。 |
| `progressUpdate` | 计划支持 | 可报告的长任务进度。 |
| `progressEnd` | 计划支持 | 可报告的长任务结束。 |
| `invalidated` | 计划支持 | 通知客户端刷新缓存。 |
| `memory` | 不支持 | 内存变更。 |

## Capabilities（42 项）

| 字段 | 状态 | 范围 |
| --- | --- | --- |
| `supportsConfigurationDoneRequest` | 第一版支持 | 初始化响应为 `true`。 |
| `supportsFunctionBreakpoints` | 计划支持 | 函数断点。 |
| `supportsConditionalBreakpoints` | 计划支持 | 源码条件断点。 |
| `supportsHitConditionalBreakpoints` | 计划支持 | 命中次数条件。 |
| `supportsEvaluateForHovers` | 计划支持 | 悬停求值。 |
| `exceptionBreakpointFilters` | 计划支持 | 声明异常筛选器。 |
| `supportsStepBack` | 不支持 | 反向执行。 |
| `supportsSetVariable` | 计划支持 | 变量修改。 |
| `supportsRestartFrame` | 不支持 | 帧重启。 |
| `supportsGotoTargetsRequest` | 不支持 | 可跳转位置。 |
| `supportsStepInTargetsRequest` | 计划支持 | 步入位置。 |
| `supportsCompletionsRequest` | 计划支持 | 控制台补全。 |
| `completionTriggerCharacters` | 计划支持 | 补全触发字符。 |
| `supportsModulesRequest` | 不支持 | 模块查询。 |
| `additionalModuleColumns` | 不支持 | 模块表格扩展列。 |
| `supportedChecksumAlgorithms` | 计划支持 | 源码校验和算法。 |
| `supportsRestartRequest` | 计划支持 | 会话内重启。 |
| `supportsExceptionOptions` | 计划支持 | 异常分类选项。 |
| `supportsValueFormattingOptions` | 计划支持 | 值显示格式。 |
| `supportsExceptionInfoRequest` | 计划支持 | 当前异常详情。 |
| `supportTerminateDebuggee` | 计划支持 | 断开时覆盖默认终止行为。 |
| `supportSuspendDebuggee` | 计划支持 | 分离后保持暂停。 |
| `supportsDelayedStackTraceLoading` | 第一版支持 | 帧分页验收后启用。 |
| `supportsLoadedSourcesRequest` | 计划支持 | 已加载源码清单。 |
| `supportsLogPoints` | 计划支持 | 日志断点。 |
| `supportsTerminateThreadsRequest` | 不支持 | 指定线程终止。 |
| `supportsSetExpression` | 计划支持 | 通过表达式修改值。 |
| `supportsTerminateRequest` | 计划支持 | 优雅终止。 |
| `supportsDataBreakpoints` | 不支持 | 数据断点。 |
| `supportsReadMemoryRequest` | 不支持 | 读内存。 |
| `supportsWriteMemoryRequest` | 不支持 | 写内存。 |
| `supportsDisassembleRequest` | 不支持 | 反汇编。 |
| `supportsCancelRequest` | 计划支持 | 请求级取消。 |
| `supportsBreakpointLocationsRequest` | 计划支持 | 可断点位置。 |
| `supportsClipboardContext` | 计划支持 | 剪贴板求值上下文。 |
| `supportsSteppingGranularity` | 计划支持 | 可选单步粒度。 |
| `supportsInstructionBreakpoints` | 不支持 | 指令断点。 |
| `supportsExceptionFilterOptions` | 计划支持 | 异常筛选选项。 |
| `supportsSingleThreadExecutionRequests` | 计划支持 | 针对单线程的独立控制。 |
| `supportsDataBreakpointBytes` | 不支持 | 字节范围数据断点。 |
| `breakpointModes` | 计划支持 | 由目标声明断点模式。 |
| `supportsANSIStyling` | 计划支持 | 和客户端双向协商 ANSI 样式。 |
