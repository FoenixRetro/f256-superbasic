10    cls
20    for i=0 to 100
30        col=random(80): row=random(60): c=32+random(128-32)
40        print at row,col; chr$(c);
50        assert screen(row,col)=c
50        assert screen$(row,col)=chr$(c)
60    next
70    print at 0,0; "Done"
