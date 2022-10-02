# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		assign.py
#		Purpose :	Test generator
#		Date :		22nd September 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,re,random
from simpletests import *

# *******************************************************************************************
#
#								Variable Classes
#
# *******************************************************************************************

class Variable:
	def __init__(self,index):
		self.name = "".join([ chr(random.randint(0,25)+97)+str(random.randint(0,9)) for x in range(1,random.randint(2,4))])+"_"+str(index)
		if index < 20 and random.randint(0,3) == 0:
			self.name = chr(index+65)
		self.value = 0

	def setup(self):
		pass
	def getName(self):
		return self.name 
	def getValue(self):
		return self.value 
	def updateValue(self):
		newValue = self.getNewValue()
		self.value = newValue 
		return [self.getName(),self.getValue()]
	def getChecks(self):
		return ["assert {0} = {1}".format(self.getName(),self.getValue())]

class IntegerVariable(Variable):
	def getNewValue(self):
		return str(random.randint(-444444444,444444444))

class FloatVariable(Variable):
	def getName(self):
		return Variable.getName(self)+"#"
	def getNewValue(self):
		return str(random.randint(-444444444,444444444)/1000)

class StringVariable(Variable):
	def __init__(self,index):
		Variable.__init__(self,index)
		self.value = '""'
	def getName(self):
		return Variable.getName(self)+"$"
	def getNewValue(self):
		txt = "".join([chr(random.randint(0,25)+65) for x in range(1,random.randint(0,24))])
		return '"'+txt+'"'


# *******************************************************************************************
#
#						Repeated assignments generator
#
# *******************************************************************************************

class AssignOne(TestAssertion):
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

class AssignTestSet(TestSet):

	def getFactoryList(self):
		return [ 			 															# list of test factory classes
			AssignOne()
		]

	def startup(self):
		self.variables = [] 															# create variables, all initially zero or ""
		varCount = max(2,self.count // 3)
		for i in range(0,varCount):
			if i%3 == 0 or t.allStrings:
				v = StringVariable(i)
			elif i%3 == 1:
				v = IntegerVariable(i)
			elif i%3 == 2:
				v = FloatVariable(i)
			self.variables.append(v)
			v.setup()
		return self

	def closedown(self):
		for v in self.variables:
			for c in v.getChecks():
				self.handle.write("{0} {1}\n".format(self.nextLineNumber(),c))
		return self

if __name__ == "__main__":
	t =AssignTestSet()
	t.allStrings = False
	if len(sys.argv) == 2:
		t.allStrings = True
		t.do(200)
	t.startup().create().closedown().terminate()

