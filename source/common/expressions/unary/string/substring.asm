; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		substring.asm
;		Purpose:	Left$/Mid$/Right$ - put here as Left/Right are same code.
;		Created:	29th September 2022
;		Reviewed: 	27th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Left$(<string>,<characters>)
;
; ************************************************************************************************

Unary_Left: 	;; [left$(]
		plx
		clc 								; only one parameter
		jsr 	SubstringInitial 			; set up.
		lda 	NSMantissa0+1,x 			; Param #1 is the length
		sta 	NSMantissa0+2,x 				
		stz 	NSMantissa0+1,x 			; Start is zero.
		bra 	SubstringMain 				

; ************************************************************************************************
;
;								Left$(<string>,<characters>)
;
; ************************************************************************************************

Unary_Right: 	;; [right$(]
		plx
		clc 								; only one parameter
		jsr 	SubstringInitial 			; set up.
		lda 	NSMantissa0+1,x 			; length => param 2
		sta 	NSMantissa0+2,x

		lda 	NSExponent,x 				; total length
		sbc 	NSMantissa0+1,x 			; length - required.
		bcs 	_URNotUnderflow		
		lda 	#0 							; start from the beginning, as something like right$("AB",3)
_URNotUnderflow:
		sta 	NSMantissa0+1,x 			; this is the start position		
		bra 	SubstringMain

; ************************************************************************************************
;
;								Mid$(<string>,<start>,<characters>)
;
; ************************************************************************************************

Unary_Mid: 	;; [mid$(]
		plx
		sec 								; two parameters
		jsr 	SubstringInitial 			; set up.
		;
		lda 	NSMantissa0+1,x 			; first parameter is zero ?
		beq 	_UMError
		dec 	NSMantissa0+1,x				; reduce initial offset by 1 as MID$(a$,1..) is actually the first character
		bra 	SubstringMain
_UMError:		
		jmp 	ArgumentError

; ************************************************************************************************
;
;				Substring from offset A, length in FPAExponent, chars required in X
;
; ************************************************************************************************

SubstringMain:		
		lda 	NSMantissa0+1,x 			; is the initial offset >= the length	
		cmp 	NSExponent,x 	
		bcs 	_SSMNull 					; if so, return an empty string.
		;
		lda 	NSMantissa0+2,x 			; if copy count is zero
		beq 	_SSMNull 					; return empty string.
		;
		clc 								; add the offset +1 to the address and
		lda	 	NSMantissa0,x 				; put in zTemp, this is the start of the substring to copy.
		adc 	NSMantissa0+1,x 
		sta 	zTemp0
		lda	 	NSMantissa1,x
		adc 	#0
		sta 	zTemp0+1
_SSMNoCarry:		
		lda 	NSMantissa0+2,x 			; characters required.
		jsr 	StringTempAllocate 			; allocate that many characters

		phy 								; save Y
		ldy 	#0 							; start copying in.
_SSMCopy:
		lda 	(zTemp0),y 					; get next character
		beq 	_SSMEString 				; no more to copy
		jsr 	StringTempWrite 			; and write it out.
		iny 
		dec 	NSMantissa0+2,x
		bne 	_SSMCopy 
_SSMEString:		
		ply
_SSMExit:
		rts				

_SSMNull:
		lda 	#0
		jsr 	StringTempAllocate		
		rts

; ************************************************************************************************
;
;		Common initial code. Read 1st String, 2nd byte and if CS set, 3rd byte on to stack
;		levels X,X+1 and X+2
;
; ************************************************************************************************

SubstringInitial:
		phx 								; save initial stack position
		;
		;		Get string
		;
		php 								; save carry on stack indicating 2 parameters
		;
		jsr 	EvaluateString 				; get a string
		;
		phy 								; calculate length to exponent.
		ldy 	#$FF
_SIFindLength:
		iny
		lda 	(zTemp0),y
		bne 	_SIFindLength
		tya
		sta 	NSExponent,x
		ply
		;
		;		First parameter
		;
		inx
		jsr 	CheckComma 					; comma next
		jsr 	Evaluate8BitInteger 		; get next parameter
		plp 								; is it the last parameter ?
		bcc 	_SSIExit 					; if so, exit.
		;
		;		Second parameter
		;
		inx
		jsr 	CheckComma 					; comma next
		jsr 	Evaluate8BitInteger 		; get last parameter
		;
		;		On the stack at this point <LowS> <HighS> <Length> <Param1> <Param2>
		;
_SSIExit:
		plx
		jsr 	CheckRightBracket 			; check closing bracket
		rts 								; exit
		.send 	code
		
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
