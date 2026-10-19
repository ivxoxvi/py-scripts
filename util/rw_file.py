import csv
import inspect
import json
import os
import tempfile
from functools import partial
from io import StringIO
from pathlib import Path
from typing import Any, Literal, overload

import anyio.to_thread

# Supported data formats
DataType = Literal["str", "list", "json", "jsonl", "csv", "tsv"]

# File suffix -> data type, used when `typ="auto"`. Unlisted suffixes fall back to `str`.
_SUFFIX_TYPES: dict[str, DataType] = {
    ".json": "json",
    ".jsonl": "jsonl",
    ".ndjson": "jsonl",
    ".csv": "csv",
    ".tsv": "tsv",
}

# Default write path
DEFAULT_OUTPUT_ROOT = Path("output")

# Delimiter of separated-values files
_SV_DELIM = {"csv": ",", "tsv": "\t"}


def _caller_dir(depth: int = 1) -> Path:
    """Return the directory path of the caller at the specified stack depth.

    Args:
        depth (int, optional): How many stack frames you want to walk backward
            from the immediate caller.
            Defaults to 1.

    Returns:
        Path: Absolute directory of the source file for the target stack frame.
    """
    return Path(inspect.stack(context=0)[depth + 1].filename).resolve().parent


def _resolve_typ(path: Path) -> DataType:
    """Turn `auto` into a concrete data type according to the suffix of `path`.

    Args:
        path (Path): file path.

    Returns:
        DataType: supported data type.
    """
    return _SUFFIX_TYPES.get(path.suffix.lower(), "str")


def _parse(text: str, typ: DataType) -> Any:
    if typ == "str":
        return text
    if typ == "list":
        return text.splitlines()
    if typ == "json":
        return json.loads(text)
    if typ == "jsonl":
        return [json.loads(l) for l in text.splitlines() if l.strip()]
    if typ in _SV_DELIM:
        return list(
            csv.DictReader(StringIO(text, newline=""), delimiter=_SV_DELIM[typ])
        )
    raise ValueError(f"file type not supported: {typ}")


def _dump(data: Any, typ: DataType, *, header: bool = True) -> str:
    if typ == "str":
        return str(data)
    if typ == "list":
        return "".join(f"{x}\n" for x in data)
    if typ == "json":
        return json.dumps(data, ensure_ascii=False, indent=4)
    if typ == "jsonl":
        items = data if isinstance(data, (list, tuple)) else [data]
        return "".join(json.dumps(i, ensure_ascii=False) + "\n" for i in items)
    if typ in _SV_DELIM:
        rows = data if isinstance(data, list) else [data]
        if not rows:
            return ""
        # Extract all distinct keys from a list of dicts, so supports rows containing extra keys.
        fields = list(dict.fromkeys(k for r in rows for k in r))
        buf = StringIO(newline="")
        w = csv.DictWriter(buf, fieldnames=fields, delimiter=_SV_DELIM[typ])
        if header:
            w.writeheader()
        w.writerows(rows)
        return buf.getvalue()
    raise ValueError(f"file type not supported: {typ}")


def _read(path: Path, typ: DataType | Literal["auto"]) -> Any:
    if typ == "auto":
        typ = _resolve_typ(path)
    with open(path, "r", encoding="utf-8", newline="") as f:
        return _parse(f.read(), typ)


def _write(
    data: Any, path: Path, typ: DataType | Literal["auto"], append: bool
) -> None:
    if typ == "auto":
        typ = _resolve_typ(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    if append:
        if typ == "json":
            raise ValueError("Appending to JSON files is not supported")
        header = not (path.exists() and path.stat().st_size > 0)
        with open(path, "a", encoding="utf-8", newline="") as f:
            f.write(_dump(data, typ, header=header))
        return
    # Atomic write: writes to a temporary file first, then replaces the target file.
    fd, tmp = tempfile.mkstemp(dir=path.parent, suffix=".tmp")
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="") as f:
            f.write(_dump(data, typ))
        os.replace(tmp, path)
    except BaseException:
        Path(tmp).unlink(missing_ok=True)
        raise


