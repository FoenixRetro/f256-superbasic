; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		delete.asm
;		Purpose:	Delete line from current position
;		Created:	5th October 2022
;		Reviewed: 	No.
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;							Delete line at current position from the program
;		
; ************************************************************************************************

MemoryDeleteLine:
		jsr 	IMemoryFindEnd 				; find end to zTemp2.
		;
		lda 	(codePtr) 					; size to delete => y
		tay
_MDDLLoop:
		lda 	(codePtr),y 				; copy down
		sta 	(codePtr)

		lda 	codePtr 					; check done the lot.
		cmp 	zTemp2
		bne 	_MDLDLNext
		lda 	codePtr+1
		cmp 	zTemp2+1
		bne 	_MDLDLNext
_MDDLExit:
		rts

_MDLDLNext:		
		inc 	codePtr						; next byte
		bne 	_MDDLLoop
		inc 	codePtr+1
		bra 	_MDDLLoop

; ************************************************************************************************
;
;						Move zTemp2 to program end (not a required function)
;
; ************************************************************************************************

IMemoryFindEnd:
		.set16 	zTemp2,BasicStart
_MDLFELoop:
		lda 	(zTemp2)
		beq 	_MDLFEExit
		clc
		adc 	zTemp2
		sta 	zTemp2
		bcc 	_MDLFELoop
		inc 	zTemp2+1		
		bra 	_MDLFELoop
_MDLFEExit:
		rts

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
