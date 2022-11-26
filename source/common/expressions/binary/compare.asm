; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		compare.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	22nd September 2022
;		Reviewed :	27th November 2022
;		Purpose :	Comparison code
;
; ***************************************************************************************
; ***************************************************************************************

		.section code

compare_equals .macro
		jsr 	CompareBaseCode
		cmp 	#\1
		beq 	ReturnTrue
		bra 	ReturnFalse
		.endm

compare_not_equals .macro
		jsr 	CompareBaseCode
		cmp 	#\1
		bne 	ReturnTrue
		bra 	ReturnFalse
		.endm

; ***************************************************************************************
;
; 						Return True/False as function or value
;
; ***************************************************************************************

UnaryTrue: ;; [true]
		plx
ReturnTrue:		
		lda 	#1  						; set to 1
		jsr 	NSMSetByte 				
		lda 	#$80 						; set sign flag, so it is -1
		sta 	NSStatus,x 					
		rts

UnaryFalse: ;; [false]
		plx
ReturnFalse:		
		jmp 	NSMSetZero 					; set it all to zero

; ***************************************************************************************
;
; 								> = < (compare == value)
;
; ***************************************************************************************
;;
;;	{=}	
;;		Compares two strings or numbers. Returns -1 if equal, 0 if not equal
;;; 	| if a = 1 then print "a is 1"
;;
BinaryCompareEqual: 			;; [=]
		plx
		.compare_equals 0

;;
;;	{<}	
;;		Compares two strings or numbers. Returns -1 if the first is less than the second, 0
;; 		otherwise.
;;; 	| if a < 1 then print "a is less than 1"
;;
BinaryCompareLess: 			;; [<]
		plx
		.compare_equals $FF

;;
;;	{>}	
;;		Compares two strings or numbers. Returns -1 if the first is greater than the second, 0
;; 		otherwise.
;;; 	| if a > 1 then print "a is greater than 1"
;;
BinaryCompareGreater: 			;; [>]
		plx
		.compare_equals 1

; ***************************************************************************************
;
; 								> = < (compare <> value)
;
; ***************************************************************************************

;;
;;	{<>}	
;;		Compares two strings or numbers. Returns -1 if not equal, 0 if equal
;;; 	| if a <> 1 then print "a is not equal to 1"
;;
BinaryCompareNotEqual: 		;; [<>]
		plx
		.compare_not_equals 0
;;
;;	{<=}	
;;		Compares two strings or numbers. Returns -1 if the first is less than or equal to the 
;;		second, 0 otherwise.
;;; 	| if a <= 1 then print "a is less than or equal to 1"
;;
BinaryCompareLessEqual: 		;; [<=]
		plx
		.compare_not_equals 1

;;
;;	{>=}	
;;		Compares two strings or numbers. Returns -1 if the first is greater than or equal to the 
;;		second, 0 otherwise.
;;; 	| if a >= 1 then print "a is greater than or equal to 1"
;;
BinaryCompareGreaterEqual: 	;; [>=]
		plx
		.compare_not_equals $FF

; ***************************************************************************************
;
; 				Compare two string or number values, return $FF,0,1
;
; ***************************************************************************************

CompareBaseCode:
		jsr 	DereferenceTopTwo 			; make both values if references.
		;
		lda 	NSStatus,x 					; check if either is a string.
		ora 	NSStatus+1,x 	
		and 	#NSTString 	 
		bne 	_CBCString 					; if so do string code, which will check if both.
		;
		lda 	NSExponent,x 				; check both are integers
		ora 	NSExponent+1,x  		
		bne 	_CBCFloat
		lda 	NSStatus,x
		ora 	NSStatus+1,x
		and 	#NSTFloat
		bne 	_CBCFloat
		;
		;		do the integer comparison.
		;
		jsr 	CompareFixMinusZero 		; fix up -0 just in cases.
		inx
		jsr 	CompareFixMinusZero
		dex
		lda 	NSStatus,x 					; are the signs different ?
		eor 	NSStatus+1,x
		bpl 	_CDCSameSign
		;
		lda 	NSStatus,x 					; if first one is -ve
		bmi 	_CBCLess 					; return $FF
_CBCGreater:
		lda 	#1
		rts		
_CBCEqual:
		lda 	#0
		rts				
		;
		;		They are the same sign.
		;
_CDCSameSign:				
		jsr 	SubTopTwoStack 				; unsigned subtract
		jsr 	NSMIsZero 					; or the mantissa together
		beq 	_CBCEqual 					; -0 == 0

		lda 	NSMantissa3,x 				; sign of the result. if +ve return $01 else return $FF
		eor 	NSStatus+1,x 				; however if both were -ve this is inverted
		bpl 	_CBCGreater
_CBCLess:
		lda 	#$FF
		rts

_CBCString:
		jmp 	CompareStrings
		
_CBCFloat:
		jmp 	CompareFloat

; ***************************************************************************************
;
; 						Fixup minus zero issue for comparison.
;			  (If either compare is -0, then can give spurious results)
;
; ***************************************************************************************

CompareFixMinusZero:
		jsr 	NSMIsZero
		bne 	_CFXMZNotZero
		stz 	NSStatus,x
_CFXMZNotZero:
		rts

		.send code
; ***************************************************************************************
;
;									Changes and Updates
;
; ***************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ***************************************************************************************
