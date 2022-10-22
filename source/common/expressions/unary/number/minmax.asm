; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		minmax.asm
;		Purpose:	Min() and Max() functions
;		Created:	22nd October 2022
;		Reviewed: 	
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Min/Max function
;
; ************************************************************************************************

Unary_Min: ;; [min(] 				
		lda 	#1
		bra 	UnaryMinMaxMain
Unary_Max: ;; [max(] 				
		lda 	#$FF 						; value from comparator to cause a write
UnaryMinMaxMain:
		plx 								; get index on number stack
		pha 								; save comparator
		jsr 	EvaluateValue 				; get the first value.
_UMMMLoop:
		.cget 								; what comes next
		cmp 	#KWD_RPAREN 				; if right bracket then done.
		beq 	_UMMMDone 
		jsr 	CheckComma 					; must be a comma
		;
		inx 		
		jsr 	EvaluateValue
		dex
		jsr 	NSMShiftUpTwo 				; copy S[X] to S[X+2] (Compare is destructive)
		inx
		jsr 	NSMShiftUpTwo 				; copy S[X] to S[X+2], original 
		inx
		jsr 	CompareBaseCode 			; part of > = < etc. code, returns 255,0 or 1
		dex
		dex
		sta 	zTemp0 						; save required result
		pla 								; get and save comparator
		pha
		cmp 	zTemp0 						; if the comparator
		bne 	_UMMMLoop
		;
		jsr 	ExpCopyAboveDown 			; copy next up slot down
		bra 	_UMMMLoop

_UMMMDone:
		pla 								; throw the comparator
		iny 								; skip )
		rts				

ExpCopyAboveDown:
		lda 	NSStatus+1,x
		sta 	NSStatus,x
		lda 	NSExponent+1,x
		sta 	NSExponent,x
		lda 	NSMantissa0+1,x
		sta 	NSMantissa0,x
		lda 	NSMantissa1+1,x
		sta 	NSMantissa1,x
		lda 	NSMantissa2+1,x
		sta 	NSMantissa2,x
		lda 	NSMantissa3+1,x
		sta 	NSMantissa3,x
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
