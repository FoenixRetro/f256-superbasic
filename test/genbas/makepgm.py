for sz in [5,10,25,50,100,200,300,500,750,1000]:
	h = open("r{0}".format(sz),"w")
	for n in range(0,sz):
		h.write("{0} rem \"abcdefghijklmnopqrstuvwxyz\"\n".format(n*10+10))
	h.close()