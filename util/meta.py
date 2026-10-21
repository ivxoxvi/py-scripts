import inspect
from pathlib import Path


def curr_file() -> Path:
    return Path(get_frame_info(2, False).filename).resolve()


def curr_dir() -> Path:
    return Path(get_frame_info(2, False).filename).resolve().parent


def curr_module_name() -> str:
    return get_frame_info(2).frame.f_globals.get("__name__", "<unknown>")


def caller_file() -> Path:
    return Path(get_frame_info(3, False).filename).resolve()


def caller_dir() -> Path:
    return Path(get_frame_info(3, False).filename).resolve().parent


def caller_module_name() -> str:
    return get_frame_info(3).frame.f_globals.get("__name__", "<unknown>")


def get_frame_info(depth: int, context: bool = False) -> inspect.FrameInfo:
    return inspect.stack(context=1 if context else 0)[depth]  # frame 0


if __name__ == "__main__":
    print(get_frame_info(0, False))
    print(get_frame_info(0, True))
