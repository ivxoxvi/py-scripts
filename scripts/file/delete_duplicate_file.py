from pathlib import Path
import re
import shutil

dir_path = Path("/Users/vxoxvx/Downloads/血十字")


def findAllDup(dir_path: Path) -> list[Path]:
    if not dir_path.is_dir():
        return []

    count = 0
    orignal_paths = {}
    delete: list[Path] = []
    for p in dir_path.rglob("*"):
        count += 1
        file_size = p.stat().st_size
        pstr = str(p)

        m = re.search(r"(.*)(\(\d+\))(\..*)?$", pstr)
        # if match duplicate file name pattern
        if m:
            origin_path = m.group(1) + (m.group(3) or "")
            if origin_path in orignal_paths and file_size == Path(orignal_paths[origin_path]).stat().st_size:
                delete.append(pstr)
            else:
                orignal_paths[origin_path] = pstr
        else:
            if pstr in orignal_paths and  file_size == Path(orignal_paths[pstr]).stat().st_size:
                delete.append(orignal_paths[pstr])
            else:
                orignal_paths[pstr] = pstr

    for d in delete:
        dp = Path(d)
        if dp.is_dir():
            shutil.rmtree(dp)
        else:
            dp.unlink()


findAllDup(dir_path)

# p = "/Users/vxoxvx/Downloads/血十字/xsz43部汉化高清/血十字pdf汉化/12.零号病人(1).pdf"
# m = re.search(r"(.*)(\(\d+\))(\..*)?$", p)
# if m:
#     print(m.group(0))
#     print(m.group(1))
#     print(m.group(2))
#     print(m.group(3))
#     print(m.group(1) + (m.group(3) or ""))
