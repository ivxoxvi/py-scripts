import subprocess
from pathlib import Path
import sys

sys.path.append(str(Path(__file__).parent.parent.parent))
from util.rwFile import wfile

ROOT_FOLDER = r"/Users/vxoxvx/Code/OpenSources/Templates"
# {ROOT_FOLDER}/
MD_OUTPUT = f"{ROOT_FOLDER}/cloc_result.md"
EXCLUDE = [
    "node_modules",
    ".git",
    "dist",
    "build",
    "out",
    "coverage",
    "output",
    ".venv",
    "readme.md",
    ".DS_Store",
]


def get_project_loc(project_dir: Path):
    """调用cloc获取单个项目汇总数据"""
    cmd = ["cloc", str(project_dir), "--md", f"exclude-list-file={','.join(EXCLUDE)}"]
    try:
        proc = subprocess.run(
            cmd, capture_output=True, text=True, encoding="utf-8", check=True
        )
        return proc.stdout
    except Exception as err:
        print(f"cmd error: {project_dir.name} : {err}")
        return None


def main():
    root = Path(ROOT_FOLDER)
    if not root.exists():
        print(f"error: can't find -> {ROOT_FOLDER}")
        return

    cloc_results = {}
    # 遍历一级子文件夹
    for entry in root.iterdir():
        if not entry.is_dir():
            continue
        print(f"clocing：{entry}")
        data = get_project_loc(entry)
        if data:
            cloc_results[entry.name] = "\n".join(data.splitlines()[2:])+ "\n"

    # for a in cloc_results.items():
    #     print(f"{a[0]}&&&{a[1][a[1].rfind("SUM") :].split("|")[-1].strip()}&&&")

    sorted_items = sorted(
        cloc_results.items(),
        key=lambda x: int(x[1][x[1].rfind("SUM") :].split("|")[-1].strip()),
    )

    lines = ["# cloc result\n"]
    for k, v in sorted_items:
        lines.append(f"## {k}")
        lines.append(str(v))
    md = "\n".join(lines)

    # 写入文件
    wfile(MD_OUTPUT, md)
    print(f"\n✅ 统计完成！输出文件：{MD_OUTPUT}")


if __name__ == "__main__":
    main()
