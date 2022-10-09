; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		font.asm
;		Purpose:	Font source handler
;		Created:	9th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Access from font memory
;
; ************************************************************************************************

GXFontHandler:
		.debug
		stz 	gzTemp0+1 					; gzTemp0 is font #
		asl	 	gzTemp0 					; x 2
		rol	 	gzTemp0+1
		asl	 	gzTemp0 					; x 4
		rol	 	gzTemp0+1
		asl	 	gzTemp0 					; x 8		
		rol	 	gzTemp0+1
		lda 	gzTemp0+1 					; put in page C0
		ora 	#$C0
		sta 	gzTemp0+1
		lda 	#8 							; size 8x8
		ldx 	#GXGetGraphicDataFont & $FF ; XY = Graphic Data retrieval routine
		ldy 	#GXGetGraphicDataFont >> 8
		jsr 	GXDrawGraphicElement
		rts
;
;		Get line X of the graphics into the Pixel Buffer
;
GXGetGraphicDataFont:
		.debug
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
