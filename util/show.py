from __future__ import annotations

import importlib.util
import statistics
import warnings
from collections.abc import Callable, Iterable, Mapping, Sequence
from dataclasses import dataclass
from os import PathLike
from typing import TYPE_CHECKING, Any, Literal, TypeAlias

from meta import curr_dir

if TYPE_CHECKING:
    from matplotlib.axes import Axes

type Item = tuple[Any, float]
type SortMode = Literal["none", "asc", "desc"]
type Plotter = "Callable[[Axes, Sequence[Any], Sequence[float]], object]"


# ---------- 统计 ----------
@dataclass(frozen=True, slots=True)
class Stats:
    count: int
    sum: float
    mean: float
    std: float  # 总体标准差
    min: float
    max: float

    @classmethod
    def of(cls, vals: Sequence[float]) -> Stats:
        """vals 不能为空。"""
        return cls(
            count=len(vals),
            sum=sum(vals),
            mean=statistics.fmean(vals),
            std=statistics.pstdev(vals),
            min=min(vals),
            max=max(vals),
        )

    def __str__(self) -> str:
        return (
            f"count:{self.count}  sum:{self.sum:g}  mean:{self.mean:.2f}  "
            f"std:{self.std:.2f}  min:{self.min:g}  max:{self.max:g}"
        )


# ---------- 数据处理 ----------
def _identity(x: Any) -> Any:
    return x


def to_items(
    data: Mapping[Any, Any] | Iterable[Any],
    key_func: Callable[[Any], Any],
    val_func: Callable[[Any], Any],
) -> list[Item]:
    """归一化为 [(key, float_value)]，值为 None 的项会被跳过。"""
    if isinstance(data, Mapping):
        pairs = ((key_func(k), val_func(v)) for k, v in data.items())
    elif isinstance(data, Iterable) and not isinstance(data, (str, bytes)):
        pairs = ((key_func(v), val_func(v)) for v in data)
    else:
        raise TypeError(f"不支持的数据类型: {type(data).__name__}")
    return [(k, float(v)) for k, v in pairs if v is not None]


def sort_items(items: list[Item], sort: SortMode) -> list[Item]:
    if sort == "none":
        return items
    if sort not in ("asc", "desc"):
        raise ValueError(f"sort 只能是 none/asc/desc，收到: {sort!r}")
    return sorted(items, key=lambda kv: kv[1], reverse=sort == "desc")


# ---------- 图表注册表 ----------
def _plot_pie(ax: Axes, keys: Sequence[Any], vals: Sequence[float]) -> None:
    if any(v < 0 for v in vals):
        raise ValueError("pie 不支持负值")
    ax.pie(vals, labels=keys, autopct=lambda p: f"{p:.1f}%" if p > 5 else "")


PLOTTERS: dict[str, Plotter] = {
    "hist": lambda ax, keys, vals: ax.hist(vals),
    "bar": lambda ax, keys, vals: ax.bar(keys, vals),
    "line": lambda ax, keys, vals: ax.plot(keys, vals, marker="o"),
    "scatter": lambda ax, keys, vals: ax.scatter(keys, vals),
    "box": lambda ax, keys, vals: ax.boxplot(vals),
    "pie": _plot_pie,
}
_ROTATE_X = frozenset({"bar", "line", "scatter"})  # 这些图的 x 轴是 key，需要旋转标签
_FONTS = [
    "PingFang SC",
    "Microsoft YaHei",
    "SimHei",
    "Noto Sans CJK SC",
    "WenQuanYi Micro Hei",
    "DejaVu Sans",
]


# ---------- 渲染 ----------
def render_text(
    items: Sequence[Item], title: str, stats: Stats | None, width: int = 40
) -> None:
    print(f"\n<{title:=^80}>")
    peak = max(abs(v) for _, v in items) or 1
    for k, v in items:
        print(f"{k!s:>14} | {'█' * round(abs(v) / peak * width)} {v:g}")
    if stats:
        print("-" * 80)
        print(stats)
    print("=" * 82)


def render_plots(
    plot_types: Sequence[str],
    keys: Sequence[Any],
    vals: Sequence[float],
    title: str,
    stats: Stats | None,
    save_path: str | PathLike[str] | None,
    show_plot: bool,
) -> None:
    import matplotlib.pyplot as plt

    with plt.rc_context():  # 退出时自动还原 rcParams
        plt.rcParams["font.sans-serif"] = _FONTS
        plt.rcParams["axes.unicode_minus"] = False
        fig, axes = plt.subplots(
            1,
            len(plot_types),
            figsize=(5 * len(plot_types), 4),
            squeeze=False,
            layout="constrained",
        )
        try:
            for ax, t in zip(axes[0], plot_types):
                PLOTTERS[t](ax, keys, vals)
                if t in _ROTATE_X:
                    ax.tick_params(axis="x", labelrotation=45)
                ax.set_title(t)
                ax.grid(True, linestyle="--", alpha=0.5)
            if title:
                fig.suptitle(title)
            if stats:
                fig.supxlabel(str(stats), fontsize=9)
            if save_path:
                fig.savefig(save_path, dpi=150)
            if show_plot:
                plt.show()
        finally:
            plt.close(fig)  # 出错也不泄漏 figure


# ---------- 入口 ----------
def _parse_types(typ: str | Iterable[str]) -> list[str]:
    raw = typ.split(",") if isinstance(typ, str) else typ
    types = list(dict.fromkeys(t.strip() for t in raw if t.strip()))
    if not types:
        raise ValueError("typ 不能为空")
    if bad := [t for t in types if t not in PLOTTERS and t != "text"]:
        raise ValueError(f"不支持的图表类型: {bad}，可选: {[*PLOTTERS, 'text']}")
    return types


def show(
    data: Mapping[Any, Any] | Iterable[Any],
    *,
    title: str = "",
    typ: str | Iterable[str] = "bar",
    key_func: Callable[[Any], Any] = _identity,
    val_func: Callable[[Any], Any] = _identity,
    show_stats: bool = True,
    sort: SortMode = "none",
    save_path: str | PathLike[str] | None = None,
    show_plot: bool = True,
) -> Stats | None:
    """可视化 dict / iterable 数据，返回统计结果（show_stats=False 或无数据时为 None）。

    typ: 逗号分隔字符串或列表，可选 hist/bar/line/scatter/box/pie/text
    """
    types = _parse_types(typ)  # 先校验，再干活
    items = sort_items(to_items(data, key_func, val_func), sort)
    if not items:
        print("data is empty")
        return None

    keys, vals = zip(*items)
    stats = Stats.of(vals) if show_stats else None

    plot_types = [t for t in types if t != "text"]
    if plot_types and importlib.util.find_spec("matplotlib") is None:
        warnings.warn("未安装 matplotlib，已降级为文本输出", stacklevel=2)
        plot_types, types = [], [*types, "text"]

    if "text" in types:
        render_text(items, title, stats)
    if plot_types:
        render_plots(plot_types, keys, vals, title, stats, save_path, show_plot)
    return stats


if __name__ == "__main__":
    show([1, 2, 2, 3, 4, 4, 4, 5], typ="hist,text", title="example")
    s = show(
        {"A": 10, "B": 20, "C": 15},
        typ="bar,pie",
        key_func=str.upper,
        sort="desc",
        save_path=curr_dir() / "output" / "demo.png",
    )
    print(s)
