; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		readbyte.asm
;		Purpose:	Read a single byte from the currently open file.
;		Created:	30th December 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;				Read one character into A. CC = succeeded, CS = failed, A = Event error
;
; ************************************************************************************************

Export_KNLReadByte:

EventLoop:
		jsr     kernel.Yield    			; event wait		
		jsr     kernel.NextEvent
		bcs     EventLoop
		lda 	event.type 					; get event		
		;
		;		One of the error events.
		;
		cmp     #kernel.event.file.ERROR 
		beq 	_KNLRBFail
		cmp     #kernel.event.file.CLOSED
		beq     _KNLRBFail
		cmp     #kernel.event.file.NOT_FOUND 
		beq 	_KNLRBFail
		cmp     #kernel.event.file.EOF
		beq 	_KNLRBFail

		cmp     #kernel.event.file.OPENED 	; opened, do first read
		beq     _KNLRBRequestData
		cmp     #kernel.event.file.DATA 	; data, return data
		beq     _KNLRBAcquireData

		bra 	EventLoop
		;
		;		OPENED received, request first byte, then wait for it.
		;
_KNLRBRequestData:
		jsr 	KNLRequestNextByte 		
		bra 	EventLoop
		;
		;		DATA received, retrieve first byte, request next and return.
		;
_KNLRBAcquireData:
		lda 	#1 							; want a single character
        sta     kernel.args.recv.buflen

        lda     #zTemp0 & $FF 				; read it to zTemp0
        sta     kernel.args.recv.buf+0
        lda     #zTemp0 >> 8
        sta     kernel.args.recv.buf+1

        jsr     kernel.ReadData				; read the data into the buffer.
        lda 	zTemp0						; get it
        pha 								; save it
        jsr 	KNLRequestNextByte 			; request next byte.
        pla
        clc 								; return CC
        rts

_KNLRBFail:
		sec
		rts

KNLRequestNextByte:       
        lda     event.file.stream 			; read which stream ?
        sta     kernel.args.file.read.stream

        lda     #1 							; so one byte at a time.
        sta     kernel.args.file.read.buflen

        jsr     kernel.File.Read 			; read request
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
