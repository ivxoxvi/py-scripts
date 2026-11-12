import sqlite3
from dataclasses import dataclass, field

from parsel import Selector, SelectorList

DB_PATH = "/Users/vxoxvx/Misc/Dictionary/Longman/ldoce5.db"

_con: sqlite3.Connection | None = None

# 排除 class 含 cn_txt 的节点内的文本(即去掉中文翻译)
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
    signpost: str | None = None  # 义项标签,如 SHORT/NOT LONG
    en: str = ""  # 英文释义
    cn: str | None = None  # 中文释义
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
        """所有英文释义"""
        return [s.en for s in self.senses if s.en]

    @property
    def cn_definitions(self) -> list[str]:
        """所有中文释义"""
        return [s.cn for s in self.senses if s.cn]

    @property
    def examples(self) -> list[Example]:
        """所有例句"""
        return [ex for s in self.senses for ex in s.examples]


# ---------- 解析 ----------


def _all_text(sel: SelectorList) -> str | None:
    if not sel:
        return None
    text = sel[0].xpath("string(.)").get()
    return " ".join(text.split()) if text else None


def _en_text(sel: Selector) -> str:
    raw = "".join(sel.xpath(_NO_CN_TEXT).getall())
    return " ".join(raw.split())


def _parse_html(html: str) -> Entry:
    root = Selector(text=html)
    entry = Entry(
        headword=_all_text(root.css(".ldoceEntry .Head .HWD")),
        pron=_all_text(root.css(".ldoceEntry .PRON")),
        pos=_all_text(root.css(".ldoceEntry .lm5pp_POS")),
    )

    for sense_sel in root.css(".ldoceEntry .Sense"):
        defs = sense_sel.css(".DEF")
        if not defs:
            continue

        sense = Sense(
            signpost=_all_text(sense_sel.css(".ACTIV")),
            en=_en_text(defs[0]),
            cn=_all_text(sense_sel.css(".DEF .cn_txt")),
        )

        for ex in sense_sel.css(".EXAMPLE .english"):
            sense.examples.append(
                Example(en=_en_text(ex), cn=_all_text(ex.css(".cn_txt")))
            )

        entry.senses.append(sense)

    return entry


# ---------- 查询 ----------


def _get_con() -> sqlite3.Connection:
    global _con
    if _con is None:
        _con = sqlite3.connect(DB_PATH)
    return _con


def query(word: str, max_redirect: int = 5) -> WordResult:
    """查询单词,返回 WordResult。查不到时 entries 为空,bool(result) 为 False。"""
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

            if defi.startswith("@@@LINK="):  # 重定向词条
                if depth < max_redirect:
                    _lookup(defi[len("@@@LINK=") :].strip().lower(), depth + 1)
            else:
                result.entries.append(_parse_html(defi))

    _lookup(word.strip().lower(), 0)
    return result


if __name__ == "__main__":
    r = query("abridged")

    if not r:
        print("没找到")
    else:
        print(r.en_definitions)  # 英文释义列表
        print(r.cn_definitions)  # 中文释义列表
        for ex in r.examples:  # 例句
            print(ex.en, "|", ex.cn)

        # 也可以按义项逐个访问
        print("=======================")
        for s in r.senses:
            print(s.signpost, "*****", s.en, "*****", s.cn)
            for ex in s.examples:
                print("  ", ex.en, ex.cn)
