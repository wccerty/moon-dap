# 版本记录

版本链接指向 Mooncakes，源码链接固定到对应的 GitHub 提交。

| 版本 | 发布日期 | 主要变化 |
| --- | --- | --- |
| [0.2.1](https://mooncakes.io/docs/wccerty/moon-dap@0.2.1) | 2026-11-24 | 按客户端列基数返回补全的 UTF-16 起点。修复规则示例省略帧 ID 时误用局部变量的行为，补充多行和作用域回归。 |
| [0.2.0](https://mooncakes.io/docs/wccerty/moon-dap@0.2.0) | 2026-11-23 | 新增动态源码、函数断点、命中次数与日志断点、结构化求值和赋值、补全、异常详情。加入 JSON 表达式包及多源码规则引擎示例。[发布源码](https://github.com/wccerty/moon-dap/tree/6a23ba6) |
| [0.1.1](https://mooncakes.io/docs/wccerty/moon-dap@0.1.1) | 2026-11-23 | 修复轮询计时与取出请求同时发生时的请求丢失。完成 VS Code 与 Neovim 的外部 VM 验收。[发布源码](https://github.com/wccerty/moon-dap/tree/7eab699) |
| [0.1.0](https://mooncakes.io/docs/wccerty/moon-dap@0.1.0) | 2026-11-23 | 发布 DAP 分帧、生成协议类型、会话和 native stdio/TCP。提供迷你解释器及支持条件断点、寄存器求值和 ELF 源码映射的 MoonBpfLab 接入示例。[发布源码](https://github.com/wccerty/moon-dap/tree/d3fb31b) |

[协议覆盖](docs/coverage.md) · [验证记录](docs/verification.md) · [完整提交历史](https://github.com/wccerty/moon-dap/commits/main/)
