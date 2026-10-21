from __future__ import annotations

import sqlite3
import sys
from collections.abc import Sequence
from pathlib import Path
from pprint import pprint
from typing import Any


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


import logging
from abc import ABC, abstractmethod

import requests



log = logging.getLogger(__name__)

class Dic():
    def __init__(self,source=) -> None:
        pass

_MISSING = object()  # 区分"没查过"和"查过但没有"


# --------------------------------------------------------------------------
# 信息源基类
# --------------------------------------------------------------------------
class Source(ABC):
    """一个信息源。子类实现 fetch，并按需覆盖支持的字段方法。
    字段方法接收 fetch 返回的原始数据，不支持/没有时返回 None。"""

    name: str = "source"

    @abstractmethod
    def fetch(self, word: str) -> Any | None:
        """取回原始数据；查不到返回 None。允许抛异常，由 DictEntry 兜底。"""

    def phonetic(self, raw: Any) -> str | None:
        return None

    def definitions(self, raw: Any) -> list[str] | None:
        return None

    def examples(self, raw: Any) -> list[str] | None:
        return None

    def translation(self, raw: Any) -> str | None:
        return None

    def audio(self, raw: Any) -> str | None:
        return None


class ECDictSource(Source):
    name = "ecdict"

    def __init__(self, db_path: str):
        from vendor.ECDICT.stardict import StarDict
        self._sd = StarDict(db_path)

    def fetch(self, word: str) -> dict | None:
        return self._sd.query(word)

    def phonetic(self, raw: dict) -> str | None:
        p = (raw.get("phonetic") or "").strip()
        return f"/{p}/" if p else None

    def translation(self, raw: dict) -> str | None:
        return (raw.get("translation") or "").strip() or None

    def definitions(self, raw: dict) -> list[str] | None:
        text = (raw.get("definition") or "").strip()
        return [ln.strip() for ln in text.splitlines() if ln.strip()] or None

class FreeDictionarySource(Source):
    name = "dictionaryapi.dev"
    URL = "https://api.dictionaryapi.dev/api/v2/entries/en/{word}"

    def __init__(self, session: requests.Session | None = None, timeout: float = 10):
        self._http = session or requests.Session()
        self._timeout = timeout

    def fetch(self, word: str) -> list | None:
        resp = self._http.get(self.URL.format(word=word), timeout=self._timeout)
        if resp.status_code != 200:
            return None
        data = resp.json()
        # 找不到时返回的是 dict（{"title": "No Definitions Found"}），不是 list
        return data if isinstance(data, list) and data else None

    def phonetic(self, raw: list) -> str | None:
        for entry in raw:
            if entry.get("phonetic"):
                return entry["phonetic"]
            for ph in entry.get("phonetics", []):
                if ph.get("text"):
                    return ph["text"]
        return None

    def audio(self, raw: list) -> str | None:
        for entry in raw:
            for ph in entry.get("phonetics", []):
                if ph.get("audio"):
                    return ph["audio"]
        return None

    def definitions(self, raw: list) -> list[str] | None:
        out: list[str] = []
        for entry in raw:
            for m in entry.get("meanings", []):
                pos = m.get("partOfSpeech", "")
                for d in m.get("definitions", []):
                    if d.get("definition"):
                        out.append(
                            f"({pos}) {d['definition']}" if pos else d["definition"]
                        )
        return out or None

    def examples(self, raw: list) -> list[str] | None:
        out: list[str] = []
        for entry in raw:
            for m in entry.get("meanings", []):
                for d in m.get("definitions", []):
                    ex = d.get("example")
                    if ex and ex not in out:
                        out.append(ex)
        return out or None


class MyMemorySource(Source):
    name = "mymemory"
    URL = "https://api.mymemory.translated.net/get"

    def __init__(
        self,
        target: str = "zh-CN",
        session: requests.Session | None = None,
        timeout: float = 10,
    ):
        self._target = target
        self._http = session or requests.Session()
        self._timeout = timeout

    def fetch(self, word: str) -> dict | None:
        resp = self._http.get(
            self.URL,
            params={"q": word, "langpair": f"en|{self._target}"},
            timeout=self._timeout,
        )
        if resp.status_code != 200:
            return None
        return resp.json().get("responseData")

    def translation(self, raw: dict) -> str | None:
        text = (raw.get("translatedText") or "").strip()
        return text or None


class DictEntry:
    def __init__(self, word: str, sources: Sequence[Source], *, eager: bool = True):
        word = word.strip()
        if not word:
            raise ValueError("word cannot be empty")
        if not sources:
            raise ValueError("at least one source is required")

        self.word = word
        self.sources = list(sources)
        self._raw: dict[str, Any] = {}  # source.name -> 原始数据 / None（查过没有）
        self._fields: dict[str, Any] = {}  # field -> 结果 / None（缓存，含"没有"）

        if eager:
            self._get_raw(self.sources[0])

    # ---- 内部：原始数据（每个源最多请求一次）----
    def _get_raw(self, src: Source) -> Any | None:
        raw = self._raw.get(src.name, _MISSING)
        if raw is _MISSING:
            try:
                raw = src.fetch(self.word)
            except Exception as e:  # 网络/解析错误 -> 视为该源没有
                log.warning("source %s failed for %r: %s", src.name, self.word, e)
                raw = None
            self._raw[src.name] = raw
        return raw

    # ---- 内部：按字段依次回退 ----
    def _get(self, field: str) -> Any | None:
        if field in self._fields:
            return self._fields[field]

        result = None
        for src in self.sources:
            raw = self._get_raw(src)
            if raw is None:
                continue
            try:
                value = getattr(src, field)(raw)
            except Exception as e:
                log.warning("source %s failed parsing %s: %s", src.name, field, e)
                continue
            if value:  # 非空才算有
                result = value
                break

        self._fields[field] = result
        return result

    # ---- 对外 API ----
    def phonetic(self) -> str | None:
        return self._get("phonetic")

    def translation(self) -> str | None:
        return self._get("translation")

    def audio(self) -> str | None:
        return self._get("audio")

    def definitions(self, limit: int | None = None) -> list[str] | None:
        v = self._get("definitions")
        return v[:limit] if v and limit else v

    def examples(self, limit: int | None = None) -> list[str] | None:
        v = self._get("examples")
        return v[:limit] if v and limit else v

    def __repr__(self) -> str:
        return f"DictEntry({self.word!r}, sources={[s.name for s in self.sources]})"


if __name__ == "__main__":
    sources = [
        ECDictSource("stardict.db"),
        FreeDictionarySource(),
        MyMemorySource(),
    ]
    e = DictEntry("happy", sources)
    print(e.phonetic())
    print(e.translation())
    print(e.examples(2))
    print(e.audio())
    print(e.definitions(3))
