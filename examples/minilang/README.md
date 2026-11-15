# 迷你解释器调试示例

`demo.mdap` 使用 `fn` / `end` 定义函数。函数内可用 `set 名称 JSON值`、`print 名称`、`call 函数名`、`return` 和 `wait 轮数`。空行和以 `#` 开头的行是注释。源码路径作为 `launch.program` 传入，示例只实现 `launch`。

## VS Code

在项目根目录运行 native 构建。另开终端启动示例，参数 `--tcp 4711` 对应示例的 `debugServer`。PowerShell 命令如下。

```powershell
moon build --target native
& ./_build/native/debug/build/examples/minilang/minilang.exe --tcp 4711
```

Linux 和 macOS 的示例构建产物没有 `.exe` 后缀，按 `moon build` 输出的实际路径启动。正常监听时 stderr 显示 `moon-dap tcp 4711`。

在项目根目录的另一终端运行以下命令。VS Code 已安装并可通过 `code` 启动时，它会为 [本地调试类型](vscode/package.json) 打开扩展开发宿主，并在示例工作区使用 [launch.json](.vscode/launch.json)。

```text
code --new-window --extensionDevelopmentPath=./examples/minilang/vscode ./examples/minilang ./examples/minilang/demo.mdap
```

1. 在 `demo.mdap` 第 4 行 `call greet` 加行断点。
2. 在运行和调试栏选择「调试迷你解释器」，按 F5。预期停在第 4 行。
3. 在变量栏展开「局部变量 → config → limits」。预期看到 `name = "月兔"`，以及 `[0] = 2`、`[1] = 5`。
4. 按 F11 步入 `greet`。预期调用栈中同时出现 `greet` 和 `main`。按 F10 执行一条赋值，再用 Shift+F11 步出，预期回到 `main` 的第 5 行。
5. 继续运行，观察调试控制台输出和会话退出。TCP 监听器可在其终端用 Ctrl+C 结束。

若要用实际的 VS Code 扩展测试宿主重跑本项目的冒烟脚本，先运行相同的 TCP 服务，再运行以下命令。`<独立测试目录>` 用任一专用临时目录替换。

```text
code --user-data-dir <独立测试目录> --extensionDevelopmentPath=./examples/minilang/vscode --extensionTestsPath=./examples/minilang/vscode/smoke.cjs ./examples/minilang
```

脚本在 VS Code API 上设置真实源码断点、使用 `launch.json` 启动调试，并通过编辑器命令步入函数。已在 Windows x64 的 VS Code 1.145.1 官方便携版通过。若独立测试配置触发工作区信任提示，可在仅包含本例的测试进程中加上 `--disable-workspace-trust`，因为测试宿主无法显示该对话框。[验证记录](../../docs/verification.md) · [VS Code 调试适配器开发指南](https://code.visualstudio.com/api/extension-guides/debugger-extension)

## Neovim

安装 nvim-dap 后，将以下配置放入自己的 Neovim 配置。把程序路径改为本机实际文件路径，在 TCP 示例运行时调用 `require("dap").continue()`。设置断点可调用 `require("dap").toggle_breakpoint()`。本机未安装 Neovim，此配置尚待实际编辑器验证。[nvim-dap](https://github.com/mfussenegger/nvim-dap)

```lua
local dap = require("dap")
vim.filetype.add({ extension = { mdap = "minilang" } })
dap.adapters.minilang = { type = "server", host = "127.0.0.1", port = 4711 }
dap.configurations.minilang = {
  {
    type = "minilang",
    request = "launch",
    name = "调试当前文件",
    program = function() return vim.fn.expand("%:p") end,
  },
}
```

使用 stdio 时，将适配器一项换成以下配置。将 `command` 替换为构建产物的绝对路径。

```lua
dap.adapters.minilang = {
  type = "executable",
  command = "C:/path/to/minilang.exe",
  args = { "--stdio" },
}
```
