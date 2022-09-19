; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		04data.inc
;		Purpose:	Main Data
;		Created:	18th September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									Mandatory Zero page code
;
; ************************************************************************************************

		.section zeropage

codePtr:	 								; address of current line (allow for 32 bit)
		.fill 	4
basicStack: 								; BASIC stack address
		.fill 	2		
zTemp0: 									; temporary words used in the interpreter.
		.fill 	2
zTemp1:
		.fill 	2
zTemp2:
		.fill 	2
	
		.send zeropage

; ************************************************************************************************
;
;								   Preferable Zero page code
;
; ************************************************************************************************

		.section zeropref

		.send zeropref


; ************************************************************************************************
;
;										Non Zero Page Data
;
; ************************************************************************************************

		.section storage

identStart: 								; start of identifier in line buffer
		.fill 	1
identTypeStart: 							; start of type information (#$ and ( in the line buffer)
		.fill 	1
identTypeEnd: 								; character after end of type information in the line buffer
		.fill 	1		
identHash: 									; hash of identifier (including the type characters)
		.fill 	1
identTypeByte: 								; type descriptor in format used in identifier record
		.fill 	1	 						; (see tokenising.pdf)

tokenOffset: 								; used for tokenising - tokenised result goes here
		.fill 	1		
tokenLineNumber:
		.fill 	2		
tokenBuffer: 	
		.fill 	253

lineBuffer: 								; used for input - ASCII line goes here
		.fill 	256

		.send 	storage

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
