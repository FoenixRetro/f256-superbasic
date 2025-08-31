# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "pyfatfs",
#     "setuptools==80.4.0",
# ]
# ///

from pyfatfs import PyFat, PyFatFS
from pathlib import Path
import struct

TESTS_DIR = Path(__file__).parent.resolve()
WORKING_DIR = TESTS_DIR / ".output"

MBR_SIZE = 512
DEFAULT_OFFSET_SECTORS = 2048  # 1 MiB alignment


def create_fat32_image(*, disk_image_path: Path, size_mb: int=64, label: str) -> None:
    size_bytes = size_mb * 1024 * 1024
    with open(disk_image_path, "wb") as file_handle:
        file_handle.seek(size_bytes - 1)
        file_handle.write(b"\0")

    fat_file = PyFat.PyFat()
    try:
        fat_file.mkfs(disk_image_path, size=size_bytes, fat_type=PyFat.PyFat.FAT_TYPE_FAT32, label=label)
    except Exception as exception:
        raise RuntimeError(f"Error initializing FAT filesystem", exception)
    finally:
        fat_file.close()


def read_bpb_fields(vbr: bytes):
    """
    Extract key FAT32 BPB fields from the Volume Boot Record (sector 0 of a super-floppy).
    Offsets follow Microsoft FAT32 BPB layout.
    """
    if len(vbr) < 90:
        raise ValueError("Boot sector too short")

    bytes_per_sector = struct.unpack_from("<H", vbr, 0x0B)[0]
    sectors_per_cluster = vbr[0x0D]
    reserved_sector_count = struct.unpack_from("<H", vbr, 0x0E)[0]
    num_fats = vbr[0x10]
    totsec16 = struct.unpack_from("<H", vbr, 0x13)[0]
    media = vbr[0x15]
    fatsz16 = struct.unpack_from("<H", vbr, 0x16)[0]
    sectors_per_track = struct.unpack_from("<H", vbr, 0x18)[0]
    num_heads = struct.unpack_from("<H", vbr, 0x1A)[0]
    hidden_sectors = struct.unpack_from("<I", vbr, 0x1C)[0]
    totsec32 = struct.unpack_from("<I", vbr, 0x20)[0]
    fatsz32 = struct.unpack_from("<I", vbr, 0x24)[0]

    # basic sanity checks
    if bytes_per_sector not in (512, 1024, 2048, 4096):
        raise ValueError(f"Unexpected bytes/sector: {bytes_per_sector}")

    if totsec16 != 0 and totsec32 != 0:
        # FAT spec: one of these is zero; for FAT32 typically totsec16==0.
        pass

    total_sectors = totsec32 if totsec16 == 0 else totsec16
    if total_sectors == 0:
        raise ValueError("Invalid FAT BPB: total sectors is 0")

    return {
        "bytes_per_sector": bytes_per_sector,
        "sectors_per_cluster": sectors_per_cluster,
        "reserved_sector_count": reserved_sector_count,
        "num_fats": num_fats,
        "fatsz_sectors": fatsz32 if fatsz16 == 0 else fatsz16,
        "media": media,
        "sectors_per_track": sectors_per_track,
        "num_heads": num_heads,
        "hidden_sectors": hidden_sectors,
        "total_sectors": total_sectors,
    }


def build_mbr(*, part_lba_start: int, part_sectors: int) -> bytes:
    """
    Create a minimal MBR with a single partition entry of type 0x0C (FAT32 LBA).
    CHS fields are set to 0xFE/0xFF/0xFF to avoid BIOS CHS math; OSes use LBA.
    """
    mbr = bytearray(MBR_SIZE)

    # partition entry at 0x1BE (first of four 16-byte entries)
    entry = bytearray(16)
    entry[0] = 0x00                                     # status (0x80 would mark "active", optional)
    entry[1:4] = b"\xFE\xFF\xFF"                        # CHS start (dummy)
    entry[4] = 0x0C                                     # partition type (FAT32 LBA)
    entry[5:8] = b"\xFE\xFF\xFF"                        # CHS end (dummy)
    struct.pack_into("<I", entry, 8, part_lba_start)    # LBA start
    struct.pack_into("<I", entry, 12, part_sectors)     # sectors in partition
    mbr[0x1BE:0x1BE+16] = entry

    # signature
    mbr[510] = 0x55
    mbr[511] = 0xAA

    return bytes(mbr)


