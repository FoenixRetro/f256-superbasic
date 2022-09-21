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

		.include "../generated/kwdtext.dat"
		
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
		beq 	_TKExit
		cmp 	#' '
		bcc 	_TKFindFirst
		;
		;		If it is 0-9 extract a 2 byte integer into the token line number
		;
		cmp 	#'0'
		bcc 	_TKNoLineNumber
		cmp 	#'9'+1
		bcs 	_TKNoLineNumber
		jsr 	TokeniseExtractLineNumber
_TKNoLineNumber:		
		;----------------------------------------------------------------------------------------
		;
		;							Main tokenising loop
		;
		;----------------------------------------------------------------------------------------

_TKTokeniseLoop:
		lda 	lineBuffer,x 				; next character, exit if zero EOL.
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

		;----------------------------------------------------------------------------------------
		;
		;		So we now have a punctuation character. Special cases are those >= 64 and < or > followed by = > or <
		;		and quoted strings. For 64 conversion see the punctuation.ods
		;
		;----------------------------------------------------------------------------------------

_TKTokenisePunctuation:
		cmp 	#'"'						; quoted string ?
		beq 	_TKString
		cmp 	#'#'						; hexadecimal constant (# only appears at end of identifiers)
		beq 	_TKHexConstant
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

_TKString: 									; tokenise a string "Hello world"
		jsr 	TokeniseString
		bra 	_TKTokeniseLoop
_TKHexConstant: 							; tokenise hex constant #A277
		jsr 	TokeniseHexConstant
		bra 	_TKTokeniseLoop

		;----------------------------------------------------------------------------------------
		;
		;		Have < or >. Check following character is < = >. These are mapped onto 
		;		codes 0-5 for << >> <= >= <> , see punctuation.ods
		;
		;----------------------------------------------------------------------------------------

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

		;----------------------------------------------------------------------------------------
		;
		;		Exit point, writes EOL and returns
		;
		;----------------------------------------------------------------------------------------

_TKExit:lda 	#KWC_EOL 					; write end of line byte
		jsr 	TokeniseWriteByte		
		rts	

		;----------------------------------------------------------------------------------------
		;
		;		Found _ or A..Z, which means an identifier or a token.
		;
		;----------------------------------------------------------------------------------------

_TKTokeniseIdentifier:		
		stx 	identStart 					; save start
		stz 	identTypeByte 				; zero the type byte
_TKCheckLoop:
		inx 								; look at next, we know first is identifier.
		lda  	lineBuffer,x
		cmp 	#"_" 						; legal char _ 0-9 A-Z
		beq 	_TKCheckLoop
		cmp	 	#"0"
		bcc 	_TKEndIdentifier
		cmp 	#"9"+1
		bcc 	_TKCheckLoop
		cmp	 	#"A"
		bcc 	_TKEndIdentifier
		cmp 	#"Z"+1
		bcc 	_TKCheckLoop
_TKEndIdentifier:
		stx 	identTypeStart 				; save start of type text (if any !)
		;
		ldy 	#$08 						; this is the identifier type byte for #
		cmp 	#"#"						; followed by #
		beq 	_TKHasTypeCharacter
		ldy 	#$10 						; this is the identifier type byte for $
		cmp 	#"$"						; followed by $ or #
		bne 	_TKNoTypeCharacter
_TKHasTypeCharacter:
		sty 	identTypeByte 				; has # or $, save the type
		inx 								; read next
		lda 	lineBuffer,x
_TKNoTypeCharacter:
		cmp 	#"("						; is it open parenthesis (e.g. array)
		bne 	_TKNoArray
		inx 								; skip the (
		lda 	identTypeByte 				; set bit 2 (e.g. array)
		ora 	#$04
		sta 	identTypeByte
_TKNoArray:		
		stx 	identTypeEnd 				; save end marker, e.g. continue from here.
		jsr 	TokeniseCalculateHash 		; calculate the has for those tokens

		;----------------------------------------------------------------------------------------
		;
		;			Search the token tables.
		;
		;----------------------------------------------------------------------------------------

checktokens .macro
		ldy 	#(\1) >> 8
		lda 	#(\1) & $FF
		jsr 	TokeniseSearchTable
		.endm
		.checktokens KeywordSet0			; check the three token tables for the keyword.
		ldx 	#0 							
		bcs 	_TKFoundToken
		.checktokens KeywordSet1
		ldx 	#$81
		bcs 	_TKFoundToken
		.checktokens KeywordSet1
		ldx 	#$82
		bcs 	_TKFoundToken

		;----------------------------------------------------------------------------------------
		;
		;			 No shift found, so it's a procedure or a variable declaration
		;
		;----------------------------------------------------------------------------------------

		jsr 	CheckCreateVariableRecord 	; failed all, it's a variable, create record if does not exist.
		ldx 	identTypeEnd 				; X points to following byte
		jmp 	_TKTokeniseLoop 			; and go round again.

		;----------------------------------------------------------------------------------------
		;
		;				Found a token, X contains the shift (or 0), A the token
		;
		;----------------------------------------------------------------------------------------

_TKFoundToken:
		pha 								; save token
		txa 								; shift in X, is there one ?
		beq 	_TKNoTShift
		jsr 	TokeniseWriteByte 			; if so, write it out
_TKNoTShift:
		pla 								; restore and write token
		jsr 	TokeniseWriteByte
		ldx 	identTypeEnd 				; X points to following byte
		jmp 	_TKTokeniseLoop 			; and go round again.

; ************************************************************************************************
;
;									Tokenise a string.
;
; ************************************************************************************************

TokeniseString:
		lda 	#KWC_STRING 				; string token.
		jsr 	TokeniseWriteByte
		inx									; start of quoted string.
		phx 								; push start of string on top
		dex
_TSFindEnd:							
		inx
		lda 	lineBuffer,x 				; next character
		beq 	_TSEndOfString
		cmp 	#'"'
		bne 	_TSFindEnd
_TSEndOfString:
		ply  								; so now Y is first character, X is character after end.		
		pha 								; save terminating character
		jsr 	TOWriteBlockXY 				; write X to Y as a data block
		pla 								; terminating character
		beq 	_TSNotQuote					; if it wasn't EOS skip it
		inx
_TSNotQuote:		
		rts		
;
;		Write Y to X with a trailing NULL.
;
TOWriteBlockXY:
		stx 	zTemp0 						; write end character
		tya
		eor 	#$FF
		sec
		adc 	zTemp0
		inc 	a 							; one extra for NULL
		jsr 	TokeniseWriteByte
_TOBlockLoop:
		cpy 	zTemp0
		beq 	_TOBlockExit
		lda 	lineBuffer,y
		jsr 	TokeniseWriteByte				
		iny
		bra 	_TOBlockLoop
_TOBlockExit:
		lda 	#0
		jsr 	TokeniseWriteByte
		rts

; ************************************************************************************************
;
;									Tokenise a hex constant
;
; ************************************************************************************************

TokeniseHexConstant:
		lda 	#KWC_HEXCONST 				; hex constant token.
		jsr 	TokeniseWriteByte
		inx									; start of quoted string.
		phx 								; push start of constant on top
		dex
_THFindLoop:							
		inx 	
		lda 	lineBuffer,x
		cmp 	#"0"
		bcc 	_THFoundEnd
		cmp 	#"9"+1
		bcc 	_THFindLoop
		cmp 	#"A"
		bcc 	_THFoundEnd
		cmp 	#"F"+1
		bcc 	_THFindLoop
_THFoundEnd:
		ply 								; restore start
		jsr 	TOWriteBlockXY 				; output the block
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
