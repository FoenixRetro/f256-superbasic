; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		compare.asm
;		Purpose:	X[S] to X[S+1]
;		Created:	23rd September 2022
;		Reviewed: 	27th November 2022
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section 	code

; ************************************************************************************************
;
;							Compare Stack vs 2nd. Return -1,0 or 1 in A
;
; ************************************************************************************************

CompareFloat:	
		jsr 	FloatSubtract 				; Calculate S[X]-S[X+1]
		;
		;		At this point the mantissae are equal. If we were comparing integers
		; 		then this should be zero - if float we ignore the lowest 13 bits, which gives
		;		an approximation for equality of 1 part in 2^19
		; 		This is about 1 part in 500,000 - so it is "almost equal".
		;			
		lda 	NSMantissa1,x 			 	; so we ignore this - by changing bits checked
		and 	#$F8
		ora 	NSMantissa2,x
		ora 	NSMantissa3,x
		beq 	_FCExit 					; zero, so approximately identical
		;
		;		Not equal, so get result from sign.
		;
		lda 	#1 							; return +1 if result>0
		bit 	NSStatus,x
		bpl 	_FCExit
_FCNegative:		
		lda 	#$FF 						; and return -1 if result<0
_FCExit:
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
