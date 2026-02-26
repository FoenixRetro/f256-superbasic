; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		getinkey.asm
;		Purpose:	Get/Inkey handler.
;		Created:	5th January 2023
;		Reviewed: 	No
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
; 										GET()
;
; ************************************************************************************************

AscGet: ;; [get(]
		plx 								; restore stack pos
AscGet2:
		jsr 	CheckRightBracket
		jsr 	KNLGetSingleCharacter
		jmp 	NSMSetByte
_AGBreak:
		.error_break

; ************************************************************************************************
;
; 										INKEY()
;
; ************************************************************************************************

AscInkey: ;; [inkey(]
		plx 								; restore stack pos
AscInkey2:
		jsr 	CheckRightBracket
		jsr 	KNLGetKeyPressed
		jmp 	NSMSetByte

; ************************************************************************************************
;
; 								Character returning versions
;
; ************************************************************************************************

ChrGet:	 ;; [get$(]
		plx
		jsr 	AscGet2
		jmp 	ChrToString

ChrInkey: ;; [inkey$(]
		plx
		jsr 	AscInkey2
		;
		;		Convert A to string.
		;
ChrToString:
		cmp 	#0 							; if zero, return ""
		beq 	_GKISNull

		pha
		lda 	#1 							; allocate space for one char
		jsr 	StringTempAllocate
		pla 								; write number to it
		jmp 	StringTempWrite

_GKISNull:
		lda 	#0
		jmp 	StringTempAllocate

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
