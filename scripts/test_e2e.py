"""使用真实 stdio 与 TCP 连接驱动示例的完整 DAP 会话。"""

import argparse
from contextlib import contextmanager
import json
import os
from pathlib import Path
import queue
import socket
import subprocess
import threading
import unittest

from check_schema import SCHEMA, validate


ROOT = Path(__file__).resolve().parents[1]
PROGRAM = ROOT / "examples/minilang/demo.mdap"
BINARY = ROOT / "_build/native/debug/build/examples/minilang" / (
    "minilang.exe" if os.name == "nt" else "minilang"
)
TIMEOUT = 20


def protocol_names(base, field):
    return {
        part["properties"][field]["enum"][0]: name
        for name, value in SCHEMA["definitions"].items()
        if {"$ref": f"#/definitions/{base}"} in value.get("allOf", [])
        for part in value["allOf"]
        if "properties" in part
    }


REQUESTS = protocol_names("Request", "command")
EVENTS = protocol_names("Event", "event")


def read_messages(stream, inbox):
    try:
        while first := stream.readline():
            header = first
            if not header.startswith(b"Content-Length: "):
                raise AssertionError(f"无效输出头 {header!r}")
            if stream.readline() != b"\r\n":
                raise AssertionError("缺少头部结束符")
            size = int(header.removeprefix(b"Content-Length: "))
            raw = stream.read(size)
            if len(raw) != size:
                raise EOFError("适配器输出半帧")
            inbox.put(json.loads(raw))
    except Exception as error:
        inbox.put(error)
    finally:
        inbox.put(None)


class Client:
    def __init__(self, reader, writer):
        self.writer = writer
        self.inbox = queue.Queue()
        self.sent = {}
        self.seq = 0
        self.adapter_seq = 0
        self.trace = []
        threading.Thread(target=read_messages, args=(reader, self.inbox), daemon=True).start()

    def send(self, command, arguments=None, split=False):
        self.seq += 1
        message = {"seq": self.seq, "type": "request", "command": command}
        if arguments is not None:
            message["arguments"] = arguments
        validate(REQUESTS.get(command, "Request"), message)
        body = json.dumps(message, ensure_ascii=False).encode()
        frame = f"Content-Length: {len(body)}\r\n\r\n".encode() + body
        self.sent[self.seq] = command
        if split:
            self.writer.write(frame[:8])
            self.writer.flush()
            frame = frame[8:]
        self.writer.write(frame)
        self.writer.flush()
        return self.seq

    def receive(self):
        try:
            message = self.inbox.get(timeout=TIMEOUT)
        except queue.Empty as error:
            raise AssertionError(f"等待适配器超时。已收到 {self.trace}") from error
        if message is None:
            raise EOFError(f"适配器提前关闭。已收到 {self.trace}")
        if isinstance(message, Exception):
            raise message
        self.adapter_seq += 1
        assert message["seq"] == self.adapter_seq, message
        if message["type"] == "event":
            label = message["event"]
            validate(EVENTS[label], message)
        else:
            label = message["command"]
            expected = self.sent.pop(message["request_seq"])
            assert label == expected, message
            if message["success"]:
                definition = REQUESTS.get(label, "").removesuffix("Request") + "Response"
                validate(definition if definition in SCHEMA["definitions"] else "Response", message)
            else:
                validate("ErrorResponse", message)
        self.trace.append(f"{message['seq']}:{message['type']}:{label}")
        return message

    def reply(self, seq, success=True):
        reply = self.receive()
        assert reply["type"] == "response", reply
        assert (reply["request_seq"], reply["success"]) == (seq, success), reply
        return reply

    def event(self, name):
        event = self.receive()
        assert event["type"] == "event" and event["event"] == name, event
        return event.get("body", {})

    def request(self, command, arguments=None, success=True):
        return self.reply(self.send(command, arguments), success)

    def initialize(self):
        seq = self.send("initialize", {
            "adapterID": "moon-dap", "linesStartAt1": True, "columnsStartAt1": True,
            "supportsVariableType": True, "supportsVariablePaging": True,
        }, split=True)
        body = self.reply(seq)["body"]
        assert body["supportsConfigurationDoneRequest"] is True
        assert body["supportsDelayedStackTraceLoading"] is True


@contextmanager
def process(*args):
    with subprocess.Popen(
        [str(BINARY), *args], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
        stderr=subprocess.PIPE, cwd=ROOT,
    ) as proc:
        try:
            yield proc
        finally:
            if proc.poll() is None:
                proc.kill()
            proc.wait(timeout=TIMEOUT)


@contextmanager
def listener():
    with process("--tcp", "0") as proc:
        inbox = queue.Queue()
        threading.Thread(target=lambda: inbox.put(proc.stderr.readline()), daemon=True).start()
        ready = inbox.get(timeout=TIMEOUT)
        assert ready.startswith(b"moon-dap tcp "), ready
        yield int(ready.split()[-1])


@contextmanager
def connect(port):
    with socket.create_connection(("127.0.0.1", port), timeout=TIMEOUT) as sock:
        with sock.makefile("rb") as reader, sock.makefile("wb") as writer:
            try:
                yield Client(reader, writer)
            finally:
                try:
                    sock.shutdown(socket.SHUT_RDWR)
                except OSError:
                    pass


