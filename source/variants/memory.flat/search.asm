; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		search.asm
;		Purpose:	Find Line number >= XA
;		Created:	1st October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;				Set codePtr -> Line Number >= XA ; set CC if >=, set Z if found.
;		  If there is no larger number, codePtr points to EOS, carry clear, Z not known.
;
; ************************************************************************************************

MemorySearch:
		sta 	zTemp0 						; save line number zTemp0
		stx 	zTemp0+1
		.resetCodePointer 					; point to start of program memory
		;
		;		Search loop. 
		;
_MTAXLoop:	
		.cget0 								; get next line number.
		clc 
		beq 	_MTAXExit 					; reached end, exit with CC.

		ldy 	#1 							; calculate current line# - requested line#
		.cget 	
		sec 	
		sbc 	zTemp0
		sta 	zTemp1 						; save interim to set Z

		iny 								; do the MSB
		.cget
		sbc 	zTemp0+1
		ora 	zTemp1

		beq 	_MTAXExit	 				; found
		bcs 	_MTAXExit 					; current < required exit

		.cnextline 		 					; failed, try next line.		
		bra 	_MTAXLoop

_MTAXExit:		
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
