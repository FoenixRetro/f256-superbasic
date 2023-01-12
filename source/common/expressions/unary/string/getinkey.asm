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
_AGKey:	jsr 	ProcessEvents 				; any ongoing events.
		bne 	_AGBreak
		jsr 	PopKeyboardQueue 			; wait for key.
		cmp 	#0
		beq 	_AGKey
		jsr 	NSMSetByte 					
		rts
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
		jsr 	PopKeyboardQueue 			; get key if any, non returns zero.
		jsr 	NSMSetByte 					
		rts

; ************************************************************************************************
;
; 								Character returning versions
;
; ************************************************************************************************

ChrGet:	 ;; [get$(]
		plx
		jsr 	AscGet2
		jmp 	GetInkeyToString

ChrInkey: ;; [inkey$(]	
		plx	
		jsr 	AscInkey2
		;
		;		Convert A to string.
		;
GetInkeyToString:
		cmp 	#0 							; if zero, return ""
		beq 	_GKISNull

		pha
		lda 	#1 							; allocate space for one char
		jsr 	StringTempAllocate
		pla 								; write number to it
		jsr 	StringTempWrite
		rts

_GKISNull:
		lda 	#0
		jsr 	StringTempAllocate		
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
