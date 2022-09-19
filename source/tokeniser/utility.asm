; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		utility.asm
;		Purpose:	Tokeniser Utilities
;		Created:	19th September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;					   Fix case of line in LineBuffer to U/C outside quotes
;
; ************************************************************************************************

FixLineBufferCase:
		ldx 	#0
_FLBCLoop:
		lda 	lineBuffer,x 				; get next character
		beq 	_FLBCExit 					; end of string.
		cmp 	#'"'						; quote, go to in quotes
		beq 	_FLBCInQuotes
		inx
		cmp 	#'a'						; needs capitalising ?
		bcc 	_FLBCLoop
		cmp 	#'z'+1
		bcs 	_FLBCLoop
		sec 								; make U/C
		sbc 	#32		
		sta	 	lineBuffer-1,x 				; write back
		bra 	_FLBCLoop
		;
_FLBCInQuotes:
		inx 								; advance
		lda 	lineBuffer,x 				; get next
		beq 	_FLBCExit 					; exit on EOS
		cmp 	#'"' 				 		; until " found
		bne 	_FLBCInQuotes 		
		inx 								; skip over it
		bra 	_FLBCLoop
		;
_FLBCExit:
		rts

; ************************************************************************************************
;
;		  Extract line number from lineBuffer,x - we know there's at least *one* digit
;		  (this code is seperate so that the tokenising code could be in its own page)
;
; ************************************************************************************************

TokeniseExtractLineNumber:
		lda 	tokenLineNumber+1 			; push current value on stack
		pha
		lda 	tokenLineNumber
		pha
		jsr 	_TELNTimes2 				; line # x 4
		jsr 	_TELNTimes2 				; line # x 2
		;
		clc 								; add stacked value
		pla 
		adc 	tokenLineNumber
		sta 	tokenLineNumber
		pla 
		adc 	tokenLineNumber+1
		sta 	tokenLineNumber+1 			; line # x 5
		jsr 	_TELNTimes2 				; line # x 10
		;
		lda 	lineBuffer,x 				; get and consume character
		inx
		and 	#15 						; add to line #
		clc
		adc 	tokenLineNumber
		sta 	tokenLineNumber
		bcc 	_TLENNoCarry
		inc 	tokenLineNumber+1
_TLENNoCarry:		
		lda 	lineBuffer,x 				; more digits ?
		cmp 	#'0'
		bcc 	_TLENExit
		cmp 	#'9'+1
		bcc 	TokeniseExtractLineNumber
_TLENExit:
		rts
_TELNTimes2:		
		asl 	tokenLineNumber
		rol 	tokenLineNumber+1
		rts

; ************************************************************************************************
;
;								Write Byte to tokenBuffer
;
; ************************************************************************************************

TokeniseWriteByte:	
		phx
		ldx 	tokenOffset 				; next slot to write to
		sta 	tokenOffset,x 				; write byte out
		inc 	tokenOffset 				; advance slot.
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
