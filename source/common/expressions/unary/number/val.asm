; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		val.asm
;		Purpose:	String to Integer/Float#
;		Created:	29th September 2022
;		Reviewed: 	27th November 2022
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section	code

; ************************************************************************************************
;
; 								Val(String) and IsVal(String)
;
;		These have common code. Traditionally VAL() fails if given a bad value. ISVAL() allows 
;		people to check in advance.
;
; ************************************************************************************************

ValUnary: ;; [val(]	
		plx 								; restore stack pos
		jsr 	ValMainCode 				; do the main val() code
		bcs 	_VUError 					; couldn't convert
		rts
_VUError:
		jmp 	TypeError


IsValUnary: ;; [isval(]	
		plx 								; restore stack pos
		jsr 	ValMainCode 				; do the main val() code
		bcs 	_VUBad
		jmp 	ReturnTrue
_VUBad:
		jmp 	ReturnFalse

; ************************************************************************************************
;
;				Main val code - tries to convert, returns CS if fails, CC if good.
;
; ************************************************************************************************

ValMainCode:		
		jsr 	EvaluateString 				; get a string
		jsr 	CheckRightBracket 			; check right bracket present

; ************************************************************************************************
;
;								Evaluate value at zTemp0 into X.
;
; ************************************************************************************************

ValEvaluateZTemp0:
		phy
		lda 	(zTemp0) 					; check not empty string
		beq 	_VMCFail2 		

		ldy 	#$FF 						; start position		
		pha 								; save first character
		cmp 	#"-"		 				; is it - ?
		bne 	_VMCStart
		iny 								; skip over -
		;
		;		Evaluation loop
		;
_VMCStart:		
		sec 								; initialise first time round.
_VMCNext:
		iny 								; pre-increment
		lda 	(zTemp0),y 					; next character = EOS ?
		beq 	_VMCSuccess 				; successful.

		jsr 	EncodeNumber 				; send it to the number-builder
		bcc 	_VMCFail 					; if failed, give up.
		clc 								; next time round, countinue
		bra 	_VMCNext

_VMCFail:
		pla
_VMCFail2:		
		ply
		sec
		rts

_VMCSuccess:
		lda 	#0 							; construct final
		jsr 	EncodeNumber 				; by sending a duff value.
		pla 								; if it was -ve
		cmp 	#"-"
		bne 	_VMCNotNegative
		jsr		NSMNegate 					; negate it.
_VMCNotNegative:		
		ply
		clc
		rts		

		.send	code

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
