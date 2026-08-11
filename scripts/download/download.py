#!/usr/bin/env python3
import sys
import urllib.request
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor

sys.path.append(str(Path(__file__).parent.parent))
from util.rw_file import rfile, wfile


DOWNLOAD_URL_FILE = "download_urls.txt"
DOWNLOAD_DIR = "downloads"


def download(url: str, dest: Path):
    """
    下载文件
    """

    def _progress(block_num, block_size, total_size):
        if total_size <= 0:
            sys.stdout.write(f"\r已接收 {block_num * block_size / 1024:.1f} KB")
        else:
            percent = min(100, 100 * block_num * block_size / total_size)
            sys.stdout.write(f"\r{percent:6.2f}%  {dest.name}")
        sys.stdout.flush()

    dest.parent.mkdir(parents=True, exist_ok=True)
    try:
        urllib.request.urlretrieve(url, dest, _progress)
    except Exception as e:
        print(f"\n❌ {url}失败:", e, file=sys.stderr)


def generate_save_path(args: tuple, idx: int) -> Path:
    """
    生成文件保存路径
    """
    filename = None
    if len(args) > 1 and args[1].strip():
        filename = args[1].strip()

    filename = urllib.parse.unquote(args[0].split("/")[-1].split("?")[0])
    if not filename:
        filename = f"download-{idx}"

    counter = 1
    save_path = Path(__file__).resolve().parent / Path(DOWNLOAD_DIR) / filename
    stem, suffix = save_path.stem, save_path.suffix
    while save_path.exists():
        save_path = save_path.with_name(f"{stem}({counter}){suffix}")
        counter += 1
    return save_path


download_entrys = [
    url.strip()
    for url in rfile(DOWNLOAD_URL_FILE, typ="list")
    if not url.startswith("# ") and url.strip()
]

for idx, entry in enumerate(download_entrys):
    args = tuple(entry.split(" "))

    save_path = generate_save_path(args, idx)
    download(args[0], save_path)

# TODO: 改为工作窃取的多线程下载
