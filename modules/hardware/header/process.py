"""Convert boot screen files into assembly data.

Converts boot screen assets (character sets, attributes, palette) into
RLE-compressed assembly data for the header display.

RLE Format:
    $FF <byte> <count>     repeat
    $FF 00                 end
"""

import sys
from pathlib import Path
from typing import TextIO


def main(*, build_dir: Path, assets_dir: Path) -> None:
    """Generate assembly header data file from boot screen assets."""
    rle_marker = 255
    height = 14
    width = 80

    if not build_dir.exists():
        build_dir.mkdir(parents=True, exist_ok=True)

    output_path = build_dir / "headerdata.dat"

    with open(output_path, "w", encoding="utf-8") as out:
        out.write(";\n;\tAutomatically generated.\n;\n")
        out.write("\t.section code\n\n")

        out.write(f"Header_Height = {height}\n\n")
        out.write(f"Header_RLE = {rle_marker}\n\n")

        # Process binary assets
        for asset in ["jattrs", "jchars", "kattrs", "kchars"]:
            out.write(f"Header_{asset}:\n")
            data = process_binary_file(
                assets_dir / f"{asset}.bin",
                height=height,
                width=width,
                rle_marker=rle_marker,
            )

            out.write("\t.byte\t{0}\n\n".format(",".join([str(x) for x in data])))  # noqa: UP030

        # Process palette
        out.write("Header_Palette:\n")
        process_palette_file(assets_dir / "palette.hex", out)

        out.write("\t.send code\n\n")


def rle_compress(b: list[int], *, marker: int) -> list[int]:
    """Compress a list of bytes using RLE with a specified marker."""
    r: list[int] = []
    while len(b) != 0:
        assert b[0] != marker, f"Compress marker {b[0]} not allowed"

        if len(b) > 3 and b[0] == b[1] and b[1] == b[2]:
            c = 0
            while c < 250 and c + 1 < len(b) and b[0] == b[c + 1]:
                c += 1
            r.append(marker)
            r.append(b[0])
            r.append(c)
            b = b[c:]
        else:
            r.append(b[0])
            b = b[1:]
    r.append(marker)
    r.append(0)
    return r


def process_binary_file(
    filepath: Path, *, rle_marker: int, height: int, width: int
) -> list[int]:
    """Process a binary asset file and return RLE-compressed data."""
    with open(filepath, "rb") as f:
        data = f.read()

    # Convert to list and truncate to screen size
    src = list(data)[: height * width]
    return rle_compress(src, marker=rle_marker)


def process_palette_file(filepath: Path, out: TextIO) -> None:
    """Process palette hex file."""
    with open(filepath, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                out.write(f"\t.dword ${line}\n")


if __name__ == "__main__":
    main(
        build_dir=Path(sys.argv[1] if len(sys.argv) > 1 else ".build"),
        assets_dir=Path(sys.argv[2] if len(sys.argv) > 2 else "assets"),
    )
