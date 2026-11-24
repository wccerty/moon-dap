"""核验待发布归档，或在独立模块中验证 Mooncakes 安装。"""

import argparse
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import tempfile
from zipfile import ZipFile

from test_bpflab import EXAMPLE, ROOT, build_adapter, verify


REQUIRED = {
    "LICENSE", "README.md", "moon.mod", "protocol/generated.mbt",
    "vendor/dap/License-code.txt", "vendor/dap/License.txt",
    "vendor/dap/README.md", "vendor/dap/debugAdapterProtocol.json",
    *(f"{name}/moon.pkg" for name in ("expression", "framing", "protocol", "session", "transport")),
    *(f"{name}/pkg.generated.mbti" for name in ("expression", "framing", "protocol", "session", "transport")),
}
TOP_LEVEL = {"CHANGELOG.md", "LICENSE", "README.md", "THIRD_PARTY_NOTICES.md", "moon.mod"}
DIRECTORIES = {"docs", "expression", "framing", "protocol", "session", "transport", "vendor"}


def check_archive(path):
    with ZipFile(path) as archive:
        checked = set()
        for item in archive.infolist():
            name = PurePosixPath(item.filename)
            allowed = (
                len(name.parts) == 1 and name.name in TOP_LEVEL
                or len(name.parts) >= 2 and name.parts[0] in DIRECTORIES
            )
            if (
                not allowed or "\\" in item.filename or any(
                    part == ".." or part.startswith(".") for part in name.parts
                ) or name.name.endswith(("_test.mbt", "_wbtest.mbt"))
            ):
                raise SystemExit(f"归档包含不应发布的路径 {item.filename}")
            if not item.is_dir():
                checked.add(name.as_posix())
        if missing := REQUIRED - checked:
            raise SystemExit(f"归档缺少必要文件 {sorted(missing)}")
    print(f"发布归档通过检查，共 {len(checked)} 个文件")


def verify_registry():
    with tempfile.TemporaryDirectory(prefix="moon-dap-registry-") as directory:
        module = Path(directory)
        for filename in ("moon.mod", "moon.pkg", "adapter.mbt", "program.mbt"):
            shutil.copyfile(EXAMPLE / filename, module / filename)
        assert not (module / "moon.work").exists()
        subprocess.run(["moon", "tree"], cwd=module, check=True)
        verify(build_adapter(module))
        rules = module / "rules"
        rules.mkdir()
        for source in (ROOT / "examples/rules").glob("*.mbt"):
            if not source.stem.endswith("_wbtest"):
                shutil.copyfile(source, rules / source.name)
        shutil.copyfile(ROOT / "examples/rules/moon.pkg", rules / "moon.pkg")
        subprocess.run(["moon", "build", "--target", "native", "rules"], cwd=module, check=True)
    print("已从 Mooncakes 安装依赖并完成独立模块的真实 DAP 会话")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    choice = parser.add_mutually_exclusive_group(required=True)
    choice.add_argument("--archive", type=Path)
    choice.add_argument("--registry", action="store_true")
    args = parser.parse_args()
    if args.archive:
        check_archive(args.archive)
    else:
        verify_registry()
