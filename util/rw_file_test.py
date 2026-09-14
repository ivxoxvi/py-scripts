import csv
import json
from pathlib import Path

import pytest
from rw_file import *


@pytest.fixture
def tmp_workdir(tmp_path: Path, monkeypatch: pytest.MonkeyPatch):
    """
    把测试代码所在目录指向临时目录，用来适配 rfile/wfile 里 inspect.stack 获取 caller 的逻辑
    模拟：测试脚本在 tmp_path 目录执行，相对文件基于这个目录解析
    """
    monkeypatch.chdir(tmp_path)
    return tmp_path


def test_curr_dir(tmp_workdir: Path):
    """测试 curr_dir 返回调用文件所在目录"""
    p = curr_dir()
    assert isinstance(p, Path)
    # curr_dir 的 caller 是本测试函数，caller_file = test_file_utils.py
    # 这里我们只校验返回 Path 对象，路径逻辑在 rfile 一起验证
    assert p.exists()


def test_rfile_str(tmp_workdir: Path):
    # 准备文件
    fpath = tmp_workdir / "test_str.txt"
    fpath.write_text("hello world\nline2", encoding="utf-8")

    content = rfile(fpath, typ="str")
    assert content == "hello world\nline2"


def test_rfile_list(tmp_workdir: Path):
    fpath = tmp_workdir / "lines.txt"
    fpath.write_text("a\nb\nc", encoding="utf-8")
    lines = rfile(fpath, typ="list")
    assert lines == ["a\n", "b\n", "c"]


def test_rfile_json(tmp_workdir: Path):
    data = {"name": "test", "value": 123}
    fpath = tmp_workdir / "data.json"
    fpath.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")

    loaded = rfile(fpath, typ="json")
    assert loaded == data


def test_rfile_jsonl(tmp_workdir: Path):
    lines = [{"id": 1}, {"id": 2}, {"id": 3}]
    content = "\n".join(json.dumps(x, ensure_ascii=False) for x in lines)
    fpath = tmp_workdir / "data.jsonl"
    fpath.write_text(content, encoding="utf-8")

    res = rfile(fpath, typ="jsonl")
    assert res == lines


def test_rfile_csv(tmp_workdir: Path):
    csv_text = "name,age\nAlice,20\nBob,30"
    fpath = tmp_workdir / "data.csv"
    fpath.write_text(csv_text, encoding="utf-8")
    rows = rfile(fpath, typ="csv")
    assert len(rows) == 2
    assert rows[0]["name"] == "Alice"
    assert rows[0]["age"] == "20"


def test_rfile_tsv(tmp_workdir: Path):
    tsv_text = "name\tage\nAlice\t20\nBob\t30"
    fpath = tmp_workdir / "data.tsv"
    fpath.write_text(tsv_text, encoding="utf-8")
    rows = rfile(fpath, typ="tsv")
    assert len(rows) == 2
    assert rows[1]["name"] == "Bob"


def test_rfile_unsupported_type(tmp_workdir: Path):
    fpath = tmp_workdir / "dummy.txt"
    fpath.write_text("xxx")
    with pytest.raises(ValueError, match="not support this file type: xml"):
        rfile(fpath, typ="xml")  # pyright: ignore[reportCallIssue,reportArgumentType]


# ========= wfile 测试 =========
def test_wfile_str(tmp_workdir: Path):
    out_path = tmp_workdir / "out_str.txt"
    wfile("test content", out_path, typ="str")
    assert out_path.read_text(encoding="utf-8") == "test content"


def test_wfile_list(tmp_workdir: Path):
    out_path = tmp_workdir / "out_list.txt"
    wfile(["apple", "banana", "cherry"], out_path, typ="list")
    lines = out_path.read_text(encoding="utf-8").splitlines()
    assert lines == ["apple", "banana", "cherry"]


def test_wfile_json(tmp_workdir: Path):
    data = {"foo": "bar", "num": 42}
    out_path = tmp_workdir / "out.json"
    wfile(data, out_path, typ="json")
    loaded = json.loads(out_path.read_text(encoding="utf-8"))
    assert loaded == data


def test_wfile_jsonl_single_and_list(tmp_workdir: Path):
    out_path = tmp_workdir / "out.jsonl"
    # list 写入
    wfile([{"id": 1}, {"id": 2}], out_path, typ="jsonl")
    content = out_path.read_text(encoding="utf-8")
    assert len(content.strip().splitlines()) == 2

    # 单条对象写入（非list分支）
    out_path2 = tmp_workdir / "single.jsonl"
    wfile({"id": 99}, out_path2, typ="jsonl")
    line = out_path2.read_text(encoding="utf-8").strip()
    assert json.loads(line) == {"id": 99}


def test_wfile_csv(tmp_workdir: Path):
    rows = [{"name": "A", "val": "1"}, {"name": "B", "val": "2"}]
    out_path = tmp_workdir / "out.csv"
    wfile(rows, out_path, typ="csv")
    with open(out_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        data = list(reader)
    assert data == rows


def test_wfile_csv_append_no_duplicate_header(tmp_workdir: Path):
    """追加写入csv：已有文件时，不要重复写表头"""
    rows1 = [{"name": "A", "val": "1"}]
    rows2 = [{"name": "B", "val": "2"}]
    out_path = tmp_workdir / "append.csv"
    wfile(rows1, out_path, typ="csv")
    wfile(rows2, out_path, typ="csv", append=True)

    text = out_path.read_text(encoding="utf-8")
    lines = text.strip().splitlines()
    # 只有一行表头，两行数据
    assert lines[0] == "name,val"
    assert len(lines) == 3


def test_wfile_append_str(tmp_workdir: Path):
    out_path = tmp_workdir / "append.txt"
    wfile("hello", out_path, typ="str")
    wfile(" world", out_path, typ="str", append=True)
    assert out_path.read_text(encoding="utf-8") == "hello world"


def test_wfile_unsupported_type(tmp_workdir: Path):
    out_path = tmp_workdir / "dummy.bin"
    with pytest.raises(ValueError, match="not support this file type: xml"):
        wfile("abc", out_path, typ="xml")  # pyright: ignore[reportCallIssue,reportArgumentType]


def test_wfile_relative_with_root(tmp_workdir: Path):
    """wfile 相对路径 + root 参数，自动拼接 output 目录"""
    wfile("test_root", "root_test.txt", typ="str", root=tmp_workdir / "output")
    target = tmp_workdir / "output" / "root_test.txt"
    assert target.exists()
    assert target.read_text() == "test_root"
