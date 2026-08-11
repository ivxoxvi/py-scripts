import sys
from pathlib import Path
import string
import matplotlib.pyplot as plt


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

# pylint: disable=C0413
from util.rw_file import rfile
from util.show import show

ROOT = "/Users/vxoxvx/Downloads/longman-communication-9000.tsv"

if __name__ == "__main__":
    data = rfile(ROOT, typ="tsv")
    initial_count = {char: 0 for char in string.ascii_uppercase}

    for line in data:
        key = line["# word"][0].upper()
        initial_count[key] += 1

    show(initial_count, typ="hist,pie",sort="desc")
