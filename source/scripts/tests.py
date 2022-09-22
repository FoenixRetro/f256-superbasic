# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		tests.py
#		Purpose :	Test generator
#		Date :		22nd September 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,re,random

class TestAssertion(object):
	def shortInteger(self):
		if random.randint(0,1) == 0:
			return random.randint(-20,20)
		return random.randint(-2000,2000)

	def str(self,n):
		return str(n)

class IntegerMath(TestAssertion):
	def create(self):
		n1 = self.shortInteger()
		n2 = self.shortInteger()
		opList = "+-*/%&|^"
		op = opList[random.randint(0,len(opList)-1)]
		if op == "%" or op == "|" or op == "&" or op == "^":
			n1 = abs(n1)
			n2 = abs(n2)
		if (op == "*" and abs(n1)*abs(n2) > 0x7FFFFFF):
			return None
		if (op == "/" or op == "%") and n2 == 0:
			return None 
		r = int(eval("{0}{1}{2}".format(n1,op,n2)))
		return ["({0}{1}{2})".format(n1,"\\" if op == "/" else op,n2),self.str(r)]

class TestSet(object):
	def __init__(self,seed = None):
		random.seed()
		self.seed = random.randint(0,99999) if seed is None else seed
		random.seed(self.seed)
		self.factories = [IntegerMath()]
		self.lineNumber = 1
		sys.stderr.write("Seed = {0}\n".format(self.seed))

	def create(self,handle,count = 500):
		for i in range(0,count):
			factory = random.randint(0,len(self.factories)-1)
			test = None 
			while test is None:
				test = self.factories[factory].create()
			handle.write("{0} assert {1} = {2}\n".format(self.lineNumber,test[0],test[1]))				
			self.lineNumber += 1
		handle.write("{0} call #ffff\n".format(self.lineNumber))

if __name__ == "__main__":
	TestSet().create(sys.stdout)

