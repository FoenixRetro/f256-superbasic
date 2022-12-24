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

		.section code

Boot:	jmp 	Start
		.include "../../../modules/_build/_linker.module"

Start:	ldx 	#$FF 						; stack reset
		txs	

		lda 	0  							; turn on editing of MMU LUT
		ora 	#$80
		sta 	0

		jsr		UpdateFont 					; update font if between FPGA updates.
		
		jsr 	EXTInitialise 				; hardware initialise

		;jsr 	KNLLoadFile
			
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

		ldx 	#Prompt >> 8 				; display prompt
		lda 	#Prompt & $FF
		jsr 	PrintStringXA

		.tickinitialise 					; initialise tick handler
											; (mandatory)

		jsr 	NewProgram 					; erase current program

		.if 	AUTORUN==1 					; run straight off
		jsr 	BackloadProgram
		jmp 	CommandRun
		.else		
		jmp 	WarmStart					; make same size.
		jmp 	WarmStart
		.endif

Prompt:	.include "../generated/timestamp.asm"
		.text 	13,13,0

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
;
; ************************************************************************************************
