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

paging = True

exports = {}
exports["hardware"] = 	[ "EXTPrintCharacter","EXTPrintNoControl","EXTInitialise"]
exports["graphics"] = 	[ "GXGraphicDraw" ]
exports["sound"] = 		[ "SNDCommand","SNDUpdate"]
exports["tokeniser"] = 	[ "TKListConvertLine","TKTokeniseLine","TKInitialise" ]

print("PagingEnabled = {0}".format(1 if paging else 0))

for module in exports.keys():
	print("\t.if {0}Integrated == 1".format(module))
	for routine in exports[module]:
		print("{0}:".format(routine))
		if paging:
			print("\tinc 8+5")
			print("\tjsr\tExport_{0}".format(routine))
			print("\tphp")
			print("\tdec 8+5")
			print("\tplp")
			print("\trts")
		else:
			print("\tjmp\tExport_{0}".format(routine))

	print("\t.endif")




