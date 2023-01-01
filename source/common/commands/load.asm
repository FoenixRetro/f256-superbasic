; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		load.asm
;		Purpose:	LOAD command
;		Created:	30th December 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									LOAD a Basic file
;
; ************************************************************************************************

		.section code

Command_Load: ;; [LOAD]
		jsr 	EvaluateString 				; file name to load

		ldx 	zTemp0+1					; zTemp0 -> XA
		lda 	zTemp0 
		jsr 	KNLOpenFileRead 			; open file for reading
		bcs 	CLErrorHandler 				; error, so fail.
		sta 	CurrentFileStream 			; save the reading stream.

		jsr     KNLReadByteInit             ; Init reader with the stream
		jsr 	NewProgram 					; does the actual NEW.
		stz 	LoadEOFFlag 				; clear EOF Flag.
_CLLoop:
		jsr 	LoadReadLine 				; get next line.
		beq 	_CLExit 					; end, exit.

		jsr 	TKTokeniseLine 				; tokenise the line.

		lda 	tokenLineNumber 			; line number = 0
		ora 	tokenLineNumber+1
		beq 	_CLLoop 					; not legal code, blank line or maybe a comment.

		jsr 	EditProgramCode 			; do the editing etc.	
		bra 	_CLLoop
		;
		;		File loaded
		;
_CLExit:			
		lda 	CurrentFileStream
		jsr 	KNLCloseFile
		;
		;		Complete message - it's a bit slow.
		;		
CLComplete:
		lda 	#_CLCMsg & $FF
		ldx 	#_CLCMsg >> 8
		jsr 	PrintStringXA
		jmp 	WarmStart
_CLCMsg:
		.text 	"Complete.",13,0
		;
		;		Close file and handle error
		;
CLCloseError:
		pha
		lda 	CurrentFileStream
		jsr 	KNLCloseFile
		pla
		;
		;		Handle error, file never opened, file handling stuff.
		;
CLErrorHandler:
		cmp 	#KERR_NOTFOUND
		beq 	_CLEHNotFound
		.error_driveio
_CLEHNotFound:
		.error_notfound		

; ************************************************************************************************
;
;				Read line into lineBuffer ; return Z set if no more lines
;	
; ************************************************************************************************

LoadReadLine:
		ldx 	#0 							; look for first character non space/ctl
		jsr 	LoadReadCharacter
		beq 	_LRLExit 					; eof ?
		cmp 	#' '+1 						; space control tab skip
		bcc 	LoadReadLine
_LRLLoop:
		sta 	lineBuffer,x 				; write into line buffer
		stz 	lineBuffer+1,x 				; make ASCIIZ
		inx
		jsr 	LoadReadCharacter 			; next line

		cmp 	#32 						; until < space ctrl/eof.
		bcs 	_LRLLoop		
		lda 	#1 							; return code 1, okay.
_LRLExit:
		rts


; ************************************************************************************************
;
;			Return a single character, handle TABS, return $0D for $0A, 0 if EOF.
;
; ************************************************************************************************

LoadReadCharacter:
		phx
		phy
		lda 	LoadEOFFlag 				; already done EOF.
		bne 	_LRCIsEOF

		jsr 	KNLReadByte 				; read a byte
		bcc		_LRCExit 					; read okay.

		cmp 	#KERR_EOF 					; if error not EOF it's an actual error.
		bne 	CLCloseError
		dec 	LoadEOFFlag
_LRCIsEOF:		
		lda 	#0
_LRCExit:
		cmp 	#9 							; convert tab to space
		bne 	_LRCNotTab
		lda 	#' '
_LRCNotTab:
		cmp 	#$0A
		bne 	_LRCNotLF
		lda 	#$0D
_LRCNotLF:
		ply
		plx		
		cmp 	#0 							; set Z flag if EOF.
		rts		

		.send code

		.section storage

LoadEOFFlag:
		.fill 	1
CurrentFileStream:
		.fill 	1

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