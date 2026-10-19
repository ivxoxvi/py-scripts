from __future__ import annotations

import json
from pathlib import Path

import pytest

from rw_file import (
    curr_dir,
    rfile,
    rfile_async,
    wfile,
    wfile_async,
)

# Current direction
HERE = Path(__file__).resolve().parent

# Content of separated-values files for testing
ROWS = [
    {"name": "Alice", "note": "hello, world", "city": "北京"},
    {"name": "Bob", "note": 'say "hi"', "city": "上海"},
    {"name": "Carol", "note": "line1\nline2", "city": ""},
]


# Specify the async backend
@pytest.fixture
def anyio_backend():
    return "asyncio"


# ---------------------------------------------------------------- round trip
@pytest.mark.parametrize(
    "typ, data",
    [
        ("str", "hello\n你好\n"),
        ("list", ["a", "b", "中文"]),
        ("json", {"a": 1, "b": [1, 2, 3], "c": "中文"}),
        ("jsonl", [{"a": 1}, {"b": "中文"}]),
        ("csv", ROWS),
        ("tsv", ROWS),
    ],
)
def test_round_trip(tmp_path, typ, data):
    p = tmp_path / f"f.{typ}"
    wfile(data, p, typ=typ)
    assert rfile(p, typ=typ) == data


def test_default_typ_is_auto(tmp_path):
    p = tmp_path / "a.json"
    wfile({"a": 1}, p)
    assert rfile(p) == {"a": 1}


# ---------------------------------------------------------------- auto
@pytest.mark.parametrize(
    "name, data",
    [
        ("a.json", {"a": [1, 2], "b": "中文"}),
        ("a.jsonl", [{"a": 1}, {"a": 2}]),
        ("a.ndjson", [{"a": 1}, {"a": 2}]),
        ("a.csv", ROWS),
        ("a.tsv", ROWS),
        ("a.txt", "plain text"),
    ],
)
def test_auto_round_trip(tmp_path, name, data):
    p = tmp_path / name
    wfile(data, p)
    assert rfile(p) == data


def test_auto_explicit_keyword_same_as_default(tmp_path):
    p = tmp_path / "a.json"
    wfile({"a": 1}, p, typ="auto")
    assert rfile(p, typ="auto") == rfile(p) == {"a": 1}


@pytest.mark.parametrize(
    "name", ["README", "a.log", "a.md", "a.unknown", "data.tar.gz", ".hidden"]
)
def test_auto_falls_back_to_str(tmp_path, name):
    p = tmp_path / name
    wfile("hello", p)
    assert p.read_text(encoding="utf-8") == "hello"
    assert rfile(p) == "hello"


def test_auto_suffix_is_case_insensitive(tmp_path):
    p = tmp_path / "DATA.JSON"
    wfile({"a": 1}, p)
    assert rfile(p) == {"a": 1}


def test_auto_str_data_to_json_file_is_json_encoded(tmp_path):
    p = tmp_path / "a.json"
    wfile("abc", p)
    assert p.read_text(encoding="utf-8") == '"abc"'


def test_auto_explicit_typ_overrides_suffix(tmp_path):
    p = tmp_path / "a.json"
    wfile("not json at all", p, typ="str")
    assert rfile(p, typ="str") == "not json at all"


def test_auto_list_must_be_explicit(tmp_path):
    p = tmp_path / "a.txt"
    wfile(["a", "b"], p, typ="list")
    assert rfile(p) == "a\nb\n"  # auto reads .txt as str
    assert rfile(p, typ="list") == ["a", "b"]


def test_auto_append_json_suffix_rejected(tmp_path):
    p = tmp_path / "a.json"
    wfile({"a": 1}, p)
    with pytest.raises(ValueError):
        wfile({"b": 2}, p, append=True)
    assert rfile(p) == {"a": 1}


def test_auto_append_jsonl_suffix(tmp_path):
    p = tmp_path / "a.jsonl"
    wfile([{"i": 1}], p)
    wfile([{"i": 2}], p, append=True)
    assert rfile(p) == [{"i": 1}, {"i": 2}]


def test_auto_append_csv_suffix_writes_header_only_once(tmp_path):
    p = tmp_path / "a.csv"
    wfile([{"a": 1}], p, append=True)
    wfile([{"a": 2}], p, append=True)
    assert p.read_text(encoding="utf-8").splitlines() == ["a", "1", "2"]


def test_auto_relative_write_and_read_back():
    out = wfile({"a": 1}, "_pytest_tmp_auto.json")
    try:
        assert rfile("output/_pytest_tmp_auto.json") == {"a": 1}
    finally:
        out.unlink(missing_ok=True)
        try:
            out.parent.rmdir()
        except OSError:
            pass