@overload
def rfile(path: str | Path, *, typ: Literal["str"]) -> str: ...
@overload
def rfile(path: str | Path, *, typ: Literal["list"]) -> list[str]: ...
@overload
def rfile(path: str | Path, *, typ: Literal["json"]) -> Any: ...
@overload
def rfile(path: str | Path, *, typ: Literal["jsonl"]) -> list[Any]: ...
@overload
def rfile(path: str | Path, *, typ: Literal["csv", "tsv"]) -> list[dict[str, str]]: ...
@overload
def rfile(path: str | Path, *, typ: Literal["auto"] = ...) -> Any: ...
def rfile(path: str | Path, *, typ: DataType | Literal["auto"] = "auto") -> Any:
    """Read file according to the specified file type.

    Args:
        path (str | Path): File path, either relative or absolute.
            If relative, resolve it against the caller's file directory.
        typ (ReadType, optional): File type to parse.
            Supported options: `auto`, `str`, `list`, `json`, `jsonl`, `csv`, `tsv`.
            `auto` infers the type from the file suffix, and falls back to `str`
            if the suffix is missing or unknown. Defaults to "auto".

    Returns:
        Any: Return type is determined by `typ`:
            - `str`: str
            - `list`: list[str]
            - `json`: Any (parsed JSON object)
            - `jsonl`: list[Any] (list of parsed JSON objects)
            - `csv` / `tsv`: list[dict[str, str]]
            - `auto`: depends on the inferred type
    """
    p = Path(path)
    if not p.is_absolute():
        p = _caller_dir() / p
    return _read(p, typ)


def wfile(
    data: Any,
    path: str | Path,
    *,
    root: str | Path = DEFAULT_OUTPUT_ROOT,
    typ: DataType | Literal["auto"] = "auto",
    append: bool = False,
) -> Path:
    """Write file according to the specified file type.

    Args:
        data (Any): Data to be written.
        path (str | Path): Output file path, either relative or absolute.
            If relative, resolve it against `<caller's file directory>/<root>`.
        root (str | Path, optional): Root directory for relative output paths.
            Defaults to DEFAULT_OUTPUT_ROOT (`output/`).
        typ (WriteType, optional): File format to write.
            Supported options: `auto`, `str`, `list`, `json`, `jsonl`, `csv`, `tsv`.
            `auto` infers the type from the file suffix, and falls back to `str`
            if the suffix is missing or unknown. Defaults to "auto".
        append (bool, optional): If True, append to the file.
            If False, overwrite the file. JSON files can not be appended, use jsonl instead.
            Defaults to False.

    Returns:
        Path: Path of the written file.
    """
    p = Path(path)
    if not p.is_absolute():
        p = _caller_dir() / root / p
    _write(data, p, typ, append)
    return p


async def rfile_async(
    path: str | Path, *, typ: DataType | Literal["auto"] = "auto"
) -> Any:
    """Async version of rfile.

    Unlike `rfile`, relative paths are NOT resolved against the caller's file
    directory, they are relative to the CWD. Pass absolute paths instead.

    Args:
        path (str | Path): File path, preferably absolute.
        typ (ReadType, optional): File type to parse.
            Supported options: `auto`, `str`, `list`, `json`, `jsonl`, `csv`, `tsv`.
            Defaults to "auto".

    Returns:
        Any: Return type is determined by `typ`, see `rfile`.
    """
    return await anyio.to_thread.run_sync(partial(_read, Path(path), typ))


async def wfile_async(
    data: Any,
    path: str | Path,
    *,
    typ: DataType | Literal["auto"] = "auto",
    append: bool = False,
) -> None:
    """Async version of wfile.

    Unlike `wfile`, relative paths are NOT resolved against the caller's file
    directory and `root` is not applied. Pass absolute paths instead.

    Args:
        data (Any): Data to be written.
        path (str | Path): Output file path, preferably absolute.
        typ (WriteType, optional): File format to write.
            Supported options: `auto`, `str`, `list`, `json`, `jsonl`, `csv`, `tsv`.
            Defaults to "auto".
        append (bool, optional): If True, append to the file.
            If False, overwrite the file. Defaults to False.
    """
    await anyio.to_thread.run_sync(partial(_write, data, Path(path), typ, append))


def curr_dir() -> Path:
    """Return the directory of the file that calls this function."""
    return _caller_dir()


if __name__ == "__main__":
    pass
