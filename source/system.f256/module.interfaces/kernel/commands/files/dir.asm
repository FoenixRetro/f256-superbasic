; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		dir.asm
;		Purpose:	List directory of default drive
;		Created:	1st January 2023
;		Reviewed:	No.
;		Author:		Paul Robson (paul@robsons.org.uk)
;					Jessie Oberreuter (gadget@hackwrenchlabs.com)
;
; ************************************************************************************************
; ************************************************************************************************

	.section code

; ************************************************************************************************
;
;									DIR command
;
; ************************************************************************************************

Command_Dir:	;; [dir]
		phy
		lda     KNLDefaultDrive				; set drive to list.
		sta     kernel.args.directory.open.drive
		stz     kernel.args.directory.open.path_len
		jsr     kernel.Directory.Open
		bcs     _CDExit

_CDEventLoop:
		jsr     GetNextEvent
		bcc     _CDProcessEvent
		jsr     kernel.Yield        		; Polite, not actually needed.
		bra     _CDEventLoop
    
_CDProcessEvent
		lda     KNLEvent.type
		cmp     #kernel.event.directory.CLOSED
		beq    	_CDSuccess

		jsr     _CDMessages 				; handle various messages
		bra     _CDEventLoop
_CDSuccess:
		ply
		lda     #0
		clc
		rts
_CDExit:
		ply
		jmp 	WarmStart

;
;		Dispatch messages
;		
_CDEVErr:
		lda     KNLEvent.directory.stream
		sta     kernel.args.directory.close.stream
		jmp     kernel.Directory.Close


_CDMessages:
		cmp     #kernel.event.directory.OPENED
		beq     _CDEVRead
		cmp     #kernel.event.directory.VOLUME
		beq     _CDEVVolume
		cmp     #kernel.event.directory.FILE
		beq     _CDEVFile
		cmp     #kernel.event.directory.FREE
		beq     _CDEVFree
		cmp     #kernel.event.directory.EOF
		beq     _CDEVEOF
		cmp     #kernel.event.directory.ERROR
		beq     _CDEVErr
		rts


_CDEVRead:
		lda     KNLEvent.directory.stream
		sta     kernel.args.directory.read.stream
		jmp     kernel.Directory.Read

_CDEVVolume:
		lda 	#"["
		jsr 	EXTPrintCharacter
		lda     KNLEvent.directory.volume.len
		jsr     _CDReadData
		jsr 	PrintStringXA
		lda 	#"]"
		jsr 	EXTPrintCharacter
		lda 	#13
		jsr 	EXTPrintCharacter
		bra     _CDEVRead

_CDEVEOF:
		lda     KNLEvent.directory.stream
		sta     kernel.args.directory.close.stream
		jsr     kernel.Directory.Close
		rts


_CDEVFile:
		lda 	#32
		jsr 	EXTPrintCharacter
		lda     KNLEvent.directory.file.len
		pha
		jsr     _CDReadData
		jsr 	PrintStringXA
		pla
		eor 	#$FF
		sec
		adc 	#16
		tax
_CDEVTab:
		lda 	#32
		jsr 	EXTPrintCharacter
		dex
		bpl 	_CDEVTab
		jsr 	_CDReadExtended
		lda 	lineBuffer
		ldx 	lineBuffer+1
		jsr 	ConvertInt16
		jsr 	PrintStringXA
		ldx 	#_CDEVFMessage >> 8
		lda 	#_CDEVFMessage & $FF
		jsr 	PrintStringXA
		bra     _CDEVRead

_CDEVFMessage:
		.text 	" block(s).",13,0
_CDEVFree:
		jsr     _CDReadExtended
		lda 	lineBuffer
		ldx 	lineBuffer+1
		jsr 	ConvertInt16
		jsr 	PrintStringXA
		ldx 	#_CDEVFreeMessage >> 8
		lda 	#_CDEVFreeMessage & $FF
		jsr 	PrintStringXA
		bra     _CDEVEOF

_CDEVFreeMessage:
		.text 	" blocks free.",13,0

;
; 		IN: A = # of bytes to read
;
_CDReadData:

		sta     kernel.args.recv.buflen

		lda     #lineBuffer & $FF
		sta     kernel.args.recv.buf+0
		lda     #lineBuffer >> 8
		sta     kernel.args.recv.buf+1
		jsr     kernel.ReadData

		ldx     kernel.args.recv.buflen
		stz     lineBuffer,x

		lda 	#lineBuffer & $FF
		ldx 	#lineBuffer >> 8
		rts

_CDReadExtended:
		lda     #2
		sta     kernel.args.recv.buflen
		lda     #lineBuffer & $FF
		sta     kernel.args.recv.buf+0
		lda     #lineBuffer >> 8
		sta     kernel.args.recv.buf+1
		jmp     kernel.ReadExt



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
