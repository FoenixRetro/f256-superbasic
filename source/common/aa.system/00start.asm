; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		00start.asm
;		Purpose:	Start up code.
;		Created:	18th September 2022
;		Reviewed: 	23rd November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									Kernel Header
;
; ************************************************************************************************

		.section code

F256Header:
		.text	$f2,$56         			; Signature
		.byte   4               			; 4 blocks
		.byte   4               			; mount at $8000
		.word   Boot 	      				; Start here
		.byte   1 			               	; version
		.byte   0               			; reserved
		.byte   0               			; reserved
		.byte   0               			; reserved
		.text   "basic",0 					; name of program.
		.text   0							; arguments
		.text	"The SuperBASIC environment.",0	; description


; ************************************************************************************************
;
;									 Main Program
;
; ************************************************************************************************

		* = F256Header + 64

CPU_CORE_1x = 0
CPU_CORE_2x = 1

print_char .macro
		lda 	\1
		jsr 	EXTPrintCharacter
		.endm

print_hex .macro
		lda 	\1
		jsr 	PrintHex
		.endm

set_start_column .macro
		lda 	#15
		sta		EXTColumn
		.endm


Boot:	jmp 	Start
		.include "../../../modules/.build/_exports.module.asm"

Start:	ldx 	#$FF 						; stack reset
		txs

		jsr 	EXTInitialise 				; hardware initialise

		lda 	0  							; turn on editing of MMU LUT
		ora 	#$80
		sta 	0

		lda 	$2002 						; if $2002..5 is BT65 then jump to $2000
		cmp 	#"B"
		bne 	_NoMachineCode
		lda 	$2003
		cmp 	#"T"
		bne 	_NoMachineCode
		lda 	$2004
		cmp 	#"6"
		bne 	_NoMachineCode
		lda 	$2005
		cmp 	#"5"
		bne 	_NoMachineCode
		jmp 	$2000

_NoMachineCode:

		lda 	#0 							; zero the default drive.
		jsr 	KNLSetDrive

		jsr 	TKInitialise 				; initialise tokeniser.

		.if 	graphicsIntegrated==1 		; if installed
		lda 	#0 							; graphics system initialise.
		tax
		tay
		jsr 	GXGraphicDraw
		.endif

		.if 	soundIntegrated==1 			; if installed
		lda 	#$0F 						; initialise sound system
		jsr 	SNDCommand
		.endif

		stz 	$0001

		.print_char #128+13				; set text color to bright red

		; display hardware information
		.set_start_column

		.print_hex $D6AD
		.print_hex $D6AC
		.print_hex $D6AB
		.print_hex $D6AA
		.print_char #' '
		.print_char $D6A8
		.print_char $D6A9

		.print_char #'/'					; print core version
		lda		#'1'						; default to '1'
		bit 	$D6A7 						; test the 7th bit of machine ID
		bpl 	_1x_core
		lda		#'2'
	_1x_core:
		jsr 	EXTPrintCharacter
		.print_char #'x'

		; display Kernel information
		.print_char #13
		.set_start_column

		lda 	#$08
		ldx 	#$E0
		jsr 	PrintStringXA

		; display SuperBASIC version & prompt
		.print_char #13
		.set_start_column

		lda 	#<Prompt
		ldx 	#>Prompt
		jsr 	PrintStringXA


		.tickinitialise 					; initialise tick handler
											; (mandatory)

		jsr 	ResetIOTracking 			; reset the I/O tracking.

		jsr 	NewProgram 					; erase current program

		.if 	AUTORUN==1 					; run straight off
		jsr 	BackloadProgram
		jmp 	RunCurrentProgram
		.else
		jmp 	WarmStart					; make same size.
		jmp 	WarmStart
		.endif

Prompt:	.include "../generated/timestamp.asm"
		.text 	13,13,13,0

		.send code


; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;		27/11/22 		Removed prompt - now doesn't clear screen and drops to line 6.
;		05/12/22 		Added call to break to temporarily handle break bug in Kernel.
;						Added Gadget-style boot prompt.
;		08/12/22 		Removed initial break check call.
;		02/01/23 		Tidied up boot display
;		18/01/23 		Added test for simple machine code boot.
;
; ************************************************************************************************
