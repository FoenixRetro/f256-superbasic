; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		newfont.asm
;		Purpose:	Update font while not in FPGA
;		Created:	14th December 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

UpdateFont:
		lda 	1 							; save position
		pha

		lda 	#1 							; switch to I/O block 1
		sta 	1

		.set16 	zTemp0,FontBinary 			; copy FontBinary to $C000-$C7FF
		.set16 	zTemp1,$C000

_UFCopy1:
		ldy 	#0
_UFCopy2:
		lda 	(zTemp0),y
		sta 	(zTemp1),y
		iny
		bne 	_UFCopy2
		inc 	zTemp0+1
		inc 	zTemp1+1
		lda 	zTemp1+1
		cmp 	#$C8
		bne 	_UFCopy1
		;		
		pla 								; restore.
		sta 	1
		rts

		.include 	"../common/generated/font.dat"
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
