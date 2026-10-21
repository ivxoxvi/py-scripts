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
