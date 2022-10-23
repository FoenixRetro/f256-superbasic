'
'		Simple PNG Game. Testing the BASICs :)
'
cls:bitmap on:sprites on:bitmap clear 0
for i = 0 to 15
sprite i image i to (i & 7) * 34 + 17,20+(i >> 3)*34
next
