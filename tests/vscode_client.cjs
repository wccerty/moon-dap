const assert = require("node:assert/strict");
const { spawn } = require("node:child_process");
const { once } = require("node:events");
const { resolve } = require("node:path");
const { createInterface } = require("node:readline");
const { test } = require("node:test");
const { DebugClient } = require("@vscode/debugadapter-testsupport");

const root = resolve(__dirname, "..");
const program = resolve(root, "examples/minilang/demo.mdap");
const binary = resolve(
  root, "_build/native/debug/build/examples/minilang",
  process.platform === "win32" ? "minilang.exe" : "minilang",
);

test("官方 DAP 测试客户端命中断点并检查变量", { timeout: 15000 }, async () => {
  const server = spawn(binary, ["--tcp", "0"], { cwd: root, stdio: ["ignore", "ignore", "pipe"] });
  const lines = createInterface({ input: server.stderr });
  const closed = once(server, "close");
  let client;
  try {
    const [ready] = await Promise.race([
      once(lines, "line"),
      closed.then(([code]) => { throw Error(`适配器提前退出 ${code}`); }),
    ]);
    const info = /^moon-dap tcp (\d+)$/.exec(ready);
    assert.ok(info, ready);
    client = new DebugClient("", "", "moon-dap-minilang");
    await client.start(Number(info[1]));
    await client.hitBreakpoint({ program }, { path: program, line: 4, column: 1 }, undefined, { line: 4 });
    const stack = await client.stackTraceRequest({ threadId: 1 });
    const scopes = await client.scopesRequest({ frameId: stack.body.stackFrames[0].id });
    const variables = await client.variablesRequest({ variablesReference: scopes.body.scopes[0].variablesReference });
    const config = variables.body.variables.find(item => item.name === "config");
    assert.ok(config.variablesReference > 0);
    const children = await client.variablesRequest({ variablesReference: config.variablesReference });
    assert.equal(children.body.variables.find(item => item.name === "name").value, '"月兔"');
    const stopped = client.waitForEvent("stopped");
    await client.stepInRequest({ threadId: 1 });
    assert.equal((await stopped).body.reason, "step");
    const stepped = await client.stackTraceRequest({ threadId: 1 });
    assert.equal(stepped.body.stackFrames[0].name, "greet");
  } finally {
    try {
      if (client) await client.stop();
    } finally {
      lines.close();
      server.kill();
      await closed;
    }
  }
});
