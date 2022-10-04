; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		read.asm
;		Purpose:	Read from Data statement
;		Created:	4th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;											READ command
;
; ************************************************************************************************

Command_Read:	;; [read]
		;
		;		Get the thing to read into.
		;
		ldx 	#0 							; evaluate the term which is the var/array element to assign
		jsr 	EvaluateTerm
		lda 	NSStatus,x
		and 	#NSBIsReference				; get status byte on stack, identifies int, float, string.
		beq 	_CRSyntax 					; check reference (bit 0)
		;
		;		Now find something to be DATA
		;
		jsr 	SwapDataCodePtrs 			; swap code and data
		lda 	inDataStatement 			; if in a data statement, we don't need to search
		bne 	_CRContinueData
		;
		;		Look for Data.
		;
_CRKeepSearching:		
		lda 	#KWD_DATA 					; scan for instruction
		tax
		jsr 	ScanForward
		cmp 	#KWD_DATA 					; found data ?
		beq 	_CRHaveData 				; found it
		.cnextline 							; goto next instruction
		ldy 	#3 							; start of line.
		.cget0 								; check there is one.
		bne 	_CRKeepSearching
		.error_data
		;
		; 		Now have codePtr (dataPtr really) pointing at DATA keyword
		;
_CRHaveData:
_CRContinueData:		
		;
		ldx 	#1 			
		jsr 	EvaluateValue 				; evaluate value into slot # 1
		dex
		jsr		AssignVariable 				; do the assignment
		;
		stz 	inDataStatement 			; clear in data
		.cget 								; followed by a comma ?
		cmp 	#KWD_COMMA 					; if not, end of data statement
		bne 	_CRSwapBack
		iny 								; consume comma
		inc 	inDataStatement 			; set in data statement currently.
_CRSwapBack:		
		jsr 	SwapDataCodePtrs			; swap them back.		
		.cget 								; followed by a comma
		iny
		cmp 	#KWD_COMMA
		beq 	Command_Read 				; if so go round again.
		dey 								; unpick get.
		rts

_CRSyntax:
		jmp 	SyntaxError

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
