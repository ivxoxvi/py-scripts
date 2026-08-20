import inspect
import sys
from pathlib import Path


def add_proj_root():
    i, max_layer = 0, 5
    root = Path(__file__).resolve()
    while not (root / "pyproject.toml").exists():
        if i == max_layer or root == root.parent:
            raise FileNotFoundError("can't find project root")
        root = root.parent
        i += 1
    if str(root) not in sys.path:
        sys.path.append(str(root))


add_proj_root()

exclude_dirs = {
    "venv",
    ".venv",
    "__pycache__",
    "build",
    "dist",
    ".git",
    ".idea",
    ".vscode",
    "node_modules",
}
exclude_files = {}
exclude_suffix = {}


def scan_py_files(root_dir: str | Path):
    py_files = []
    for file in Path(root_dir).rglob("*.py"):
        if any(part in exclude_dirs for part in file.parts):
            continue
        if file.name in exclude_files:
            continue
        if file.suffix in exclude_suffix:
            continue
        py_files.append(file)
    return py_files


if __name__ == "__main__":
    source_code = inspect.getsource(add_proj_root)
    print(source_code)
