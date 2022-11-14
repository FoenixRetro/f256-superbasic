; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		val.asm
;		Purpose:	String to Integer/Float#
;		Created:	29th September 2022
;		Reviewed: 	
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section	code

; ************************************************************************************************
;
; 								Val(String) and IsVal(String)
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

;
;		Main val code - tries to convert, returns CS if fails, CC if good.
;
ValMainCode:		
		jsr 	EvaluateString 				; get a string
		jsr 	CheckRightBracket 			; check right bracket present

		phy

		lda 	(zTemp0) 					; check not empty string
		beq 	_VMCFail2 		

		ldy 	#$FF 						; start position		
		pha 								; save first character
		cmp 	#"-"		 				; is it -
		bne 	_VMCStart
		iny 								; skip over -
_VMCStart:		
		sec 								; initialise first time round.
_VMCNext:
		iny 								; pre-increment
		lda 	(zTemp0),y 					; next character
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
		jsr 	EncodeNumber
		pla
		cmp 	#"-"
		bne 	_VMCNotNegative
		jsr		NSMNegate
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
