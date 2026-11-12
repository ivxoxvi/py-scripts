import sqlite3
from dataclasses import dataclass, field

from parsel import Selector, SelectorList

DB_PATH = "/Users/vxoxvx/Misc/Dictionary/Oxford/oeld.db"

_con: sqlite3.Connection | None = None

# 剔除 cn_txt 内部文本，和原版保持一致
_NO_CN_TEXT = (
    ".//text()[not(ancestor-or-self::*"
    '[contains(concat(" ", normalize-space(@class), " "), " cn_txt ")])]'
)


@dataclass
class Example:
    en: str
    cn: str | None = None


@dataclass
class Sense:
    signpost: str | None = None  # OELD 这份样例没有 signpost，一般为 None
    en: str = ""
    cn: str | None = None
    examples: list[Example] = field(default_factory=list)


@dataclass
class Entry:
    headword: str | None = None
    pron: str | None = None
    pos: str | None = None
    senses: list[Sense] = field(default_factory=list)


@dataclass
class WordResult:
    word: str
    entries: list[Entry] = field(default_factory=list)

    def __bool__(self) -> bool:
        return bool(self.entries)

    @property
    def senses(self) -> list[Sense]:
        return [s for e in self.entries for s in e.senses]

    @property
    def en_definitions(self) -> list[str]:
        return [s.en for s in self.senses if s.en]

    @property
    def cn_definitions(self) -> list[str]:
        return [s.cn for s in self.senses if s.cn]

    @property
    def examples(self) -> list[Example]:
        return [ex for s in self.senses for ex in s.examples]


# ---------- 文本辅助函数（原样保留） ----------
def _all_text(sel: SelectorList) -> str | None:
    if not sel:
        return None
    text = sel[0].xpath("string(.)").get()
    return " ".join(text.split()) if text else None


def _en_text(sel: Selector) -> str:
    raw = "".join(sel.xpath(_NO_CN_TEXT).getall())
    return " ".join(raw.split())


# ---------- OELD 专用解析器 ----------
def _parse_html(html: str) -> list[Entry]:
    """
    OELD 一份 HTML 里经常同时包含 UK / US 两个 entryWrapper
    所以这里返回 list[Entry]，而不是单个 Entry
    """
    root = Selector(text=html)
    entry_list: list[Entry] = []

    for wrap in root.css(".entryWrapper"):
        hw = _all_text(wrap.css(".hw"))
        pos = _all_text(wrap.css(".grambhead .pos"))
        pron = _all_text(wrap.css(".grambhead .phoneticSymbol"))

        entry = Entry(
            headword=hw,
            pron=pron,
            pos=pos,
        )

        # semb > li：每个是一条义项
        for sense_node in wrap.css(".semb > li"):
            ind_node = sense_node.css(".ind")
            if not ind_node:
                continue

            sense = Sense(
                signpost=None,
                en=_en_text(ind_node[0]),
                cn=_all_text(sense_node.css(".ind .cn_txt")),
            )

            # 抓取所有 .ex 例句
            for ex_node in sense_node.css(".ex"):
                sense.examples.append(
                    Example(
                        en=_en_text(ex_node),
                        cn=_all_text(ex_node.css(".cn_txt")),
                    )
                )
            entry.senses.append(sense)
        entry_list.append(entry)
    return entry_list


# ---------- DB 连接、查询逻辑 ----------
def _get_con() -> sqlite3.Connection:
    global _con
    if _con is None:
        _con = sqlite3.connect(DB_PATH)
    return _con


def query(word: str, max_redirect: int = 5) -> WordResult:
    result = WordResult(word=word)
    seen: set[int] = set()

    def _lookup(w: str, depth: int) -> None:
        rows = (
            _get_con()
            .execute(
                """
            SELECT e.id, e.defi
            FROM term t JOIN entry e ON e.id = t.entry_id
            WHERE t.term = ?
            ORDER BY e.id
            """,
                (w,),
            )
            .fetchall()
        )
        for entry_id, defi in rows:
            if entry_id in seen:
                continue
            seen.add(entry_id)

            if defi.startswith("@@@LINK="):
                if depth < max_redirect:
                    target = defi[len("@@@LINK=") :].strip().lower()
                    _lookup(target, depth + 1)
            else:
                entries = _parse_html(defi)
                result.entries.extend(entries)

    _lookup(word.strip().lower(), 0)
    return result


if __name__ == "__main__":
    r = query("abnormally")

    if not r:
        print("没找到")
    else:
        print("en: ",r.en_definitions)
        print("ch: ",r.cn_definitions)
        print("example:")
        for ex in r.examples:
            print(ex.en, "|", ex.cn)

        print("=======================")
        for s in r.senses:
            print("sense:")
            print(s.signpost, "*****", s.en, "*****", s.cn)
            for ex in s.examples:
                print("  ", ex.en, ex.cn)
