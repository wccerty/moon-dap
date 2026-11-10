"""运行 MoonBit 编解码样本，并按固定的 Draft 4 规范逐项校验。"""

import json
from pathlib import Path
import subprocess

from jsonschema import Draft4Validator


ROOT = Path(__file__).resolve().parents[1]
SCHEMA = json.loads((ROOT / "vendor/dap/debugAdapterProtocol.json").read_bytes())


def validate(definition, message):
    schema = {
        "$schema": SCHEMA["$schema"],
        "definitions": SCHEMA["definitions"],
        "$ref": "#/definitions/" + definition,
    }
    Draft4Validator(schema).validate(message)


def main():
    Draft4Validator.check_schema(SCHEMA)
    run = subprocess.run(
        ["moon", "run", "--target", "native", "tests/codec_fixture"],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        check=True,
    )
    count = 0
    for line in run.stdout.decode("utf-8").splitlines():
        row = json.loads(line)
        validate(row["definition"], row["message"])
        count += 1
    if count != 11:
        raise SystemExit(f"应校验 11 个样本，实际得到 {count} 个")
    print(f"Draft 4 校验通过：{count} 个 MoonBit 往返样本")


if __name__ == "__main__":
    main()
