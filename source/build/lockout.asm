	* = $E000
StopCPU:
	bra 	StopCPU
	* = $FFFA
	.word 	StopCPU
	.word 	StopCPU
	.word 	StopCPU
