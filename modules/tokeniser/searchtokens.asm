; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		searchtokens.asm
;		Purpose:	Seach token table for a specific identifier
;		Created:	19th September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;	Search the token table at YA for the currently selected identifier. Returns CS and token ID
; 	in A if found, CC if not found
;
; ************************************************************************************************

TOKSearchTable:
		sty 	zTemp0+1 					; (zTemp0),y points to current token.
		sta 	zTemp0
		ldy 	#0
		lda 	#$80 						; token #
		sta 	zTemp1
		;
		;		Token search loop
		;
_TSTLoop:
		lda 	(zTemp0),y 					; length, 0 (skip) -ve (end)
		bmi 	_TSTFail 					; -ve = end of table
		beq 	_TSTNext 					; zero, check next it's a dummy
		;
		iny 								; get the hash
		lda 	(zTemp0),y
		dey
		cmp 	identHash 					; check they match, if not go to next
		bne 	_TSTNext

		lda 	identTypeEnd 				; length of identifier
		sec
		sbc 	identStart
		cmp 	(zTemp0),y 					; no match, then return.
		bne 	_TSTNext
		;
		phy 								; save Y , we might fail
		iny 								; point to text 	
		iny
		ldx 	identStart 					; offset in line buffer in X
_TSTCompareName:
		lda 	lineBuffer,x 				; compare text.
		cmp 	(zTemp0),y
		bne 	_TSTNextPullY 				; fail, pullY and do next
		inx
		iny
		cpx 	identTypeEnd 				; complete match.
		bne 	_TSTCompareName
		ply 								; throw Y
		lda 	zTemp1 						; get token #
		sec 								; return with CS = passed.
		rts
_TSTNextPullY:
		ply 								; restore current, fall through.		
		;
		;		Go to next token.
		;		
_TSTNext:
		inc 	zTemp1 						; token counter
		tya
		clc
		adc 	(zTemp0),y 					; add [Length] + 2 to Y
		inc 	a 							; +1
		inc 	a 							; +2
		tay 			
		bpl 	_TSTLoop 					; if Y < $80 loop back
		;
		tya 								; add Y to zTemp0 and reset Y
		ldy 	#0   						; so we can use Y to search fast
		clc  								; but have tables > 255 bytes
		adc 	zTemp0 						; when Y gets >= 128 we reset Y
		sta 	zTemp0 						; and adjust the table pointer/
		bcc 	_TSTLoop
		inc 	zTemp0+1
		bra 	_TSTLoop

_TSTFail:		
		clc
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
