; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		bsave.asm
;		Purpose:	BSAVE command (load binary)
;		Created:	4th January 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									Save a Binary File
;
; ************************************************************************************************

		.section code

Command_BSave: ;; [BSAVE]
		jsr 	BSaveHandler
		cmp 	#0
		bne 	_BSError
		rts
_BSError:		
		jmp 	CLErrorHandler

; ************************************************************************************************
;
;							BSAVE code ; returns A = 0 or error
;
; ************************************************************************************************

BSaveHandler:
		ldx 	#0
		jsr 	EvaluateString 				; file name to load
		jsr 	CheckComma 					; consume comma
		inx 							
		jsr 	EvaluateInteger 			; load address (full physical address)
		jsr 	CheckComma 					; consume comma
		inx 							
		jsr 	EvaluateInteger 			; data length (3 bytes only)
		
		phy
		;
		;		Try to open the file.
		;
		lda 	NSMantissa0					; file name -> XA
		ldx 	NSMantissa1
		jsr 	KNLOpenFileWrite 			; open file for reading
		bcs 	_BSErrorExit 				; error, so fail.
		sta 	BasicFileStream 			; save the reading stream.

		;
		;		Open memory for access
		;
		ldx 	#1 							; address is in slot # 1
		jsr 	BLOpenPhysicalMemory 		; open for access.
		;
		ldx 	#0 							; number of bytes in kernel buffer
		ldy 	BLYOffset 					; used for data offset.
		;
		;		Main write loop.
		;
_BSWriteToFileLoop:
		sec 								; pre decrement count.
		lda 	NSMantissa0+2 				
		sbc 	#1
		sta 	NSMantissa0+2
		;
		lda 	NSMantissa1+2 				
		sbc 	#0
		sta 	NSMantissa1+2
		;
		lda 	NSMantissa2+2 
		sbc 	#0
		sta 	NSMantissa2+2
		bmi 	_BSFileComplete 			; undercounted, so exit.
		;
		lda 	(zTemp2),y 					; get byte to save
		sta 	KNLReadBuffer,x 			; save in the buffer and bump buffer index
		inx
		;
		iny 								; next byte
		bne 	_BSNoCheck
		jsr 	BLAdvancePhysicalMemory 	; check not gone to next page.
_BSNoCheck:
		cpx 	#KNLReadBufferLen 			; done the whole buffer
		bne 	_BSWriteToFileLoop 			; no , do the next byte.
		jsr 	BSFlushBuffer 				; yes, flush the buffer
		bra 	_BSWriteToFileLoop 			; and keep on going
		;
		;		Written whole file, except possibly some left in the buffer.
		;
_BSFileComplete:
		jsr 	BSFlushBuffer 				; write the buffer remainder.
		jsr 	BLClosePhysicalMemory 		; close the access.
		lda 	BasicFileStream 			; close the file
		jsr 	KNLCloseFile
		lda 	#0
		ply
		rts
		;
		;		Handle error, file never opened, file handling stuff.
		;
_BSErrorExit:
		ply
		rts

; ************************************************************************************************
;
;									Flush Buffer to file.
;		
; ************************************************************************************************

BSFlushBuffer:
		cpx 	#0 							; buffer empty ?
		beq 	_BSFBExit 					; if so, exit.
		lda 	#KNLReadBuffer & $FF 		; where to write from.
		sta 	zTemp0
		lda 	#KNLReadBuffer >> 8
		sta 	zTemp0+1 					; # of bytes in X
		jsr 	CLWriteByteBlock 			; write it.
		ldx 	#0 							; buffer is empty.
_BSFBExit:		
		rts

		.send code

		.section storage
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
