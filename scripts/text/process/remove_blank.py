import string
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
from util.rw_file import rfile, wfile

INPUT_FILE = "./remove_blank_input.txt"


def remove_blank(s: str) -> str:
    return s.translate(str.maketrans("", "", string.whitespace))


if __name__ == "__main__":
    s = rfile(INPUT_FILE, typ="str")
    str_no_blank = remove_blank(s)
    print(str_no_blank)

    str_len = len(s)
    str_no_blank_len = len(str_no_blank)
    print(
        f"\nword count: {str_len} -> {str_no_blank_len}, removed {str_len - str_no_blank_len} blanks."
    )
