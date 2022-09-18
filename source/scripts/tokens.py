# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		tokens.py
#		Purpose :	Raw token data
#		Date :		18th September 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,re

# *******************************************************************************************
#
#								Raw token source class
#
# *******************************************************************************************

class TokenSource(object):
	def get(self):
		return """
			{+}							// Shift up
				while
				if
				repeat
				for
				proc
			{-} 						// Shift down
				wend
				endif
				until
				next
				endproc
			{u} 						// Unary functions
				abs( 		asc( 		chr$( 		alloc(		page		dec( 		
				hex$( 		left$( 		mid$( 		right$( 	rnd( 		sgn( 		
				spc( 		str$( 		val(  		isval(		getdate$( 	gettime$( 	
				not			len( 		int( 		

			{0}							// Set 0
				cls 		data 		dim 		let 		goto		gosub 		
				return 		print		rem  		then 		to			read

			{1}							// Set 1
				end 		new 		list 		run 		stop		assert 		
				clear 		restore

"""		

# *******************************************************************************************
#
#										Token Classes
#
# *******************************************************************************************

class Token(object):
	def __init__(self,name,set):
		self.name = name.upper().strip()
		self.set = set 
		self.id = None
	#
	def sortKey(self):
		return "9"+str(self.set)+self.name
	#
	def getName(self):
		return self.name 
	def getSet(self):
		return self.set 
	def getID(self):
		return self.id 
	def setID(self,id):
		self.id = id

class CtrlToken(Token):
	def sortKey(self):
		return "0"+str(self.set)+self.name

class UnaryToken(Token):
	def __init__(self,name):
		Token.__init__(self,name,0)
	def sortKey(self):
		return "3"+self.name 

class StructureToken(Token):
	def __init__(self,name,adjust):
		Token.__init__(self,name,0)
		self.adjustment = adjust 
	def sortKey(self):
		return ("1" if self.adjustment > 0 else "2")+self.name  

# *******************************************************************************************
#
#									Token Collection
#
# *******************************************************************************************

class TokenCollection(object):
	def __init__(self):
		self.tokens = {}  																# name -> object
		self.tokenList = [] 															# sorted list of objects
		for i in range(0,3):
			self.addToken("!0:EOF"+str(i),CtrlToken("!0:EOF",i)) 						# add EOF/Shift tokens
			self.addToken("!1:SH1"+str(i),CtrlToken("!1:SH1",i))
			self.addToken("!2:SH2"+str(i),CtrlToken("!2:SH2",i))
		self.loadTokens()
		self.allocateIDs() 																# allocate IDs.
	#
	#		Load tokens in
	#
	def loadTokens(self):
		s = TokenSource().get().upper().replace("\t"," ").split("\n") 					# get source into lines no tabs
		s = [x if x.find("//") < 0 else x[:x.find("//")] for x in s]					# remove comments
		cClass = "0"
		for w in " ".join(s).split():													# convert into list.
			if w.startswith("{") and w.endswith("}"):
				cClass = w[1:-1] 
			else:
				if cClass == "+" or cClass == "-":										# Adjuster / structure
					newToken = StructureToken(w,1 if cClass == "+" else -1)
				elif cClass == "U": 													# Unary function
					newToken = UnaryToken(w)
				else: 																	# The rest
					newToken = Token(w,int(cClass))
				self.addToken(w,newToken)
		self.tokenList.sort(key = lambda x:x.sortKey())									# sort into the correct order
	#
	#		Add a token
	#
	def addToken(self,w,newToken):
		assert w not in self.tokens,"Duplicate token "+w  								# only once
		self.tokens[w] = newToken 														# set up array/dictionary
		self.tokenList.append(newToken)
	#
	#		Allocate Token IDs
	#
	def allocateIDs(self):
		self.nextFreeID = [128,128,128]
		for t in self.tokenList:
			s = t.getSet()			
			t.setID(self.nextFreeID[s])
			self.nextFreeID[s] += 1
	#
	#		Dump a token group , text and constants.
	#
	def dumpGroup(self,set,textHandle,constHandle):
		textHandle.write("KeywordSet{0}:\n".format(set))
		for t in self.tokenList:
			if t.getSet() == set:
				hash = sum([ord(x) for x in t.getName()]) & 0xFF
				name = "" if t.getName().startswith("!") else t.getName()
				textHandle.write("\t.text\t{0},${1:02x},{2:16} ; ${3:02x} {4}\n".format(len(name),hash,'"'+name+'"',t.getID(),t.getName()))
				if t.getID() >= 131:
					constHandle.write("KWD_{0:32} = ${1:02x}; ${1:02x} {2}\n".format(self.processName(t.getName()),t.getID(),t.getName()))
		textHandle.write("\t.text\t$FF\n")
	#
	#		Process Name to remove control characters if any.
	#
	def processName(self,s):
		return s.replace("!","PLING").replace("$","DOLLAR").replace(":","COLON").replace("(","LPAREN")

if __name__ == "__main__":
	t = TokenCollection()
	h1 = open("generated/kwdtext.dat","w")
	h2 = open("generated/kwdconst.inc","w")
	for i in range(0,3):
		t.dumpGroup(i,h1,h2)
	h1.close()
	h2.close()