# ---------------------------------------------------------------- csv / tsv
def test_csv_read(tmp_path):
    p = tmp_path / "a.csv"
    p.write_text("x,y\n1,2\n3,4\n", encoding="utf-8")
    assert rfile(p, typ="csv") == [{"x": "1", "y": "2"}, {"x": "3", "y": "4"}]


def test_tsv_uses_tab_delimiter(tmp_path):
    p = tmp_path / "a.tsv"
    wfile([{"x": "a,b", "y": "c"}], p, typ="tsv")
    raw = p.read_text(encoding="utf-8")
    assert "\t" in raw.splitlines()[0]
    assert rfile(p, typ="tsv") == [{"x": "a,b", "y": "c"}]


def test_csv_empty_data_writes_empty_file(tmp_path):
    p = tmp_path / "e.csv"
    wfile([], p, typ="csv")
    assert p.read_text(encoding="utf-8") == ""
    assert rfile(p, typ="csv") == []


def test_csv_heterogeneous_keys_are_merged(tmp_path):
    p = tmp_path / "h.csv"
    wfile([{"a": 1}, {"a": 2, "b": 3}], p, typ="csv")
    assert rfile(p, typ="csv") == [{"a": "1", "b": ""}, {"a": "2", "b": "3"}]


def test_csv_write_single_dict(tmp_path):
    p = tmp_path / "h.csv"
    wfile({"a": 2, "b": 3}, p, typ="csv")
    assert rfile(p, typ="csv") == [{"a": "2", "b": "3"}]


def test_csv_no_blank_lines_between_rows(tmp_path):
    p = tmp_path / "n.csv"
    wfile([{"a": 1}, {"a": 2}], p, typ="csv")
    assert b"\r\r" not in p.read_bytes()


# ---------------------------------------------------------------- list / jsonl
def test_list_round_trip_has_no_blank_line_growth(tmp_path):
    p = tmp_path / "l.txt"
    wfile(["a", "b"], p, typ="list")
    for _ in range(3):
        wfile(rfile(p, typ="list"), p, typ="list")
    assert p.read_text(encoding="utf-8") == "a\nb\n"


def test_jsonl_skips_blank_lines(tmp_path):
    p = tmp_path / "b.jsonl"
    p.write_text('{"a": 1}\n\n   \n{"a": 2}\n', encoding="utf-8")
    assert rfile(p, typ="jsonl") == [{"a": 1}, {"a": 2}]


def test_jsonl_single_object_written_as_one_line(tmp_path):
    p = tmp_path / "s.jsonl"
    wfile({"a": 1}, p, typ="jsonl")
    assert rfile(p, typ="jsonl") == [{"a": 1}]


# ---------------------------------------------------------------- encoding
def test_json_keeps_non_ascii_unescaped(tmp_path):
    p = tmp_path / "c.json"
    wfile({"k": "中文"}, p, typ="json")
    assert "中文" in p.read_text(encoding="utf-8")
    assert "\\u" not in p.read_text(encoding="utf-8")


# ---------------------------------------------------------------- append
def test_append_str(tmp_path):
    p = tmp_path / "a.txt"
    wfile("a", p)
    wfile("b", p, append=True)
    assert rfile(p) == "ab"


def test_append_jsonl(tmp_path):
    p = tmp_path / "a.jsonl"
    wfile([{"i": 1}], p, typ="jsonl")
    wfile([{"i": 2}], p, typ="jsonl", append=True)
    assert rfile(p, typ="jsonl") == [{"i": 1}, {"i": 2}]


def test_append_csv_writes_header_only_once(tmp_path):
    p = tmp_path / "a.csv"
    wfile([{"a": 1}], p, typ="csv", append=True)
    wfile([{"a": 2}], p, typ="csv", append=True)
    assert p.read_text(encoding="utf-8").splitlines() == ["a", "1", "2"]
    assert rfile(p, typ="csv") == [{"a": "1"}, {"a": "2"}]


def test_append_json_is_rejected(tmp_path):
    p = tmp_path / "a.json"
    wfile({"a": 1}, p, typ="json")
    with pytest.raises(ValueError):
        wfile({"b": 2}, p, typ="json", append=True)
    assert rfile(p, typ="json") == {"a": 1}


# ---------------------------------------------------------------- paths
def test_absolute_path_creates_parent_dirs(tmp_path):
    """原 bug：绝对路径时不会创建父目录。"""
    p = tmp_path / "x" / "y" / "z.txt"
    wfile("hi", p)
    assert p.read_text(encoding="utf-8") == "hi"


def test_wfile_returns_final_path(tmp_path):
    p = tmp_path / "r.txt"
    assert wfile("x", p) == p


def test_wfile_relative_path_uses_root(tmp_path):
    out = wfile("x", "sub/a.txt", root=tmp_path)
    assert out == tmp_path / "sub" / "a.txt"
    assert out.read_text(encoding="utf-8") == "x"


