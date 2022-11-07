'
'	Level data
'
proc getLevelData(n)
	level$ = ""
	if n = 0 then level$ = "....XXX ...XXX. ..XXX.. ..XXX.. .XXXX.."
	if n = 1 then level$ = "....XXX ...XXXX ..XXXXX .XXXXXX XXXXXXX"
	if n = 2 then level$ = "XXXXXXX X...... X...... XXXXXXX ......."
	if n = 3 then level$ = "XXXXX.. X...X.. X...XXX XXXXX.. ....X.."
	if n = 4 then level$ = ".....X. ....XX. ..XX.X. X....X. XXXXXX."
	if n = 5 then level$ = ".....X. ....XX. .XXX.X. X....X. XXXXXX."
	if n = 6 then level$ = "XX..... .XX.... ..XX... ....XX. .....XX
endproc





