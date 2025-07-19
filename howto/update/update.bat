@echo off
rem
rem		Script for Windows ito update F256Jr BASIC & Kernel
rem
python fnxmgr.zip --port COM3 --flash-bulk bulk.csv
python fnxmgr.zip --port COM3 --boot flash 
