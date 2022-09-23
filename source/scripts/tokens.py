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
				not			len( 		int( 		true 		false	

			{0}							// Set 0
				cls 		data 		dim 		let 		goto		gosub 		
				return 		print		rem  		then 		to			read
				call
			{1}							// Set 1
				end 		new 		list 		run 		stop				
				clear 		restore 	assert

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
		self.label = None
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
	def getLabel(self):
		return self.label
	#
	def setID(self,id):
		self.id = id
	def setLabel(self,label):
		self.label = label

class PunctuationToken(Token):
	def __init__(self,name):
		Token.__init__(self,name,-1)
		self.precedence = 0
	def getPrecedence(self):
		return self.precedence
	def sortKey(self):
		return "P"+self.name 
	def setPrecedence(self,p):
		self.precedence = p 

class CtrlToken(Token):
	def sortKey(self):
		return "0"+str(self.set)+self.name

class UnaryToken(Token):
	def __init__(self,name):
		Token.__init__(self,name,0)
	def sortKey(self):
		return "1"+self.name 

class StructureToken(Token):
	def __init__(self,name,adjust):
		Token.__init__(self,name,0)
		self.adjustment = adjust 
	def sortKey(self):
		return ("2" if self.adjustment > 0 else "3")+self.name  
	def getAdjustment(self):
		return self.adjustment

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
		self.createPunctuationTokens() 													# create punctuation tokens
		self.scanSource()																# look for code
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
	#		Create all punctuation tokens.
	#
	def createPunctuationTokens(self):
		tokens = [ None ] * 64 															# tokens go here.
		for i in range(32,64): 															# standard
			tokens[i] = chr(i)
		for i in range(0,2): 															# double
			for j in range(0,3):
				tokens[i*4+j] = "<>"[i]+"<=>"[j]
		for i in range(64,128):															
			c = chr(i).upper()
			if c < 'A' or c > 'Z':
				tokens[((i & 0x20) >> 2) | (i & 7) | 0x10] = c
		for i in range(0,64):															# create all the punctuation tokens.
			newToken = PunctuationToken(tokens[i] if tokens[i] is not None else "!!"+str(i))
			newToken.setID(i)
			newToken.setPrecedence(self.getOperatorPrecedence(newToken.getName()))
			self.addToken(newToken.getName(),newToken)
	#
	#		Get operator precedence
	#
	def getOperatorPrecedence(self,op):
		prec = {
			"&":1,"|":1,"^":1,														
			">":2,">=":2,"<":2,"<=":2,"=":2,"<>":2,
			"+":3,"-":3,
			"*":4,"/":4,"%":4,"<<":4,">>":4,"\\":4,
			"!":5,"?":5,"$":5
		} 
		return prec[op] if op in prec else 0
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
	#		Dump a token group , text 
	#
	def dumpGroupText(self,set,h):
		h.write("KeywordSet{0}:\n".format(set))
		for t in self.tokenList:
			if t.getSet() == set:
				hash = sum([ord(x) for x in t.getName()]) & 0xFF
				name = "" if t.getName().startswith("!") else t.getName()
				h.write("\t.text\t{0},${1:02x},{2:16} ; ${3:02x} {4}\n".format(len(name),hash,'"'+name+'"',t.getID(),t.getName()))
		h.write("\t.text\t$FF\n")
	#
	#		Dump a token group , constants
	#
	def dumpGroupConstants(self,set,h):
		for t in self.tokenList:
			if t.getSet() == set:
				name = "" if t.getName().startswith("!") else t.getName()
				if (t.getID() >= 131 or t.getID() < 64) and t.getID() != 31 and t.getID() != 32:
					h.write("KWD_{0:32} = ${1:02x}; ${1:02x} {2}\n".format(self.processName(t.getName()),t.getID(),t.getName()))
	#
	#		Dump precedence table
	#
	def dumpPrecedenceTable(self,h):
		h.write("PrecedenceLevel:\n".format(set))
		for t in self.tokenList:
			if isinstance(t,PunctuationToken):
				h.write("\t.byte\t{0:2}\t; ${1:02x} {2}\n".format(t.getPrecedence(),t.getID(),t.getName()))
	#
	#		Dump vector table
	#				
	def dumpVectorTable(self,set,h):
		h.write("VectorSet{0}:\n".format(set if set >= 0 else "Punc"))
		for t in self.tokenList:
			if t.getSet() == set:
				label = t.getLabel() if t.getLabel() is not None else "SyntaxError"
				h.write("\t.word\t{0:32} ; ${1:02x} {2}\n".format(label,t.getID(),t.getName()))
	#
	#		Process Name to remove control characters if any.
	#
	def processName(self,s):
		s = s.replace("!","PLING").replace("$","DOLLAR").replace(":","COLON").replace("(","LPAREN")
		s = s.replace("<","LESS").replace(">","GREATER").replace("=","EQUAL").replace("\\","BACKSLASH").replace(")","RPAREN")
		s = s.replace("@","AT").replace("[","LSQPAREN").replace("]","RSQPAREN").replace("^","HAT").replace("+","PLUS")
		s = s.replace("-","MINUS").replace("*","STAR").replace("/","SLASH").replace("%","PERCENT").replace("&","AMPERSAND")
		s = s.replace("?","QMARK").replace(";","SEMICOLON").replace("'","QUOTE").replace("`","BQUOTE").replace("{","LCURLY")
		s = s.replace("}","RCURLY").replace("_","UNDERSCORE").replace("|","BAR").replace(",","COMMA").replace("#","HASH")
		s = s.replace(".","PERIOD").replace('"',"DQUOTE").replace("~","TILDE").replace(" ","SPACE").replace("","")
		#s = s.replace("","").replace("","").replace("","").replace("","").replace("","")
		return s 
	#
	#		Dump group 0 info
	#
	def group0Info(self,h1):
		h1.write("KWC_EOL = $80\n")
		h1.write("KWC_STRING = $FF\n")
		h1.write("KWC_HEXCONST = $FE\n")
		lowInc = 999
		lowDec = 999
		highAdjust = 0
		lowUnary = 999
		highUnary = 0 
		for t in self.tokenList:
			if t.getSet() == 0:
				if isinstance(t,UnaryToken):
					lowUnary = min(t.getID(),lowUnary)
					highUnary = max(t.getID(),highUnary)
				if isinstance(t,StructureToken):
					highAdjust = max(t.getID(),highUnary)
					lowInc = min(t.getID(),lowInc)
					if t.getAdjustment() < 0:
						lowDec = min(t.getID(),lowDec)
		h1.write("KWC_FIRST_STRUCTURE = ${0:02x}\n".format(lowInc))						
		h1.write("KWC_FIRST_STRUCTURE_DEC = ${0:02x}\n".format(lowDec))						
		h1.write("KWC_LAST_STRUCTURE = ${0:02x}\n".format(highAdjust))						
		h1.write("KWC_FIRST_UNARY = ${0:02x}\n".format(lowUnary))
		h1.write("KWC_LAST_UNARY = ${0:02x}\n".format(highUnary))
	#
	#		Scan source for keywords
	#
	def scanSource(self):
		for root,dirs,files in os.walk("."):
			for f in [x for x in files if x.endswith(".asm")]:
				for s in open(root+os.sep+f).readlines():
					if s.find(";;") > 0:
						m = re.match("^(.*?)\\:\\s*\\;\\;\\s*\\[(.*?)\\]",s)
						assert m is not None,"Bad line "+m
						word = m.group(2).strip().upper()
						assert word in self.tokens,"Not known "+word
						assert self.tokens[word].getLabel() is None,"Duplicate "+word
						self.tokens[word].setLabel(m.group(1).strip())

if __name__ == "__main__":
	note = ";\n;\tThis is automatically generated.\n;\n"
	t = TokenCollection()
	h1 = open("generated/kwdtext.dat","w")
	h1.write(note)
	for i in range(0,3):
		t.dumpGroupText(i,h1)
	h1.close()

	h2 = open("generated/kwdconst.inc","w")
	h2.write(note)
	for i in range(-1,1):
		t.dumpGroupConstants(i,h2)
	h2.close()

	h = open("generated/precedence.dat","w")
	h.write(note)
	t.dumpPrecedenceTable(h)
	h.close()

	h = open("generated/vectors.dat","w")
	h.write(note)
	t.dumpVectorTable(-1,h)
	for i in range(0,3):
		t.dumpVectorTable(i,h)
	h.close()

	h1 = open("generated/kwdconst0.inc","w")
	h1.write(note)
	t.group0Info(h1)
	h1.close()
