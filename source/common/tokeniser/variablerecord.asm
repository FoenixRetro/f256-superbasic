; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		variablerecord.asm
;		Purpose:	Handle a possibly new variable identifier
;		Created:	19th September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;		Check to see if the currently specified identifier is in the table.  If not, create it
; 		as specified.
;
;		Then compile a reference to it in the tokenised code.
;
; ************************************************************************************************

CheckCreateVariableRecord:
		.set16 	zTemp0,VariableSpace 		; initialise pointer
		jsr 	VariableOpen 				; make variable space available
		;
		;		Search the variable table to see if it already exists
		;
_CCVSearch:
		lda 	(zTemp0) 					; end of list
		beq 	_CCVFail
		ldy 	#1 							; read the hash 
		lda 	(zTemp0),y 					; does it match ?
		cmp 	identHash 					
		bne 	_CCVNext
		;
		;		Compare the identifier to the variable record. We don't match
		; 		types because these could be reset in the procedure code.
		;
		ldy 	#8 							; name in variable record
		ldx 	identStart
_CCVCompare:
		lda 	lineBuffer,x 				; xor them. zero if the same, except
		eor 	(zTemp0),y 					; bit 7 is used for EOS.
		inx 								; advance pointers
		iny 	
		asl 	a 							; A = 0 if they match, CS if end.
		bne 	_CCVNext  					; didn't match go to next.
		bcc 	_CCVCompare 				; not finished yet.
		;
		cpx 	identTypeEnd 				; matched whole thing ?
		beq 	_CCVFound 					; yes, we were successful
		;
_CCVNext:
		clc
		lda 	(zTemp0) 					; add offset to pointer
		adc 	zTemp0
		sta 	zTemp0
		bcc 	_CCVSearch
		inc 	zTemp0+1
		bra 	_CCVSearch				
		;
		;		Could not find the identifier. zTemp0 points to the free space in the
		;		variable storage, conveniently.
		;
_CCVFail:
		ldy 	#1 							; create the new record. Offset 1 is hash
		lda 	identHash
		sta 	(zTemp0),y
		iny 								; offset 2 is the type byte
		lda 	identTypeByte 				
		sta 	(zTemp0),y
		iny
_CCVData:
		lda 	#0 							; erase data 3-7
		sta 	(zTemp0),y
		iny
		cpy 	#8
		bcc 	_CCVData
		ldx 	identStart 					; copy name into 8 on.
_CCVCopyName:
		lda 	lineBuffer,x
		sta 	(zTemp0),y
		inx
		iny
		cpx 	identTypeEnd
		bne 	_CCVCopyName
		;
		tya 								; patch offset
		sta 	(zTemp0)
		lda 	#0 							; offset for next is zero.
		sta 	(zTemp0),y
		;
		dey
		lda 	(zTemp0),y 					; set bit 7 of last bit
		ora 	#$80
		sta 	(zTemp0),y
		;
		;
		;		Variable record at zTemp0 - output to tokeniser
		;		
_CCVFound:
		jsr 	VariableClose 				; map out variables, perhaps.
		lda 	zTemp0+1 					; write out MSB
		sec
		sbc 	#(VariableSpace >> 8) 		; offset from the start
		ora 	#$40 						; make it a writeable token
		jsr 	TokeniseWriteByte
		lda 	zTemp0 						; write out LSB
		jsr 	TokeniseWriteByte
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
