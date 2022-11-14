# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		errors.py
#		Purpose :	Build the error files
#		Date :		20th September 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys
eText = []
errors = open("common/errors/text/errors."+sys.argv[1],"r").readlines()
errors = [x.replace("\t"," ").strip() for x in errors if not x.startswith("#") and x.strip() != ""]

note = ";\n;\tThis is automatically generated.\n;\n"
h1 = open("common/generated/errors.inc","w")
h2 = open("common/generated/errors.asm","w")
h1.write(note)
h2.write(note)
h2.write(".section code\n")
for i in range(0,len(errors)):
	e = [x.strip() for x in errors[i].split(":")]
	if e[0].startswith("!"):
		e[0] = e[0][1:]
		h2.write("{0}Error:\n\t.error_{1}\n".format(e[0],e[0].lower()))	
	h1.write("ERRID_{0} = {1}\n".format(e[0].upper(),i+1))
	h1.write("error_{0} .macro\n\tlda\t#{1}\n\tjmp\tErrorHandler\n\t.endm\n".format(e[0].lower(),str(i+1)))
	eText.append(e[1])
h2.write("ErrorText:\n")
h2.write("\n".join(['\t.text\t"{0}",0'.format(x) for x in eText]))
h2.write("\n.send code\n")
h1.close()
h2.close()