; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		frames.asm
;		Purpose:	Open/Close Frames on the BASIC stack
;		Created:	1st October 2022
;		Reviewed: 	
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;		Open a frame. A contains the identifier in the upper nibl, and the bytes to claim is
; 		the lower nibble (includes frame marker) doubled
;
; ************************************************************************************************

StackOpen:
		pha 								; save frame byte
		and 	#$0F 						; the bytes to subtract.
		asl 	a 							; claim twice this for storage
		;
		eor 	#$FF 						; 2's complement addition
		sec 								; so basically subtracting from
		adc 	basicStack 	 				; basicStack
		sta 	basicStack
		bcs 	_SONoBorrow
		dec 	basicStack+1
		lda 	basicStack+1 				; have we reached stack overflow
		cmp 	#BasicStackBase >> 8
		bcc 	_SOMemory
_SONoBorrow:
		pla 								; get marker back and write at TOS
		sta 	(basicStack)		
		rts

_SOMemory:
		ERR_STACK
		
; ************************************************************************************************
;
;										Close a frame
;
; ************************************************************************************************

StackClose:
		lda 	(basicStack) 				; get TOS marker
		and 	#$0F 						; bytes to add back
		asl 	a 							; claim twice this.
		adc 	basicStack 					; add to the stack pointer.
		sta 	basicStack
		bcc 	_SCExit
		inc 	basicStack+1
_SCExit:
		rts		

; ************************************************************************************************
;
;								Check in Frame A, if not report Error X
;
; ************************************************************************************************

StackCheckFrame:
		eor 	(basicStack) 				; xor with toS marker
		and 	#$F0 						; check type bits
		bne 	_SCFError 					; different, we have structures mixed up
		rts
_SCFError:
		txa 								; report error X
		jmp 	ErrorHandler		
		
		.send code

; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ************************************************************************************************
