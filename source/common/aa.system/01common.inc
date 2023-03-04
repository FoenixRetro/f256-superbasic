; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		01common.inc
;		Purpose:	Common includes/defines/setups
;		Created:	18th September 2022
;		Reviewed: 	17th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										Configuration options
;
;			  Addresses should be on page boundaries (except for ZeroPageMandatory)
;
; ************************************************************************************************
;
;		Variables that have to be in zero page because it's used in (xx),y
;
ZeroPageMandatory = $30 
;
; 		Variables that would be nice to be in zero page, but it's not required
;
ZeroPagePreference = $50
;
;		Control Variables - low usage control variables.	
;
ControlStorage = $400
;
;		Variables that can go anywhere
;
MemoryStorage = $420
;
;		Where program memory starts and stops
;
BasicStart = $2000
BasicEnd = $8000
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
;		Basic Position and Return Stack Size
;
BasicStackSize = 512
BasicStackBase = $1000-BasicStackSize
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
;		26/11/22 		Stack moved into Zero Page for speed/space, okayed by Jessie O.
;
; ************************************************************************************************
