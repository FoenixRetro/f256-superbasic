# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		simpletests.py
#		Purpose :	Test generator
#		Date :		22nd September 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,re,random

# *******************************************************************************************
#
#					Base test class, provides support functions
#
# *******************************************************************************************

class TestAssertion(object):
	def shortInteger(self):
		if random.randint(0,1) == 0:
			return random.randint(-20,20)
		return random.randint(-2000,2000)

	def float(self):
		return random.randint(-40000000,40000000)/1000
		
	def smallFloat(self):
		return random.randint(-9000,9000)/1000

	def string(self,maxLen = 9):
		return "".join([chr(random.randint(97,117)) for x in range(0,random.randint(0,maxLen))])
		
	def str(self,n):
		return str(n) if n == int(n) else "{0:.7f}".format(n)

	def make(self,test):
		return "assert {0} = {1}".format(test[0],test[1])

	def toDisplay(self,v):
		return '"'+v+'"' if isinstance(v,str) else self.str(v)

# *******************************************************************************************
#
#							Integer mathematic/binary operation
#
# *******************************************************************************************

class IntegerMath(TestAssertion):
	def create(self,parent):
		n1 = self.shortInteger()
		n2 = self.shortInteger()
		opList = "+-*/%&|^"
		op = opList[random.randint(0,len(opList)-1)]
		if op == "%" or op == "|" or op == "&" or op == "^": 							# -ve makes no sense with these
			n1 = abs(n1)
			n2 = abs(n2)
		if (op == "*" and abs(n1)*abs(n2) > 0x7FFFFFF):	 								# multiply out of range
			return None
		if (op == "/" or op == "%") and n2 == 0:										# divide/modulus with zero
			return None 
		r = int(eval("{0}{1}{2}".format(n1,op,n2)))
		return ["({0}{1}{2})".format(n1,"\\" if op == "/" else op,n2),self.str(r)]

# *******************************************************************************************
#
#							Float mathematic/binary operation
#
# *******************************************************************************************

class FloatMath(TestAssertion):
	def create(self,parent):
		n1 = self.float()
		n2 = self.float()
		opList = "+-*"
		op = opList[random.randint(0,len(opList)-1)]
		if op == "/" and n2 == 0:				
			return None 
		r = eval("{0}{1}{2}".format(n1,op,n2))
		return ["({0}{1}{2})".format(n1,op,n2),self.str(r)]

# *******************************************************************************************
#
#								 Integer Comparison class
#
# *******************************************************************************************

class IntegerCompare(TestAssertion):
	def create(self,parent):
		n1 = self.shortInteger()
		n2 = self.shortInteger()
		op = [">","<","==",">=","<=","!="][random.randint(0,5)]							# pick a compare
		r = -1 if eval("{0}{1}{2}".format(n1,op,n2)) else 0
		return ["{0}{1}{2}".format(n1,op.replace("!=","<>").replace("==","="),n2),r] 	# do translated to BASIC

# *******************************************************************************************
#
#								 Float Comparison class
#
# *******************************************************************************************

class FloatCompare(TestAssertion):
	def create(self,parent):
		n1 = self.float()
		n2 = self.float()
		op = [">","<","==",">=","<=","!="][random.randint(0,5)]							# pick a compare
		r = -1 if eval("{0}{1}{2}".format(n1,op,n2)) else 0
		return ["({0}{1}{2})".format(n1,op.replace("!=","<>").replace("==","="),n2),r] 	# do translated to BASIC

# *******************************************************************************************
#
#								 String Comparison/Concat class
#
# *******************************************************************************************

class StringBinary(TestAssertion):
	def create(self,parent):
		s1 = self.string()
		s2 = self.string()
		if random.randint(0,2) > 0:
			op = [">","<","==",">=","<=","!="][random.randint(0,5)]						# pick a compare
			ev = '"{0}"{1}"{2}"'.format(s1,op,s2)
			r = -1 if eval(ev) else 0		
			return [ev.replace("!=","<>").replace("==","="),r] 							# do translated to BASIC
		else:
			return [ '"{0}"+"{1}"'.format(s1,s2),'"'+s1+s2+'"']

# *******************************************************************************************
#
#								 Unary functions returning numbers
#
# *******************************************************************************************

