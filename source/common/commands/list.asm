; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		list.asm
;		Purpose:	LIST statement
;		Created:	4th October 2022
;		Reviewed:
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									LIST the program
;
; ************************************************************************************************

Command_List:	;; [list]
		stz 	listIndent 					; reset indent.
		stz		NSMantissa0+4				; set the lower (slot 4) to 0 and upper (slot 7) to $FFFF
		stz 	NSMantissa1+4 				
		lda 	#$FF
		sta 	NSMantissa0+7
		sta 	NSMantissa1+7
		;
		.cget 								; is first a comma, if so goto 2nd 
		cmp 	#KWD_COMMA 			
		beq 	_CLSecond
		jsr 	CLIsDigit 					; if not digit, list all
		bcs 	_CLStart
		ldx 	#4 							; get 1st range into slot 4
		jsr 	Evaluate16BitInteger
		.cget 								; comma follows ?
		cmp 	#KWD_COMMA
		beq 	_CLSecond 					; if so go get it
		;
		lda 	NSMantissa0+4 				; copy 4->7
		sta 	NSMantissa0+7
		lda 	NSMantissa1+4
		sta 	NSMantissa1+7
		bra 	_CLStart

_CLSecond:
		iny 								; consume comma		
		jsr 	CLIsDigit 					; digit found
		bcs 	_CLStart 					; if not, continue listing
		ldx 	#7 							; load 2nd range into slot 7
		jsr 	Evaluate16BitInteger

_CLStart
		.cresetcodepointer
		;
_CLLoop:
		jsr 	EXTBreakCheck 				; break check
		beq 	_CLExit

		.cget0 								; any more ?
		beq 	_CLExit
		; 
		ldx 	#4 							; check range every time, line numbers aren't in order.
		jsr 	CLCompareLineNo 
		bcc 	_CLNext
		ldx 	#7
		jsr 	CLCompareLineNo
		beq 	_CLDoThisOne
		bcs 	_CLNext
_CLDoThisOne:		
		jsr 	ScanGetCurrentLineStep 		; get indent adjust.
		jsr 	ListConvertLine 			; convert line into token Buffer
		ldx 	#(tokenBuffer >> 8) 		; print that line
		lda 	#(tokenBuffer & $FF) 	
		jsr 	PrintStringXA
		lda 	#13 						; new line
		jsr 	EXTPrintCharacter
_CLNext:		
		.cnextline
		bra 	_CLLoop
_CLExit:
		jmp 	WarmStart

; ************************************************************************************************
;
;		Compare Line# current line vs Line Number in S[X], returns CC/CS/Z/NZ as per 6502
;
; ************************************************************************************************

CLCompareLineNo:
		sec
		ldy 	#1
		.cget
		sbc 	NSMantissa0,x
		sta 	zTemp0
		iny
		.cget
		sbc 	NSMantissa1,x
		ora 	zTemp0
		rts

; ************************************************************************************************
;
;									Check if digit, CC if yes, CS no.
;
; ************************************************************************************************

CLIsDigit:
		.cget
		cmp 	#"0"
		bcc	 	_CLIDExitFalse
		cmp 	#"9"+1
		rts
_CLIDExitFalse:
		sec
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
