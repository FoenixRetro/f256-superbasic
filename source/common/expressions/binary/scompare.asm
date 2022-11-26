; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		scompare.asm
;		Purpose:	Compare strings
;		Created:	23rd September 2022
;		Reviewed: 	27th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;						  Compare String S[X],S[X+1] - return 255,0,1
;
; ************************************************************************************************

CompareStrings:
		lda 	NSStatus,x 					; check both are strings
		and 	NSStatus+1,x
		and 	#NSBIsString
		beq 	_CSTypeError

		lda 	NSMantissa0,x 				; copy string addresses to zTemp0/1
		sta 	zTemp0
		lda 	NSMantissa1,x
		sta 	zTemp0+1

		lda 	NSMantissa0+1,x 		
		sta 	zTemp1
		lda 	NSMantissa1+1,x
		sta 	zTemp1+1

		phy 								; save Y so we can access strings
		ldy 	#$FF 						; -1 for pre increment.
_CSLoop:
		iny 				
		lda 	(zTemp0),y 					; check if they are the same
		cmp 	(zTemp1),y
		bne 	_CSDifferent
		cmp 	#0 							; reached end ?
		bne 	_CSLoop 					; still comparing
_CSExit:		
		ply 								; reached end, return zero in A from EOS
		rts

_CSDifferent:
		lda 	#255 						; if < return $FF
		bcc		_CSExit
		lda 	#1 							; otherwise return 1.
		bra 	_CSExit

_CSTypeError:
		jmp 	TypeError

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
