; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		who.asm
;		Purpose:	WHO command
;		Created:	26th November 2022
;		Reviewed: 	1st December 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

WhoCommand: ;; [who]
		ldx 	#(_WHOMessage >> 8)
		lda 	#(_WHOMessage & $FF)
		jsr 	PrintStringXA
		rts
;
;		List - should we include econtreasd, emwhite etc ? Stefany's call I think.
;
_WHOMessage:
		.byte 	$81
		.text 	"Brought to you by :",13,13
		.text 	9,"Stefany Allaire",13
		.text 	9,"Jessie Oberreuter",13
		.text 	9,"Paul Robson",13
		.text 	9,"Peter Weingartner",13
		.byte 	0

		
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
