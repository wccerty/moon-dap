"""从固定版 Microsoft DAP Schema 生成 MoonBit 类型及 JSON 编解码。"""

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess


ROOT = Path(__file__).resolve().parents[1]
SCHEMA = ROOT / "vendor/dap/debugAdapterProtocol.json"
OUTPUT = ROOT / "protocol/generated.mbt"
REVISION = "d2387e875a1ec4c2ed9964edea22617c81651cc0"
SHA256 = "5dc16664b5cd7a08a769c14dc19be900dc4c3e7d227cd922583780d25480877a"
REFERENCE = "#/definitions/"
SAFE_INT = 9007199254740991
OPEN_OBJECTS = {"LaunchRequestArguments", "AttachRequestArguments"}
RESERVED = {
    "type", "match", "as", "loop", "fn", "let", "test", "continue", "break",
    "async", "lazy", "module",
}
JSON_TYPES = {"array", "boolean", "integer", "null", "number", "object", "string"}


def quote(value):
    return json.dumps(value, ensure_ascii=False)


def field_name(value):
    value = re.sub(r"([A-Z]+)([A-Z][a-z])", r"\1_\2", value)
    value = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", value).lower()
    if value.startswith("_"):
        value = "private_" + value.lstrip("_")
    return value + "_" if value in RESERVED else value


def type_part(value):
    return "".join(part[0].upper() + part[1:] for part in re.split(r"\W+|_+", value) if part)


def bounds(node):
    ranges = {
        None: (-SAFE_INT, SAFE_INT),
        "int32": (-2147483648, 2147483647),
        "uint32": (0, 4294967295),
        "int64": (-SAFE_INT, SAFE_INT),
        "uint64": (0, SAFE_INT),
    }
    low, high = ranges[node.get("format")]
    return max(low, node.get("minimum", low)), min(high, node.get("maximum", high))


