; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		delete.asm
;		Purpose:	Delete line from current position
;		Created:	5th October 2022
;		Reviewed: 	16th December 2022
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;					Delete line at current position (codePtr) from the program
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
		cmp 	zTemp2 						; has codePtr (copyFrom) reached the last byte to copy.
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
;								Move zTemp2 to program end 
;
;								(not a required function)
;
; ************************************************************************************************

IMemoryFindEnd:
		.set16 	zTemp2,BasicStart 			; final position
_MDLFELoop:
		lda 	(zTemp2) 					; scan forward using offsets.
		beq 	_MDLFEExit
		clc
		adc 	zTemp2
		sta 	zTemp2
		bcc 	_MDLFELoop
		inc 	zTemp2+1		
		bra 	_MDLFELoop
_MDLFEExit:
		rts

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
