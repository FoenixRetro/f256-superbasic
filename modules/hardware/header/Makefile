# F256 Header Data Generator
#
# This makefile manages boot screen assets for the SuperBASIC interpreter.
# Use the `updateassets` target to download the latest assets from the Foenix
# F256 bootscreens repository, and `all` to process them into header data.
#
# Generated data includes character sets, color attributes, and palettes
# for F256Jr, F256Jr2, F256K, and F256K2 systems.

ifeq ($(OS),Windows_NT)
include ..\..\..\documents\common.make
else
include ../../../documents/common.make
endif

ASSETS_BASE_URL = $(ASSETS_REPO)/raw/refs/heads/main/
ASSETS_DIR = assets
BUILD_DIR = .build

all:
	$(Q)$(PYTHON) process.py $(BUILD_DIR) $(ASSETS_DIR)

updateassets:	jattrs.bin jchars.bin \
				j2attrs.bin j2chars.bin \
				kattrs.bin kchars.bin \
				k2attrs.bin k2chars.bin \
				palette.hex

# F256Jr boot screen assets
jattrs.bin:
	$(Q)$(CURL) -o $(ASSETS_DIR)$(S)$@ $(ASSETS_BASE_URL)f256jr_boot_attrs.bin

jchars.bin:
	$(Q)$(CURL) -o $(ASSETS_DIR)$(S)$@ $(ASSETS_BASE_URL)f256jr_boot_chars.bin

# F256Jr2 boot screen assets
j2attrs.bin:
	$(Q)$(CURL) -o $(ASSETS_DIR)$(S)$@ $(ASSETS_BASE_URL)f256jr2_boot_attrs.bin

j2chars.bin:
	$(Q)$(CURL) -o $(ASSETS_DIR)$(S)$@ $(ASSETS_BASE_URL)f256jr2_boot_chars.bin

# F256K boot screen assets
kattrs.bin:
	$(Q)$(CURL) -o $(ASSETS_DIR)$(S)$@ $(ASSETS_BASE_URL)f256k_boot_attrs.bin

kchars.bin:
	$(Q)$(CURL) -o $(ASSETS_DIR)$(S)$@ $(ASSETS_BASE_URL)f256k_boot_chars.bin

# F256K2 boot screen assets
k2attrs.bin:
	$(Q)$(CURL) -o $(ASSETS_DIR)$(S)$@ $(ASSETS_BASE_URL)f256k2_boot_attrs.bin

k2chars.bin:
	$(Q)$(CURL) -o $(ASSETS_DIR)$(S)$@ $(ASSETS_BASE_URL)f256k2_boot_chars.bin

# Standard text palette
palette.hex:
	$(Q)$(CURL) -o $(ASSETS_DIR)$(S)$@ $(ASSETS_BASE_URL)f256jr_std_text_palette.hex

clean:
	$(Q)$(CDEL) $(BUILD_DIR)$(S)*.*

.PHONY: all clean
