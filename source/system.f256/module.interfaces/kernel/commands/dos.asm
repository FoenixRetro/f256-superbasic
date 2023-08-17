; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		dos.asm
;		Purpose:	DOS boot
;		Created:	13th January 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section arguments
ArgumentStrings .fill 128
ArgumentArray   .fill (8+1)*2		; DOS provides a maximum of 8 tokens
		.send

		.section code
BootXA:
		sta		zTemp0+0
		stx		zTemp0+1

		ldx		#0
		ldy		#0

_copy_next_string
		tya
		clc
		adc		#<ArgumentStrings
		sta		ArgumentArray,x
		inx
		lda		#>ArgumentStrings
		adc		#0
		sta		ArgumentArray,x
		inx

_copy_string
		lda		(zTemp0),y
		beq		_copy_done
		cmp		#' '
		beq		_skip_spaces
		sta		ArgumentStrings,y
		iny
		bra		_copy_string

_skip_spaces
		lda		#0
		sta		ArgumentStrings,y
		iny
		lda		(zTemp0),y
		beq		_copy_done
		cmp		#' '
		beq		_skip_spaces
		bra		_copy_next_string

_copy_done
		lda		#0
		sta		ArgumentStrings,y

		stx		kernel.args.extlen

		stz		ArgumentArray,x
		stz		ArgumentArray+1,x

		lda		#<ArgumentArray
		sta		kernel.args.ext
		lda		#>ArgumentArray
		sta		kernel.args.ext+1

		lda		#<ArgumentStrings
		sta		kernel.args.buf
		lda		#>ArgumentStrings
		sta		kernel.args.buf+1

		jsr		kernel.RunNamed

		lda		#3					; reset the token buffer to empty
		sta		tokenOffset			; (3 bytes for line number & offset)
		stz		tokenLineNumber
		stz		tokenLineNumber+1
		.csetcodepointer tokenOffset

		.error_noprogram
		jmp		WarmStart


		.send code

; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;		25/02/23		Tweaked to allow general usage. Actual "dos" command no longer supported.
;
; ************************************************************************************************
