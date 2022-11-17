; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		input.asm
;		Purpose:	Input one line, screen scrape
;		Created:	17th November 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Input line into lineBuffer
;
;		This can use ExtInputSingleCharacter *or* $FFCF, the screen editor or similar.
;
; ************************************************************************************************

EXTInputLine:
		jsr 	ExtInputSingleCharacter
		cmp 	#13
		beq 	_EILExit
		jsr 	ExtPrintCharacter
		bra 	EXTInputLine
		rts

		;
		;		Copy line from screen into input buffer and right trim.
		;
_EILExit:	
		lda 	1 							; save I/O page
		pha
		lda 	#2 							; switch to page 2
		sta 	1
		ldy 	#0 							; copy current line into buffer.
_EILScrapeLine:
		lda 	(EXTAddress),y
		sta 	lineBuffer,y
		iny
		cpy 	EXTScreenWidth
		bne 	_EILScrapeLine	

_EILTrimSpaces: 							; right trim
		dey
		beq 	_EILEndTrim		
		lda 	lineBuffer,y
		cmp 	#' '
		beq 	_EILTrimSpaces
		iny 								; trim after non space character.
_EILEndTrim: 
		lda 	#0 							; trim here.
		sta 	lineBuffer,y		
		lda 	#13 						; echo the RETURN
		jsr 	ExtPrintCharacter
		pla 								; reset I/O page
		sta 	1
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
