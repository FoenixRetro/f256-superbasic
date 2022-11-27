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

splitPoint = None 

branches = {} 

for s in open("output/basic.lst").readlines():
	if s.find("StartModuleCode:") > 0:
		splitPoint = int(s[1:5],16)
	if s.find("jsr") > 0 or s.find("jmp") > 0:
			s = s.replace("jmp","jsr").strip().lower()
			if s.find("jsr (") < 0 and s.find("assemble_jsr") < 0:
				if s.find(";") >= 0:
					s = s[:s.find(";")].strip()
				m = re.match("^\\.([0-9a-f]+).*?jsr\\s\\$([0-9a-f]+).*jsr\\s*(.*?)\\s*$",s)
				assert m is not None,"Can't process "+s
				addr = int(m.group(1),16)
				assert addr not in branches,"Duplicate address ? {0:04x}".format(addr)
				branches[addr] = { "target":int(m.group(2),16),"label":m.group(3).strip() }

addresses = [x for x in branches.keys()]
addresses.sort()

print("Split point at ${0:04x}\n".format(splitPoint))		

linkRoutines = {}
backCount = 0

print("Routines called from Paged code:")
for a in addresses:
	target = branches[a]["target"]
	label = branches[a]["label"]

	if a < splitPoint: 															# In the main code - check calling
		if target >= splitPoint:
			if label not in linkRoutines:
				linkRoutines[label] = []
			linkRoutines[label].append(a)

	if a >= splitPoint: 														# In the paging - called back to main.		
		if target < splitPoint:
			print("\tAt ${0:04x} call to ${1:04x} [{2}]".format(a,target,label))
			backCount += 1
		if label in linkRoutines:
			print("\t{0} is called by export function at ${1:04x}".format(label,a))
print()

print("Routines called in Paged Code")
lk = [x for x in linkRoutines.keys()]
lk.sort()
for l in lk:
	print("\t{0:32} called {1} times.".format(l,len(linkRoutines[l])))
print()

if backCount > 0:
	print("**** WARNING {0} BACK CALLS ****".format(backCount))