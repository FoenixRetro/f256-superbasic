; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		insert.asm
;		Purpose:	Insert line into code
;		Created:	5th October 2022
;		Reviewed: 	16th December 2022
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;				Insert line in tokenbuffer space at current codePtr point (CC) end (CS)
;		
; ************************************************************************************************

MemoryInsertLine:
		php
		jsr 	IMemoryFindEnd 				; find end to zTemp2.

		lda 	zTemp2+1 					; is there space for the new line ?
		inc 	a
		cmp 	#(BasicEnd >> 8)-1
		bcs 	_MDLIError 					; no, fail.
		;
		plp 								; do at a specific point or the end ?
		bcc 	_MDLIFound 					; if specific point already set.
		;
		lda 	zTemp2 						; if CS on entry append, so put on the
		sta 	codePtr 					; end.
		lda 	zTemp2+1
		sta 	codePtr+1
		;
		;		zTemp2 is top, codePointer is insert point. Make space for the token buffer
		;	 	data (offset, line#, buffer)
		;
_MDLIFound:
		lda 	tokenOffset 				; insert gap in Y, the offset, e.g. length of the new line
		tay
_MDLIInsert:		
		lda 	(zTemp2) 					; shift one byte up , at least one covers end case (copying link 0)
		sta 	(zTemp2),y 					; work from top down.

		lda 	codePtr 					; reached insert point ?
		cmp 	zTemp2
		bne 	_MDLINext
		lda 	codePtr+1
		cmp 	zTemp2+1
		beq 	_MDLIHaveSpace
_MDLINext:
		lda 	zTemp2 						; if no, keep zTemp2 going backwards opening up space.
		bne 	_MDLINoBorrow
		dec 	zTemp2+1
_MDLINoBorrow:
		dec 	zTemp2
		bra 	_MDLIInsert
		;
		;		Now we have the space, copy the buffer in.
		;
_MDLIHaveSpace:		
		ldy 	tokenOffset 				; bytes to copy
		dey 								; from offset-1 (last written) to the end of the buffer.
_MDLICopy:
		lda 	tokenOffset,y
		sta 	(codePtr),y
		dey
		bpl 	_MDLICopy
		rts

_MDLIError:
		.error_memory

; ************************************************************************************************
;
;									Append line at XA
;
;			Can just jump to MDLInsertLine. This allows optimisation of the appending
;
; ************************************************************************************************

MDLAppendLine:
		stx 	zTemp0+1 					; save new line at zTemp0
		sta 	zTemp0

		.set16 	zTemp1,BasicStart 			; check if program empty.
		lda 	(zTemp1)
		bne 	_MDLANoInitialise
		.set16 	AppendPointer,BasicStart 	; reseet the append pointer

_MDLANoInitialise:
		clc
		lda 	AppendPointer 				; copy append pointer to zTemp1 adding the offset as you go
		sta 	zTemp1
		adc 	(zTemp0)
		sta 	AppendPointer
		lda 	AppendPointer+1
		sta 	zTemp1+1
		adc 	#0
		sta 	AppendPointer+1
		;
		ldy 	#0
_MDLACopy:
		lda 	(zTemp0),y 					; copy new line in
		sta 	(zTemp1),y
		iny
		tya	
		cmp 	(zTemp0) 					; done whole line
		bne 	_MDLACopy
			
		lda 	#0 							; end of program.
		sta 	(zTemp1),y

		rts

		.send code

		.section storage
AppendPointer:
		.fill 	2
		.send storage		

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
	