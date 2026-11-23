const assert = require("node:assert/strict");
const vscode = require("vscode");

async function run() {
  const type = "moon-dap-bpflab";
  const folder = vscode.workspace.workspaceFolders[0];
  const helper = vscode.Uri.joinPath(folder.uri, "demo", "helper.bpf");
  await vscode.window.showTextDocument(await vscode.workspace.openTextDocument(helper));
  const breakpoint = new vscode.SourceBreakpoint(new vscode.Location(helper, new vscode.Position(3, 0)));
  vscode.debug.addBreakpoints([breakpoint]);

  let verifyStop;
  let timer;
  const tracker = vscode.debug.registerDebugAdapterTrackerFactory(type, {
    createDebugAdapterTracker() {
      return {
        onDidSendMessage(message) {
          if (message.type === "event" && message.event === "stopped") verifyStop?.(message.body);
        },
      };
    },
  });
  async function waitForStop(action) {
    const stopped = new Promise((resolve, reject) => {
      verifyStop = resolve;
      timer = setTimeout(() => reject(Error("等待 VS Code stopped 事件超时")), 12000);
    });
    try {
      const [body] = await Promise.all([stopped, action()]);
      return body;
    } finally {
      clearTimeout(timer);
      verifyStop = undefined;
    }
  }

  try {
    const first = await waitForStop(async () => {
      assert.equal(await vscode.debug.startDebugging(folder, "调试 ELF 嵌套调用"), true);
    });
    assert.equal(first.reason, "breakpoint");
    const session = vscode.debug.activeDebugSession;
    assert.equal(session.type, type);
    const trace = () => session.customRequest("stackTrace", { threadId: 1 });
    const { stackFrames } = await trace();
    assert.deepEqual(stackFrames.map(frame => [frame.name, frame.line]), [["add_one", 4], ["increment", 2], ["main", 3]]);
    const evaluated = await session.customRequest("evaluate", { expression: "r0", frameId: stackFrames[0].id });
    assert.equal(evaluated.result, "1");
    const stepped = await waitForStop(() => vscode.commands.executeCommand("workbench.action.debug.stepOut"));
    assert.equal(stepped.reason, "step");
    assert.deepEqual((await trace()).stackFrames.map(frame => frame.name), ["increment", "main"]);
    console.log("VS Code：ELF 源码断点、三层真实调用栈、寄存器求值和步出通过");
  } finally {
    await vscode.debug.stopDebugging(vscode.debug.activeDebugSession);
    tracker.dispose();
    vscode.debug.removeBreakpoints([breakpoint]);
  }
}

module.exports = { run };
