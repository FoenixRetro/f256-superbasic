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

	def string(self,maxLen = 6):
		return "".join([chr(random.randint(97,117)) for x in range(0,random.randint(0,maxLen))])
		
	def str(self,n):
		return str(n) if n == int(n) else "{0:.7f}".format(n)

# *******************************************************************************************
#
#							Integer mathematic/binary operation
#
# *******************************************************************************************

class IntegerMath(TestAssertion):
	def create(self):
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
	def create(self):
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
	def create(self):
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
	def create(self):
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
	def create(self):
		s1 = self.string()
		s2 = self.string()
		op = [">","<","==",">=","<=","!="][random.randint(0,5)]							# pick a compare
		ev = '"{0}"{1}"{2}"'.format(s1,op,s2)
		r = -1 if eval(ev) else 0		
		return [ev.replace("!=","<>").replace("==","="),r] 								# do translated to BASIC

# *******************************************************************************************
#
#								 Unary functions returning numbers
#
# *******************************************************************************************

class UnaryNumber(TestAssertion):
	def create(self):
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
		else:
			return None

# *******************************************************************************************
#
#									Complete Test Set class
#
# *******************************************************************************************

class TestSet(object):
	def __init__(self,seed = None):
		random.seed() 																	# randomise against clock
		self.seed = random.randint(1,99999) if seed is None else seed 					# pick a seed if not provided
		random.seed(self.seed)	
		self.factories = [ 	 															# list of test factory classes
							#FloatCompare(),FloatMath(),
							#IntegerCompare(),IntegerMath(),
							#StringBinary()
							UnaryNumber()
		]
		self.lineNumber = 1
		self.step = 1
		sys.stderr.write("Seed = {0}\n".format(self.seed))

	def create(self,handle,count = 140):
		handle.write("{0} rem \"Seed {1}\"\n".format(self.lineNumber,self.seed))		# put the seed in the BASIC listing
		self.lineNumber += self.step
		for i in range(0,count):														# create tests
			factory = random.randint(0,len(self.factories)-1)							# pick a factory
			test = None 
			while test is None:															# get a legitimate test
				test = self.factories[factory].create()
			handle.write("{0} assert {1} = {2}\n".format(self.lineNumber,test[0],test[1]))				
			self.lineNumber += self.step
		handle.write("{0} call #ffff\n".format(self.lineNumber))						# on emulator jmp $FFFF returns to OS
		for i in range(0,16):
			handle.write(chr(255))

if __name__ == "__main__":
	h = open("storage/load.dat","w")
	TestSet().create(h)
	h.close()

