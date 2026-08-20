from pathlib import Path

ROOT = r"/Users/vxoxvx/Downloads/spring框架/spring/gc2048-2"

root = Path(ROOT)
files = [entry for entry in root.iterdir() if entry.is_file()]

index = 0
for file in files:
    if not file.is_file():
        continue
    if file.name.startswith("."):
        continue
    file.rename(file.parent / f"{root.name}-{index}{file.suffix}")
    index += 1