class Generator:
    def __init__(self, definitions):
        self.definitions = definitions
        self.pending = definitions.copy()
        self.declarations = []

    def flatten(self, node):
        if "allOf" not in node:
            return node
        properties = {}
        required = []
        for part in node["allOf"]:
            if "$ref" in part:
                part = self.flatten(self.definitions[part["$ref"].removeprefix(REFERENCE)])
            if part.get("type") not in ("object", None) or "additionalProperties" in part:
                raise ValueError("allOf 成员不是可合并对象")
            properties.update(part.get("properties", {}))
            required.extend(part.get("required", []))
        return {"type": "object", "properties": properties, "required": required}

    def register(self, name, node):
        existing = self.pending.setdefault(name, node)
        if existing != node:
            raise ValueError(f"类型名冲突 {name}")
        return name

    def mb_type(self, node, name):
        if "$ref" in node:
            return node["$ref"].removeprefix(REFERENCE)
        kind = node.get("type")
        if isinstance(kind, list) and set(kind) == JSON_TYPES:
            return "Json"
        if isinstance(kind, list) or "oneOf" in node or "enum" in node:
            return self.register(name, node)
        if kind == "object":
            if "properties" in node:
                return self.register(name, node)
            additional = node.get("additionalProperties", True)
            element = self.mb_type(additional, name + "Value") if isinstance(additional, dict) else "Json"
            return f"Map[String, {element}]"
        if kind == "array":
            return f"Array[{self.mb_type(node['items'], name + 'Item')}]"
        if kind == "integer":
            low, high = bounds(node)
            return "Int" if -2147483648 <= low and high <= 2147483647 else "Int64"
        return {"boolean": "Bool", "number": "Double", "string": "String"}[kind]

    def decoder(self, node, name):
        return "(value, path) => " + self.decode(node, name)

    def decode(self, node, name):
        kind = node.get("type")
        mb_type = self.mb_type(node, name)
        if kind == "integer":
            low, high = bounds(node)
            expr = f"integer(value, path, {low}L, {high}L)"
            return expr + ".to_int()" if mb_type == "Int" else expr
        if kind == "number":
            return "number(value, path)"
        if kind == "array":
            return f"array_of(value, path, {self.decoder(node['items'], name + 'Item')})"
        if mb_type.startswith("Map["):
            additional = node.get("additionalProperties", True)
            if isinstance(additional, dict):
                return f"map_of(value, path, {self.decoder(additional, name + 'Value')})"
            return "object(value, path)"
        return "@json.from_json(value, path~)"

    def encode(self, node, name, expr):
        kind = node.get("type")
        mb_type = self.mb_type(node, name)
        if mb_type == "Int64":
            return f"wide_json({expr})"
        if kind == "array":
            item = self.encode(node["items"], name + "Item", "item")
            return f"Json::array({expr}.map(item => {item}))"
        if mb_type.startswith("Map[") and isinstance(node.get("additionalProperties"), dict):
            item = self.encode(node["additionalProperties"], name + "Value", "item")
            return f"map_to_json({expr}, item => {item})"
        return f"@json.to_json({expr})"

    def emit(self, name, declaration, encode, decode, binding="self"):
        self.declarations.extend([
            declaration,
            f"pub impl ToJson for {name} with fn to_json({binding}) {{\n{encode}\n}}",
            f"pub extend {name} with ToJson::{{to_json}}",
            f"pub impl @json.FromJson for {name} with fn from_json(value, path) {{\n{decode}\n}}",
            f"pub extend {name} with @json.FromJson::{{from_json}}",
        ])

    def render_object(self, name, node):
        props = node.get("properties", {})
        required = set(node.get("required", []))
        preserve = name in OPEN_OBJECTS or not props
        fields = []
        keys = ", ".join(map(quote, props))
        encode = [f"let fields = extras(self.additional, [{keys}])" if preserve else "let fields = Map([])"]
        decode = ["let fields = object(value, path)"]
        values = []
        for key, prop in props.items():
            key_json = quote(key)
            enum = prop.get("enum", [])
            if len(enum) == 1 and key in required:
                tag = quote(enum[0])
                encode.append(f"fields.set({key_json}, Json::string({tag}))")
                decode.append(f"required(fields, {key_json}, path, (value, path) => literal(value, path, {tag}))")
                continue
            member = field_name(key)
            child = name + type_part(key)
            ty = self.mb_type(prop, child)
            required_field = key in required
            fields.append(f"{member} : {ty}" + ("" if required_field else "?"))
            wrapper = "required" if required_field else "optional"
            values.append(f"{member}: {wrapper}(fields, {key_json}, path, {self.decoder(prop, child)})")
            encoded = self.encode(prop, child, f"self.{member}" if required_field else "item")
            if required_field:
                encode.append(f"fields.set({key_json}, {encoded})")
            else:
                encode.append(f"if self.{member} is Some(item) {{ fields.set({key_json}, {encoded}) }}")
        if preserve:
            fields.append("additional : Map[String, Json]")
            values.append(f"additional: extras(fields, [{keys}])")
        if len({field.split()[0] for field in fields}) != len(fields):
            raise ValueError(f"字段名冲突 {name}")
        encode.append("Json::object(fields)")
        decode.append("{\n" + ",\n".join(values) + "\n}")
        binding = "self" if fields else "_"
        self.emit(
            name,
            f"pub(all) struct {name} {{\n" + "\n".join(fields) + "\n}",
            "\n".join(encode),
            "\n".join(decode),
            binding,
        )

    def render_enum(self, name, values):
        cases = [(type_part(value), quote(value)) for value in values]
        declaration = f"pub(all) enum {name} {{\n" + "\n".join(case for case, _ in cases) + "\n}"
        encode = "match self {\n" + "\n".join(f"{case} => Json::string({wire})" for case, wire in cases) + "\n}"
        decode = "match value {\n" + "\n".join(f"String({wire}) => {case}" for case, wire in cases) + '\n_ => invalid(path, "未知枚举值")\n}'
        self.emit(name, declaration, encode, decode)

    def render_union(self, name, node):
        if "oneOf" in node:
            members = [self.mb_type(item, name) for item in node["oneOf"]]
            if len(members) != 2:
                raise ValueError(f"{name} 的 oneOf 需要更新生成器")
            left, right = members
            self.emit(
                name,
                f"pub(all) enum {name} {{ First({left})\n Second({right}) }}",
                "match self { First(item) => @json.to_json(item)\n Second(item) => @json.to_json(item) }",
                f"""let first : {left}? = Some(@json.from_json(value, path~)) catch {{ _ => None }}
let second : {right}? = Some(@json.from_json(value, path~)) catch {{ _ => None }}
match (first, second) {{
  (Some(item), None) => First(item)
  (None, Some(item)) => Second(item)
  _ => invalid(path, "oneOf 必须恰好匹配一个分支")
}}""",
            )
            return
        kind = set(node["type"])
        if kind == {"string", "null"}:
            self.emit(
                name, f"pub(all) enum {name} {{ Text(String)\n NullValue }}",
                "match self { Text(item) => Json::string(item)\n NullValue => Json::null() }",
                'match value { String(item) => Text(item)\n Null => NullValue\n _ => invalid(path, "需要字符串或 null") }',
            )
        elif kind == {"integer", "string"}:
            self.emit(
                name, f"pub(all) enum {name} {{ Text(String)\n Integer(Int64) }}",
                "match self { Text(item) => Json::string(item)\n Integer(item) => wide_json(item) }",
                f"match value {{ String(item) => Text(item)\n _ => Integer(integer(value, path, {-SAFE_INT}L, {SAFE_INT}L)) }}",
            )
        else:
            raise ValueError(f"未知联合类型 {name}: {kind}")

    def render(self, name, original):
        node = self.flatten(original)
        if "oneOf" in node or isinstance(node.get("type"), list):
            self.render_union(name, node)
        elif "enum" in node:
            self.render_enum(name, node["enum"])
        elif node["type"] == "object":
            self.render_object(name, node)
        elif node["type"] == "string" and "_enum" in node:
            self.emit(
                name, f"pub(all) struct {name} {{ value : String }}",
                "Json::string(self.value)", "{ value: @json.from_json(value, path~) }",
            )
        else:
            raise ValueError(f"无法生成定义 {name}")

    def generate(self):
        done = set()
        while remaining := [name for name in self.pending if name not in done]:
            for name in remaining:
                try:
                    self.render(name, self.pending[name])
                except (KeyError, ValueError) as error:
                    raise ValueError(f"{name}: {error}") from error
                done.add(name)
        header = (
            "// 由 scripts/generate_protocol.py 生成，请勿直接修改。\n"
            "// 来源 Microsoft Debug Adapter Protocol，Copyright (c) Microsoft Corporation.\n"
            f"// 提交 {REVISION}，见 vendor/dap/License-code.txt。\n"
        )
        return header + "\n" + "\n\n".join("///|\n" + line for line in self.declarations) + "\n"


