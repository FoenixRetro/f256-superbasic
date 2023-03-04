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
; ************************************************************************************************

InputLine:
		pha
		phx
		phy

		lda 	1 							; save I/O page
		pha
_EILLoop:		
		jsr 	KNLGetSingleCharacter 		; get one single character
		cmp 	#13 						; scrape line if exit.		
		beq 	_EILExit
		cmp 	#4 							; Ctrl+D delete at cursor
		beq 	_EILDelete
		cmp 	#8 							; Ctrl+H backspace
		beq 	_EILBackspace
		cmp 	#' '						; < space, print it
		bcc 	_EILPrintLoop
		cmp 	#$7F 						; if -ve print it
		bcs 	_EILPrintLoop
		;
		tax 								; save character in X
		lda	 	#2 							; screen character memory
		sta 	1
		ldy 	EXTScreenWidth 				; read the last character.
		dey
		lda 	(EXTAddress),y 				
		cmp 	#' ' 						; if not space then reject.
		bne 	_EILLoop 					
		;
		phx 								; save character on stack
		lda 	#2  						; insert a space
		sta 	1
		jsr 	EXTILInsert 				; insert in text screen
		inc 	1
		jsr 	EXTILInsert 				; insert in colour screen
		pla 								; get character back.
_EILPrintLoop:		
		jsr 	EXTPrintCharacter
		bra 	_EILLoop
		rts
		;
		;		Backspace		
		;
_EILBackspace:		
		lda 	EXTColumn					; can we backspace ?
		beq 	_EILLoop
		lda 	#2 							; move cursor left
		jsr 	EXTPrintCharacter
_EILDelete		
		;
		lda 	#2 							; text block
		sta 	1
		lda 	#' ' 						; backspace text.
		jsr 	EXTILDelete
		;
		inc 	1 							; colour block
		ldy 	EXTColumn 					; get attribute of last character
		dey
		lda 	(EXTAddress),y
		jsr 	EXTILDelete 				; backspace attribute
		bra 	_EILLoop 					; and go round.
		;
		;		Copy line from screen into input buffer and right trim.
		;
_EILExit:	
		lda 	#2 							; switch to page 2
		sta 	1
		ldy 	#0 							; copy current line into buffer.
_EILScrapeLine:
		lda 	(EXTAddress),y
		sta 	lineBuffer,y
		iny
		cpy 	EXTScreenWidth
		bne 	_EILScrapeLine	
		;
_EILTrimSpaces: 							; right trim
		dey
		cpy 	#$FF 						; back past the start
		beq 	_EILEndTrim		 			; zero the input line.
		lda 	lineBuffer,y
		cmp 	#' '
		beq 	_EILTrimSpaces 				; if fail this found non space character
_EILEndTrim: 
		iny 								; trim after non space character.
		lda 	#0 							; trim here.
		sta 	lineBuffer,y		
		lda 	#13 						; echo the RETURN
		jsr 	EXTPrintCharacter
		pla 								; reset I/O page
		sta 	1

		ply
		plx
		pla
		rts
;
;		Backspace from current position, put A on the end
;
EXTILDelete:
		pha 								; save the new character
		ldy 	EXTColumn 					; start copying from here.
_EXTDLoop:
		iny 								; copy one byte down.
		lda 	(EXTAddress),y
		dey
		sta 	(EXTAddress),y
		;
		iny 								; do till end of line.
		cpy 	EXTScreenWidth 
		bcc 	_EXTDLoop
		;
		dey 	 							; write in last slot.
		pla
		sta 	(EXTAddress),y
		rts
;
;		Insert at current position.
;		
EXTILInsert:
		ldy 	EXTScreenWidth 				; end position
_EXTILoop:
		dey 								; back one
		cpy 	EXTColumn 					; exit if reached insert point.
		beq 	_EXTIExit
		dey 								; copy one byte up.
		lda 	(EXTAddress),y
		iny
		sta 	(EXTAddress),y
		bra 	_EXTILoop 
_EXTIExit:
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
;		27/11/22 		Added Ctrl+D Delete at character
;		22/12/22 		When trimming if first character was non-space got erased so deleting
;						lines 1-9 did not work.
;		30/01/23 		Moved out of hardware module into normal space.
;		04/03/23 		Code at _EILLoop when inserting pre-checks for space.
;
; ************************************************************************************************
