# ************************************************************************************************
# ************************************************************************************************
#
#		Name:		Makefile
#		Purpose:	Main make file
#		Created:	18th September 2022
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ************************************************************************************************
# ************************************************************************************************

ifeq ($(OS),Windows_NT)
include ..\documents\common.make
else
include ../documents/common.make
endif

ASMOPTS = -q -b -Wall -c -L output$(S)basic.lst -l output$(S)basic.lbl -Wall
APPNAME = basic.rom
SCRIPTDIR = scripts$(S)
LANGUAGE = en

EMSRC = $(EMU_REPO)$(S)emulator
EMUCODE = $(EMSRC)$(S)src $(EMSRC)$(S)include $(EMSRC)$(S)framework $(EMSRC)$(S)6502 $(EMSRC)$(S)roms

SOURCES = emulator/framework/main.cpp emulator/framework/gfx.cpp emulator/framework/debugger.cpp \
		  emulator/src/sys_processor.cpp emulator/src/sys_debug_uk101.cpp emulator/src/hardware.cpp emulator/src/hw_fifo.cpp
DEFINES = -D EMSCRIPTEN -D LINUX -D NO_DEBUGGER -DINCLUDE_OS_SUPPORT
EMFLAGS = -I. -I emulator/framework -I emulator//cpu -I emulator/include -I emulator -O2 -s USE_SDL=2 -s WASM=1 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS='["png"]'
COMPILE = emcc $(SOURCES) $(DEFINES) $(CADDRESSES) $(EMFLAGS) -o f256.html
LOADERS = python makeloader.py $(CADDRESSES)

all: build

build: pull build1
	make -C ../source basic
	$(CCOPY) utility$(S)dummy* loading
	make -C ../source basic
	$(CCOPY) ../source/build/basic.rom loading/basic.basic
	$(LOADERS)
	$(COMPILE)

pull:
	cd $(EMU_REPO) && git diff --quiet || (echo "Error: Emulator repository has uncommitted changes" && exit 1)
	cd $(EMU_REPO) && git diff --cached --quiet || (echo "Error: Emulator repository has staged changes" && exit 1)
	cd $(EMU_REPO) && git switch main
	cd $(EMU_REPO) && git pull

build1:
	$(CCOPY) -R $(EMUCODE) emulator
	$(CDEL) loading$(S)*.*

server:
	python -m http.server 8000
