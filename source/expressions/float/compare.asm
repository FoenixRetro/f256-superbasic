; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		compare.asm
;		Purpose:	X[S] to X[S+1]
;		Created:	23rd September 2022
;		Reviewed: 	
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;							Compare Stack vs 2nd. Return -1,0 or 1 in A
;
; ************************************************************************************************

CompareFloat:	
		jsr 	FloatSubtract 				; Calculate S[X]-S[X+1]
		;
		;		At this point the mantissae are equal. If we were comparing integers
		; 		then this should be zero - if float we ignore the lowest byte, which gives
		;		an approximation for equality of 1 part in 2^22.
		; 		This is about 1 part in 4 million.
		;				
		lda 	#0
;		ora 	NSMantissa0,x 			 	; so we ignore this - by changing bits checked
		ora 	NSMantissa1,x				; the accuracy can be tweaked.
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

; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;		15/08/22 		Code Review
;
; ************************************************************************************************
