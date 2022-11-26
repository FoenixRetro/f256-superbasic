; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		rnd.asm
;		Purpose:	Random number generator
;		Created:	29th September 2022
;		Reviewed: 	27th November 2022
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
		jsr 	Random32Bit 				; get a random number
		jsr 	URCopyToMantissa  			; put in mantissa
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
		jsr 	NSMIsZero 					; if zero, then don't generate a new number
		beq 	_URCopySeed

		lda 	NSStatus,x 					; if -ve, then seed using parameter
		bpl 	_URDontSeed

		lda 	NSMantissa0,x 				; copy - value to seed butchering it.
		eor 	#$17
		sta 	RandomSeed+0
		lda 	NSMantissa1,x
		eor 	#$A5
		sta 	RandomSeed+1
		lda 	NSMantissa2,x
		eor 	#$C2
		sta 	RandomSeed+2	
		lda 	NSMantissa3,x
		eor 	#$9D
		sta 	RandomSeed+3
		jsr 	Random32Bit
_URDontSeed:
		jsr 	Random32Bit 				; generate a number
_URCopySeed:
		jsr 	URCopyToMantissa 			; copy into mantissa

		lda 	#-30 						; force into 0-1 range
		sta 	NSExponent,x
		lda 	#NSTFloat 						
		sta 	NSStatus,x 					; positive float
		rts

URCopyToMantissa:
		lda 	RandomSeed+0
		sta 	NSMantissa0,x
		lda 	RandomSeed+1
		sta 	NSMantissa1,x
		lda 	RandomSeed+2
		sta 	NSMantissa2,x
		lda 	RandomSeed+3
		and 	#$3F 						; make legal mantissa
		sta 	NSMantissa3,x
		rts

; ************************************************************************************************
;
;								Generate 32 bit random number.
;
; ************************************************************************************************

Random32Bit:
		phy
		ldy 	#7 							; do it 7 times
		lda 	RandomSeed+0 				; check the seed isn't zero
		bne 	_Random1
		tay 								; if so do it 256 times
		lda		#$AA 						; and use this to seed the seed....
_Random1:
		asl 	a 							; LSFR RNG
		rol 	RandomSeed+1
		rol 	RandomSeed+2
		rol 	RandomSeed+3
		bcc 	_Random2
		eor 	#$C5
_Random2:		
		dey
		bne 	_Random1
		sta 	RandomSeed+0
		ply
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
;
; ************************************************************************************************
