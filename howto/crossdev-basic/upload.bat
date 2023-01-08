@echo off
rem
rem		Script for Linux to update F256Jr BASIC & Kernel
rem
python fnxmgr.zip --port COM3 --binary %1 --address 28000
