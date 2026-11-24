# 代码来源与许可

moon-dap 的手写库代码、适配器示例和本项目编写的测试采用 Apache-2.0。根目录 [LICENSE](LICENSE) 为本项目许可证。上游规范、文档及依赖保留各自的许可证。

| 内容 | 用途及来源 | 许可 |
| --- | --- | --- |
| Microsoft Debug Adapter Protocol | 仓库包含固定提交的 JSON Schema，并用本项目脚本生成 MoonBit 消息类型及编解码。生成文件首部保留 Microsoft 署名；上游版本、Schema 哈希和原许可证文件随仓库提供。[上游来源及许可证](vendor/dap/README.md) | 规范文档 CC BY 3.0 US，代码 MIT |
| MoonBit 异步库 `moonbitlang/async@0.20.6` | 作为库依赖提供异步运行、stdio 与 TCP，由 Mooncakes 解析。[依赖来源](https://mooncakes.io/docs/moonbitlang/async@0.20.6) | Apache-2.0 |
| MoonBpfLab `0.2.0` | 示例从 Mooncakes 依赖上游 VM，直接调用步进、栈及寄存器接口。仓库提供 MoonBit 适配器及示例指令和映射，未拷贝上游 VM 源码。[依赖来源](https://mooncakes.io/docs/btlqql/moon_bpflab@0.2.0) | Apache-2.0 |
| `@vscode/debugadapter-testsupport@1.68.0` | 以固定 npm 版本安装，测试编辑器客户端与适配器的互操作。[依赖来源](https://github.com/microsoft/vscode-debugadapter-node) | MIT |
| `jsonschema==4.25.1` | 以固定 Python 版本安装，针对官方 DAP Schema 校验测试消息。[依赖来源](https://github.com/python-jsonschema/jsonschema) | MIT |

迷你解释器脚本、规则引擎示例 JSON、MoonBpfLab 示例指令及协议测试夹具由本项目编写。ELF 测试对象和源码映射由本项目脚本从仓库中的示例指令生成。开发过程使用 AI 辅助，交付内容通过代码复核、自动化测试和已记录的编辑器实测验证。依赖版本、编辑器实测范围及对应测试命令见 [验证记录](docs/verification.md)。
