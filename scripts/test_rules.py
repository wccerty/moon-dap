"""用真实 stdio 会话验证规则引擎的动态源码与调试能力。"""

import json
from pathlib import Path
import unittest

from test_e2e import Client, ROOT, TIMEOUT, process


DEMO = ROOT / "examples/rules/demo.json"
BINARY = ROOT / "_build/native/debug/build/examples/rules/rules.exe"


def start(client, bundle, *, one_based=True):
    capabilities = client.request("initialize", {
        "adapterID": "moon-dap-rules",
        "supportsVariableType": True,
        "supportsVariablePaging": True,
        "linesStartAt1": one_based,
        "columnsStartAt1": one_based,
    })["body"]
    for capability in (
        "supportsLoadedSourcesRequest",
        "supportsFunctionBreakpoints",
        "supportsConditionalBreakpoints",
        "supportsHitConditionalBreakpoints",
        "supportsLogPoints",
        "supportsEvaluateForHovers",
        "supportsSetVariable",
        "supportsSetExpression",
        "supportsCompletionsRequest",
        "supportsExceptionInfoRequest",
    ):
        assert capabilities[capability] is True, capability
    launch = client.send("launch", {"bundle": bundle, "stopOnEntry": True})
    client.event("initialized")
    return launch


def stack(client):
    return client.request("stackTrace", {"threadId": 1})["body"]["stackFrames"]


def step(client, command, reason):
    client.request(command, {"threadId": 1})
    event = client.event("stopped")
    assert event["reason"] == reason, event
    return event


