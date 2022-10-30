; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		access.asm
;		Purpose:	Lock/Unlock bitmap access
;		Created:	6th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;							Set up ready to access the bitmap
;
; ************************************************************************************************

GXOpenBitmap:
		sei 								; no interrupts here
		lda 	0 							; save original MMU Control register
		sta 	gxOriginalMMUSetting
											; Edit and use the mapping LUT
		lda 	#GXMappingLUT*16+$80+GXMappingLUT
		sta 	0

		lda 	GXEditSlot 					; Save the original LUT slot value
		sta 	gxOriginalLUTValue
		cli
		rts

; ************************************************************************************************
;
;							Tidy up after accessing the bitmap
;
; ************************************************************************************************

GXCloseBitmap:
		sei
		lda 	gxOriginalLUTValue 			; restore LUT slot value
		sta 	GXEditSlot
		lda 	gxOriginalMMUSetting 		; restore MMU Control register
		sta 	0
		cli
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
