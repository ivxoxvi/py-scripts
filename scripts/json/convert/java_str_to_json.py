import json
from typing import Dict, List, Any, Optional, Callable, Tuple

import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))
from util.rw_file import rfile


class JavaStrToJsonParser:
    def __init__(self, java_str: str):
        self.java_str = java_str
        self.index = 0
        self.length = len(java_str)

    def parse(self) -> Any:
        if self.java_str == "null":
            return None
        if self.current() == "[":
            return self.parse_array()
        if self.current().isupper():
            return self.parse_obj()
        else:
            return self.parse_primitive()

    def parse_array(self) -> list[Any]:
        if self.current() != "[":
            raise ValueError("java array string should start with [")
        self.step()
        self.skip_blank()

        arr = []
        while self.index < self.length:
            arr.append(self.parse_obj())
            self.skip_blank()
            if self.current() == ",":
                continue
            elif self.current() == "]":
                break
            else:
                raise ValueError("java array string should end with ]")
        self.step()
        return arr

    def parse_obj(self) -> Dict[str, Any]:
        obj = {}
        self.skip_class_name()
        self.step()  # skip '('
        while True:
            key, value = self.parse_field()
            obj[key] = value
            if self.current() == ",":
                continue
            elif self.current() == ")":
                break
            else:
                raise ValueError("java obj string should end with )")
        return obj

    def parse_field(self) -> Tuple[str, Any]:
        self.skip_blank()
        key = self.skip_str_before("=")
        self.skip_blank()
        value = self.parse()
        return key, value

    def parse_primitive(self):
        if self.current().isnumeric():
            self.step()
            value = self.skip_str_before('"')
            self.step()
            return value
        else:
            start = self.index
            while self.index < self.length and not self.current() in [",", ")", "]"]:
                self.step()
            value_str = self.java_str[start : self.index].strip()
            if value_str == "null":
                return None
            if value_str == "true":
                return True
            if value_str == "false":
                return False
            try:
                if "." in value_str:
                    return float(value_str)
                else:
                    return int(value_str)
            except ValueError:
                return value_str

    def current(self) -> str:
        return self.java_str[self.index]

    def step(self) -> None:
        self.index += 1

    def skip_blank(self) -> str:
        return self.skip_until(lambda c: not c.isspace())

    def skip_class_name(self) -> str:
        return self.skip_until(lambda c: not c.isalpha())

    def skip_str_before(self, stop_char: str) -> str:
        return self.skip_until(lambda c: not self.current() == stop_char)

    def skip_until(self, stop_condition: Callable[[str], bool]) -> str:
        start = self.index
        while self.index < self.length and not stop_condition(self.current()):
            self.step()
        return self.java_str[start : self.index]


obj = JavaStrToJsonParser(rfile(r"java_str.txt")).parse()
print(json.dumps(obj, indent=4, ensure_ascii=False))
