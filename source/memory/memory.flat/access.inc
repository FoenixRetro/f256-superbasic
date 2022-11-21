; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		03access.inc
;		Purpose:	Macros used for accessing program code space
;		Created:	18th September 2022
;		Reviewed: 	No.
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;								(codePtr) access and modify
;
; ************************************************************************************************

cget 	.macro
		lda 	(codePtr),y
		.endm

cget0 	.macro
		lda 	(codePtr)
		.endm

cset 	.macro
		sta 	(codePtr),y
		.endm

cset0 	.macro
		sta 	(codePtr)
		.endm

ccmp 	.macro
		cmp 	(codePtr),y
		.endm

; ************************************************************************************************
;
;		  codePtr has been updated, adjust any physical selections (e.g. page selection)
;
; ************************************************************************************************

cresync .macro
		.endm

; ************************************************************************************************
;
;								Advance codePtr to the next line
;
; ************************************************************************************************

cnextline .macro
		clc
		lda 	(codePtr)					; get offset 
		adc 	codePtr
		sta 	codePtr
		bcc 	_CREExit
		inc 	codePtr+1
_CREExit:
		.endm

cskipdatablock .macro
		iny
		tya
		sec
		adc 	(codePtr),y
		tay
		.endm	

; ************************************************************************************************
;
;									Set a value in codePointer.
;
; ************************************************************************************************

csetcodepointer 	.macro
		lda 	#((\1) & $FF)
		sta 	codePtr
		lda 	#((\1) >> 8)
		sta 	codePtr+1
		.cresync
		.endm

cresetcodepointer 	.macro
		.csetcodepointer BasicStart
		.endm

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