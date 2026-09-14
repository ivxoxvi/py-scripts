import csv
import inspect
import json
import os
from collections.abc import Iterable, Mapping
from io import StringIO
from pathlib import Path
from typing import Any, Literal, overload


@overload
def rfile(path: str | Path, *, typ: Literal["str"]) -> str: ...
@overload
def rfile(path: str | Path, *, typ: Literal["list"]) -> list[str]: ...
@overload
def rfile(path: str | Path, *, typ: Literal["json"]) -> Any: ...
@overload
def rfile(path: str | Path, *, typ: Literal["jsonl"]) -> list[Any]: ...
@overload
def rfile(path: str | Path, *, typ: Literal["csv"]) -> list[dict[str, str]]: ...
@overload
def rfile(path: str | Path, *, typ: Literal["tsv"]) -> list[dict[str, str]]: ...


def rfile(path: str | Path, *, typ="str"):
    """Read file according to the specified file type.

    if the input path is relative, it will be resolved aginest caller's file directory.

    Args:
        path: File path, either relative or absolute.
        typ: File type to parse. Supported options: `str`, `list`, `json`, `jsonl`, `csv`, `tsv`.

    Returns:
        Return type is determined by `typ`:
            - `str`: str
            - `list`: list[str]
            - `json`: Any (parsed JSON object)
            - `jsonl`: list[Any] (list of parsed JSON objects)
            - `csv` / `tsv`: list[dict[str, str]]
    """
    if not Path(path).is_absolute():
        caller_file = inspect.stack()[1].filename
        path = Path(caller_file).parent / path

    with open(path, "r", encoding="utf-8") as f:
        if typ == "str":
            return f.read()
        if typ == "list":
            return f.readlines()
        if typ == "json":
            return json.load(f)
        if typ == "jsonl":
            result = []
            for line in f:
                line = line.strip()
                if line:
                    result.append(json.loads(line))
            return result
        if typ == "csv":
            return list(csv.DictReader(f))
        if typ == "tsv":
            return list(csv.DictReader(f, delimiter="\t"))
        raise ValueError(f"not support this file type: {typ}")


DEFAULT_OUTPUT_ROOT = Path("output")


@overload
def wfile(
    data: str,
    path: str | Path,
    *,
    typ: Literal["str"] = "str",
    root: str | Path = DEFAULT_OUTPUT_ROOT,
    append: bool = False,
) -> None: ...
@overload
def wfile(
    data: list[str],
    path: str | Path,
    *,
    typ: Literal["list"],
    root: str | Path = DEFAULT_OUTPUT_ROOT,
    append: bool = False,
) -> None: ...
@overload
def wfile(
    data: Any,
    path: str | Path,
    *,
    typ: Literal["json"],
    root: str | Path = DEFAULT_OUTPUT_ROOT,
    append: bool = False,
) -> None: ...
@overload
def wfile(
    data: Any,
    path: str | Path,
    *,
    typ: Literal["jsonl"],
    root: str | Path = DEFAULT_OUTPUT_ROOT,
    append: bool = False,
) -> None: ...
@overload
def wfile(
    data: Iterable[Mapping[Any, Any]],
    path: str | Path,
    *,
    typ: Literal["csv"],
    root: str | Path = DEFAULT_OUTPUT_ROOT,
    append: bool = False,
) -> None: ...


def wfile(
    data: Any,
    path: str | Path,
    *,
    typ="str",
    root: str | Path = DEFAULT_OUTPUT_ROOT,
    append: bool = False,
):
    """Write file according to the specified file type.

    if the input path is relative, it will be resolved aginest caller's file directory.

    Args:
        data: Data to be written.
        path: Output file path, either relative or absolute..
        typ: File format to write. Supported options: `str`, `list`, `json`, `jsonl`, `csv`
        root: Root directory for relative output paths. Default: `output/`
        append: If True, append to the file. If False, overwrite the file.
    """
    if not Path(path).is_absolute():
        caller_file = inspect.stack()[1].filename
        path = Path(caller_file).parent / root / path
        path.parent.mkdir(parents=True, exist_ok=True)
    mode = "a" if append else "w"

    with open(path, mode, encoding="utf-8") as f:
        if typ == "str":
            f.write(str(data))
        elif typ == "list":
            f.writelines(item + "\n" for item in data)
        elif typ == "json":
            json.dump(data, f, ensure_ascii=False, indent=4)
        elif typ == "jsonl":
            if isinstance(data, list):
                f.writelines(
                    json.dumps(item, ensure_ascii=False) + "\n" for item in data
                )
            else:
                f.write(json.dumps(data, ensure_ascii=False) + "\n")
        elif typ == "csv":
            stream = StringIO()
            headers = data[0].keys()
            writer = csv.DictWriter(stream, fieldnames=headers)
            write_header = not (
                append and os.path.exists(path) and os.path.getsize(path) > 0
            )
            if write_header:
                writer.writeheader()
            writer.writerows(data)
            f.write(stream.getvalue())
        else:
            raise ValueError(f"not support this file type: {typ}")


def curr_dir() -> Path:
    caller_file = inspect.stack()[1].filename
    return Path(caller_file).parent
