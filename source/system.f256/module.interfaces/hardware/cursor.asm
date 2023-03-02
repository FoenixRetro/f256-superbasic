; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		cursor.asm
;		Purpose:	Cursor control
;		Created:	2nd March 2023
;		Reviewed: 	No.
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

CursorControl: ;; [cursor]
		ldx 	#0
		.cget
		iny
		cmp 	#KWD_OFF
		beq 	_CCOnOff
		inx
		cmp 	#KWD_ON
		beq 	_CCOnOff
		jmp 	SyntaxError
_CCOnOff:
		lda 	1 							; save current I/O
		pha
		stz 	1 		 					; page 0.

		lda 	$D010 						; read Cursor control register
		and 	#$FE 						; clear enable bit
		stx 	zTemp0 						; put bit back in
		ora 	zTemp0
		sta 	$D010

		pla 	 							; switch I/O back
		sta 	1
		rts
		
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
