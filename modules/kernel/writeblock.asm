; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		writeblock.asm
;		Purpose:	Wrote a block of memory to 
;		Created:	30th December 2022
;		Reviewed: 	No
;		Authors:	Paul Robson (paul@robsons.org.uk)
;                   Jessie Oberreuter (gadget@hackwrenchlabs.com)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;							Write data at (zTemp0) to Stream A, X bytes.
;
;					  On error CS ; A = code. On success, CC, A = bytes read.
;
; ************************************************************************************************

Export_KNLWriteBlock:
		phx
		phy
		;
		;		Already handled OPENED so can write out.
		;
		sta     kernel.args.file.write.stream ; save the stream.

		lda     zTemp0 						; save the data location.
		sta     kernel.args.file.write.buf+0
		lda     zTemp0+1
		sta     kernel.args.file.write.buf+1
	  
		stx     kernel.args.file.write.buflen ; Set the buffer length

		jsr     kernel.File.Write 			; write it out.
		lda 	#kernel.event.file.ERROR 	; in case it fails.
		bcs 	_KWBFailed

_KNLWLoop:									; wait for an event.
		jsr     kernel.Yield        
		jsr     kernel.NextEvent
		bcs     _KNLWLoop

		lda     event.type 					; various errors.
		cmp     #kernel.event.file.CLOSED
		beq 	_KWBFailed
		cmp     #kernel.event.file.ERROR
		beq 	_KWBFailed
		cmp     #kernel.event.file.EOF
		beq 	_KWBFailed

		cmp     #kernel.event.file.WROTE 	; wait until block write succeeds
		bne 	_KNLWLoop      
		clc
		lda    event.file.wrote.wrote 		; get bytes written.
		bra 	_KWBExit

_KWBFailed:
		sec
_KWBExit:
		ply
		plx
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
