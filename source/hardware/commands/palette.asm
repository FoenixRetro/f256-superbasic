; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		palette.asm
;		Purpose:	Change Palette command
;		Created:	1st November 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

PaletteCommand: ;; [palette]
		ldx 	#0
		jsr 	Evaluate8BitInteger 		; colour
		jsr 	CheckComma
		inx
		jsr 	Evaluate16BitInteger 		; r
		jsr 	CheckComma
		inx
		jsr 	Evaluate8BitInteger 		; g
		jsr 	CheckComma
		inx
		jsr 	Evaluate8BitInteger 		; b

		lda 	NSMantissa0 				; get colour #
		sta 	zTemp0 						
		lda 	#$D0 >> 2 					; MSB = D0/4
		sta 	zTemp0+1

		asl 	zTemp0 						; zTemp = $D000+Colour x 4
		rol	 	zTemp0+1
		asl 	zTemp0
		rol	 	zTemp0+1

		lda 	#1 							; I/O Page 2
		sta 	1

		phy 
		lda 	NSMantissa0+3 				; fix to r,g,b
		sta 	(zTemp0)
		ldy 	#1
		lda 	NSMantissa0+2
		sta 	(zTemp0),y
		lda 	NSMantissa0+1
		iny
		sta 	(zTemp0),y
		ply
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
