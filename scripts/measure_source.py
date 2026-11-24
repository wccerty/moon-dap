"""从指定 Git 提交统计 MoonBit 源码规模。"""

import argparse
from pathlib import PurePosixPath
import subprocess


HANDWRITTEN = ("核心库", "示例", "测试与夹具")
GROUPS = (*HANDWRITTEN, "生成协议", "第三方源码")


def git(*args):
    return subprocess.check_output(["git", *args])


def category(path):
    if path.parts[0] == "vendor":
        return "第三方源码"
    if path.as_posix() == "protocol/generated.mbt":
        return "生成协议"
    if path.parts[0] == "tests" or path.stem.endswith(("_test", "_wbtest")):
        return "测试与夹具"
    if path.parts[0] == "examples":
        return "示例"
    return "核心库"


def measure(commit):
    counts = {group: [0, 0, 0] for group in GROUPS}
    paths = git("ls-tree", "-rz", "--name-only", commit).decode("utf-8").split("\0")
    for name in paths:
        path = PurePosixPath(name)
        if path.suffix != ".mbt":
            continue
        lines = git("show", f"{commit}:{name}").splitlines()
        result = counts[category(path)]
        result[0] += 1
        result[1] += len(lines)
        result[2] += sum(bool(line.strip()) and not line.lstrip().startswith(b"//") for line in lines)
    return counts


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("revision", nargs="?", default="HEAD", help="Git 提交、分支或标签，默认 HEAD")
    args = parser.parse_args()
    commit = git("rev-parse", "--verify", "--end-of-options", args.revision + "^{commit}").decode().strip()
    counts = measure(commit)
    print(f"Git 提交 {commit[:7]}")
    print("| 分类 | 文件数 | 物理行 | 有效行估算 |")
    print("| --- | ---: | ---: | ---: |")
    for name, (files, physical, effective) in counts.items():
        print(f"| {name} | {files:,} | {physical:,} | {effective:,} |")
    files, physical, effective = (sum(counts[group][column] for group in HANDWRITTEN) for column in range(3))
    print(f"| 手写合计 | {files:,} | {physical:,} | {effective:,} |")
    print()
    print("有效行估算剔除空行和仅含 // 注释的行。只统计 Git 中的 .mbt 文件。")


if __name__ == "__main__":
    main()
