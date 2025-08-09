# Split the SuperBASIC ROM file into 8192-byte binary chunks

import sys
from pathlib import Path


PAGE_SIZE = 8192  # size of each page in bytes


def main(*, build_dir: Path):
    with open(build_dir / "basic.rom", "rb") as f:
        code = list(f.read())

    pages = int((len(code) + PAGE_SIZE - 1) / PAGE_SIZE)  # how many pages
    while len(code) < PAGE_SIZE * pages:  # pad out
        code.append(0xFF)

    for p in range(1, pages + 1):  # output binary slices
        chunk = code[(p - 1) * PAGE_SIZE : (p - 0) * PAGE_SIZE]  # binary chunk
        with open(build_dir / "sb{0:02x}.bin".format(p), "wb") as out:
            out.write(bytes(chunk))


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python splitrom.py <build_dir>")
        sys.exit(1)

    main(
        build_dir=Path(sys.argv[1]),
    )