def test_wfile_relative_default_root_is_caller_dir_output():
    out = wfile("x", "_pytest_tmp_default_root.txt")
    try:
        assert out == HERE / "output" / "_pytest_tmp_default_root.txt"
        assert out.read_text(encoding="utf-8") == "x"
    finally:
        out.unlink(missing_ok=True)
        try:
            out.parent.rmdir()
        except OSError:
            pass


def test_rfile_relative_path_resolves_against_caller_file():
    target = HERE / "_pytest_tmp_rel.txt"
    target.write_text("rel", encoding="utf-8")
    try:
        # 即使 cwd 不是测试文件所在目录，也应读到
        assert rfile("_pytest_tmp_rel.txt") == "rel"
    finally:
        target.unlink(missing_ok=True)


def test_rfile_relative_independent_of_cwd(tmp_path, monkeypatch):
    target = HERE / "_pytest_tmp_cwd.txt"
    target.write_text("cwd", encoding="utf-8")
    monkeypatch.chdir(tmp_path)
    try:
        assert rfile("_pytest_tmp_cwd.txt") == "cwd"
    finally:
        target.unlink(missing_ok=True)


def test_curr_dir_is_caller_dir():
    assert curr_dir() == HERE


# ---------------------------------------------------------------- errors / atomicity
def test_rfile_missing_file_raises(tmp_path):
    with pytest.raises(FileNotFoundError):
        rfile(tmp_path / "nope.txt")


def test_read_unsupported_type_raises(tmp_path):
    p = tmp_path / "a.txt"
    p.write_text("x", encoding="utf-8")
    with pytest.raises(ValueError):
        rfile(p, typ="xml")  # type: ignore[arg-type]


def test_write_unsupported_type_raises(tmp_path):
    with pytest.raises(ValueError):
        wfile("x", tmp_path / "a.xml", typ="xml")  # type: ignore[arg-type]


def test_invalid_json_content_raises(tmp_path):
    p = tmp_path / "bad.json"
    p.write_text("{not json", encoding="utf-8")
    with pytest.raises(json.JSONDecodeError):
        rfile(p)  # auto -> json


def test_failed_overwrite_keeps_original_and_leaves_no_tmp(tmp_path):
    p = tmp_path / "a.json"
    wfile({"ok": True}, p, typ="json")
    with pytest.raises(TypeError):
        wfile({"bad": object()}, p, typ="json")
    assert rfile(p, typ="json") == {"ok": True}
    assert [f.name for f in tmp_path.iterdir()] == ["a.json"]


def test_overwrite_replaces_content(tmp_path):
    p = tmp_path / "a.txt"
    wfile("long content here", p)
    wfile("short", p)
    assert rfile(p) == "short"


# ---------------------------------------------------------------- async
@pytest.mark.anyio
@pytest.mark.parametrize(
    "typ, data",
    [
        ("str", "hi"),
        ("list", ["a", "b"]),
        ("json", {"a": [1, 2]}),
        ("jsonl", [{"a": 1}, {"a": 2}]),
        ("csv", ROWS),
        ("tsv", ROWS),
    ],
)
async def test_async_round_trip(tmp_path, typ, data):
    p = tmp_path / f"f.{typ}"
    await wfile_async(data, p, typ=typ)
    assert await rfile_async(p, typ=typ) == data


@pytest.mark.anyio
@pytest.mark.parametrize(
    "name, data",
    [
        ("a.json", {"a": 1}),
        ("a.jsonl", [{"a": 1}, {"a": 2}]),
        ("a.csv", ROWS),
        ("a.txt", "plain"),
    ],
)
async def test_async_auto_round_trip(tmp_path, name, data):
    p = tmp_path / name
    await wfile_async(data, p)
    assert await rfile_async(p) == data


@pytest.mark.anyio
async def test_async_creates_parent_dirs(tmp_path):
    p = tmp_path / "a" / "b.txt"
    await wfile_async("x", p)
    assert p.exists()


@pytest.mark.anyio
async def test_async_append(tmp_path):
    p = tmp_path / "a.jsonl"
    await wfile_async([{"i": 1}], p, typ="jsonl")
    await wfile_async([{"i": 2}], p, typ="jsonl", append=True)
    assert await rfile_async(p, typ="jsonl") == [{"i": 1}, {"i": 2}]


@pytest.mark.anyio
async def test_async_concurrent_writes(tmp_path):

    import anyio  # pylint: disable=C0415

    async def one(i: int):
        await wfile_async(f"v{i}", tmp_path / f"{i}.txt")

    async with anyio.create_task_group() as tg:
        for i in range(20):
            tg.start_soon(one, i)
    assert [(tmp_path / f"{i}.txt").read_text() for i in range(20)] == [
        f"v{i}" for i in range(20)
    ]