class UnaryNumber(TestAssertion):
	def create(self,parent):
		t1 = random.randint(0,10)
		n1 = self.shortInteger() if random.randint(0,1) == 0 else self.float()
		s1 = self.string()
		if t1 == 0:
			return [ "abs({0})".format(str(n1)),str(abs(n1))]
		elif t1 == 1:
			s = 0 if (n1 == 0) else (-1 if n1 < 0 else 1)
			return [ "sgn({0})".format(str(n1)),str(s)]
		elif t1 == 2:
			return [ "len(\"{0}\")".format(s1),str(len(s1))]
		elif t1 == 3:
			a = ord(s1[0]) if s1 != "" else 0
			return [ "asc(\"{0}\")".format(s1),str(a)]
		elif t1 == 4:
			s = int(abs(n1)) * (-1 if n1 < 0 else 1)
			return [ "int({0})".format(str(n1)),str(s)]
		elif t1 == 5:
			n1 = self.smallFloat()				# Precision is lost if you have 999999.322 say
			s = abs(n1)-int(abs(n1)) 
			return [ "frac({0})".format(str(n1)),self.str(s)]
		elif t1 == 6:
			n = 0 if random.randint(0,3) == 0 else self.shortInteger()
			return [ "not({0})".format(str(n)),str(0 if n != 0 else -1)]
		elif t1 == 7:
			return [ "val(\"{0}\")".format(self.str(n1)),self.str(n1)]
		elif t1 == 8:
			isString = random.randint(0,1) == 0
			isMin = random.randint(0,1) == 0
			cList = [s1 if isString else n1] 
			for i in range(1,random.randint(1,4)):
				cList.append(self.string() if isString else self.shortInteger() if random.randint(0,1) == 0 else self.float())
			result = self.toDisplay(min(cList) if isMin else max(cList))
			return [ "{0}({1})".format("min" if isMin else "max",",".join([self.toDisplay(x) for x in cList])),result ]
		else:
			return None

# *******************************************************************************************
#
#								 Unary functions returning strings
#
# *******************************************************************************************

class UnaryString(TestAssertion):
	def create(self,parent):
		t1 = random.randint(0,10)
		s1 = self.string()
		if t1 == 0:
			n1 = random.randint(35,126)
			return [ "chr$({0})".format(n1),'"{0}"'.format(chr(n1)) ]
		elif t1 == 1:
			n1 = random.randint(0,11)
			return [ "spc({0})".format(n1),'"{0}"'.format("            "[:n1]) ]
		elif t1 == 2:
			n1 = random.randint(0,len(s1)+2)
			return [ 'left$(\"{0}\",{1})'.format(s1,n1),'"'+s1[:n1]+'"']
		elif t1 == 3:
			n1 = random.randint(0,len(s1)+2)
			return [ 'right$(\"{0}\",{1})'.format(s1,n1),'"'+s1[max(0,len(s1)-n1):]+'"']
		elif t1 == 4:
			n1 = random.randint(1,len(s1)+1)
			l1 = random.randint(0,3)
			s = s1[n1-1:][:l1]
			return [ 'mid$(\"{0}\",{1},{2})'.format(s1,n1,l1),'"'+s+'"']
		elif t1 == 5:
			s = str(random.randint(-1000,1000))
			return [ 'str$({0})'.format(s),'"'+s+'"']
		elif t1 == 6:
			s = str(random.randint(-1000,1000))+"."+str(random.randint(1,9))
			return [ 'str$({0})'.format(s),'"'+s+'0000"']

		else:
			return None

# *******************************************************************************************
#
#								 Parenthesis check
#
# *******************************************************************************************

class Parenthesis(TestAssertion):

	def createExpression(self,level):
		if level == 0: 													# level 0 = single term.
			return str(random.randint(-10,10))
		elements = []
		for i in range(0,random.randint(1,3)):							# build a chain at this level.
			elements.append(self.createExpression(level-1))
			elements.append("+-*"[random.randint(0,2)])
		expr = " ".join(elements[:-1])
		return "("+expr+")"

	def create(self,parent):
		try:
			expr = self.createExpression(3)
			v = eval(expr)
			return [expr,v]
		except ValueError:
			return self.createValidExpression(level)

# *******************************************************************************************
#
#									Complete Test Set class
#
# *******************************************************************************************

class TestSet(object):

	def __init__(self,seed = None,handle = None):
		self.handle = handle if handle is not None else open("storage/load.dat","w")
		random.seed() 																	# randomise against clock
		self.seed = random.randint(1,99999) if seed is None else seed 					# pick a seed if not provided
		random.seed(self.seed)	
		self.factories = self.getFactoryList()
		self.lineNumber = 1
		self.step = 1
		self.count = 300
		sys.stderr.write("Seed = {0}\n".format(self.seed))

	def do(self,count):
		self.count = count 
		return self 

	def getCount(self):
		return self.count 

	def getFactoryList(self):
		return [ 			 															# list of test factory classes
			FloatCompare(),FloatMath(),
			IntegerCompare(),IntegerMath(),
			StringBinary(),UnaryNumber(),
			UnaryString(),Parenthesis()
		]

	def nextLineNumber(self):
		self.lineNumber += self.step
		return self.lineNumber-self.step

	def startup(self):
		return self

	def create(self):
		self.handle.write("{0} rem \"Seed {1}\"\n".format(self.lineNumber,self.seed))	# put the seed in the BASIC listing
		self.lineNumber += self.step
		for i in range(0,self.count):													# create tests
			factory = random.randint(0,len(self.factories)-1)							# pick a factory
			test = None 
			while test is None:															# get a legitimate test
				test = self.factories[factory].create(self)
			self.handle.write("{0} {1}\n".format(self.nextLineNumber(),self.factories[factory].make(test)))
		return self 

	def closedown(self):
		return self

	def terminate(self):
		self.handle.write("{0} call $ffff\n".format(self.nextLineNumber()))				# on emulator jmp $FFFF returns to OS
		for i in range(0,16): 															# high byte end line data.
			self.handle.write(chr(255))

if __name__ == "__main__":
	TestSet().startup().create().closedown().terminate()

