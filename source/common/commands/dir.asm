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
		lda     DefaultDrive				; set drive to list.
		sta     kernel.args.directory.open.drive
		stz     kernel.args.directory.open.fname_len
		jsr     kernel.Directory.Open
		bcs     _CDExit

_CDEventLoop:
		jsr     kernel.Yield        		; Polite, not actually needed.
		jsr     kernel.NextEvent
		bcs     _CDEventLoop

		lda     event.type  
		cmp     #kernel.event.directory.CLOSED
		beq    	_CDExit

		jsr     _CDMessages 				; handle various messages
		bra     _CDEventLoop
;
;		Dispatch messages
;		

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
		beq     _CDEVEOF
		rts

_CDEVRead:
		lda     event.directory.stream
		sta     kernel.args.directory.read.stream
		jmp     kernel.Directory.Read

_CDEVVolume:
		bra     _CDEVRead

_CDEVFile:
		lda 	#32
		jsr 	EXTPrintCharacter
		lda     event.directory.file.len
		jsr     _CDReadData
		jsr     _CDPrintData
		lda 	#13
		jsr 	EXTPrintCharacter
		bra     _CDEVRead

_CDEVFree:
		bra     _CDEVEOF

_CDEVEOF:
		lda     event.directory.stream
		sta     kernel.args.directory.close.stream
		jmp     kernel.Directory.Close

_CDExit:
		jmp 	WarmStart


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

		rts

; ************************************************************************************************
;
;								Print lineBuffer in lower case
;
; ************************************************************************************************

_CDPrintData:
		ldx 	#0
_CDPLoop:
		lda 	lineBuffer,x
		cmp		#"A"
		bcc 	_CDPNotUpper
		cmp 	#"Z"+1
		bcs 	_CDPNotUpper
		eor 	#32
_CDPNotUpper:
		jsr 	EXTPrintCharacter
		inx
		lda 	lineBuffer,x
		bne 	_CDPLoop
		rts

;read_ext
;		lda     #<buf
;		sta     kernel.args.recv.buf+0
;		lda     #>buf
;		sta     kernel.args.recv.buf+1
;		lda     #2
;		sta     kernel.args.recv.buflen
;
;		jmp     kernel.ReadExt

print_ext
; TODO: overlay the appropriate struct and read the members.
;
;		lda     buf+1
;		jsr     print_hex
;
;		lda     buf+0
;		jsr     print_hex
;
;		rts
;

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
