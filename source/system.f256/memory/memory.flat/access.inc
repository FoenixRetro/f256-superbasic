; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		03access.inc
;		Purpose:	Macros used for accessing program code space
;		Created:	18th September 2022
;		Reviewed: 	23rd November 2022
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;								(codePtr) access and modify
;
; ************************************************************************************************

cget 	.macro 								; get character
		lda 	(codePtr),y
		.endm 

cget0 	.macro 								; get 1st character e.g. offset to next line
		lda 	(codePtr)
		.endm

cset 	.macro 								; update character
		sta 	(codePtr),y
		.endm

cset0 	.macro 								; update offset
		sta 	(codePtr)
		.endm

ccmp 	.macro 								; compare against
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
		lda 	(codePtr)					; get offset and add
		adc 	codePtr
		sta 	codePtr
		bcc 	_CREExit
		inc 	codePtr+1 					; carry
_CREExit:
		.endm

; ************************************************************************************************
;
;									Advance past a data block
;
; ************************************************************************************************

cskipdatablock .macro
		iny 								; point to offset
		tya 								; A = offset position
		sec 								; add size +1 hence SEC
		adc 	(codePtr),y
		tay 								; make current position.
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

; ************************************************************************************************
;
;			Reset the code pointer back to the start, may need page switches to make
;			it current as well.
;
; ************************************************************************************************

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
