; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		restore.asm
;		Purpose:	Reset data pointer
;		Created:	4th October 2022
;		Reviewed: 	1st December 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;							Restore resets the data pointer
;
; ************************************************************************************************

Command_Restore:	;; [restore]
		jsr 	SwapDataCodePtrs 			; swap code and data
		.cresetcodepointer 					; back to the start
		jsr 	SwapDataCodePtrs 			; put them back
		lda 	#3 							; start at offset 3, e.g. first instruction of first line.
		sta 	dataPointer+4   			; (read checks not EOF)
		stz 	inDataStatement 			; not in data statement
		rts

; ************************************************************************************************
;
;						Swap code & data pointers / Y offset round.
;
; ************************************************************************************************

SwapDataCodePtrs:
		phx
		ldx 	#3 							; swap 32 bit code pointer over
_SDCPLoop:
		lda 	safePtr,x
		pha
		lda 	dataPointer,x
		sta 	safePtr,x
		pla
		sta 	dataPointer,x
		dex
		bpl 	_SDCPLoop
		;
		lda 	dataPointer+4 				; swap Y position over.
		sty 	dataPointer+4
		tay
		;
		.cresync 							; sync up hardware
		plx
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
