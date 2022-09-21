; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		simple.asm
;		Purpose:	Simple binary operations
;		Created:	21st September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

;
;		Dummy ADD and SHIFTLEFT routines.
;
Add: 	;; [+]
		plx
		clc
		lda		NSMantissa0,x
		adc 	NSMantissa0+1,x 	
		sta 	NSMantissa0,x
		lda		NSMantissa1,x
		adc 	NSMantissa1+1,x 	
		sta 	NSMantissa1,x
		lda		NSMantissa2,x
		adc 	NSMantissa2+1,x 	
		sta 	NSMantissa2,x
		lda		NSMantissa3,x
		adc 	NSMantissa3+1,x 	
		sta 	NSMantissa3,x
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
