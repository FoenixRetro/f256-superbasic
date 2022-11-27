; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		backload.asm
;		Purpose:	Backloader for Emulator
;		Created:	18th September 2022
;		Reviewed: 	23rd November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Load ASCII code at source into BASIC
;
; ************************************************************************************************

BackloadProgram:
		ldx 	#_BLLoad >> 8
		lda 	#_BLLoad & $FF
		jsr 	PrintStringXA
		.set16 	BackLoadPointer,SOURCE_ADDRESS
		lda 	#$FF
		sta 	$FFFA
_BPLoop:		
		ldx 	#$FF

		jsr 	BLReadByte 					; read a byte
		cmp 	#0
		beq 	_BPExit 					; if 0 exit
		bmi 	_BPExit 					; if -ve exit
_BPCopy:
		inx  								; copy byte into the lineBuffer
		sta 	lineBuffer,x
		stz 	lineBuffer+1,x
		jsr 	BLReadByte 					; read next byte
		bmi 	_BPEndLine 					; -ve = EOL
		cmp 	#9 							; handle TAB, make it space.
		bne 	_BPNotTab
		lda 	#' '
_BPNotTab:		
		cmp 	#' ' 						; < ' ' = EOL
		bcs 	_BPCopy 					; until a control character, should be 13 received.
_BPEndLine:		
		jsr 	TKTokeniseLine 				; tokenise the line.

		.if AUTORUN==1 						; if autorun do full insert/delete for testing
		nop
		jsr 	EditProgramCode
		.else
		sec 								; append not insert
		jsr 	MemoryInsertLine 			; append to current program
		.endif
		bra 	_BPLoop
		;
		;		Exit backloading
		;
_BPExit:
		stz 	$FFFA
		jsr 	ClearCommand 				; clear variables etc.
		rts
_BLLoad:
		.text 	"Loading from Memory",13,0

; ************************************************************************************************
;
;		Read one byte from source - this can be the hardware access from storage/load.dat
;		or the in memory loaded BASIC source
;
; ************************************************************************************************

BLReadByte:
		lda 	BackLoadPointer 			; copy pointer to zTemp0
		sta 	zTemp0 	
		lda 	BackLoadPointer+1
		sta 	zTemp0+1
		lda 	(zTemp0) 					; read next byte
		inc 	BackLoadPointer 			; bump pointer
		bne 	_BLNoCarry
		inc 	BackLoadPointer+1
_BLNoCarry:
		cmp 	#0
		rts
		.send code

		.section storage
BackLoadPointer:
		.fill 	2
		.send storage

; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;		26/11/22  		Reinserted speed up emulator hack (write to $FFFA)
;
; ************************************************************************************************
