;;
; Display the boot header for the machine.
;;

		.section code

is_jr	.macro
		stz 	$0001
		lda 	$D6A7
		and 	#$10
		.endm

;;
; Display the boot header graphics.
;
; Selects the appropriate header assets for JR/KR hardware variants, unpacks the
; RLE-compressed character/attribute data into screen memory, and loads the boot
; palette.
;
; \out Y        Starting line number for the info text
; \sideeffects  - Modifies zero-page locations $0001, `zTemp0`, and `zTemp1`.
;               - Modifies `A`, `X`, and `Y` registers
;               - Writes to $C000 screen memory and $D800/$D840 palette registers.
;;
EXTShowHeader:
		lda 	$0008+3
		pha
		lda 	$0008+4
		clc
		adc 	#3
		sta 	$0008+3
		;
		ldx 	#(Header_jchars & $FF)
		ldy 	#(Header_jchars >> 8)-$40

		.is_jr
		beq 	_EXTSHNotK1

		ldx 	#(Header_kchars & $FF)
		ldy 	#(Header_kchars >> 8)-$40
_EXTSHNotK1:
		lda 	#2
		jsr 	_ESHCopyBlock
		;
		ldx 	#(Header_jattrs & $FF)
		ldy 	#(Header_jattrs >> 8)-$40

		.is_jr
		beq 	_EXTSHNotK2

		ldx 	#(Header_kattrs & $FF)
		ldy 	#(Header_kattrs >> 8)-$40
_EXTSHNotK2:
		lda 	#3
		jsr 	_ESHCopyBlock
		;
		stz 	$0001
		ldx 	#16*4-1
_EXTCopyLUT:
		lda 	Header_Palette-$4000,x
		sta 	$D800,x
		sta 	$D840,x
		dex
		bpl 	_EXTCopyLUT
		pla
		sta 	$0008+3

		ldy 	#Header_jinfo_line
		.is_jr
		beq 	_exit
		ldy 	#Header_kinfo_line

	_exit:
		rts

_ESHCopyBlock:
		sta 	$0001
		stx 	zTemp0 						; zTemp0 is RLE packed data
		sty 	zTemp0+1
		.set16 	zTemp1,$C000 				; where it goes.
_ESHCopyLoop:
		lda 	(zTemp0) 					; get next character
		cmp 	#Header_RLE 				; packed ?
		beq 	_ESHUnpack
		sta 	(zTemp1) 					; copy it out.
		lda 	#1 							; source add 1
		ldy 	#1 							; dest add 1
_ESHNext:
		clc 								; zTemp0 + A
		adc 	zTemp0
		sta 	zTemp0
		bcc 	_ESHNoCarry
		inc 	zTemp0+1
_ESHNoCarry:
		tya 								; zTemp1 + Y
		clc
		adc 	zTemp1
		sta 	zTemp1
		bcc 	_ESHCopyLoop
		inc 	zTemp1+1
		bra 	_ESHCopyLoop
		;
_ESHUnpack:
		ldy 	#2 							; get count into X
		lda 	(zTemp0),y
		tax
		dey 								; byte into A
		lda 	(zTemp0),y
		beq 	_ESHExit 					; exit if zero.
		ldy 	#0 							; copy start position
_ESHCopyOut:
		sta 	(zTemp1),y
		iny
		dex
		bne 	_ESHCopyOut
		lda 	#3 							; Y is bytes on screen, 3 bytes from source
		bra 	_ESHNext
		;
_ESHExit:
		rts

		.send code
