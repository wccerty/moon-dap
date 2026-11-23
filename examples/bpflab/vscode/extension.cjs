const vscode = require("vscode");

function activate(context) {
  context.subscriptions.push(vscode.debug.registerDebugAdapterDescriptorFactory(
    "moon-dap-bpflab",
    {
      createDebugAdapterDescriptor() {
        const path = process.env.MOON_DAP_BPF_ADAPTER;
        if (!path) throw new Error("请先设置 MOON_DAP_BPF_ADAPTER 为适配器的绝对路径");
        return new vscode.DebugAdapterExecutable(path);
      },
    },
  ));
}

module.exports = { activate };