def patch_hidden_sectors(*, vbr: bytes, hidden: int) -> bytes:
    """
    Return a copy of the VBR with BPB_HiddenSectors (offset 0x1C) set to `hidden`.
    """
    vbr2 = bytearray(vbr)
    struct.pack_into("<I", vbr2, 0x1C, hidden)
    return bytes(vbr2)


def create_mbr_image(*, src_image_path: Path, dst_image_path: Path, offset_sectors: int=DEFAULT_OFFSET_SECTORS):
    raw = src_image_path.read_bytes()
    if len(raw) < 512:
        raise RuntimeError("Input image too small (need at least 512 bytes)")

    vbr = raw[:512]
    bpb = read_bpb_fields(vbr)
    bps = bpb["bytes_per_sector"]

    if len(raw) % bps != 0:
        raise RuntimeError(f"Input size {len(raw)} not multiple of bytes/sector {bps}")

    fs_total_sectors = len(raw) // bps
    # prefer BPB-reported size if available (sanity check)
    if bpb["total_sectors"] not in (0, fs_total_sectors):
        # warn but proceed with the actual file length
        print(f"Warning: BPB total_sectors={bpb['total_sectors']} != file_sectors={fs_total_sectors}; using file length.")

    part_start = offset_sectors
    part_sectors = fs_total_sectors

    # build MBR
    mbr = build_mbr(part_lba_start=part_start, part_sectors=part_sectors)

    # patch VBR HiddenSectors to the partition offset
    vbr_patched = patch_hidden_sectors(vbr=vbr, hidden=part_start)

    # reassemble filesystem image with patched VBR
    fs_patched = vbr_patched + raw[512:]

    # compose output disk image: [MBR][zeros ... up to offset][patched filesystem]
    out_size_bytes = (part_start + part_sectors) * bps
    out = bytearray(out_size_bytes)
    out[:MBR_SIZE] = mbr
    out[part_start * bps : part_start * bps + len(fs_patched)] = fs_patched

    dst_image_path.write_bytes(bytes(out))


def copy_dir(*, fat_handle: PyFatFS.PyFatFS, source_dir: Path, target_dir: str) -> None:
    for src in source_dir.iterdir():
        dst = str(Path(target_dir) / src.name)

        if src.is_dir():
            fat_handle.makedir(dst)
            copy_dir(fat_handle=fat_handle, source_dir=src, target_dir=dst)
        elif src.is_file():
            with open(src, "rb") as src_file:
                fat_handle.create(dst)
                with fat_handle.open(dst, "wb") as dst_file:
                    dst_file.write(src_file.read())


def main(*, test_dir: str):
    src_image_path = WORKING_DIR / "tests-src.img"
    src_image_path.parent.mkdir(parents=True, exist_ok=True)

    create_fat32_image(disk_image_path=src_image_path, size_mb=64, label="TESTS")

    fat_handle = PyFatFS.PyFatFS(src_image_path)
    try:
        copy_dir(
            fat_handle=fat_handle,
            source_dir=TESTS_DIR / test_dir,
            target_dir="/",
        )
    finally:
        fat_handle.close()

    dst_image_path = WORKING_DIR / "tests.img"
    create_mbr_image(src_image_path=src_image_path, dst_image_path=dst_image_path)
    src_image_path.unlink()


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Prepare disk image with the specified set of tests")
    parser.add_argument("-t", "--test-dir", help=f"Test dir'", required=True, type=str)
    main(**vars(parser.parse_args()))
