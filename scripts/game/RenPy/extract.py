import sys
from pathlib import Path

from unrpa import UnRPA

sys.path.append(str(Path(__file__).parent.parent.parent))
from util.rw_file import caller_dir

ROOT = "/Users/vxoxvx/Downloads/goodluke_thegame-1/goodluke_thegame.app/Contents/Resources/autorun/game/audio.rpa"
OUTPUT = str(caller_dir() / "output" / "resources")

unrpaer = UnRPA(
    filename=ROOT,
    path=OUTPUT,
    mkdir=True,
    verbosity=1,
    continue_on_error=False,
)


unrpaer.list_files()
print()
unrpaer.extract_files()
