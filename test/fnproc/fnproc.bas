10    ' FN test program
20    '
30    ' Inline definitions (must be skipped during execution)
40    fn square(x) = x * x
50    fn add(a, b) = a + b
60    fn pi() = 3.14159
70    fn double(x)
80    return x * 2
90    endfn
100   fn absval(x)
110     if x < 0
120       return -x
130     else
140       return x
150     endif
160   endfn
170   fn sum3(a, b, c)
180     s = a + b + c
190   return s
200   endfn
210   fn greet$(n) = "Hello #" + str$(n)
220   fn upper$(s$)
230     if s$ = "a"
240       return "A"
250     else
260       return s$
270     endif
280   endfn
290   fn fact(n)
291     if n <= 1
292       return 1
293     endif
294   return n * fact(n - 1)
295   endfn
298   proc hello(n)
300     print "Hello #";n
310   endproc
320   '
330   ' Inline proc definition (must be skipped)
340   proc setval(v)
350     g = v
360   endproc
370   '
380   ' Single parameter (single-line)
390   print square(5)
400   print square(0)
410   print square(-3)
420   '
430   ' Two parameters (single-line)
440   print add(3, 4)
450   print add(-10, 10)
460   '
470   ' No parameters (single-line)
480   print pi()
490   '
500   ' Variables unaffected by parameter localisation
510   x = 99
520   print square(5)
530   print x
540   '
550   ' Multi-line function
560   print double(7)
570   print double(-3)
580   '
590   ' Multi-line with IF (return statement)
600   print absval(5)
610   print absval(-5)
620   print absval(0)
630   '
640   ' Multi-line with local variable
650   print sum3(10, 20, 30)
660   '
670   ' String-returning functions
680   print greet$(1)
690   print greet$(42)
700   print upper$("a")
710   print upper$("b")
720   '
730   ' Nested function calls
740   print add(square(2), square(3))
750   print square(add(1, 2))
760   print absval(add(-10, 3))
770   '
780   ' Recursive function
781   print fact(1)
782   print fact(2)
783   print fact(3)
784   print fact(4)
785   print fact(5)
786   '
787   ' PROC calls (inline definitions were skipped)
790   hello(1)
800   hello(2)
810   g = 0
820   setval(99)
830   print g
840   '
850   ' GOSUB/RETURN still works outside functions
860   g = 0
870   gosub 950
880   print g
890   '
900   print "All tests done"
910   end
920   '
930   ' GOSUB subroutine
950   g = 42
960   return
