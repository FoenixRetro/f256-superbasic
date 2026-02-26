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

    # Map module page number to MMU slot increments from slot 5 default (N+2):
    #   page 1 (sb04 = N+3): 1 increment past default
    #   page 2 (sb05 = N+4): 2 increments past default
    page_to_incs = {1: 1, 2: 2}

    for module in exports:
        page = exports[module]["page"]
        routines = exports[module]["routines"]
        module_name = exports[module]["name"]
        incs = page_to_incs[page]
        print(f"\t.if {module_name}Integrated == 1")
        for routine in routines:
            print(f"{routine}:")
            if paging:
                for _ in range(incs):
                    print("\tinc 8+5")
                print(f"\tjsr\tExport_{routine}")
                print("\tphp")
                for _ in range(incs):
                    print("\tdec 8+5")
                print("\tplp")
                print("\trts")
            else:
                print(f"\tjmp\tExport_{routine}")

        print("\t.endif")


def read_exports(build_dir: Path) -> dict[str, dict]:
    """Read all `.exports` files from the build directory.

    Files named `<module>_p2.exports` are treated as page 2 exports
    (requiring double inc/dec 8+5). All others are page 1.
    """
    all_exports: dict[str, dict] = {}

    if not build_dir.exists():
        return all_exports

    # Find all .exports files in the build directory
    for file_path in build_dir.glob("*.exports"):
        if module_exports := read_module_exports(file_path):
            stem = file_path.stem  # filename without extension
            if stem.endswith("_p2"):
                module_name = stem[:-3]  # strip _p2 suffix
                page = 2
            else:
                module_name = stem
                page = 1
            module_exports.sort()
            all_exports[stem] = {
                "name": module_name,
                "page": page,
                "routines": module_exports,
            }

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
