; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		load.asm
;		Purpose:	Kernel load routines
;		Created:	24th December 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;											Load file
;
; ************************************************************************************************

Export_KNLLoadFile:
		;
		;		Drive number (letter ?)
		;
		lda 	#0
        sta     kernel.args.file.open.drive
        ;
        ;		File Name
        ;
        lda 	#fname & $FF
        sta     kernel.args.file.open.fname+0            
        lda     #fname >> 8
        sta     kernel.args.file.open.fname+1
        ;
        ;		File Name length :-( ASCIIZ rules.
        ;
        lda     #4
        sta     kernel.args.file.open.fname_len
        ;
        ;		Open file, $FF on error.
        ;
        lda     #kernel.args.file.open.READ
        sta     kernel.args.file.open.mode
        jsr     kernel.File.Open
        bcs     error 		
        ;
        ;		Event loop
        ;
events:
		jsr 	kernel.nextevent
		bcs 	events

        lda     event.type  						
        jsr 	PAGEDPrintHex
        ;
        ;		Error events.
        ;
		cmp     #kernel.event.file.CLOSED
		beq     outch
		cmp     #kernel.event.file.NOT_FOUND
		beq     outch
        cmp     #kernel.event.file.ERROR
        beq     outch
        ;
        ;		Non error events
        ;
        cmp     #kernel.event.file.EOF 			; go closed
        beq     eof
        cmp     #kernel.event.file.OPENED 		; start read cycle
        beq     read
        cmp     #kernel.event.file.DATA 		; data received
        beq     data
        bra 	events
        ;
        ;		Request a read
        ;
read:
		lda     event.file.stream 				; set stream to read
		sta     kernel.args.file.read.stream
		lda 	#1 								; read 1 byte
        sta     kernel.args.file.read.buflen
        jsr 	kernel.file.read
        bra 	events 							; wait for result.
        ;
        ;		Data available ?
        ;
data:		
		lda     event.file.data.read 			; amount of data read ?
        sta     kernel.args.recv.buflen

        lda     #zTemp0 & $FF 					; where it goes
        sta     kernel.args.recv.buf+0
        lda     #zTemp0 >> 8
        sta     kernel.args.recv.buf+1

        jsr     kernel.ReadData 				; copy the read data

        lda 	zTemp0 							; display it.
        jsr 	PAGEDPrintCharacter
        bra 	read	 						; request another read.
        ;
        ;		EOF so close file.
        ;
eof:
		pha 									; save even to display.
        lda     event.file.stream
        sta     kernel.args.file.close.stream
        jsr     kernel.File.Close
        pla
outch:	jsr 	PAGEDPrintHex
h1:		bra 	h1
error:	lda 	#$FF
		bra 	outch

fname:	.text 	"test"

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
