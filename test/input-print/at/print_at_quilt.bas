10    cls
20    p = 15
30    for r=0 to 59
40        for c=0 to 79
50            cprint chr$(p);
60            p = p + 1: if p>31 then p=15
70        next
80    next
90    print at 0,0;
