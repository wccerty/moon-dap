"""构建外部 VM 接入，并通过 stdio 验证真实指令执行。"""

import json
from pathlib import Path
import struct
import subprocess
import tempfile
import unittest

from test_e2e import Client, TIMEOUT, process


ROOT = Path(__file__).resolve().parents[1]
EXAMPLE = ROOT / "examples/bpflab"


def build_elf_example(directory):
    """从两份源码生成已解析相对调用的 ELF64/BPF 示例及 PC 映射。"""
    instructions = bytearray()
    entries = []
    for file, functions in [("main.bpf", ("main",)), ("helper.bpf", ("increment", "add_one"))]:
        path = EXAMPLE / "demo" / file
        for line, source in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
            if not source.strip() or source.lstrip().startswith("#"):
                continue
            op, dst, src, offset, imm = json.loads(source)
            pc = len(entries)
            name = functions[-1] if pc >= 6 else functions[0]
            entries.append({"pc": pc, "path": str(path), "line": line, "name": name})
            instructions += struct.pack("<BBhi", op, dst | (src << 4), offset, imm)
    strings = b"\0.text\0.shstrtab\0"
    text_offset = 64
    strings_offset = text_offset + len(instructions)
    sections_offset = (strings_offset + len(strings) + 7) & ~7
    header = struct.pack(
        "<16sHHIQQQIHHHHHH", b"\x7fELF\x02\x01\x01", 1, 247, 1, 0, 0,
        sections_offset, 0, 64, 0, 0, 64, 3, 2,
    )
    text = struct.pack(
        "<IIQQQQIIQQ", 1, 1, 6, 0, text_offset, len(instructions), 0, 0, 8, 0,
    )
    string_table = struct.pack(
        "<IIQQQQIIQQ", 7, 3, 0, 0, strings_offset, len(strings), 0, 0, 1, 0,
    )
    elf_file = directory / "nested.o"
    elf_file.write_bytes(
        (header + instructions + strings).ljust(sections_offset, b"\0")
        + bytes(64) + text + string_table
    )
    map_file = directory / "nested.json"
    map_file.write_text(json.dumps(entries, ensure_ascii=False, indent=2), encoding="utf-8")
    return {"program": str(elf_file), "programFormat": "elf", "sourceMap": str(map_file)}


def build_adapter(module=EXAMPLE):
    run = subprocess.run(
        ["moon", "build", "--target", "native", "--output-json", "."],
        cwd=module, text=True, encoding="utf-8", stdout=subprocess.PIPE, check=True,
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

    def test_elf_source_map_and_nested_stepping(self):
        with tempfile.TemporaryDirectory() as directory, process(binary=self.binary) as proc:
            options = build_elf_example(Path(directory))
            client = Client(proc.stdout, proc.stdin)
            capabilities = client.request("initialize", {"adapterID": "moon-bpflab"})["body"]
            self.assertTrue(capabilities["supportsBreakpointLocationsRequest"])
            invalid = Path(directory) / "invalid.json"
            entry = json.loads(Path(options["sourceMap"]).read_text(encoding="utf-8"))[0]
            invalid.write_text(json.dumps([entry, entry]), encoding="utf-8")
            failed = client.request("launch", {**options, "sourceMap": str(invalid)}, success=False)
            self.assertEqual(failed["message"], "targetError")
            launch = client.send("launch", options)
            client.event("initialized")
            main = str(EXAMPLE / "demo/main.bpf")
            helper = str(EXAMPLE / "demo/helper.bpf")
            for path, line in [(main, 3), (helper, 4)]:
                candidates = client.request("breakpointLocations", {
                    "source": {"path": path}, "line": line,
                })["body"]["breakpoints"]
                self.assertEqual(candidates, [{"line": line, "column": 1}])
                self.assertTrue(client.request("setBreakpoints", {
                    "source": {"path": path}, "breakpoints": [{"line": line}],
                })["body"]["breakpoints"][0]["verified"])
            client.request("configurationDone")
            client.reply(launch)

            def frames(**page):
                return client.request("stackTrace", {"threadId": 1, **page})["body"]

            self.assertEqual(client.event("stopped")["reason"], "breakpoint")
            self.assertEqual(frames()["stackFrames"][0]["source"]["path"], main)
            client.request("continue", {"threadId": 1})
            self.assertEqual(client.event("stopped")["reason"], "breakpoint")
            stack = frames()["stackFrames"]
            self.assertEqual([(f["name"], f["line"], f["source"]["path"]) for f in stack], [
                ("add_one", 4, helper), ("increment", 2, helper), ("main", 3, main),
            ])
            self.assertEqual(frames(startFrame=1, levels=1), {"stackFrames": stack[1:2], "totalFrames": 3})
            self.assertEqual(client.request("scopes", {"frameId": stack[1]["id"]})["body"]["scopes"], [])
            client.request("evaluate", {"expression": "r0", "frameId": stack[1]["id"]}, success=False)
            for name, line in [("increment", 3), ("main", 4)]:
                client.request("stepOut", {"threadId": 1})
                self.assertEqual(client.event("stopped")["reason"], "step")
                frame = frames()["stackFrames"][0]
                self.assertEqual((frame["name"], frame["line"]), (name, line))
            client.request("setBreakpoints", {"source": {"path": helper}, "breakpoints": []})
            client.request("next", {"threadId": 1})
            self.assertEqual(client.event("stopped")["reason"], "step")
            self.assertEqual(frames()["stackFrames"][0]["line"], 5)
            self.assertEqual(client.request("evaluate", {"expression": "r0"})["body"]["result"], "3")
            client.request("continue", {"threadId": 1})
            self.assertEqual(client.event("output")["output"], "r0 = 3\n")
            self.assertEqual(client.event("exited")["exitCode"], 0)
            client.event("terminated")
            client.request("disconnect")
            self.assertEqual(proc.wait(timeout=TIMEOUT), 0)

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
    import sys

    if len(sys.argv) == 3 and sys.argv[1] == "--prepare-example":
        directory = Path(sys.argv[2]).resolve()
        directory.mkdir(parents=True, exist_ok=True)
        config = {**build_elf_example(directory), "adapter": str(build_adapter())}
        print(json.dumps(config, ensure_ascii=False))
    else:
        unittest.main(verbosity=2)
