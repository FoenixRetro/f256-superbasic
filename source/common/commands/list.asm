; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		list.asm
;		Purpose:	LIST statement
;		Created:	4th October 2022
;		Reviewed:	1st December 2022
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
		;
		lda 	#$3F 						; silence at list.
		jsr 	SNDCommand
		;
		.cget 								; followed by an identifier ?
		and 	#$C0 				 		; if so, we are list procedure() which is a seperate block		
		cmp 	#$40  						; of code.
		beq 	_CLListProcedure
		;
		stz		NSMantissa0+4				; set the lower (slot 4) to 0 and upper (slot 7) to $FFFF
		stz 	NSMantissa1+4 				; these are the default top and bottom.
		lda 	#$FF
		sta 	NSMantissa0+7
		sta 	NSMantissa1+7
		;
		;		Now decode the various combinations of list [something],[something]
		;
		;
		;		First value.
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
		;
		;		Second value.
		;
_CLSecond:
		iny 								; consume comma		
		jsr 	CLIsDigit 					; digit found
		bcs 	_CLStart 					; if not, continue listing
		ldx 	#7 							; load 2nd range into slot 7
		jsr 	Evaluate16BitInteger
		;
		;		Loop through the whole program 
		;
_CLStart
		.cresetcodepointer
		;
_CLLoop:
		.breakcheck 		 				; break check here, as we want the option of breaking out of long lists.
		bne 	_CLBreak

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
		jsr 	CLListOneLine 				; routine to list the current line.
_CLNext:		
		.cnextline
		bra 	_CLLoop
_CLExit:
		jmp 	WarmStart
_CLBreak:
		.error_break


; ************************************************************************************************
;
;									List from procedure.
;
; ************************************************************************************************

_CLListProcedure:
		.cget 								; get the reference - look for this (4000-7FFF) in the code.
		sta 	zTemp1
		iny
		.cget
		sta 	zTemp1+1
		;
		;		Look for the procedure first.
		;
		.cresetcodepointer 					; search for it.
_CLLPSearch:
		.cget0 								; get offset
		cmp 	#0 							; if zero, end
		beq 	_CLExit		

		ldy 	#3 							; check if PROC something
		.cget
		cmp 	#KWD_PROC
		bne 	_CLLPNext
		iny 								; check if PROC this.
		.cget
		cmp 	zTemp1 						; does it match ?
		bne 	_CLLPNext
		iny
		.cget
		cmp 	zTemp1+1
		beq 	_CLLPFound
_CLLPNext:
		.cnextline
		bra 	_CLLPSearch
		;
		;		Procedure found, list until end of program or ENDPROC.
		;
_CLLPFound:
		.cget0 								; reached end
		beq 	_CLExit

		.breakcheck 		 				; break check
		bne 	_CLBreak

		ldy 	#3 							; get first keyword
		.cget
		pha
		jsr 	CLListOneLine 				; list line and go forward
		.cnextline
		pla 								; reached ENDPROC ?
		cmp 	#KWD_ENDPROC
		bne 	_CLLPFound
		jmp 	WarmStart

; ************************************************************************************************
;
;								List the current line
;
; ************************************************************************************************

CLListOneLine:
		jsr 	ScanGetCurrentLineStep 		; get indent adjust.
		jsr 	TKListConvertLine 			; convert line into token Buffer
		ldx 	#(tokenBuffer >> 8) 		; print that line
		lda 	#(tokenBuffer & $FF) 	
		jsr 	PrintStringXA
		lda 	#13 						; new line
		jsr 	EXTPrintCharacter
		rts

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
;		05/12/22 		LIST break reports.
;		15/12/22 		LIST silences sound.
;		02/01/23 		Break check call now a macro.
;		01/03/23 		LIST procedure checks break.
;
; ************************************************************************************************
