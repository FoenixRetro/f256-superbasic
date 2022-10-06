; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		call.asm
;		Purpose:	END command
;		Created:	22nd September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

CallCommand: ;; [call]
		ldx 	#0
		jsr 	Evaluate16BitInteger
		;
_CCClear		
		inx  								; clear 1,2 and 3 (for A X Y)	
		jsr 	NSMSetZero
		cpx 	#4
		bne 	_CCClear
		ldx 	#0 							; and keep trying
_CCCParam:
		.cget 								; comma follows ?
		cmp 	#KWD_COMMA
		bne 	_CCCRun6502
		iny 								; skip comma
		inx	 								; next level
		jsr 	Evaluate8BitInteger 		; get A/X/Y
		cpx 	#3
		bcc 	_CCCParam 					; done all 3 ?
_CCCRun6502:				
		phy 								; save position
		lda 	NSMantissa1 				; put address in zTemp0
		sta 	zTemp0+1
		lda 	NSMantissa0
		sta 	zTemp0
		;
		lda 	NSMantissa0+1 				; get registers
		ldx 	NSMantissa0+2
		ldy 	NSMantissa0+3
		jsr 	_CCCZTemp0 					; call zTemp0
		ply 								; restore position and exit
		rts
_CCCZTemp0:									; call (zTemp0)
		jmp 	(zTemp0)
		
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
