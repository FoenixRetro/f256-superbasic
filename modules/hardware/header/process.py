"""Convert boot screen files into assembly data.

Converts boot screen assets (character sets, attributes, palette) into
RLE-compressed assembly data for the header display.

RLE Format:
    $FF <byte> <count>     repeat
    $FF 00                 end
"""

import sys
from pathlib import Path
from typing import Callable, TextIO


def main(*, build_dir: Path, assets_dir: Path) -> None:
    """Generate assembly header data file from boot screen assets."""
    rle_marker = 255
    min_height = 14
    header_offset = 4
    width = 80

    if not build_dir.exists():
        build_dir.mkdir(parents=True, exist_ok=True)

    output_path = build_dir / "headerdata.dat"

    with open(output_path, "w", encoding="utf-8") as out:
        out.write(";\n;\tAutomatically generated.\n;\n")
        out.write("\t.section code\n\n")

        out.write(f"Header_RLE = {rle_marker}\n\n")
        out.write(f"Header_info_offset = {header_offset}\n\n")

        asset_types = ["attrs", "chars"]

        def asset_name(machine: str, asset_type: str) -> str:
            return f"{machine}{asset_type}"

        # Process binary assets
        for machine in ["j", "k", "j2", "k2"]:
            heights = {}
            for asset_type in asset_types:
                asset = asset_name(machine, asset_type)
                with open(assets_dir / f"{asset}.bin", "rb") as f:
                    data = f.read()

                height = get_header_height(
                    data=data,
                    width=width,
                    min_height=min_height,
                    is_blank=is_blank_attr if asset_type == "attrs" else is_blank_char,
                )

                heights[asset_type] = height

                out.write(f"Asset_{asset}_height = {height}\n")
                out.write(f"Asset_{asset}:\n")
                data = compress_header(
                    data,
                    height=height,
                    width=width,
                    rle_marker=rle_marker,
                )

                out.write("\t.byte\t{0}\n\n".format(",".join([str(x) for x in data])))  # noqa: UP030

            if heights["attrs"] != heights["chars"]:
                raise ValueError(
                    f"Mismatched {machine} header dimensions: "
                    f"attrs height={heights['attrs']} vs chars height={heights['chars']}"
                )

        def write_asset_aliases(*, machines: list[str]):
            for machine in machines:
                for asset_type in asset_types:
                    alias = asset_name(machine[0:1], asset_type)
                    asset = asset_name(machine, asset_type)
                    out.write(f"\tHeader_{alias} = Asset_{asset}\n")
                    if asset_type == "chars":
                        out.write(
                            f"\tHeader_{machine[0:1]}info_line = Asset_{asset}_height - Header_info_offset\n"
                        )

        out.write(".if HARDWARE_GEN == 1\n")
        write_asset_aliases(machines=["j", "k"])
        out.write(".else\n")
        write_asset_aliases(machines=["j2", "k2"])
        out.write(".endif\n\n")

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


def get_header_height(
    *, data: bytes, width: int, min_height: int, is_blank: Callable[[int], bool]
) -> int:
    """Some headers may be taller than the minimum height. Determine the actual height
    by finding the last non-empty line beyond the minimum height."""

    def is_empty_line(*, height: int) -> bool:
        start = height * width
        end = start + width
        return all(is_blank(x) for x in data[start:end])

    height = min_height
    while not is_empty_line(height=height) and (height + 1) * width <= len(data):
        height += 1
    return height


def is_blank_attr(byte: int) -> bool:
    return byte == 0xF2 or byte == 0x12


def is_blank_char(byte: int) -> bool:
    return byte == 0x20


def compress_header(
    data: bytes, *, rle_marker: int, height: int, width: int
) -> list[int]:
    """Process a binary asset file and returns a list of RLE-compressed data."""
    # Convert to list and truncate to header size
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
