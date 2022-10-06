# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		linetest.py
#		Purpose :	Line test code
#		Date :		6th October 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random,re
from tokens import *

# *******************************************************************************************
#
#						Create a stream of editable lines, some deletions
#
# *******************************************************************************************

startLine = random.randint(10,2000)
lineStep = random.randint(1,20)
testLines = 250
maxLineSize = 40


remToken = TokenCollection().getToken("REM").getID()

resultCode = {}
textEntry = []
for i in range(0,testLines):
	lineNumber = startLine+random.randint(0,testLines)*lineStep
	s = "{0}".format(lineNumber)
	if i % 2 == 0:
		s = s + " REM \"{0}\"".format("".join([chr(random.randint(65,90)) for x in range(0,random.randint(0,maxLineSize))]))
		resultCode[lineNumber] = s 
	else:
		if lineNumber in resultCode:
			del resultCode[lineNumber]
	textEntry.append(s)

textEntry.append("65000 call $FFFF")
#
#		Output the 'typed in'
#
h = open("storage/load.dat","w")
h.write("\n".join(textEntry))
h.close()
#
#		Create the 'tokenised and sorted' bytes
#
lines = [x for x in resultCode.keys()]
lines.sort()
code = []
for l in lines:
	m = re.match("^\\d+\\s*REM\\s*\\\"(.*)\\\"$",resultCode[l])
	assert m is not None
	data = m.group(1)
	code += [ len(data)+8,l & 0xFF,l >> 8,remToken,0xFF,len(data)+1] 
	code += [ ord(x) for x in data ]
	code += [ 0,0x80 ]
code += [0xC,0xE8,0xFD]
h = open("common/generated/linetest.bin","wb")
h.write(bytes(code))
h.close()

