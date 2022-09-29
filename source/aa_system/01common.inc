; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		01common.inc
;		Purpose:	Common includes/defines/setups
;		Created:	18th September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										Configuration options
;
; ************************************************************************************************
;
;		Variables that have to be in zero page because it's used in (xx),y
;
ZeroPageMandatory = $30 
;
; 		Variables that would be nice to be in zero page, but it's not required
;
ZeroPagePreference = $600
;
;		Variables that can go anywhere
;
MemoryStorage = $700
;
;		Where program memory starts and ends
;
BasicStart = $2000
;
;		Build address of ROM
;		
CodeStart = $8000
;
;		Start of variable/string space. This is a fixed location in memory.
;
VariableSpace = $1000
;
;		End of variable space
;
EndVariableSpace = $2000
;
;		Basic Math Stack Size
;
MathStackSize = 8
;
;		Basic Return Stack Size
;
BasicStackSize = 512
;
;		Max Input Line Length
;	
MaxLineSize = 80

; ************************************************************************************************
;
;									Set up code and data sections
;
; ************************************************************************************************

		* = ZeroPageMandatory 				; *must* be in zero page
		.dsection zeropage

		* = ZeroPagePreference 				; not required to be in zero page, but preferable
		.dsection zeropref

		* = MemoryStorage 					; doesn't matter if zero page or not 
		.dsection storage

		* = CodeStart
		.dsection code

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
