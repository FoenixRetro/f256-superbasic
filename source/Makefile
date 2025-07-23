# Makefile for F256 SuperBASIC

ifeq ($(OS),Windows_NT)
include ..\documents\common.make
else
include ../documents/common.make
endif
#
#		Current version
#
MAJOR_VERSION = 1
MINOR_VERSION = 1
VERSION ?= $(MAJOR_VERSION).$(MINOR_VERSION)

# Hardware platform: 0 = F256
HARDWARE = 0
# Hardware generation: 1 = J/K, 2 = J2/K2
HARDWARE_GEN ?= 1
LANGUAGE = en
DOLLAR = $$
ASFLAGS += -D HARDWARE=$(HARDWARE) -D HARDWARE_GEN=$(HARDWARE_GEN) \
			'-D MONITOR_ADDRESS=$(DOLLAR)$(LMONITOR)' '-D LOCKOUT_ADDRESS=$(DOLLAR)$(LLOCKOUT)' \
			'-D BASIC_ADDRESS=$(DOLLAR)$(LBASIC)' '-D SOURCE_ADDRESS=$(DOLLAR)$(LSOURCE)' \
			'-D SPRITE_ADDRESS=$(DOLLAR)$(LSPRITES)' '-D TILEMAP_ADDRESS=$(DOLLAR)$(LTILEMAP)' \
			'-D TILEIMAGES_ADDRESS=$(DOLLAR)$(LTILEIMAGES)' \
			-L $(BUILDDIR)debug$(S)basic.lst -l $(BUILDDIR)debug$(S)basic.lbl

MODULES = +hardware +graphics +tokeniser +sound +kernel
BUILD_OUT = $(BUILDDIR)basic.rom
SCRIPTDIR = scripts$(S)

all:  build

#
#		Update api.asm
#
updatekernel:
	$(call updatekernel,common$(S)api)
	@echo "Updated kernel"

#
#		Update bootscreen assets
#
updateassets:
	$(Q)$(MAKE) -B -C ..$(S)modules$(S)hardware$(S)header updateassets
	@echo "Updated bootscreen assets"

#
#		Create sprites
#
sprites:
	$(Q)$(MAKE) -B -C ..$(S)spritebuild
#
#		Build and download tools
#
tools: fnxmgr

#
#		Update FoenixMgr "binary"
#
fnxmgr:
	$(Q)$(CURL) -o $(BINDIR)fnxmgr.zip $(LDR_REPO)/raw/refs/heads/master/FoenixMgr.zip

#
#		Show various things
#
stack:
	$(Q)$(PYTHON) $(SCRIPTDIR)showstack.py

strings:
	$(Q)$(PYTHON) $(SCRIPTDIR)showstring.py

vars:
	$(Q)$(PYTHON) $(SCRIPTDIR)showvar.py

#
#		Regular build
#
build: ASFLAGS += -D AUTORUN=0
build: prelim
	$(call cleandir,$(BUILDDIR))
	$(call cleandir,$(BUILDDIR)debug$(S))

	@echo "Compiling assembly"
	$(Q)$(ASM) $(ASFLAGS) _basic.asm -o $(BUILD_OUT)

	@echo "Splitting ROM"
	$(Q)$(PYTHON) $(SCRIPTDIR)splitrom.py $(BUILDDIR)

#
#		Scripts run in advance generating tables etc.
#
prelim:
	@echo "Building submodules"
	$(Q)$(MAKE) -B -C ..$(S)modules

	@echo "Generating assembly sources"
	$(Q)$(PYTHON) $(SCRIPTDIR)errors.py $(LANGUAGE)
	$(Q)$(PYTHON) $(SCRIPTDIR)opcodes.py >common$(S)generated$(S)asmcore.asm
	$(Q)$(PYTHON) $(SCRIPTDIR)makebuild.py $(MODULES)
	$(Q)$(PYTHON) $(SCRIPTDIR)tokens.py
	$(Q)$(PYTHON) $(SCRIPTDIR)constants.py
	$(Q)$(PYTHON) $(SCRIPTDIR)version.py $(VERSION)

#
#		Print base version to console
#
baseversion:
	@: $(info $(MAJOR_VERSION).$(MINOR_VERSION))

#
#		Make sure a release with the current version does not already exist
#
versioncheck:
	@if [ -n "$$(git tag -l v$(VERSION))" ]; then \
		echo "Error: Tag v$(VERSION) already exists. Please bump the version before creating a release."; \
		exit 1; \
	fi

#
#		Create a versioned release
#
release: VERSION := $(shell $(PYTHON) $(SCRIPTDIR)version.py)
release: versioncheck
	@echo "Creating v$(VERSION), gen $(HARDWARE_GEN) release binaries"
	$(Q)$(MAKE) -C . build VERSION=$(VERSION)

	$(call cleandir,$(RELEASEDIR))
	$(call cleandir,$(RELEASEDIR)debug$(S))
	$(call cleandir,$(RELEASEDIR)syntax$(S))
	$(call cleandir,$(RELEASEDIR)manual$(S))

	@echo "Copying build artifacts"
	$(Q)$(CCOPY) $(BUILDDIR)*.* $(RELEASEDIR)
	$(Q)$(CCOPY) $(BUILDDIR)debug$(S)*.* $(RELEASEDIR)debug

	$(Q)$(CCOPY) ..$(S)reference$(S)source$(S)*.pdf $(RELEASEDIR)manual
	$(Q)$(CCOPY) ..$(S)documents$(S)superbasic.sublime-syntax $(RELEASEDIR)syntax

	$(Q)$(PYTHON) -c "with open('$(RELEASEDIR)VERSION', 'w') as f: f.write('$(VERSION)')"

	@echo "Done"

#
#		Run various tests.
#
test:
	$(PYTHON) $(SCRIPTDIR)simpletests.py

astest:
	$(PYTHON) $(SCRIPTDIR)assign.py

sastest:
	$(PYTHON) $(SCRIPTDIR)assign.py all

artest:
	$(PYTHON) $(SCRIPTDIR)array.py

benchmark:
	$(CCOPY) ..$(S)documents$(S)benchmarks$(S)bm$(ID).bas storage$(S)load.dat

paging:
	$(PYTHON) $(SCRIPTDIR)checkpaging.py
