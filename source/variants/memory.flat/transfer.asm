; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		memory.asm
;		Purpose:	BASIC program space manipulation
;		Created:	1st October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Transfer to line number AX
;
; ************************************************************************************************

MemoryTransferAX:
		sta 	zTemp0 						; save line number zTemp0
		stx 	zTemp0+1
		.resetCodePointer 					; point to start of program memory
		;
		;		Search loop. 
		;
_MTAXLoop:	
		.cget0 								; get next line number.
		beq 	_MTAXError 					; not found.
		ldy 	#1 							; check LSB
		.cget 
		cmp 	zTemp0 
		bne 	_MTAXNext
		iny 								; check MSB
		.cget
		cmp 	zTemp0+1
		beq 	_MTAXExit 					; success !
_MTAXNext:		
		.cnextline 		 					; failed, try next line.		
		bra 	_MTAXLoop
_MTAXExit:		
		rts
_MTAXError:
		.error_line

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
