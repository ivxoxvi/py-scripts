import importlib.util


def show(
    data,
    *,
    title="",
    typ="bar",
    key_func=lambda x: x,
    val_func=lambda x: x,
    show_sum=True,
    sort="none",
) -> None:
    # determine the output type
    types = [t.strip() for t in typ.split(",") if t.strip()]
    if importlib.util.find_spec("matplotlib") is None:
        print("do not intall matplotlib, use std print as output")
        types = ["print"]

    # process data
    if isinstance(data, dict):
        items = [(key_func(k), val_func(v)) for k, v in data.items()]
    elif isinstance(data, list):
        items = [(key_func(v), val_func(v)) for v in data]
    else:
        raise TypeError(f"this data type is not supported: {type(data)}")
    if not items:
        print("data is empty")
        return

    match sort:
        case "none":
            pass
        case "asc":
            items.sort(key=lambda x: x[1])
        case "desc":
            items.sort(key=lambda x: -x[1])

    keys, vals = zip(*items)

    # calculte statistical data
    stats = {}
    if show_sum:
        nums = [float(v) for v in vals if v is not None]
        if nums:
            stats["count"] = len(nums)
            stats["sum"] = sum(nums)
            stats["mean"] = stats["sum"] / stats["count"]
            stats["std"] = (
                sum((x - stats["mean"]) ** 2 for x in nums) / stats["count"]
            ) ** 0.5
            stats["min"] = min(nums)
            stats["max"] = max(nums)
        else:
            stats["count"] = len(vals)

    # std print output
    if types == ["print"]:
        print(f"\n<{title:=^80}>\n")
        if stats:
            print(stats)
        print("=" * 80)
        return

    # plot output
    import matplotlib.pyplot as plt  # pylint: disable=C0415

    plt.rcParams["font.sans-serif"] = [
        "SimHei",
        "Microsoft YaHei",
        "Arial Unicode MS",
    ]
    plt.rcParams["axes.unicode_minus"] = False

    n = len(types)
    fig, axes = plt.subplots(1, n, figsize=(5 * n, 4))
    if n == 1:
        axes = [axes]

    for ax, t in zip(axes, types):
        match t:
            case "hist":
                ax.hist(vals)
            case "bar":
                ax.bar(keys, vals)
            case "line":
                ax.plot(keys, vals, marker="o")
            case "box":
                ax.boxplot(vals)
            case "scatter":
                ax.scatter(keys, vals)
            case "pie":

                def pie_format(pct):
                    return f"{pct:.1f}%" if pct > 5 else ""

                ax.pie(vals, labels=keys, autopct=pie_format)
            case _:
                raise TypeError(f"this picture type is not supported: {t}")
        ax.grid(True, linestyle="--", alpha=0.5)

    if title:
        fig.suptitle(title)
    if stats:
        stat_str = f"count:{stats['count']}  sum:{stats['sum']}  mean:{stats['mean']:.2f}  std:{stats['std']:.2f}  min:{stats['min']:.2f}  max:{stats['max']:.2f}"
        fig.text(0.5, 0.01, stat_str, ha="center", fontsize=10)
    plt.show()


if __name__ == "__main__":
    show([1, 2, 2, 3, 4, 4, 4, 5], typ="hist,line,pie", title="example")
    show({"A": 10, "B": 20, "C": 15}, typ="bar,pie", key_func=str.upper, show_sum=True)
