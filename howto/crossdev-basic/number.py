import sys 
line = 1000
for s in sys.stdin:
	print("{0} {1}".format(line,s.strip()))
	line += 10
print("{0}{0}{0}{0}".format(chr(255)))