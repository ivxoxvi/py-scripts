import ast
import inspect
import sys
from pathlib import Path


def add_proj_root_to_path():
    """add project dir to the path"""
    i, max_layer = 0, 5
    root = Path(__file__).resolve()
    while not (root / "pyproject.toml").exists():
        if i == max_layer or root == root.parent:
            raise FileNotFoundError("can't find project root")
        root = root.parent
        i += 1
    if str(root) not in sys.path:
        sys.path.append(str(root))


add_proj_root_to_path()

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


def process(code):
    tree = ast.parse(code)
    # whether has add_proj_root_to_path function
    # if yes, compare func code with func code in this file
    # if idenetify, return
    # else, insert func code to the code
    print(tree.body)
    print(ast.unparse(tree))


if __name__ == "__main__":
    source_code = inspect.getsource(add_proj_root_to_path)
    print(source_code)
