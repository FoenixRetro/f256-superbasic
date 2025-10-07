## 1.1.2025-10-06

### Features

- `at` modifier for `print` ([`5bd1cf7`](https://github.com/FoenixRetro/f256-superbasic/commit/5bd1cf7a900e8717b1adb75df3ccea221976698b))
- `screen`/`screen$` support ([`b72c90a`](https://github.com/FoenixRetro/f256-superbasic/commit/b72c90a9b576bd7e2d0456eb1d7f6069c4f278d7))
- Display 2x core status on bootscreens ([`feed0e8`](https://github.com/FoenixRetro/f256-superbasic/commit/feed0e8e17615325ab0ca0d20d4427daac089242))

### Bug fixes

- Have DIR return normally, not breaking program flow, and report free blocks ([`2b7bd5c`](https://github.com/FoenixRetro/f256-superbasic/commit/2b7bd5c112f1ffab43b30745265935ec177593d2))
- `print at 59, 79; "*";` scrolls up the screen ([`ab9e000`](https://github.com/FoenixRetro/f256-superbasic/commit/ab9e000b1d88313a5cfbbf06a52aa81947dc3996))
- [**BREAKING**] Remove apostrophe-as-line-separator feature ([`54aa8e9`](https://github.com/FoenixRetro/f256-superbasic/commit/54aa8e982496664cb8ce5ca6ab545810f07f09b4))

### Performance

- Speedup disc operations ([`6cf6ce1`](https://github.com/FoenixRetro/f256-superbasic/commit/6cf6ce1a3a6730ebbbd08e75d0f40df6c83b3040))

### Under the hood

- README fixes, MAME testing instructions ([`1c43a28`](https://github.com/FoenixRetro/f256-superbasic/commit/1c43a289f675d8a896b1d961d731d6f13ceed8da))
- Automate module exports, remove temp build artifacts ([`730a55f`](https://github.com/FoenixRetro/f256-superbasic/commit/730a55f3b17e3353a8fa3afa3ec4b007473c336f))
- Comment up various `print`-related routines ([`142d33d`](https://github.com/FoenixRetro/f256-superbasic/commit/142d33d3ad277f68ae3653433737a8492c15f48e))
- Enable line ending normalization ([`c21ae79`](https://github.com/FoenixRetro/f256-superbasic/commit/c21ae7969b28cedaec8b829a5d52aa3ae68a9dac))
- Support for gen 2 builds ([`78e6ad2`](https://github.com/FoenixRetro/f256-superbasic/commit/78e6ad2b920ea65d6d69f91e4f6a7bf4c6cb51e0))
- Bring build/release Makefiles up-to-date with repo changes etc. ([`55b78c5`](https://github.com/FoenixRetro/f256-superbasic/commit/55b78c51e5299f1774b46cb5b7b8114b257a89ba))
- "Prepare release PR" Github workflow ([`1d5cd79`](https://github.com/FoenixRetro/f256-superbasic/commit/1d5cd796d6b9375e894d5f83e2785300ff86b275))
- Rework build & release procedure + repository cleanup ([`f6736ca`](https://github.com/FoenixRetro/f256-superbasic/commit/f6736ca1b0cc4a1e38b8da406cd38a3eeedd30d4))
- Add Contributing section ([`f2d07a7`](https://github.com/FoenixRetro/f256-superbasic/commit/f2d07a7979be463bfc383b07cb93b811a33a19c9))
- Support variable-height boostscreen rendering ([`b1c38a1`](https://github.com/FoenixRetro/f256-superbasic/commit/b1c38a18314984b03560c7dc1d6a6bf0bbd4b899))


