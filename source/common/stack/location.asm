; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		location.asm
;		Purpose:	Store and retrieve the location from the TOS
;		Created:	1st October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;		Save the current code position and offset (in Y) on the stack. By convention, this is
;		stored in the first 5 bytes above the stack frame marker.
;
; ************************************************************************************************

STKSaveCodePosition:
		phy
		tya 								; save Y
		ldy 	#5
		sta 	(basicStack),y
		dey 								; save Code Pointer
_STKSaveLoop:
		lda 	codePtr-1,y 				; allows us to access the pointer w/out issues.
		sta 	(basicStack),y
		dey
		bne 	_STKSaveLoop
		ply
		rts

; ************************************************************************************************
;
;							Load TOS into current code positions
;
; ************************************************************************************************
		
STKLoadCodePosition:
		ldy 	#1 							; load code pointer back
_STKLoadLoop:
		lda 	(basicStack),y
		sta 	codePtr-1,y
		iny
		cpy 	#5
		bne 	_STKLoadLoop
		lda 	(basicStack),y 				; get Y offset
		tay
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
