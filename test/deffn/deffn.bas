10    rem DEFFN test program
20    rem
30    rem Single parameter (single-line)
40    print square(5)
50    print square(0)
60    print square(-3)
70    rem
80    rem Two parameters (single-line)
90    print add(3, 4)
100   print add(-10, 10)
110   rem
120   rem No parameters (single-line)
130   print pi()
140   rem
150   rem Variables unaffected by parameter localisation
160   x = 99
170   print square(5)
180   print x
190   rem
200   rem Multi-line function
210   print double(7)
220   print double(-3)
230   rem
240   rem Multi-line with IF (VBA-style)
250   print absval(5)
260   print absval(-5)
270   print absval(0)
280   rem
290   rem Multi-line with local variable
300   print sum3(10, 20, 30)
310   rem
320   rem Nested function calls
330   print add(square(2), square(3))
340   print square(add(1, 2))
350   print absval(add(-10, 3))
360   rem
370   print "All tests done"
380   end
390   rem
400   rem Single-line definitions
410   deffn square(x) = x * x
420   deffn add(a, b) = a + b
430   deffn pi() = 3.14159
440   rem
450   rem Multi-line definitions
460   deffn double(x)
470   enddef x * 2
480   deffn absval(x)
490     if x < 0
500       absval = -x
510     else
520       absval = x
530     endif
540   enddef absval
550   deffn sum3(a, b, c)
560     s = a + b + c
570   enddef s
