; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		tokenise.asm
;		Purpose:	Tokenise Line
;		Created:	18th September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Tokenise ASCIIZ line in lineBuffer
;
; ************************************************************************************************

TokeniseLine:
		;
		;		Make the line buffer UpperCase outside quoted strings
		;
		jsr 	FixLineBufferCase 			; fix line case
		;
		;		Erase the tokenised line to empty
		;
		lda 	#3 							; reset the token buffer to empty
		sta 	tokenOffset
		stz 	tokenLineNumber
		stz 	tokenLineNumber+1
		;
		;		Find the first non space character
		;
		ldx 	#$FF
_TKFindFirst:
		inx
		lda 	lineBuffer,x
		cmp 	#' '
		beq 	_TKFindFirst
		;
		;		If it is 0-9 extract a 2 byte integer into the token line number
		;
		cmp 	#'0'
		bcc 	_TKNoLineNumber
		cmp 	#'9'+1
		bcs 	_TKNoLineNumber
		jsr 	TokeniseExtractLineNumber
_TKNoLineNumber:		
		;
		;		Main tokenising loop
		;
_TKTokeniseLoop:
		lda 	lineBuffer,x 				; next character, exit if zero EOL.
		.debug
		beq 	_TKExit
		inx
		cmp 	#' '
		beq 	_TKTokeniseLoop 			; keep looping if space found.
		dex 								; undo last get, A contains character, X is position.
		;
		cmp 	#'_'						; _ A-Z is identifier *or* token
		beq 	_TKTokeniseIdentifier
		cmp 	#'A'
		bcc 	_TKTokenisePunctuation 
		cmp 	#'Z'+1
		bcc 	_TKTokeniseIdentifier
		;
		;		So we now have a punctuation character. Special cases are those >= 64 and < or > followed by = > or <
		;		For 64 conversion see the punctuation.ods
		;
_TKTokenisePunctuation:
		cmp 	#'<' 						; check for < > handlers.
		beq 	_TKCheckDouble
		cmp 	#'>'
		beq 	_TKCheckDouble
_TKStandardPunctuation:
		lda 	lineBuffer,x 				; get it back.
		cmp 	#64 						; are we >= 64
		bcc 	_TKNoShift
		pha 								; save 
		and 	#7 							; lower 3 bits in zTemp0
		sta 	zTemp0
		pla
		and 	#32 						; bit 5
		lsr 	a 							; shift into bit 3
		lsr 	a
		ora 	zTemp0 
		ora 	#$10						; now in the range 16-31
_TKNoShift:		
		jsr 	TokeniseWriteByte 			; write the punctuation character
		inx 								; consume the character
		bra 	_TKTokeniseLoop 			; and loop round again.
		;
		;		Have < or >. Check following character is < = >. These are mapped onto 
		;		codes 0-5 for << >> <= >= <> , see punctuation.ods
		;
_TKCheckDouble:
		lda 	lineBuffer+1,x 				; get next character
		cmp 	#'<'						; if not < = > which are ASCII consecutive go back
		bcc 	_TKStandardPunctuation
		cmp 	#'>'+1
		bcs 	_TKStandardPunctuation
		;
		lda 	lineBuffer,x 				; this is < (60) or > (62)
		and 	#2 							; now < (0) or > (2)
		asl 	a 							; now < (0) or > (4), CC also
		adc 	lineBuffer+1,x 				; add < = > codes - < code
		sec
		sbc 	#'<' 
		jsr 	TokeniseWriteByte 			; this is in the range 0-7
		inx 								; consume both
		inx
		bra 	_TKTokeniseLoop
		;
		;		Found _ or A..Z, which means an identifier or a token.
		;
_TKTokeniseIdentifier:		
		; **TODO**

_TKExit:lda 	#$80 						; write end of line byte
		jsr 	TokeniseWriteByte		
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
