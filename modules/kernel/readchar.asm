; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		readbyte.asm
;		Purpose:	Read a single byte from the currently open file.
;		Created:	30th December 2022
;		Reviewed: 	No
;		Authors:	Paul Robson (paul@robsons.org.uk)
;                   Jessie Oberreuter (gadget@hackwrenchlabs.com)
;
; ************************************************************************************************
; ************************************************************************************************

KNLBufLen = 64 								; read buffer size.

		.section storage

KNLStream:   								; stream to read from
		.byte   ? 						
KNLBuf:      								; buffer 
		.fill   KNLBufLen 				
KNLNext:     								; next byte to return
		.byte   ? 						
KNLEnd:      								; end of bytes available.
		.byte   ? 						

		.send storage        

		.section code

; ************************************************************************************************
;
;				Init the reader.  A = file stream; can't fail.
;
; ************************************************************************************************

Export_KNLReadByteInit:
		sta     KNLStream 					; save stream
		stz     KNLNext 					; reset buffer
		stz     KNLEnd
		rts

; ************************************************************************************************
;
;				Read one character into A. CC = succeeded, CS = failed, A = Event error
;               Stream closed and CS when finished (A = EOF)
;
; ************************************************************************************************

Export_KNLReadByte:
		phx

		ldx     KNLNext 					; all data consumed ?
		cpx     KNLEnd
		bne     _KNLRBGetNextByte
		;
	  	; 		Buffer empty; try to fetch more.
	  	;
		jsr     KNLRBGetNextBlock 			; read next chunk from the stream
		bcs     _KNLRBError 				; error has occurred on read.
		;
		sta     KNLEnd 						; # read is the number available
		ldx     #0 							; reset the read pointer.
		stx     KNLNext
		;
		;		Get next byte from the buffer
		;
_KNLRBGetNextByte:
		lda     KNLBuf,x 					; get the next data item
		inc     KNLNext 					; and advance the index
		clc 								; succeeded
_KNLRBError:
		plx
		rts

; ************************************************************************************************
;
;								Read next block from the stream
;
; ************************************************************************************************

KNLRBGetNextBlock:
		lda     KNLStream 					; set stream to read from
		sta     kernel.args.file.read.stream

		lda     #KNLBufLen 					; set bytes to read.
		sta     kernel.args.file.read.buflen

		jsr     kernel.File.Read 			; read request
		lda     #kernel.event.file.ERROR    ; Kernel out of events/buffers; shouldn't happen
		bcs     _KGNBExitFail               ; report as general error

_KGRBEventLoop:
		jsr     kernel.Yield    			; event wait		
		jsr     kernel.NextEvent
		bcs     _KGRBEventLoop

		lda 	event.type 					; get event		

		cmp     #kernel.event.file.DATA 	; data, return data
		beq     _KNLRBGetNextByte

		cmp     #kernel.event.file.ERROR  	; errors on file i/o, return as appropriate.
		beq 	_KGNBExitFail

		cmp     #kernel.event.file.EOF
		beq 	_KGNBExitFail

		bra 	_KGRBEventLoop
		;
		;		Get the next data block into the buffer
		;
_KNLRBGetNextByte:

		lda     #<KNLBuf 					; Set the target buffer
		sta     kernel.args.recv.buf+0
		lda     #>KNLBuf
		sta     kernel.args.recv.buf+1

		lda     event.file.data.read 		; Set the target length
		sta     kernel.args.recv.buflen	  										

		jsr     kernel.ReadData		       	; Get the data from the kernel  (Synchronous call, no error)
		lda     event.file.data.read 		; Return # of bytes read (in A)

		clc
		rts

_KGNBExitFail:
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
