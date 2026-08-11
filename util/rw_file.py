import json
import inspect
import csv
from pathlib import Path
from typing import overload, Literal, Any


@overload
def rfile(path: str | Path, *, typ: Literal["str"]) -> str: ...
@overload
def rfile(path: str | Path, *, typ: Literal["list"]) -> list[str]: ...
@overload
def rfile(path: str | Path, *, typ: Literal["json"]) -> Any: ...
@overload
def rfile(path: str | Path, *, typ: Literal["csv"]) -> list[dict[str, str]]: ...
@overload
def rfile(path: str | Path, *, typ: Literal["tsv"]) -> list[dict[str, str]]: ...
@overload
def rfile(path: str | Path, *, typ: str = "str") -> None: ...


def rfile(path, *, typ="str"):
    if not Path(path).is_absolute():
        caller_file = inspect.stack()[1].filename
        path = Path(caller_file).parent / path

    with open(path, "r", encoding="utf-8") as file:
        if typ == "str":
            return file.read()
        if typ == "list":
            return file.readlines()
        if typ == "json":
            return json.load(file)
        if typ == "csv":
            return list(csv.DictReader(file))
        if typ == "tsv":
            return list(csv.DictReader(file, delimiter="\t"))
        raise AttributeError(f"not support this file type: {typ}")


@overload
def wfile(path: str | Path, data: str, *, typ: Literal["str"]) -> None: ...
@overload
def wfile(path: str | Path, data: list[str], *, typ: Literal["list"]) -> None: ...
@overload
def wfile(path: str | Path, data: Any, *, typ: Literal["json"]) -> None: ...
@overload
def wfile(path: str | Path, data: Any, *, typ: str = "str") -> None: ...


def wfile(path, data, *, typ="str"):
    if not Path(path).is_absolute():
        caller_file = inspect.stack()[1].filename
        path = Path(caller_file).parent / path

    with open(path, "w", encoding="utf-8") as file:
        if typ == "str":
            file.write(str(data))
        elif typ == "list":
            for item in data:
                file.write(item + "\n")
        elif typ == "json":
            json.dump(data, file, ensure_ascii=False, indent=4)
        else:
            raise AttributeError(f"not support this file type: {typ}")


def curr_dir() -> Path:
    caller_file = inspect.stack()[1].filename
    return Path(caller_file).parent
