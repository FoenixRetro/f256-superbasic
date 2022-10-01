# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		showstack.py
#		Purpose :	Show the stack at memory.dump
#		Date :		23rd September 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,re

class LabelStore(object):
	def __init__(self):
		self.labels = {}
		for s in open("output/basic.lbl").readlines():
			m = re.match("^(.*?)\\s*\\=\\s*(.*?)\\s*$",s)
			assert m is not None," ??? "+s
			s = m.group(2).strip()
			self.labels[m.group(1).lower()] = int(s[1:],16) if s.startswith("$") else int(s)
	#
	def get(self,lbl):
		return self.labels[lbl.strip().lower()]

if __name__ == "__main__":
	ls = LabelStore()
	mem = [x for x in open("memory.dump","rb").read(-1)]
	stackAt = ls.get("NSStatus")
	stackSize = ls.get("MathStackSize")

	for i in range(0,stackSize):
		status = mem[stackAt+i]
		mantissa = mem[stackAt+i+1*stackSize]
		mantissa += (mem[stackAt+i+2*stackSize] << 8)
		mantissa += (mem[stackAt+i+3*stackSize] << 16)
		mantissa += (mem[stackAt+i+4*stackSize] << 24)
		exponent = mem[stackAt+i+5*stackSize]

		val = str(mantissa)
		if (status & 0x08) != 0:
			e = exponent if exponent < 128 else exponent-256
			val = str(mantissa * pow(2,e))+"f"
		if (status & 0x80) != 0:
			val = "-"+val
		print("L:{0} M:{1:08x} E:{2:02x} S:{3:02x} = {4}".format(i,mantissa,exponent,status,val))
