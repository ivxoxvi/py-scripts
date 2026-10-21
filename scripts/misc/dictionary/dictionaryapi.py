from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Self
from urllib.parse import quote

import requests

BASE_URL = "https://api.dictionaryapi.dev/api/v2"


@dataclass(slots=True)
class License:
    name: str = ""
    url: str = ""

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> License:
        return cls(
            name=data.get("name", ""),
            url=data.get("url", ""),
        )


@dataclass(slots=True)
class Phonetic:
    text: str | None = None
    audio: str | None = None
    source_url: str | None = None
    license: License | None = None

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> Phonetic:
        license_data = data.get("license")

        return cls(
            text=data.get("text"),
            audio=data.get("audio"),
            source_url=data.get("sourceUrl"),
            license=(License.from_dict(license_data) if license_data else None),
        )


@dataclass(slots=True)
class Definition:
    definition: str
    synonyms: list[str] = field(default_factory=list)
    antonyms: list[str] = field(default_factory=list)
    example: str | None = None

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> Definition:
        return cls(
            definition=data["definition"],
            synonyms=data.get("synonyms", []),
            antonyms=data.get("antonyms", []),
            example=data.get("example"),
        )


@dataclass(slots=True)
class Meaning:
    part_of_speech: str
    definitions: list[Definition] = field(default_factory=list)
    synonyms: list[str] = field(default_factory=list)
    antonyms: list[str] = field(default_factory=list)

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> Meaning:
        return cls(
            part_of_speech=data["partOfSpeech"],
            definitions=[
                Definition.from_dict(item) for item in data.get("definitions", [])
            ],
            synonyms=data.get("synonyms", []),
            antonyms=data.get("antonyms", []),
        )


@dataclass(slots=True)
class DictionaryEntry:
    word: str
    phonetics: list[Phonetic] = field(default_factory=list)
    meanings: list[Meaning] = field(default_factory=list)
    license: License | None = None
    source_urls: list[str] = field(default_factory=list)
    phonetic: str | None = None
    origin: str | None = None

    @classmethod
    def from_dict(
        cls,
        data: dict[str, Any],
    ) -> DictionaryEntry:
        license_data = data.get("license")

        return cls(
            word=data["word"],
            phonetics=[Phonetic.from_dict(item) for item in data.get("phonetics", [])],
            meanings=[Meaning.from_dict(item) for item in data.get("meanings", [])],
            license=(License.from_dict(license_data) if license_data else None),
            source_urls=data.get("sourceUrls", []),
            phonetic=data.get("phonetic"),
            origin=data.get("origin"),
        )


class DictionaryAPIError(Exception):
    """词典 API 请求或响应异常。"""


class WordNotFoundError(DictionaryAPIError):
    """词典中没有找到该单词。"""


class DictionaryApiClient:
    def __init__(
        self,
        language: str = "en",
        timeout: float = 10.0,
    ) -> None:
        self.base_url = BASE_URL
        self.language = language
        self.timeout = timeout
        self.session = requests.Session()

    def lookup(self, word: str) -> list[DictionaryEntry]:
        word = word.strip()

        if not word:
            raise ValueError("word cannot be empty")

        url = (
            f"{self.base_url}/entries/"
            f"{quote(self.language, safe='')}/"
            f"{quote(word, safe='')}"
        )

        try:
            response = self.session.get(
                url,
                timeout=self.timeout,
            )
        except requests.RequestException as exc:
            raise DictionaryAPIError(f"Request failed: {exc}") from exc

        if response.status_code == 404:
            raise WordNotFoundError(f"No definitions found for {word!r}")

        try:
            response.raise_for_status()
        except requests.HTTPError as exc:
            raise DictionaryAPIError(f"HTTP error: {response.status_code}") from exc

        try:
            data = response.json()
        except requests.exceptions.JSONDecodeError as exc:
            raise DictionaryAPIError("Invalid JSON response") from exc

        if not isinstance(data, list):
            raise DictionaryAPIError("Expected a JSON array")

        try:
            return [DictionaryEntry.from_dict(item) for item in data]
        except (KeyError, TypeError) as exc:
            raise DictionaryAPIError(
                "Unexpected dictionary response structure"
            ) from exc

    def close(self) -> None:
        self.session.close()

    def __enter__(self) -> Self:
        return self

    def __exit__(self, *args: object) -> None:
        self.close()


if __name__ == "__main__":
    try:
        with DictionaryApiClient() as client:
            entries = client.lookup("happy")

            for entry in entries:
                print("单词：", entry.word)
                print("音标：", entry.phonetic)

                for phonetic in entry.phonetics:
                    if phonetic.text:
                        print("发音：", phonetic.text)
                    if phonetic.audio:
                        print("音频：", phonetic.audio)

                for meaning in entry.meanings:
                    print(f"\n词性：{meaning.part_of_speech}")

                    for definition in meaning.definitions:
                        print("释义：", definition.definition)

                        if definition.example:
                            print("例句：", definition.example)

                        if definition.synonyms:
                            print("同义词：", definition.synonyms)

                        if definition.antonyms:
                            print("反义词：", definition.antonyms)

                print("词条同义词：", entry.meanings[0].synonyms)
                print("词条反义词：", entry.meanings[0].antonyms)
    except WordNotFoundError as exc:
        print("单词不存在：", exc)

    except DictionaryAPIError as exc:
        print("API 请求失败：", exc)

# 单词： happy
# 音标： None
# 音频： https://api.dictionaryapi.dev/media/pronunciations/en/happy-au.mp3
# 发音： /ˈhæpiː/
# 音频： https://api.dictionaryapi.dev/media/pronunciations/en/happy-uk.mp3
# 发音： /ˈhæpi/
# 音频： https://api.dictionaryapi.dev/media/pronunciations/en/happy-us.mp3
# 
# 词性：noun
# 释义： A happy event, thing, person, etc.
# 
# 词性：noun
# 释义： Preceded by the: happy people as a group.
# 
# 词性：verb
# 释义： Often followed by up: to become happy; to brighten up, to cheer up.
# 释义： Often followed by up: to make happy; to brighten, to cheer, to enliven.
# 
# 词性：adjective
# 释义： Having a feeling arising from a consciousness of well-being or of enjoyment; enjoying good of any kind, such as comfort, peace, or tranquillity; blissful, contented, joyous.
# 例句： Music makes me feel happy.
# 释义： Experiencing the effect of favourable fortune; favored by fortune or luck; fortunate, lucky, propitious.
# 释义： Content, satisfied (with or to do something); having no objection (to something).
# 例句： Are you happy to pay me back by the end of the week?
# 释义： (Of acts, speech, etc.) Appropriate, apt, felicitous.
# 例句： a happy coincidence
# 释义： (in combination) Favoring or inclined to use.
# 例句： slaphappy, trigger-happy
# 释义： (of people, often followed by "at" or "in") Dexterous, ready, skilful.
# 词条同义词： []
# 词条反义词： []