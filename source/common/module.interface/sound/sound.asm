; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		sound.asm
;		Purpose:	Sound command
;		Created:	21st November 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;		Sound <Channel> , <Pitch> , <Length 10th/sec> [ , <Slide Value> ]
;
; ************************************************************************************************

		.section code

SoundCommand: ;; [sound]
		.cget
		cmp 	#KWD_OFF 					; SOUND OFF ?
		bne 	_SNDMain
		iny 								; skip OFF
		lda 	#$3F 						; call command $3F (silence)
		phy
		jsr 	SNDCommand
		ply
		rts

_SNDMain:
		ldx 	#0
		jsr 	Evaluate8BitInteger 		; channel
		cmp 	#4 							; must be 0-3
		bcs 	_SndError
		;
		inx 								; do the rest in slot 1.
		jsr 	CheckComma
		jsr 	Evaluate16BitInteger 		; Pitch
		lda 	NSMantissa1,x 				; must be 10 bit
		cmp 	#16
		bcs 	_SndError
		sta 	SoundCommandBlock+1 		; Pitch (2 bytes + 0)
		lda 	NSMantissa0,x
		sta 	SoundCommandBlock
		;		
		jsr 	CheckComma
		jsr 	Evaluate8BitInteger 		; Length (1 byte + 3)
		sta 	SoundCommandBlock+3
		;
		lda 	#15
		sta 	SoundCommandBlock+2 		; Volume (1 byte + 2)
		;
		stz 	SoundCommandBlock+4 		; default slide (2 bytes +4)
		stz 	SoundCommandBlock+5
		;
		.cget 								; comma follows
		cmp 	#KWD_COMMA
		bne 	_SNDPlay
		iny
		jsr 	Evaluate16BitIntegerSigned 	; Slide
		lda 	NSMantissa0,x 				; Slide (2 bytes + 4)
		sta 	SoundCommandBlock+4 		
		lda 	NSMantissa1,x
		sta 	SoundCommandBlock+5
		;
_SNDPlay:		
		phy
		lda 	NSMantissa0 				; channel.
		ora 	#$10 						; 1x = Queue sound
		ldx 	#(SoundCommandBlock & $FF)
		ldy 	#(SoundCommandBlock >> 8)
		jsr 	SNDCommand
		ply
		rts

_SndError:
		jmp 	RangeError		

		.send code

		.section storage
SoundCommandBlock:
		.fill 	6
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
