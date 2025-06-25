# F256 Header Data Generator
#
# This makefile copies boot screen assets from the Foenix F256 bootscreens
# repository and processes them into header data for the SuperBASIC interpreter.
# The generated data includes character sets, color attributes, and palettes
# for both F256Jr and F256K systems.
#
# Dependencies:
#   - https://github.com/WartyMN/Foenix-F256JR-bootscreens repository,
#     assumed to be cloned side-by-side with the `f256-superbasic` repo

ifeq ($(OS),Windows_NT)
include ..\..\..\documents\common.make
else
include ../../../documents/common.make
endif

ASSETS_SRC_DIR = ..$(S)..$(S)..$(S)..$(S)Foenix-F256JR-bootscreens
ASSETS_DIR = assets
BUILD_DIR = .build

all:	jattrs.bin jchars.bin \
		j2attrs.bin j2chars.bin \
		kattrs.bin kchars.bin \
		k2attrs.bin k2chars.bin \
		palette.hex
	python process.py $(BUILD_DIR) $(ASSETS_DIR)

# F256Jr boot screen assets
jattrs.bin: $(ASSETS_SRC_DIR)$(S)f256jr_boot_attrs.bin
	$(CCOPY) $^ $(ASSETS_DIR)$(S)$@

jchars.bin: $(ASSETS_SRC_DIR)$(S)f256jr2_boot_chars.bin
	$(CCOPY) $^ $(ASSETS_DIR)$(S)$@

# F256Jr2 boot screen assets
j2attrs.bin: $(ASSETS_SRC_DIR)$(S)f256jr2_boot_attrs.bin
	$(CCOPY) $^ $(ASSETS_DIR)$(S)$@

j2chars.bin: $(ASSETS_SRC_DIR)$(S)f256jr2_boot_chars.bin
	$(CCOPY) $^ $(ASSETS_DIR)$(S)$@

# F256K boot screen assets
kattrs.bin: $(ASSETS_SRC_DIR)$(S)f256k_boot_attrs.bin
	$(CCOPY) $^ $(ASSETS_DIR)$(S)$@

kchars.bin: $(ASSETS_SRC_DIR)$(S)f256k_boot_chars.bin
	$(CCOPY) $^ $(ASSETS_DIR)$(S)$@

# F256K2 boot screen assets
k2attrs.bin: $(ASSETS_SRC_DIR)$(S)f256k2_boot_attrs.bin
	$(CCOPY) $^ $(ASSETS_DIR)$(S)$@

k2chars.bin: $(ASSETS_SRC_DIR)$(S)f256k2_boot_chars.bin
	$(CCOPY) $^ $(ASSETS_DIR)$(S)$@

# Standard text palette
palette.hex: $(ASSETS_SRC_DIR)$(S)f256jr_std_text_palette.hex
	$(CCOPY) $^ $(ASSETS_DIR)$(S)$@

clean:
	$(CDEL) $(ASSETS_DIR)$(S)*.*
	$(CDEL) $(BUILD_DIR)$(S)*.*

.PHONY: all clean
