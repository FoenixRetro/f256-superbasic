; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		readfile.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	28th December 2022
;		Purpose :	Simple File Read Code
;
; ***************************************************************************************
; ***************************************************************************************

screenPos = $D0 							; physical position on screen
workSpace = $1000 							; working memory

; ***************************************************************************************
;
;										Boot up
;
; ***************************************************************************************

			* = $8000

			ldx     #$FF 					; set up stack and run main code.
			txs
			jmp 	start

			.include "api.asm"
			.include "display.asm"		

fileName:	.text 	"TEST"
fileNameEnd:

; ***************************************************************************************
;
;									Main Code
;
; ***************************************************************************************

start:		jsr 	displayInitialise 		; set up the very simple console I/O
			.status 'I','N'					; initialised.

; ---------------------------------------------------------------------------------------			
;						Tell Kernel where to store event data
; ---------------------------------------------------------------------------------------			

            lda     #event & $FF
            sta     kernel.args.events+0
            lda     #event >> 8
            sta     kernel.args.events+1

; ---------------------------------------------------------------------------------------			
;							Set the Drive # to read
; ---------------------------------------------------------------------------------------			

			lda 	#0 						; drive zero appears to be correct. 1-3 cause open to fail.
			sta 	kernel.args.file.open.drive

; ---------------------------------------------------------------------------------------			
;					Set the file name to 'TEST' and length to 4
; ---------------------------------------------------------------------------------------			

            lda     #fileName & $FF
            sta     kernel.args.file.open.fname+0            
            lda     #fileName >> 8
            sta     kernel.args.file.open.fname+1

            lda 	#fileNameEnd-fileName
			sta     kernel.args.file.open.fname_len

; ---------------------------------------------------------------------------------------			
;							Set the access mode to open
; ---------------------------------------------------------------------------------------			

            lda     #kernel.args.file.open.READ
            sta     kernel.args.file.open.mode

; ---------------------------------------------------------------------------------------			
;								Try to open the file
; ---------------------------------------------------------------------------------------			

            jsr     kernel.File.Open
            bcc 	FileOpened 				; carry set = Error.

            .status 'O','F' 				; Open Failed.
Halt:		jmp 	Halt

FileOpened:
			.status 'O','P'					; Open okay

; ---------------------------------------------------------------------------------------			
;								Now try to process events
; ---------------------------------------------------------------------------------------			

EventLoop:
			jsr     kernel.Yield    		; event wait		
			jsr     kernel.NextEvent
			bcs     EventLoop

			lda 	#'!' 					; print !event number
			jsr 	displayPrintCharacter
			lda	 	event.type
			jsr 	displayPrintHex
			jsr 	displayPrintSpace
			;
			lda 	event.type

			cmp     #kernel.event.file.ERROR ; Event $38
			beq     ReportA
			cmp     #kernel.event.file.CLOSED ; Event $32
			beq     ReportA
			cmp     #kernel.event.file.NOT_FOUND ; Event $28
			beq     ReportA

			cmp     #kernel.event.file.OPENED ; Event $2A
			beq     RequestRead
			cmp     #kernel.event.file.DATA ; Event $2C
			beq     RequestData
			cmp     #kernel.event.file.EOF ; Event $30

			bra 	EventLoop

; ---------------------------------------------------------------------------------------			
;						Request a read of a single character
; ---------------------------------------------------------------------------------------			

RequestRead:
            lda     event.file.stream 		; read which stream ?
            sta     kernel.args.file.read.stream

            lda     #1 						; so one byte at a time.
	        sta     kernel.args.file.read.buflen

            jsr     kernel.File.Read 		; read request
            bra 	EventLoop

; ---------------------------------------------------------------------------------------			
;									Data received
; ---------------------------------------------------------------------------------------			
			
RequestData:
			lda 	#1 						; want a single character
            sta     kernel.args.recv.buflen

            lda     #buffer & $FF
            sta     kernel.args.recv.buf+0
            lda     #buffer >> 8
            sta     kernel.args.recv.buf+1

            jsr     kernel.ReadData			; read the data into the buffer.

            lda 	event.file.data.read
            jsr 	displayPrintHex
            lda 	#"("
            jsr 	displayPrintCharacter           
            lda 	buffer
            jsr 	displayPrintCharacter
            lda 	#")"
            jsr 	displayPrintCharacter           
            jsr 	displayPrintSpace

            jmp 	RequestRead 			; more data please

; ---------------------------------------------------------------------------------------			
;			Close file, report ended with code 'A'
; ---------------------------------------------------------------------------------------			

ReportEOF:	
			lda 	#0			
ReportA:
			pha 							; display ER xx
			.status 'E','R'
			pla
			jsr 	displayPrintHexSpace

			lda     event.file.stream 		; close the stream
			sta     kernel.args.file.close.stream
			jsr     kernel.File.Close
			jmp 	Halt 					; and stop.
	
			* = workSpace

event       .dstruct    kernel.event.event_t

buffer 		.fill 	16
