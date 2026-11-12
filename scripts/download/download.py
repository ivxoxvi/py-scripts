import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))
from util.rw_file import rfile

DOWNLOAD_URLS_FILE = "download_urls.txt"
DOWNLOAD_DIR = "downloads"


def download(url: str, dest: Path, chunk_size: int = 8192) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    # for atomic download
    tmp = dest.with_suffix(dest.suffix + ".tmp")

    req = urllib.request.Request(url, headers={"User-Agent": "python-urllib"})
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            total = resp.getheader("content-length")
            total_size = int(total) if total is not None else -1
            received = 0

            with tmp.open("wb") as f:
                while chunk := resp.read(chunk_size):
                    f.write(chunk)
                    received += len(chunk)
                    if total_size <= 0:
                        sys.stdout.write(f"\r已接收 {received / 1024:.1f} KB")
                    else:
                        pct = min(100.0, received * 100 / total_size)
                        sys.stdout.write(f"\r{pct:6.2f}%  {dest.name}")
                    sys.stdout.flush()

        os.rename(tmp, dest)
        sys.stdout.write("\r" + " " * 60 + "\r")
        sys.stdout.flush()

    except urllib.error.HTTPError as e:
        print(f"\n❌ HTTP {e.code}: {url}", file=sys.stderr)
        tmp.unlink(missing_ok=True)
        raise
    except urllib.error.URLError as e:
        print(f"\n❌ 网络错误 {url}: {e.reason}", file=sys.stderr)
        tmp.unlink(missing_ok=True)
        raise
    except OSError as e:
        print(f"\n❌ 文件写入失败 {dest}: {e}", file=sys.stderr)
        tmp.unlink(missing_ok=True)
        raise
    except ValueError as _e:
        print(f"\n❌ URL 非法: {url}", file=sys.stderr)
        tmp.unlink(missing_ok=True)
        raise


def gen_save_path(row: list[str], idx: int) -> Path:
    """
    生成文件保存路径
    """
    filename: str | None = None
    if len(row) > 1 and row[1].strip():
        filename = row[1].strip()
    else:
        filename = urllib.parse.unquote(row[0].split("/")[-1].split("?")[0])
        
    if not filename:
        filename = f"download-{idx}"

    counter = 1

    save_path = Path(__file__).resolve().parent / Path(DOWNLOAD_DIR) / filename
    stem, suffix = save_path.stem, save_path.suffix
    while save_path.exists():
        save_path = save_path.with_name(f"{stem}({counter}){suffix}")
        counter += 1
    return save_path


# Usage:
# download_urls.txt:
# url1 filename1
# url2 filename2
# ...
if __name__ == "__main__":
    download_entrys = [
        url.strip()
        for url in rfile(DOWNLOAD_URLS_FILE, typ="list")
        if not url.startswith("# ") and url.strip()
    ]

    for idx, entry in enumerate(download_entrys):
        row = entry.split(" ")
        save_path = gen_save_path(row, idx)
        download(row[0], save_path)

    # TODO: 改为工作窃取的多线程下载
