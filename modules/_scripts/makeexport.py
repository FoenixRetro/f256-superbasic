# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		makeexport.py
#		Purpose :	Make the export file.
#		Date :		27th November 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,re

exports = {}
exports["hardware"] = 	[ "EXTPrintCharacter","EXTInitialise","EXTInputSingleCharacter","EXTBreakCheck","EXTReadController","EXTInputLine" ]
exports["graphics"] = 	[ "GXGraphicDraw" ]
exports["sound"] = 		[ "SNDCommand","SNDUpdate"]
exports["tokeniser"] = 	[ "TKListConvertLine","TKTokeniseLine" ]

for module in exports.keys():
	print("\t.if {0}Integrated == 1".format(module))
	for routine in exports[module]:
		print("{0}:".format(routine))
		print("\tjmp\tExport_{0}".format(routine))
	print("\t.endif")




