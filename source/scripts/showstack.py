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

class MemoryDump(object):
	def __init__(self):
		self.mem = [x for x in open("memory.dump","rb").read(-1)]
	def read(self,addr):
		return self.mem[addr]
	def readWord(self,addr):
		return self.read(addr)+(self.read(addr+1) << 8)
	def readLong(self,addr):
		return self.readWord(addr)+(self.readWord(addr+2) << 16)
	def readString(self,p):
		val = ""
		while self.read(p) != 0:
			val += chr(self.read(p))
			p += 1
		return val 

	def decode(self,mantissa,exponent,status):
		if (status & 0x10) != 0:
			val = '"'+self.readString(mantissa & 0xFFFF)+'"' if (mantissa & 0xFFFF) != 0 else '""'
		else:
			val = str(mantissa)
			if (status & 0x08) != 0:
				e = exponent if exponent < 128 else exponent-256
				val = "{0}f".format(round(mantissa * pow(2,e),3))
			if (status & 0x80) != 0:
				val = "-"+val
		return val 

if __name__ == "__main__":
	ls = LabelStore()
	md = MemoryDump()

	stackAt = ls.get("NSStatus")
	stackSize = ls.get("MathStackSize")

	for i in range(0,stackSize):
		status = md.read(stackAt+i)
		mantissa = md.read(stackAt+i+1*stackSize)
		mantissa += (md.read(stackAt+i+2*stackSize) << 8)
		mantissa += (md.read(stackAt+i+3*stackSize) << 16)
		mantissa += (md.read(stackAt+i+4*stackSize) << 24)
		exponent = md.read(stackAt+i+5*stackSize)

		print("L:{0} M:{1:08x} E:{2:02x} S:{3:02x} = {4}".format(i,mantissa,exponent,status,md.decode(mantissa,exponent,status)))
