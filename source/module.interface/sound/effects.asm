; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		effects.asm
;		Purpose:	Special effects commands
;		Created:	1st December 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										Simple SFX
;
; ************************************************************************************************

effect 	.macro
		phy 								; save pos
		lda 	#\1 						; push channel.
		pha
		lda 	#\2 						; pitch LSB
		ldx 	#\3 						; length
		ldy 	#\4 						; slide LSB
		bra 	SoundEffectCommand
		.endm

		.section code

PingCommand: 	;; [ping]
		.effect 1,200,6,0

ZapCommand: 	;; [zap]
		.effect 1,255,10,10

ShootCommand:	;;	[shoot]
		.effect 3,32,4,0

Explode: 		;; [explode]		
		.effect 3,80,10,0

SoundEffectCommand:
		sta 	SoundCommandBlock 			; set up the command block in sound.asm
		stz 	SoundCommandBlock+1
		lda 	#15
		sta 	SoundCommandBlock+2
		stx 	SoundCommandBlock+3
		sty 	SoundCommandBlock+4
		stz 	SoundCommandBlock+5
		pla
		ora 	#$10  						; execute command $11
		ldx 	#(SoundCommandBlock & $FF)
		ldy 	#(SoundCommandBlock >> 8)
		jsr 	SNDCommand
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
