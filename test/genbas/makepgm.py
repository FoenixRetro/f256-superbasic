import random
for sz in [5,10,25,50,100,200,300,500,750,1000]:
	h = open("r{0}".format(sz),"w")
	for n in range(0,sz):
		s = "".join([chr(random.randint(65,120)) for x in range(0,random.randint(15,25))])
		h.write("{0} rem \"{1}\"\n".format(n*10+10,s))
	h.close()