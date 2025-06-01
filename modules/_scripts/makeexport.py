"""Generate module entry points.

Reads exported function names from `.exports` files in the build directory
and generates corresponding entry points. If paging is enabled, includes
the necessary assembly code to handle memory bank switching.

Outputs the entry points code to standard output.
"""

import sys
from pathlib import Path


def main(*, build_dir: Path) -> None:
    """Generate module entry points and write to standard output."""
    exports = read_exports(build_dir)
    paging = True

    print(f"PagingEnabled = {1 if paging else 0}")

    for module in exports:
        print(f"\t.if {module}Integrated == 1")
        for routine in exports[module]:
            print(f"{routine}:")
            if paging:
                print("\tinc 8+5")
                print(f"\tjsr\tExport_{routine}")
                print("\tphp")
                print("\tdec 8+5")
                print("\tplp")
                print("\trts")
            else:
                print(f"\tjmp\tExport_{routine}")

        print("\t.endif")


def read_exports(build_dir: Path) -> dict[str, list[str]]:
    """Read all `.exports` files from the build directory."""
    all_exports: dict[str, list[str]] = {}

    if not build_dir.exists():
        return all_exports

    # Find all .exports files in the build directory
    for file_path in build_dir.glob("*.exports"):
        if module_exports := read_module_exports(file_path):
            module_name = file_path.stem  # filename without extension
            module_exports.sort()
            all_exports[module_name] = module_exports

    return all_exports


def read_module_exports(file_path: Path) -> list[str]:
    """Read exported function names from a single `.exports` file."""
    module_exports: list[str] = []

    with open(file_path, encoding="utf-8") as f:
        for line in f:
            export_name = line.strip()
            if export_name:
                module_exports.append(export_name)

    return module_exports


if __name__ == "__main__":
    main(build_dir=Path(sys.argv[1] if len(sys.argv) > 1 else ".build"))
