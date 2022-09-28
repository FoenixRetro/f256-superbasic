; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		backload.asm
;		Purpose:	Backloader for Emulator
;		Created:	18th September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Characters can be streamed in by $FFFA
;
; ************************************************************************************************

BackloadProgram:
		ldx 	#$FF
		stx 	$FFFA 						; fast mode
		jsr 	BLReadByte
		bmi 	_BPExit
_BPCopy:
		inx  								; copy byte in
		sta 	lineBuffer,x
		stz 	lineBuffer+1,x
		jsr 	BLReadByte 					; read next byte
		bmi 	_BPEndLine 					; -ve = EOL
		cmp 	#9 							; handle TAB
		bne 	_BPNotTab
		lda 	#' '
_BPNotTab:		
		cmp 	#' ' 						; < ' ' = EOL
		bcs 	_BPCopy
_BPEndLine:		
		jsr 	TokeniseLine 				; tokenise the line.
		jsr 	MemoryAppend 				; append to current program
		bra 	BackloadProgram
_BPExit:
		;stz 	$FFFA 						; clear fast mode
		rts

; ************************************************************************************************
;
;		Read one byte from source - this can be the hardware access from storage/load.dat
;		or the in memory loaded BASIC source
;
; ************************************************************************************************

BLReadByte:
;		lda 	$FFFA
;		rts
_BLLoad:
		lda 	$3000 						; hardcoded in the makefile.
		inc 	_BLLoad+1
		bne 	_BLNoCarry
		inc 	_BLLoad+2
_BLNoCarry:
		cmp 	#0
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
