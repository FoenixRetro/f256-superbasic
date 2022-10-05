; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		insert.asm
;		Purpose:	Insert line into code
;		Created:	5th October 2022
;		Reviewed: 	No.
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;						Insert line at XA into the program at the current point
;		
; ************************************************************************************************

MDLInsertLine:
		stx 	zTemp0+1 					; save line address at zTemp0
		sta 	zTemp0
		jsr 	MDLFindEnd					; top of program at zTemp2
		;
		lda 	zTemp2+1 					; check space
		inc 	a
		cmp 	#LowMemory >> 8
		bcs 	_MDLIMemory
		;
		.set16 	zTemp1,BasicStart 			; look for either program, or Top.
		;
_MDLIFind:
		lda 	(zTemp1) 					; reached end
		beq 	_MDLIFound 					; have found the insert point.
		ldy 	#1 							; signed line numbe comparison.
		lda 	(zTemp1),y
		cmp 	(zTemp0),y
		iny
		lda 	(zTemp1),y
		sbc 	(zTemp0),y
		bcs 	_MDLIFound 					; found line >= required line.
		;
		lda 	(zTemp1) 					; advance to next
		clc 	
		adc 	zTemp1
		sta 	zTemp1
		bcc 	_MDLIFind
		inc 	zTemp1+1
		bra 	_MDLIFind
		;
		;		zTemp2 is top, zTemp0 is source to insert, zTemp1 is insert point.
		;
_MDLIFound:
		lda 	(zTemp0) 					; insert gap in Y
		tay
_MDLIInsert:		
		lda 	(zTemp2) 					; shift one byte up , at least one covers end case.
		sta 	(zTemp2),y 					; work from top down.

		lda 	zTemp1 						; done insert point ?
		cmp 	zTemp2
		bne 	_MDLINext
		lda 	zTemp1+1
		cmp 	zTemp2+1
		beq 	_MDLIHaveSpace
_MDLINext:
		lda 	zTemp2 						; if no, keep zTemp2 going backwards
		bne 	_MDLINoBorrow
		dec 	zTemp2+1
_MDLINoBorrow:
		dec 	zTemp2
		bra 	_MDLIInsert
		;
		;		Space at zTemp1 for zTemp2 data
		;
_MDLIHaveSpace:		
		lda 	(zTemp0) 					; bytes to copy
		tay
_MDLICopy:
		dey
		lda 	(zTemp0),y
		sta 	(zTemp1),y
		cpy 	#$00
		bne 	_MDLICopy
		rts

_MDLIMemory:
		ERR_MEMORY

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
	