class RuleAdapterTest(unittest.TestCase):
    def test_dynamic_sources_breakpoints_and_edits(self):
        bundle = json.loads(DEMO.read_text(encoding="utf-8"))
        with process(binary=BINARY) as proc:
            client = Client(proc.stdout, proc.stdin)
            launch = start(client, bundle)
            sources = client.request("loadedSources")["body"]["sources"]
            self.assertEqual([source["name"] for source in sources], ["main.rule", "pricing.rule"])
            main_ref, pricing_ref = [source["sourceReference"] for source in sources]
            source = client.request("source", {
                "sourceReference": pricing_ref,
            })["body"]
            self.assertEqual(source["content"], bundle["sources"][1]["text"])
            self.assertEqual(source["mimeType"], "text/plain")
            missing = client.request("source", {"sourceReference": 999}, success=False)
            self.assertEqual(missing["message"], "invalidReference")
            locations = client.request("breakpointLocations", {
                "source": {"sourceReference": main_ref}, "line": 5, "endLine": 7,
            })["body"]["breakpoints"]
            self.assertEqual(locations, [{"line": 6, "column": 1}, {"line": 7, "column": 1}])
            function = client.request("setFunctionBreakpoints", {
                "breakpoints": [
                    {"name": "missing"},
                    {"name": "price", "condition": "order.unit > 0", "hitCondition": "==1"},
                ],
            })["body"]["breakpoints"]
            self.assertEqual([bp["verified"] for bp in function], [False, True])
            self.assertEqual(function[1]["source"]["sourceReference"], pricing_ref)
            self.assertEqual(function[1]["line"], 2)
            points = client.request("setBreakpoints", {
                "source": {"sourceReference": main_ref},
                "breakpoints": [
                    {"line": 6, "condition": "retry >= 0", "hitCondition": "%2"},
                    {"line": 6, "logMessage": "retry {retry + 1}", "hitCondition": ">=2"},
                    {"line": 6, "condition": "retry +"},
                ],
            })["body"]["breakpoints"]
            self.assertEqual([bp["verified"] for bp in points], [True, True, False])
            client.request("configurationDone")
            client.reply(launch)
            self.assertEqual(client.event("stopped")["reason"], "entry")
            entry = stack(client)[0]
            self.assertEqual(entry["source"]["sourceReference"], main_ref)
            completion = client.request("completions", {
                "text": "account.qu", "column": 11, "frameId": entry["id"],
            })["body"]["targets"]
            self.assertEqual([(v["label"], v["start"], v["length"]) for v in completion],
                             [("quantity", 9, 2)])
            changed = client.request("setExpression", {
                "expression": "account.quantity", "value": "account.quantity + 1",
                "frameId": entry["id"],
            })["body"]
            self.assertEqual(changed["value"], "3")

            hit = step(client, "continue", "breakpoint")
            self.assertEqual(hit["hitBreakpointIds"], [function[1]["id"]])
            frames = stack(client)
            self.assertEqual([(f["name"], f["line"]) for f in frames], [("price", 2), ("main", 3)])
            parent = frames[1]["id"]
            evaluated = client.request("evaluate", {
                "expression": "summary.stages[0]", "frameId": parent, "context": "watch",
            })["body"]
            container = evaluated["variablesReference"]
            self.assertGreater(container, 0)
            self.assertEqual(evaluated["namedVariables"], 1)
            failed = client.request("setVariable", {
                "variablesReference": container, "name": "missing", "value": "8",
            }, success=False)
            self.assertEqual(failed["message"], "targetError")
            changed = client.request("setVariable", {
                "variablesReference": container, "name": "score", "value": "7",
            })["body"]
            self.assertEqual(changed["value"], "7")
            members = client.request("variables", {"variablesReference": container})["body"]["variables"]
            self.assertEqual([(v["name"], v["value"]) for v in members], [("score", "7")])
            updated = client.request("setExpression", {
                "expression": "summary.stages", "value": '[{"score":7}]', "frameId": parent,
            })["body"]
            new_container = updated["variablesReference"]
            self.assertGreater(new_container, container)
            invalidated = client.request("variables", {"variablesReference": container}, success=False)
            self.assertEqual(invalidated["message"], "invalidReference")
            children = client.request("variables", {"variablesReference": new_container})["body"]["variables"]
            self.assertEqual([child["name"] for child in children], ["[0]"])
            step(client, "stepIn", "step")
            self.assertEqual(client.request("evaluate", {
                "expression": "total", "frameId": stack(client)[0]["id"],
            })["body"]["result"], "15")
            expired = client.request("variables", {
                "variablesReference": new_container,
            }, success=False)
            self.assertEqual(expired["message"], "invalidReference")
            step(client, "stepOut", "step")
            self.assertEqual(stack(client)[0]["line"], 4)
            client.request("continue", {"threadId": 1})
            log = client.event("output")
            self.assertEqual((log["category"], log["output"]), ("console", "retry 2\n"))
            stopped = client.event("stopped")
            self.assertEqual(stopped["hitBreakpointIds"], [points[0]["id"]])
            self.assertEqual(client.request("evaluate", {
                "expression": "retry", "frameId": stack(client)[0]["id"],
            })["body"]["result"], "1")
            client.request("continue", {"threadId": 1})
            self.assertEqual(json.loads(client.event("output")["output"]), 7)
            self.assertEqual(json.loads(client.event("output")["output"]), 22)
            self.assertEqual(client.event("exited")["exitCode"], 0)
            client.event("terminated")
            client.request("disconnect")
            self.assertFalse(client.sent)
            self.assertEqual(proc.wait(timeout=TIMEOUT), 0)

    def test_compile_failure_can_retry_and_exception_has_stack(self):
        with process(binary=BINARY) as proc:
            client = Client(proc.stdout, proc.stdin)
            client.request("initialize", {"adapterID": "moon-dap-rules"})
            rejected = client.request("launch", {"bundle": {
                "entry": "main", "input": None, "sources": [
                    {"name": "main", "text": "rule main arg\nreturn (\nend"},
                ],
            }}, success=False)
            self.assertIn("main.rule:2", rejected["body"]["error"]["format"])
            bundle = json.loads(DEMO.read_text(encoding="utf-8"))
            bundle["input"]["quantity"] = -2
            launch = client.send("launch", {"bundle": bundle})
            client.event("initialized")
            client.request("configurationDone")
            client.reply(launch)
            event = client.event("stopped")
            self.assertEqual(event["reason"], "exception")
            trace = stack(client)
            self.assertEqual([(f["name"], f["line"]) for f in trace], [("price", 3), ("main", 3)])
            error = client.request("exceptionInfo", {"threadId": 1})["body"]
            self.assertEqual(error["exceptionId"], "RuleRuntimeError")
            self.assertEqual(error["breakMode"], "unhandled")
            self.assertIn("price (pricing.rule:3)", error["details"]["stackTrace"])
            self.assertEqual(client.request("evaluate", {
                "expression": "total", "frameId": trace[0]["id"],
            })["body"]["result"], "-10")
            client.request("continue", {"threadId": 1})
            diagnostic = client.event("output")
            self.assertEqual(diagnostic["category"], "stderr")
            self.assertIn("规则断言失败", diagnostic["output"])
            self.assertEqual(client.event("exited")["exitCode"], 1)
            client.event("terminated")
            client.request("disconnect")
            self.assertFalse(client.sent)
            self.assertEqual(proc.wait(timeout=TIMEOUT), 0)

    def test_completion_positions_in_both_coordinate_systems(self):
        bundle = json.loads(DEMO.read_text(encoding="utf-8"))
        for one_based in (False, True):
            with self.subTest(one_based=one_based), process(binary=BINARY) as proc:
                client = Client(proc.stdout, proc.stdin)
                launch = start(client, bundle, one_based=one_based)
                client.request("configurationDone")
                client.reply(launch)
                client.event("stopped")
                frame_id = stack(client)[0]["id"]
                for prefix, line, offset in [("", 0, 8), ("😀\n", 1, 11)]:
                    with self.subTest(prefix=prefix):
                        targets = client.request("completions", {
                            "text": prefix + "account.qu", "frameId": frame_id,
                            "column": 10 + int(one_based), "line": line + int(one_based),
                        })["body"]["targets"]
                        self.assertEqual(
                            [(v["label"], v["start"], v["length"]) for v in targets],
                            [("quantity", offset + int(one_based), 2)],
                        )
                client.request("disconnect")
                self.assertEqual(proc.wait(timeout=TIMEOUT), 0)

    def test_omitted_frame_uses_global_scope(self):
        bundle = json.loads(DEMO.read_text(encoding="utf-8"))
        with process(binary=BINARY) as proc:
            client = Client(proc.stdout, proc.stdin)
            launch = start(client, bundle)
            client.request("configurationDone")
            client.reply(launch)
            client.event("stopped")
            frame_id = stack(client)[0]["id"]
            constant = client.request("evaluate", {"expression": "1 + 2"})["body"]
            self.assertEqual(constant["result"], "3")
            self.assertEqual(client.request("completions", {
                "text": "acc", "column": 4,
            })["body"]["targets"], [])
            for command, args in [
                ("evaluate", {"expression": "account.quantity"}),
                ("setExpression", {"expression": "account.quantity", "value": "9"}),
            ]:
                with self.subTest(command=command):
                    response = client.request(command, args, success=False)
                    self.assertEqual(response["message"], "targetError")
            local = client.request("evaluate", {
                "expression": "account.quantity", "frameId": frame_id,
            })["body"]
            self.assertEqual(local["result"], "2")
            changed = client.request("setExpression", {
                "expression": "account.quantity", "value": "3", "frameId": frame_id,
            })["body"]
            self.assertEqual(changed["value"], "3")
            client.request("disconnect")
            self.assertEqual(proc.wait(timeout=TIMEOUT), 0)


if __name__ == "__main__":
    if not BINARY.is_file():
        raise SystemExit("请先运行 moon build --target native")
    unittest.main(verbosity=2)
