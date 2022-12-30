; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		openclose.asm
;		Purpose:	File Input/Output commands
;		Created:	30th December 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;				Set errors so not directly accessing variables.
;
; ************************************************************************************************

KERR_GENERAL = kernel.event.file.ERROR 		; Event $38
KERR_CLOSED = kernel.event.file.CLOSED 		; Event $32
KERR_NOTFOUND = kernel.event.file.NOT_FOUND ; Event $28
KERR_EOF = kernel.event.file.EOF 			; Event $30

; ************************************************************************************************
;
;				Open file for input/output, CS = failed (drive/file not found likely)
;
; ************************************************************************************************

Export_KNLOpenFileRead:
		pha
        lda     #kernel.args.file.open.READ ; set READ mode.
        sta     kernel.args.file.open.mode
        pla

		jsr 	KNLSetupFileName

        lda     #event & $FF 				; tell kernel where to store event data
        sta     kernel.args.events+0
        lda     #event >> 8
        sta     kernel.args.events+1

		lda 	#0 							; currently drive zero only.
		sta 	kernel.args.file.open.drive

        jsr     kernel.File.Open 			; open the file and exit.
        rts

; ************************************************************************************************
;
;									Close currently open file
;
; ************************************************************************************************

Export_KNLCloseFile:
		lda     event.file.stream 			; close the stream
		sta     kernel.args.file.close.stream
		jsr     kernel.File.Close
		rts

; ************************************************************************************************
;
;					Converts ASCIIZ filename in XA to Kernel internal format.
;
; ************************************************************************************************

KNLSetupFileName:
		phy 								; save Y on stack
		sta 	zTemp0 						; save filename position in temp, and in kenrel slot
		stx 	zTemp0+1
        sta     kernel.args.file.open.fname+0            
        stx     kernel.args.file.open.fname+1
        ;
        ldy 	#$FF 						; get the filename length => Kernel slot
_KNLGetLength:
		iny
		lda 	(zTemp0),y 					
		bne 	_KNLGetLength
		sty 	kernel.args.file.open.fname_len
		ply
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
