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
		bcs 	_CLDriveNotFound 			; drive not found (apparently)
		jsr 	NewProgram 					; does the actual NEW.
_CLLoop:
		jsr 	LoadReadLine 				; get next line.
		beq 	_CLExit 					; end, exit.

		jsr 	TKTokeniseLine 				; tokenise the line.

		lda 	tokenLineNumber 			; line number = 0
		ora 	tokenLineNumber+1
		beq 	_CLLoop 					; not legal code, blank line or maybe a comment.
		jsr 	EditProgramCode 			; do the editing etc.	
		bra 	_CLLoop

_CLExit:			
		lda 	#"O"
		jsr 	EXTPrintCharacter
		lda 	#"k"
		jsr 	EXTPrintCharacter
		lda 	#13
		jsr 	EXTPrintCharacter
		jmp 	WarmStart

_CLDriveNotFound:
		.error_drive

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
		cmp 	#' ' 						; until < space ctrl/eof.
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
		jsr 	KNLReadByte 				; read a byte
		bcc		_LRCExit 					; read okay.
		cmp 	#KERR_EOF 					; if error not EOF it's an actual error.
		bne 	_LRCFatal
		lda 	#0
_LRCExit:
		cmp 	#8 							; convert tab to space
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
;
_LRCFatal:
		cmp 	#KERR_NOTFOUND
		beq 	_LRFNotFound
		.error_driveio
_LRFNotFound:
		.error_notfound	

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
