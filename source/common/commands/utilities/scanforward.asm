; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		scanforward.asm
;		Purpose:	Look for closing structures
;		Created:	1st October 2022
;		Reviewed: 	
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
; Scan forward from current position looking for closing token A or X. Return matching token in A
;
; ************************************************************************************************

ScanForward:

		sta 	zTemp0 						; save XA as the two possible matches.
		stx 	zTemp0+1
		stz 	zTemp1 						; this is the structure count - goes up with WHILE/FOR
		;									; and down with WEND/NEXT
		;
		; 		Main Scanning Loop
		;
_ScanLoop:
		.cget 								; get next and consume it
		iny

		ldx 	zTemp1 						; if the count is > 0 cannot match as in substructure
		bne 	_ScanGoNext
		;
		cmp 	zTemp0 						; see if either matches
		beq 	_ScanMatch
		cmp 	zTemp0+1
		bne 	_ScanGoNext		
_ScanMatch:									; if so, exit after skipping that token.
		cmp 	#KWC_EOL 					; if asked for EOL, backtrack.
		bne 	_ScanNotEndEOL
		dey
_ScanNotEndEOL:		
		rts 					
		;
		;		Advance. Token in A
		;
_ScanGoNext:
		cmp 	#$40 						; if 00-3F, punctuation characters, loop back
		bcc 	_ScanLoop
		cmp 	#KWC_FIRST_UNARY 			; if 40-82, skip one extra.
		bcc 	_ScanSkipOne
		cmp 	#$FC 						; FC-FF are data skips
		bcs 	_ScanSkipData
		;
		cmp 	#KWC_FIRST_STRUCTURE 		; structure keyword ?
		bcc 	_ScanLoop 					; if not, ordinary keywords.
		cmp 	#KWC_LAST_STRUCTURE+1
		bcs 	_ScanLoop
		;
		;		Structure code - can go up and down.
		;
		dec 	zTemp1 						; decrement the sructure count
		cmp 	#KWC_FIRST_STRUCTURE_DEC 	; back if it is a dec structure (e.g. WEND/NEXT)
		bcs 	_ScanLoop
		inc 	zTemp1 						; so it's an increment structure
		inc 	zTemp1 						; twice to undo the dec
		bra 	_ScanLoop
		;
		;		+2 ; for 40-7F (Variable) 80 (New line) and 81-82 (Shifts)
		;
_ScanSkipOne:		
		iny 								; consume the extra one.
		cmp 	#KWC_EOL 					; if not EOL loop back
		bne 	_ScanLoop
		;
		.cnextline 							; go to next line
		ldy 	#3 							; scan start position.
		.cget0 								; read the offset
		bne 	_ScanLoop 					; if not zero, more to scan
		.error_struct 						; couldn't find either token at level zero.
		;
		;		Skip data structure
		;
_ScanSkipData:
		;
		dey 								; point at data token
		.cskipdatablock 					; skip block
		bra 	_ScanLoop
		.send code

; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ************************************************************************************************

