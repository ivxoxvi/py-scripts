from typing import Callable
import unicodedata
from dataclasses import dataclass

import fitz

PDF_PATH = "/Users/vxoxvx/Downloads/斯图尔特微积分(上册) 第九版pdf.pdf"


def calc_display_width(s: str) -> int:
    width = 0
    for ch in s:
        eaw = unicodedata.east_asian_width(ch)
        if eaw in ("F", "W"):  # Fullwidth, Wide
            width += 2
        else:
            width += 1
    return width


def calc_real_width(s: str, target_display_width: int):
    display_width = calc_display_width(s)
    display_diff = target_display_width - display_width
    return len(s) + display_diff


def get_pdf_toc(pdf_path: str):
    with fitz.open(pdf_path) as doc:
        return doc.get_toc(), doc.page_count


def find_next_item_by_lv(index, level, toc):
    for i in range(index + 1, len(toc)):
        if toc[i][0] == level:
            return toc[i]
    return None


@dataclass
class TocItem:
    level: int
    title: str
    start: int
    length: int
    ratio: float


def process_toc(toc, total_pages: int) -> list[TocItem]:
    toc_items = []
    for i, (level, title, start) in enumerate(toc):
        next_item = find_next_item_by_lv(i, level, toc)
        end = next_item[2] - 1 if next_item is not None else total_pages
        item_page_count = end - start + 1
        toc_items.append(
            TocItem(level, title, start, item_page_count, item_page_count / total_pages)
        )
    return toc_items


def fmt_toc(toc_items: list[TocItem], *, indent=2, max_depth: int | None = None):
    if max_depth is not None:
        toc_items = [item for item in toc_items if item.level < max_depth]
    if not toc_items:
        return "Table of Content doesn't exist"
    max_display_title_len = max(
        calc_display_width(item.title) + indent * (item.level + 1) for item in toc_items
    )

    lines = []
    for item in toc_items:
        indent_space = " " * indent * (item.level - 1)
        page_info = (
            f"{item.start:>4} {f"({item.ratio*100:.1f}%)" if item.level == 1 else ""}"
        )
        target_len = calc_real_width(item.title, max_display_title_len) - len(
            indent_space
        )
        lines.append(f"{indent_space}{item.title.ljust(target_len)}{" "*5}{page_info}")
    return "\n".join(lines)


def toc_stats(
    toc_items: list[TocItem],
    page_count,
    *,
    top_n=5,
    exclude_func: Callable[[TocItem], bool] = lambda item: True,
):
    lv = 1
    item_lv1 = [
        item for item in toc_items if item.level == lv and not exclude_func(item)
    ]
    if not item_lv1:
        return "Table of Content doesn't exist"

    item_lv1.sort(key=lambda x: x.length, reverse=True)
    max5 = item_lv1[:top_n]
    min5 = item_lv1[-top_n:][::-1]
    max_display_width = max(calc_display_width(item.title) for item in max5 + min5)

    lines = [f"Total Pages Count  : {page_count:>4}"]
    lines += [f"Mean Pages Count   : {page_count//len(item_lv1):>4}"]
    lines += [f"Median Pages Count : {item_lv1[len(item_lv1)//2].length:>4}"]
    lines += [f"Level {lv} TOC Entries (Max Pages Top {top_n}):"]
    lines += [
        f"  {item.title.ljust(calc_real_width(item.title,max_display_width))}{" "*5}{item.length:4} ({item.ratio*100:.1f}%)"
        for item in max5
    ]
    lines += [f"Level {lv} TOC Entries (Min Pages Top {top_n}):"]
    lines += [
        f"  {item.title.ljust(calc_real_width(item.title,max_display_width))}{" "*5}{item.length:4} ({item.ratio*100:.1f}%)"
        for item in min5
    ]
    return "\n".join(lines)


if __name__ == "__main__":
    toc, total_pages = get_pdf_toc(PDF_PATH)
    toc_items = process_toc(toc, total_pages)
    print(f"\n<{" STATS ":=^80}>\n")
    print(
        toc_stats(
            toc_items,
            total_pages,
            top_n=10,
            exclude_func=lambda a: a.length < 10,
        )
    )
    print(f"\n<{" Table of Content ":=^80}>\n")
    print(fmt_toc(toc_items, indent=4))