def stack(client, levels=0):
    return client.request("stackTrace", {"threadId": 1, "levels": levels})["body"]


def locals_ref(client, frame):
    result = client.request("scopes", {"frameId": frame})["body"]
    return result["scopes"][0]["variablesReference"]


def variables(client, ref, **filters):
    result = client.request("variables", {"variablesReference": ref, **filters})["body"]
    return {item["name"]: item for item in result["variables"]}


def debug_session(client, on_stopped=lambda: None):
    client.initialize()
    launch = client.send("launch", {"program": str(PROGRAM)})
    client.event("initialized")
    source = {"path": str(PROGRAM)}
    reply = client.request("setBreakpoints", {"source": source, "breakpoints": [{"line": 4}, {"line": 1}]})
    assert [bp["verified"] for bp in reply["body"]["breakpoints"]] == [True, False]
    client.request("setExceptionBreakpoints", {"filters": []})
    configuration = client.send("configurationDone")
    client.reply(configuration)
    client.reply(launch)
    assert client.event("stopped")["reason"] == "breakpoint"
    on_stopped()
    assert client.request("threads")["body"]["threads"][0]["id"] == 1
    frame = stack(client, levels=1)["stackFrames"][0]
    assert (frame["name"], frame["line"]) == ("main", 4)
    assert frame["source"]["path"] == str(PROGRAM)
    local = locals_ref(client, frame["id"])
    config = variables(client, local)["config"]
    assert config["type"] == "record"
    fields = variables(client, config["variablesReference"], filter="named")
    assert fields["name"]["value"] == '"月兔"'
    array = fields["limits"]["variablesReference"]
    page = variables(client, array, filter="indexed", start=1, count=1)
    assert list(page) == ["[1]"] and page["[1]"]["value"] == "5"
    assert page["[1]"]["variablesReference"] == 0
    client.request("setBreakpoints", {"source": source, "breakpoints": []})

    client.request("stepIn", {"threadId": 1})
    assert client.event("stopped")["reason"] == "step"
    frames = stack(client)["stackFrames"]
    assert [(frame["name"], frame["line"]) for frame in frames] == [("greet", 11), ("main", 4)]
    stale = client.request("scopes", {"frameId": frame["id"]}, success=False)
    assert stale["message"] == "invalidReference"

    client.request("next", {"threadId": 1})
    assert client.event("stopped")["reason"] == "step"
    greeting = stack(client)["stackFrames"][0]
    assert (greeting["name"], greeting["line"]) == ("greet", 12)
    value = variables(client, locals_ref(client, greeting["id"]))["value"]
    assert variables(client, value["variablesReference"])["answer"]["value"] == "42"

    client.request("stepOut", {"threadId": 1})
    assert json.loads(client.event("output")["output"]) == {"answer": 42}
    assert json.loads(client.event("output")["output"]) == 7
    assert client.event("stopped")["reason"] == "step"
    assert stack(client)["stackFrames"][0]["line"] == 5

    client.request("continue", {"threadId": 1})
    assert json.loads(client.event("output")["output"])["name"] == "月兔"
    client.request("pause", {"threadId": 1})
    assert client.event("stopped")["reason"] == "pause"
    assert stack(client)["stackFrames"][0]["line"] == 6
    client.request("continue", {"threadId": 1})
    assert client.event("exited")["exitCode"] == 0
    client.event("terminated")
    client.request("disconnect")
    assert not client.sent
    print(f"  {client.seq} 条请求，{client.adapter_seq} 条响应或事件均已按顺序校验", flush=True)


class DapE2E(unittest.TestCase):
    def test_stdio(self):
        with process("--stdio") as proc:
            debug_session(Client(proc.stdout, proc.stdin))
            self.assertEqual(proc.wait(timeout=TIMEOUT), 0)

    def test_tcp_and_isolation(self):
        with listener() as port, connect(port) as first, connect(port) as second:
            def verify_other_connection():
                second.initialize()
                failure = second.request("threads", success=False)
                self.assertEqual(failure["message"], "invalidState")
                second.request("disconnect")

            debug_session(first, verify_other_connection)

    def test_stdio_eof_during_configuration(self):
        with process("--stdio") as proc:
            client = Client(proc.stdout, proc.stdin)
            client.initialize()
            client.send("launch", {"program": str(PROGRAM)})
            client.event("initialized")
            proc.stdin.close()
            self.assertEqual(proc.wait(timeout=TIMEOUT), 0)

    def test_stdio_rejects_bad_header(self):
        with process("--stdio") as proc:
            proc.stdin.write(b"Content-Length: +7\r\n\r\n{}")
            proc.stdin.flush()
            self.assertNotEqual(proc.wait(timeout=TIMEOUT), 0)
            self.assertIn(b"InvalidFrame", proc.stderr.read())
            self.assertEqual(proc.stdout.read(), b"")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", type=Path, default=BINARY)
    BINARY = parser.parse_args().binary.resolve()
    if not BINARY.is_file():
        raise SystemExit("请先运行 moon build --target native")
    unittest.main(argv=[__file__], verbosity=2)
