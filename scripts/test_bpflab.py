"""构建外部 VM 接入，并通过 stdio 验证真实指令执行。"""

import json
from pathlib import Path
import subprocess
import tempfile
import unittest

from test_e2e import Client, TIMEOUT, process


ROOT = Path(__file__).resolve().parents[1]
EXAMPLE = ROOT / "examples/bpflab"


def build_adapter():
    run = subprocess.run(
        ["moon", "build", "--target", "native", "--output-json", "."],
        cwd=EXAMPLE, text=True, encoding="utf-8", stdout=subprocess.PIPE, check=True,
    )
    for line in run.stdout.splitlines():
        if line.startswith("{"):
            artifact = json.loads(line)
            if (artifact.get("$message_type") == "artifact"
                    and artifact.get("package") == "wccerty/moon-dap-bpflab-example"):
                return Path(artifact["path"])
    raise RuntimeError("构建输出未列出 MoonBpfLab 适配器")


def verify(binary):
    program = str(EXAMPLE / "counter.bpf")

    with process(binary=binary) as proc:
        client = Client(proc.stdout, proc.stdin)
        capabilities = client.request("initialize", {
            "adapterID": "moon-bpflab", "supportsVariableType": True,
        })["body"]
        assert capabilities["supportsConditionalBreakpoints"] is True
        assert capabilities["supportsEvaluateForHovers"] is True
        launch = client.send("launch", {"program": program})
        client.event("initialized")
        points = client.request("setBreakpoints", {
            "source": {"path": program},
            "breakpoints": [{"line": 3, "condition": "r0 == 2"},
                            {"line": 3, "condition": "r11 == 0"}],
        })["body"]["breakpoints"]
        assert [point["verified"] for point in points] == [True, False]
        early = client.request("evaluate", {"expression": "r0"}, success=False)
        assert early["message"] == "invalidState"
        client.request("configurationDone")
        client.reply(launch)

        stopped = client.event("stopped")
        assert stopped["reason"] == "breakpoint"
        assert stopped["hitBreakpointIds"] == [points[0]["id"]]
        frames = client.request("stackTrace", {"threadId": 1})["body"]["stackFrames"]
        frame = frames[0]
        assert frame["line"] == 3
        assert frame["source"]["path"] == program
        scopes = client.request("scopes", {"frameId": frame["id"]})["body"]["scopes"]
        variables = client.request("variables", {
            "variablesReference": scopes[0]["variablesReference"],
        })["body"]["variables"]
        assert variables[0]["name"] == "r0" and variables[0]["value"] == "2"
        watched = client.request("evaluate", {
            "frameId": frame["id"], "expression": "r0", "context": "watch",
        })["body"]
        assert watched["result"] == "2" and watched["variablesReference"] == 0
        checked = client.request("evaluate", {"expression": "r0 == 2", "context": "hover"})["body"]
        assert checked["result"] == "true"
        unknown = client.request("evaluate", {"expression": "r11"}, success=False)
        assert unknown["message"] == "targetError"

        client.request("stepIn", {"threadId": 1})
        assert client.event("stopped")["reason"] == "step"
        stale = client.request("evaluate", {
            "frameId": frame["id"], "expression": "r0",
        }, success=False)
        assert stale["message"] == "invalidReference"
        after = client.request("evaluate", {"expression": "r0"})["body"]
        assert after["result"] == "3"
        client.request("continue", {"threadId": 1})
        assert client.event("output")["output"] == "r0 = 4\n"
        assert client.event("exited")["exitCode"] == 0
        client.event("terminated")
        client.request("disconnect")
        assert proc.wait(timeout=TIMEOUT) == 0

    print("MoonBpfLab 外部 VM：条件断点命中 r0=2，单步后 r0=3，继续运行返回 r0=4")


class BpfAdapterTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.binary = build_adapter()

    def test_debug_session(self):
        verify(self.binary)

    def test_launch_failure_can_retry(self):
        program = str(EXAMPLE / "counter.bpf")
        with tempfile.TemporaryDirectory() as directory, process(binary=self.binary) as proc:
            invalid = Path(directory) / "invalid.bpf"
            invalid.write_text("[183, 0]\n", encoding="utf-8")
            client = Client(proc.stdout, proc.stdin)
            client.request("initialize", {"adapterID": "moon-bpflab"})
            for arguments in [
                {"program": program, "stopOnEntry": "true"},
                {"program": str(invalid)},
                {"program": str(Path(directory) / "missing.bpf")},
            ]:
                with self.subTest(arguments=arguments):
                    failed = client.request("launch", arguments, success=False)
                    self.assertEqual(failed["message"], "targetError")

            launch = client.send("launch", {"program": program, "stopOnEntry": True})
            client.event("initialized")
            client.request("configurationDone")
            client.reply(launch)
            self.assertEqual(client.event("stopped")["reason"], "entry")
            self.assertEqual(client.request("evaluate", {"expression": "r0"})["body"]["result"], "0")
            client.request("disconnect")
            self.assertFalse(client.sent)
            self.assertEqual(proc.wait(timeout=TIMEOUT), 0)

    def test_breakpoint_replacement_and_clear(self):
        program = str(EXAMPLE / "counter.bpf")
        for replacement in [
            [{"line": 3, "condition": "r0 == 18446744073709551615"}],
            [],
        ]:
            with self.subTest(replacement=replacement), process(binary=self.binary) as proc:
                client = Client(proc.stdout, proc.stdin)
                client.request("initialize", {"adapterID": "moon-bpflab"})
                launch = client.send("launch", {"program": program})
                client.event("initialized")
                source = {"path": program}
                installed = client.request("setBreakpoints", {
                    "source": source, "breakpoints": [{"line": 3, "condition": "r0 == 2"}],
                })["body"]["breakpoints"]
                self.assertTrue(installed[0]["verified"])
                replaced = client.request("setBreakpoints", {
                    "source": source, "breakpoints": replacement,
                })["body"]["breakpoints"]
                self.assertEqual([item["verified"] for item in replaced], [True] * len(replacement))
                client.request("configurationDone")
                client.reply(launch)
                self.assertEqual(client.event("output")["output"], "r0 = 4\n")
                self.assertEqual(client.event("exited")["exitCode"], 0)
                client.event("terminated")
                client.request("disconnect")
                self.assertFalse(client.sent)
                self.assertEqual(proc.wait(timeout=TIMEOUT), 0)


if __name__ == "__main__":
    unittest.main(verbosity=2)
