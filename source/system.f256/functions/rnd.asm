; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		rnd.asm
;		Purpose:	Random number generator
;		Created:	11th January 2023 
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;										random function
;
; ************************************************************************************************

Unary_Random: ;; [random(]
		plx
		jsr 	URCopyToMantissa  			; put random # in mantissa
		.cget 								; ) follows
		cmp 	#KWD_RPAREN
		beq 	_URNoModulus 				; then we return a random 30 bit number.
		;
		inx
		jsr 	Evaluate16BitInteger 		; put modulus value in +1
		dex
		jsr 	IntegerModulusNoCheck 		; calculate modulus, so now 0 .. n-1
		;
_URNoModulus:		
		stz 	NSStatus,x 					; make it an integer positive
		stz 	NSExponent,x
		jsr 	CheckRightBracket
		rts

; ************************************************************************************************
;
;										rnd() function
;
; ************************************************************************************************

Unary_Rnd: ;; [rnd(]
		plx
		jsr 	EvaluateNumber 				; number to use.
		jsr 	CheckRightBracket 			; closing bracket

		lda 	NSStatus,x 					; if -ve, then seed using parameter
		bpl 	_URDontSeed

		lda 	1 							; switch to page 0
		pha
		stz 	1

		lda 	NSMantissa0,x 				; copy - value to seed butchering it.
		eor 	#$17
		sta 	$D6A4
		lda 	NSMantissa1,x
		eor 	#$A5
		sta 	$D6A5
		lda 	#3 							; set bit 1 high/low to set seed.
		sta 	$D6A6
		lda 	#1
		sta 	$D6A6
		pla
		sta 	1

_URDontSeed:
		jsr 	URCopyToMantissa 			; copy into mantissa

		lda 	#-30 						; force into 0-1 range
		sta 	NSExponent,x
		lda 	#NSTFloat 						
		sta 	NSStatus,x 					; positive float
		rts

; ************************************************************************************************
;
;							Copy a random 30 bit number to the mantissa
;
; ************************************************************************************************

URCopyToMantissa:
		lda 	1 							; switch to I/O page 1
		pha
		stz 	1

		lda 	#1
		sta 	$D6A6 						; enable LFSR

		lda 	$D6A4
		sta 	NSMantissa0,x
		lda 	$D6A5
		sta 	NSMantissa1,x
		lda 	$D6A4
		sta 	NSMantissa2,x
		lda 	$D6A5
		and 	#$3F 						; make legal mantissa
		sta 	NSMantissa3,x

		pla 
		sta 	1
		rts

		.send 	code
		
; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
; 		22/11/22 		RND(n) was only generating 0..0.5
;		22/11/22 		When setting the exponent and status at the end, was not doing so at
;						the current evaluation level.
;		11/01/23 		Set to use hardware RNG / almost complete rewrite.
;
; ************************************************************************************************
