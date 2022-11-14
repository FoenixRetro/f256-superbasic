; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		data.asm
;		Purpose:	Console Data
;		Created:	14th November 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section storage

EXTMemory = $C000
EXTTextPage = $02
EXTColourPage = $03

EXTDummySpace = 1 							; fake-space for CR character.
EXTCBlack = 0

EXTRow: 									; current row
		.fill 	1
EXTColumn: 									; current column
		.fill 	1		
EXTTextColour: 								; current colour
		.fill 	1
EXTScreenWidth:	 							; screen size
		.fill 	1
EXTScreenHeight:
		.fill 	1

		.send storage

		.section zeropage

EXTAddress: 								; current address on screen of start of line.
		.fill 	2

		.send zeropage

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
