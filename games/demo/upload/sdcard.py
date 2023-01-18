# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		sdcard.py
#		Purpose :	Create the files to upload
#		Date :		18th January 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,re,sys

stem = sys.argv[1].strip().lower() 																# header for all files.
ttyPort = None 																					# filled in while scanning
files = {}
nextID = 1
#
#		Search for the files. Get the size and work out where each is going to load to be autosaved.
#
loadTransfer = 0x10000
for s in open("files.lst").readlines():															# scan for files.
	if s.find("fnxmgr") >= 0:
		m = re.search("\\-\\-port\\s+(.*?)\\s*\\-\\-binary\\s*(.*?)\\-\\-address(.*?)\\s*$",s)
		assert m is not None,"Can't process fnxmgr command line"
		ttyPort = m.group(1).strip()															# remember tty port
		name = ".."+os.sep+m.group(2).strip()
		loadAddress = int(m.group(3).strip(),16)
		files[name] = { "file":name,"load":loadAddress,"isbasic":loadAddress == 0x28000} 		# basic information
		files[name]["size"] = os.path.getsize(name)  											# size of file to transfer
		files[name]["loadxfr"] = loadTransfer  													# where to load for transfer.
		files[name]["id"] = nextID 																# unique ID for file.
		nextID += 1
		loadTransfer = (loadTransfer + files[name]["size"] + 1024) & 0xFFFFFC00  				# make space for it
		loadTransfer += 512  																	# space incase it is the loader.
#
#		Create the new loader file, called <stem>.bas which is the basic file
#
h = open("{0}.bas".format(stem),"w")
line = 100
basicFile = None
for k in files.keys():
	f = files[k]
	if not f["isbasic"]: 																		# if a data file.
		fname = stem+str(f["id"])+".dat" 														# get its name <stem><id>,dat
		h.write("{0} print \"Loading {1}\"\n".format(line,fname)) 								# code to load it
		h.write("{0} bload \"{1}\",${2:06x}\n".format(line+10,fname,f["load"]))
		h.write("{0} print \"Loaded.\n".format(line+20))
		line += 50
	else:
		basicFile = f["file"] 																	# remember the actual basic source
		basickey = k
#
for s in open(basicFile,"r").readlines(): 														# append the basic source.
	h.write("{0}\n".format(s.strip()))
h.close()
#
files[basickey]["file"] = "{0}.bas".format(stem) 												# this is now the BASIC program to upload.
files[basickey]["size"] = os.path.getsize(files[basickey]["file"])								# update the length.
#
#		Create the Save program.
#
line = 100
h = open("save.bas","w")
for k in files.keys():
	target = stem+".bas" if files[k]["isbasic"] else stem+str(files[k]["id"])+".dat"
	h.write("{0} print \"Saving {1} as {2}\"\n".format(line,files[k]["file"],target))
	h.write("{0} bsave \"{1}\",${2:05x},{3}\n".format(line+10,target,files[k]["loadxfr"],files[k]["size"]))
	h.write("{0} print \"Saved.\"\n".format(line+20))
	line += 100
h.write("{0}{0}{0}\n".format(chr(255)))
h.close()
#
# 		Create the upload script.
#
h = open("upload.sh","w")
for k in files.keys():
	h.write("python fnxmgr.zip --port {0} --binary {1} --address {2:06x}\n".format(ttyPort,files[k]["file"],files[k]["loadxfr"]))
h.write("python fnxmgr.zip --port {0} --binary save.bas --address 28000\n".format(ttyPort))
h.close()
		

