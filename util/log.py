import logging
import sys
from collections.abc import Iterable
from logging.handlers import RotatingFileHandler
from pathlib import Path
from typing import Literal

from meta import caller_file, caller_module_name

DEFAULT_FMT = "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s"
SUPPORT_TYPS = Literal["std", "file"]


def newlog(
    typ: SUPPORT_TYPS | Iterable[SUPPORT_TYPS] = "std",
    *,
    name: str | None = None,
    level: int = logging.DEBUG,
    fmt: str = DEFAULT_FMT,
    filepath: Path | str | None = None,
) -> logging.Logger:
    types: Iterable[SUPPORT_TYPS] = [typ] if isinstance(typ, str) else list(typ)

    name = caller_module_name() if name is None else name
    logger = logging.getLogger(name)
    for old in list(logger.handlers):
        logger.removeHandler(old)
        old.close()
    logger.setLevel(level)
    # Avoid propagation to the root logger, which causes duplicate output.
    logger.propagate = False

    for t in types:
        handler: logging.Handler | None = None
        if t == "std":
            handler = logging.StreamHandler(sys.stdout)
        if t == "file":
            if filepath is None:
                filepath = caller_file().with_suffix(".log")
            Path(filepath).parent.mkdir(parents=True,exist_ok=True)
            handler = RotatingFileHandler(
                filepath,
                maxBytes=5 * 1024 * 1024,
                backupCount=3,
                encoding="utf-8",
            )

        if handler is None:
            # this is only executed when the if branches are not exhaustive.
            raise ValueError(f"handler of typ {t} does not exist")
        formatter = logging.Formatter(fmt)
        handler.setFormatter(formatter)
        logger.addHandler(handler)

    return logger


if __name__ == "__main__":
    log = newlog(
        ["std", "file"],
        filepath="/Users/vxoxvx/Code/Projects/Scripts/py-scripts/scripts/似懂非懂/aaaaa.log",
    )
    log.info("hello")
    log.error("something wrong")

    log2 = newlog("std", name="demo")
    log2.debug("only stdout")
