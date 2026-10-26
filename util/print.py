import shutil

from wcwidth import wcswidth


def print_sep(
    title: str = "", sep: str = "=", width: int | None = None, gap: bool = True
):
    total_width = width if width else shutil.get_terminal_size().columns
    title_width = wcswidth(title)

    if total_width <= title_width:
        print(title)
        return

    sep_width = total_width - title_width
    half_width = sep_width // 2
    need_pad = sep_width % 2 == 1

    left = sep * half_width
    right = sep * half_width
    pad = sep if need_pad else ""

    if gap:
        print()
    print(f"{left}{title}{right}{pad}")
    if gap:
        print()


if __name__ == "__main__":
    print_sep()
    print_sep("哈哈哈")
    print_sep("哈哈")
    print_sep("a")
    print_sep("aa")

    w = 10
    print_sep(width=w)
    print_sep("哈哈哈", width=w)
    print_sep("哈哈", width=w)
    print_sep("a", width=w)
    print_sep("aa", width=w)

    w = 1
    print_sep(width=w)
    print_sep("哈哈哈", width=w)
    print_sep("哈哈", width=w)
    print_sep("a", width=w)
    print_sep("aa", width=w)
