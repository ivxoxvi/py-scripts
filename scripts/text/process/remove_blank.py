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

INPUT_FILE = "remove_blank_input.txt"
ONPUT_FILE = "remove_blank_output.txt"

def remove_blank(s: str) -> str:
    return s.translate(str.maketrans("", "", string.whitespace))


def remove_space(s: str) -> str:
    return s.translate(str.maketrans("", "", " "))


def remove_newline(s: str) -> str:
    return s.translate(str.maketrans("", "", "\n\r"))


if __name__ == "__main__":
    s = rfile(INPUT_FILE, typ="str")
    processed_str = remove_blank(s)
    print(processed_str)

    str_len = len(s)
    processed_str_len = len(processed_str)
    print(
        f"\nword count: {str_len} -> {processed_str_len}, removed {str_len - processed_str_len} blanks."
    )

    # wfile(processed_str , typ="str","remove_blank_output")
