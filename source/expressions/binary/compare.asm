; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		compare.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		22nd September 2022
;		Reviewed :
;		Purpose :	Comparison code
;
; ***************************************************************************************
; ***************************************************************************************

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
; 								Return True/False
;
; ***************************************************************************************

ReturnTrue: ;; [true]
		lda 	#1  						; set to 1
		jsr 	NSMSetByte 				
		lda 	#$80 						; set sign flag, so it is -1
		sta 	NSStatus,x 					
		rts

ReturnFalse: ;; [false]
		jmp 	NSMSetZero 					; set it all to zero

; ***************************************************************************************
;
; 								> = < (compare == vBinarye)
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
; 								> = < (compare <> vBinarye)
;
; ***************************************************************************************

;;
;;	{<>}	
;;		Compares two strings or numbers. Returns -1 if not equal, 0 if equal
;;; 	| if a <> 1 then print "a is not equal to 1"
;;
BinaryCompareNotEqual: 		;; [<>]
		.compare_not_equals 0
;;
;;	{<=}	
;;		Compares two strings or numbers. Returns -1 if the first is less than or equal to the 
;;		second, 0 otherwise.
;;; 	| if a <= 1 then print "a is less than or equal to 1"
;;
BinaryCompareLessEqual: 		;; [<=]
		.compare_not_equals 1

;;
;;	{>=}	
;;		Compares two strings or numbers. Returns -1 if the first is greater than or equal to the 
;;		second, 0 otherwise.
;;; 	| if a >= 1 then print "a is greater than or equal to 1"
;;
BinaryCompareGreaterEqual: 	;; [>=]
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
		bne 	_CBCString
		;
		lda 	NSExponent,x 				; check both are integers
		ora 	NSExponent+1,x  		
		bne 	_CBCFloat
		;
		jsr 	SubTopTwoStack 				; unsigned
		bvc 	_CBCNoOverflow 				; make signed
		eor 	#$80
_CBCNoOverflow:
		bmi 	_CBCLess 					; if < return $FF
		;
		jsr 	NSMIsZero 					; or the mantissa together
		beq 	_CBCExit 					; if zero, return zero as equal
		lda 	#1 							; return 1
_CBCExit:
		rts
_CBCLess:
		lda 	#$FF
		rts				

_CBCString:
		.debug
_CBCFloat:
		.debug				

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
