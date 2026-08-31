import sys
from collections import Counter
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
from util.rw_file import rfile

INPUT_PATH = "./find_duplicate.txt"

if __name__ == "__main__":
    l = rfile(INPUT_PATH, typ="list")
    cnt = Counter(l)
    for s, num in cnt.most_common():
        if num >= 2:
            print(f"{s}: {num}")
    print("done")
