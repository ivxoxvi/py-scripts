import subprocess
from pathlib import Path
import sys

sys.path.append(str(Path(__file__).parent.parent.parent))
from util.rwFile import wfile

ROOT_FOLDER = r"/Users/vxoxvx/Code/Playgrounds"
MD_OUTPUT = f"{ROOT_FOLDER}/cloc-report.md"
EXCLUDE_DIR = [
    "react",
    "node_modules",
    ".next",
    ".react-router",
    ".agents",
    ".claude",
    ".vscode",
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


def run_cloc(project_dir: Path):
    cmd = [
        "cloc",
        str(project_dir),
        "--md",
        f"--exclude-dir={','.join(EXCLUDE_DIR)}",
    ]
    try:
        proc = subprocess.run(
            cmd, capture_output=True, text=True, encoding="utf-8", check=True
        )
        return proc.stdout
    except Exception as err:
        print(f"cloc error: {project_dir.name} : {err}")
        return None


def rm_cloc_header(cloc_str: str) -> str:
    return cloc_str[cloc_str.find("Language|") :]


def extract_cloc_sum(cloc_str) -> int:
    sum_line = cloc_str[cloc_str.rfind("SUM") :]
    sum_number = sum_line.split("|")[-1].strip()
    return int(sum_number)


def main():
    root = Path(ROOT_FOLDER)
    if not root.exists():
        print(f"error: can't find -> {ROOT_FOLDER}")
        return

    cloc_results = {}
    for entry in root.iterdir():
        if not entry.is_dir():
            continue
        print(f"cloc：{entry}")
        cloc_out = run_cloc(entry)
        if cloc_out:
            cloc_results[entry.name] = rm_cloc_header(cloc_out)

    sorted_items = sorted(
        cloc_results.items(),
        key=lambda x: extract_cloc_sum(x[1]),
    )

    lines = []
    for k, v in sorted_items:
        lines.append(f"## {k}\n")
        lines.append(v)
    md = "# CLOC result\n\n" + "\n".join(lines)

    wfile(MD_OUTPUT, md)
    print(f"cloc complete, report location：{MD_OUTPUT}")


if __name__ == "__main__":
    main()
