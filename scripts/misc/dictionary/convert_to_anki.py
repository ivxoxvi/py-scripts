from __future__ import annotations

import sys
from collections import defaultdict
from pathlib import Path


def add_proj_root_to_path():
    """add project dir to the path"""
    i, max_layer = 0, 5
    root = Path(__file__).resolve()
    while not (root / "pyproject.toml").exists():
        if i == max_layer or root == root.parent:
            raise FileNotFoundError("can't find the project root")
        root = root.parent
        i += 1
    if str(root) not in sys.path:
        sys.path.append(str(root))


add_proj_root_to_path()

from scripts.misc.dictionary import query_langman, query_oxford
from util.rw_file import rfile, wfile

WORD_LIST_PATH = (
    "/Users/vxoxvx/Code/Projects/Scripts/py-scripts/scripts/pdf/output/langman9000.txt"
)


def export_anki_csv(word_list: list[str], out_csv: str) -> None:
    rows = []
    not_found = []
    no_example = defaultdict(list)

    for word in word_list:
        res = query_langman.query(word)
        if not res:
            not_found.append([word])
            continue
        chunks = []
        for sense in res.senses:
            # 取第一条例句
            if sense.examples:
                ex = sense.examples[0]
                ex_line = f"{ex.en}"
                if ex.cn:
                    ex_line += f" — {ex.cn}"
            else:
                no_example[word].append(sense.cn)
                ex_line = "(no example)"

            en_def = sense.en.strip() if sense.en else "(no definition)"
            cn_def = sense.cn.strip() if sense.cn else "—"

            block = (
                f"<div class='sense-block'>"
                f"<div class='example'>Example:<br>{ex_line}</div><br>"
                f"<div class='en-def'>Definition:<br>{en_def}</div><br>"
                f"<div class='cn-def'>{cn_def}</div>"
                f"</div>"
            )
            chunks.append(block)

        # 义项之间用横线分隔
        back_body = "<hr>".join(chunks)
        rows.append({"word": word, "def": back_body})

    if not_found:
        print(f"Not found words({len(not_found)}):")
        for word in not_found:
            print(word)
    if no_example:
        print(f"No Example words({len(no_example)}):")
        for word, cn_list in no_example.items():
            print(word, cn_list)

    wfile(rows, out_csv)


if __name__ == "__main__":
    words = rfile(WORD_LIST_PATH, typ="list")
    print(f"Words length: {len(words)}")
    export_anki_csv(words, "langman9000-anki.csv")
    print("success")
