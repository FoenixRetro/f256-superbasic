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
		jsr 	NewProgram 					; does the actual NEW.
		ldx 	#_BLLoad >> 8
		lda 	#_BLLoad & $FF
		jsr 	PrintStringXA

		lda 	#SOURCE_ADDRESS >> 13 		; start page
		sta 	BackLoadPage
		.set16 	BackLoadPointer,$6000 		; and load from there.

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

		lda 	TokenLineNumber 			; line number = 0
		ora 	TokenLineNumber+1
		beq 	_BPLoop 					; not legal code, blank line or maybe a comment.

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
		phx
		ldx 	8+3 						; save current mapping for $6000 in X

		lda 	BackLoadPage	 			; set current page
		sta 	8+3

		lda 	BackLoadPointer 			; copy pointer to zTemp0
		sta 	zTemp0 	
		lda 	BackLoadPointer+1
		sta 	zTemp0+1
		lda 	(zTemp0) 					; read next byte
		inc 	BackLoadPointer 			; bump pointer
		bne 	_BLNoCarry
		inc 	BackLoadPointer+1
		bpl 	_BLNoCarry 					; need a new page
		pha
		lda 	#$60 						; reset pointer
		sta 	BackLoadPointer+1
		inc 	BackLoadPage 				; next page from source.
		pla
_BLNoCarry:
		stx 	8+3 						; restore mapping, then X.
		plx		

		cmp 	#0
		rts
		.send code

		.section storage
BackLoadPage:
		.fill  	1		
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
; 		02/12/22 		Partial rewrite to load 8k from a fixed physical address.
; 		05/12/22 		Fixed so >8k files work properly, moving page switch to
;						BLReadByte
;		13/12/22 		Blank line in text doesn't create a line 0
;
; ************************************************************************************************
