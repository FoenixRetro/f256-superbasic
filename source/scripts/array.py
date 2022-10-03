# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		array.py
#		Purpose :	Array Test generator
#		Date :		3rd October 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,re,random
from simpletests import *
from assign import *

# *******************************************************************************************
#
#								Variable Classes
#
# *******************************************************************************************

class Array(IntegerVariable):

	def setup(self,parent):
		self.dimensions = [random.randint(2,6) for n in range(0,random.randint(1,2))]
		parent.handle.write("{0} dim {1}({2})\n".format(parent.nextLineNumber(),self.getName(),self.makeDimension(self.dimensions)))
		self.data = {}

	def updateValue(self):
		element = self.makeDimension([random.randint(0,self.dimensions[n]) for n in range(0,len(self.dimensions))])
		self.data[element] = self.getNewValue()
		return [self.getItemName(element),self.data[element]]

	def getItemName(self,element):
		return self.getName()+self.getTypeChar()+"("+element+")"

	def getTypeChar(self):
		return ""

	def makeDimension(self,d):
		return ",".join([str(x) for x in d])

	def defaultData(self):
		return 0 

	def getChecks(self):
		checks = []
		if len(self.dimensions) == 1:
			for x1 in range(0,self.dimensions[0]+1):
				e = self.makeDimension([x1])
				checks.append("assert {0} = {1}".format(self.getItemName(e),self.data[e] if e in self.data else self.defaultData()))
		else:
			for x1 in range(0,self.dimensions[0]+1):
				for x2 in range(0,self.dimensions[1]+1):
					e = self.makeDimension([x1,x2])
					checks.append("assert {0} = {1}".format(self.getItemName(e),self.data[e] if e in self.data else self.defaultData()))
		return checks

# *******************************************************************************************
#
#						Repeated assignments generator
#
# *******************************************************************************************

class ArrayOne(TestAssertion):
	def create(self,parent):
		v = parent.variables[random.randint(0,len(parent.variables)-1)]					# pick a variable
		return v.updateValue()
	def make(self,data):
		kwd = "let " if random.randint(0,1) == 0 else ""
		return "{2}{0} = {1}".format(data[0],data[1],kwd)

# *******************************************************************************************
#
#									Complete Test Set class
#
# *******************************************************************************************

class ArrayTestSet(AssignTestSet):

	def getFactoryList(self):
		return [ 			 															# list of test factory classes
			ArrayOne()
		]

	def startup(self):
		self.variables = [] 															# create variables, all initially zero or ""
		varCount = max(2,self.count // 5)
		for i in range(0,varCount):
			v = Array(i)
			self.variables.append(v)
			v.setup(self)
		return self

	def closedown(self):
		for v in self.variables:
			for c in v.getChecks():
				self.handle.write("{0} {1}\n".format(self.nextLineNumber(),c))
		return self

if __name__ == "__main__":
	t =ArrayTestSet()
	t.do(40)
	t.startup().create().closedown().terminate()

