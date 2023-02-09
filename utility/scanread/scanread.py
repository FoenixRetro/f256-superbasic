# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		scanread.py
#		Purpose :	Show unreviewed files, decreasing creation order.
#		Date :		17th November 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

from PIL import Image
import os,sys,re

def formatDate(s):
	s = str(s)
	return "{0}/{1}/{2}".format(s[6:],s[4:6],s[:4])

def getDate(file,stem):
	review = [x.lower() for x in open(file).readlines() if x.lower().find(stem) >= 0]

	if len(review) == 0:
		if f.find("/generated/") < 0:
			assert False,"Bad file "+file
		return -1

	match = "^\\;\\s*{0}\\s*\\:\\s*(.*)\\s*$".format(stem)
	m = re.match(match,review[0])
	assert m is not None,"No match "+review[0]+" "+match+" "+file
	date = m.group(1).lower()
	date = "" if date == "no" or date == "no." else date
	if date != "":
		date = date.replace("january","1").replace("february","2").replace("march","3").replace("april","4")
		date = date.replace("may","5").replace("june","6").replace("july","7").replace("august","8")
		date = date.replace("september","9").replace("october","10").replace("november","11").replace("december","12")
		date = date.replace("th","").replace("st","").replace("nd","").replace("rd","")
		m = re.match("^\\s*(\\d+)\\s*(\\d+)\\s*(\\d+)\\s*$",date.strip())
		assert m is not None,"Bad date "+date+" "+file
		return int("{0:04}{1:02}{2:02}".format(int(m.group(3)),int(m.group(2)),int(m.group(1))))
	return 0

sourceList = {}
for root,dirs,files in os.walk("source"):
	for f in files:
		if (f.endswith(".inc") or f.endswith(".asm")) and not f.startswith("_") and f != "api.asm":
			sourceList[root+os.sep+f] = { "date": None }

for root,dirs,files in os.walk("modules"):
	for f in files:
		if (f.endswith(".inc") or f.endswith(".asm")) and not f.startswith("_") and f != "api.asm":
			if f != "headerdata.asm":
				sourceList[root+os.sep+f] = { "date": None }

revCount = 0
toCount = 0
unReviewed = {}
for f in sourceList.keys():
	revDate = getDate(f,"reviewed")
	crDate = getDate(f,"created")
	if revDate == 0:
		unReviewed[f] = crDate
		toCount += 1
	if revDate > 0:
		revCount += 1


urKeys = [x for x in unReviewed.keys()]
urKeys.sort(key = lambda x:-unReviewed[x])

for k in urKeys:
	print(formatDate(unReviewed[k]),"",k)

perCent = int(revCount / (toCount+revCount) * 100+0.5)
print("\nReviewed {0} Remaining {1} : {2}% complete".format(revCount,toCount,perCent))