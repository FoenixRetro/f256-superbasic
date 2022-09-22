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
		return random.randint(1,20)
	def str(self,n):
		return str(n)

class IntegerMath(TestAssertion):
	def create(self):
		n1 = self.shortInteger()
		n2 = self.shortInteger()
		op = "+"
		r = eval("{0}{1}{2}".format(n1,op,n2))	
		if (op == "\\" or op == "%") and n2 == 0:
			return None 
		return ["{0}{1}{2}".format(n1,op,n2),self.str(r)]

class TestSet(object):
	def __init__(self,seed = None):
		random.seed()
		self.seed = random.randint(0,99999) if seed is None else seed
		random.seed(self.seed)
		self.factories = [IntegerMath()]
		self.lineNumber = 1000

	def create(self,handle,count = 10):
		for i in range(0,count):
			factory = random.randint(0,len(self.factories)-1)
			test = None 
			while test is None:
				test = self.factories[factory].create()
			handle.write("{0} assert {1} = {2}\n".format(self.lineNumber,test[0],test[1]))				
			self.lineNumber += 10
		handle.write("{0} call #ffff\n".format(self.lineNumber))
if __name__ == "__main__":
	TestSet().create(sys.stdout)

