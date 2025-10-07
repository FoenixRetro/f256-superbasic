10    cls
20    for i=0 to 100
30        col=random(80): row=random(60)
40        print at row,col; "#";
50        assert screen(row,col)=35
60        assert screen$(row,col)="#"
70    next
80    print at 0,0; "Done"
