# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		checkpaging.py
#		Purpose :	Analyse the listing to see what functions are into paging and 
#					checking for back links
#		Date :		26th November 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,re

calls = {} 																		# calls from given address 
labels = {} 																	# label addresses.

def location(s):
	return 0 if s < 0xC000 else 1

for s in open("output/basic.lst").readlines():
	if s.find("jsr") > 0 or s.find("jmp") > 0:
			s = s.replace("jmp","jsr").strip().lower()
			if s.find("jsr (") < 0 and s.find("assemble_jsr") < 0:
				if s.find(";") >= 0:
					s = s[:s.find(";")].strip()
				m = re.match("^\\.([0-9a-f]+).*?jsr\\s\\$([0-9a-f]+).*jsr\\s*(.*?)\\s*$",s)
				assert m is not None,"Can't process "+s
				addr = int(m.group(1),16)
				assert addr not in calls,"Duplicate address ? {0:04x}".format(addr)
				calls[addr] = m.group(3).lower()
	if s.find(":") > 0:
		m = re.match("^\\.([0-9a-f]+).*\\s([a-z0-9A-Z_]+)\\:",s)
		if m is not None:
			labels[m.group(2).strip().lower()] = int(m.group(1),16)

backCount = 0

print("Routines called cross page:")
for c in calls:
	aSource = c 
	sTarget = calls[c]
	if not (sTarget.startswith("$") or sTarget.startswith("kernel.")):
		aTarget = labels[sTarget]
		if location(aTarget) != location(aSource):
			isExport = sTarget.startswith("export_") and aSource < 0xC000
			if not isExport:
				print("At ${0:04x} a reference to ${1:04x} [{2}] is cross page".format(aSource,aTarget,sTarget))
				backCount += 1

if backCount > 0:
	print("**** WARNING {0} BACK CALLS ****".format(backCount))