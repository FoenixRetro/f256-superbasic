@echo off
rem
rem		Script for Linux to update F256Jr BASIC & Kernel
rem
python fnxmgr.zip --port COM4 --flash-bulk bulk.csv
python fnxmgr.zip --port COM4 --boot flash 