def audit(node, path):
    supported = {
        "$ref", "allOf", "oneOf", "type", "properties", "required", "items",
        "enum", "_enum", "enumDescriptions", "title", "description",
        "format", "minimum", "maximum", "additionalProperties",
    }
    unknown = node.keys() - supported
    if unknown:
        raise ValueError(f"{path}: 未支持的 Schema 关键字 {sorted(unknown)}")
    if "$ref" in node and not node["$ref"].startswith(REFERENCE):
        raise ValueError(f"{path}: 只支持本地 definitions 引用")
    if node.get("additionalProperties") is False:
        raise ValueError(f"{path}: 禁止扩展字段的对象需要更新生成器")
    for name, child in node.get("properties", {}).items():
        audit(child, f"{path}.{name}")
    for key in ("allOf", "oneOf"):
        for index, child in enumerate(node.get(key, [])):
            audit(child, f"{path}.{key}[{index}]")
    for key in ("items", "additionalProperties"):
        if isinstance(node.get(key), dict):
            audit(node[key], f"{path}.{key}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="核对生成结果，不写入文件")
    args = parser.parse_args()
    source = SCHEMA.read_bytes()
    if hashlib.sha256(source).hexdigest() != SHA256:
        raise SystemExit("Schema SHA-256 与固定版本不符")
    definitions = json.loads(source)["definitions"]
    for name, node in definitions.items():
        audit(node, name)
    code = Generator(definitions).generate()
    formatted = subprocess.run(
        ["moonfmt", "-"], input=code.encode("utf-8"), capture_output=True, check=True,
    ).stdout.replace(b"\r\n", b"\n")
    if args.check:
        if OUTPUT.read_bytes() != formatted:
            raise SystemExit("生成结果有变化，请运行 scripts/generate_protocol.py")
    else:
        OUTPUT.write_bytes(formatted)
    print(f"已核对 {len(definitions)} 项 Schema 定义")


if __name__ == "__main__":
    main()
