const assert = require("node:assert/strict");
const vscode = require("vscode");

async function run() {
  const type = "moon-dap-minilang";
  const folder = vscode.workspace.workspaceFolders[0];
  const uri = vscode.Uri.joinPath(folder.uri, "demo.mdap");
  await vscode.window.showTextDocument(await vscode.workspace.openTextDocument(uri));
  const breakpoint = new vscode.SourceBreakpoint(new vscode.Location(uri, new vscode.Position(3, 0)));
  vscode.debug.addBreakpoints([breakpoint]);

  let waiter;
  let verified = false;
  const tracker = vscode.debug.registerDebugAdapterTrackerFactory(type, {
    createDebugAdapterTracker() {
      return {
        onDidSendMessage(message) {
          if (message.type === "response" && message.command === "setBreakpoints") {
            verified ||= message.body?.breakpoints?.some(bp => bp.verified && bp.line === 4);
          }
          if (message.type === "event" && message.event === "stopped" && waiter) {
            waiter.resolve(message.body);
          }
        },
      };
    },
  });
  function stopEvent() {
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => reject(Error("等待 VS Code stopped 事件超时")), 8000);
      waiter = { resolve(body) { clearTimeout(timer); resolve(body); }, timer };
    });
  }
  try {
    const first = stopEvent();
    first.catch(() => {});
    assert.equal(await vscode.debug.startDebugging(folder, "调试迷你解释器"), true);
    assert.equal((await first).reason, "breakpoint");
    const session = vscode.debug.activeDebugSession;
    assert.equal(session.type, type);
    assert.equal(verified, true);
    const stack = await session.customRequest("stackTrace", { threadId: 1 });
    const frame = stack.stackFrames[0];
    assert.equal(frame.line, 4);
    const scopes = await session.customRequest("scopes", { frameId: frame.id });
    const variables = await session.customRequest("variables", {
      variablesReference: scopes.scopes[0].variablesReference,
    });
    const record = variables.variables.find(item => item.name === "config");
    const children = await session.customRequest("variables", { variablesReference: record.variablesReference });
    assert.equal(children.variables.find(item => item.name === "name").value, '"月兔"');
    const stepped = stopEvent();
    stepped.catch(() => {});
    await vscode.commands.executeCommand("workbench.action.debug.stepInto");
    assert.equal((await stepped).reason, "step");
    const later = await session.customRequest("stackTrace", { threadId: 1 });
    assert.equal(later.stackFrames[0].name, "greet");
    console.log("VS Code 调试会话通过：第 4 行断点、嵌套变量与步入 greet");
  } finally {
    if (waiter) clearTimeout(waiter.timer);
    await vscode.debug.stopDebugging(vscode.debug.activeDebugSession);
    tracker.dispose();
    vscode.debug.removeBreakpoints([breakpoint]);
  }
}

module.exports = { run };
