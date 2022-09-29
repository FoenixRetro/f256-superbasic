; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		rnd.asm
;		Purpose:	Random number generator
;		Created:	29th September 2022
;		Reviewed: 	
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;										rnd function
;
; ************************************************************************************************

Unary_Rnd: ;; [rnd(]
		jsr 	EvaluateNumber 				; number to use.
		jsr 	CheckRightBracket 			; closing bracket

		jsr 	Random32Bit 				; generate a number.

		lda 	RandomSeed+0
		sta 	NSMantissa0,x
		lda 	RandomSeed+1
		sta 	NSMantissa1,x
		lda 	RandomSeed+2
		sta 	NSMantissa2,x
		lda 	RandomSeed+3
		and 	#$7F 						; make legal mantissa
		sta 	NSMantissa3,x


		lda 	#-31 						; force into 0-1 range
		sta 	NSExponent
		lda 	#NSTFloat
		sta 	NSStatus 					; positive.
		.debug
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
;
; ************************************************************************************************
