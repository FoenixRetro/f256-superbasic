; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		expandline.asm
;		Purpose:	Expand line at codePtr to tokenBuffer
;		Created:	4th October 2022
;		Reviewed:
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;							Convert one line back to text.
;
; ************************************************************************************************

ListConvertLine:
		stz 	tbOffset
		stz 	tokenBuffer
		ldy 	#2 							; convert line number to string
		lda 	(codePtr),y		
		tax
		dey
		lda 	(codePtr),y
		jsr 	ConvertInt16
		sta 	zTemp0 						; copy number into buffer
		stx 	zTemp0+1
		ldy 	#0
_LCCopyNumber:
		lda 	(zTemp0),y
		jsr 	LCLWrite
		iny		
		lda 	(zTemp0),y
		bne 	_LCCopyNumber

		jsr 	ScanGetCurrentLineStep 		; adjustment to indent
		pha 								; save on stack
		bpl 	_LCNoAdjust 				; don't adjust indent if +ve, do after.
		clc 								; add to list indent and make 0 if goes -ve.
		adc 	listIndent
		sta 	listIndent 
		bpl 	_LCNoAdjust
		stz 	listIndent 
_LCNoAdjust:
		clc		 							; work out actual indent.
		lda 	listIndent
		asl 	a
		adc 	#6
		sta 	zTemp0

_LCPadOut:
		lda 	#' '						; pad out to 6 characters
		jsr 	LCLWrite
		lda 	tbOffset
		cmp 	zTemp0
		bne 	_LCPadOut
		ldy 	#3 							; start position.
		;	-------------------------------------------------------------------
		;
		;							Main List Loop
		;
		;	-------------------------------------------------------------------

_LCMainLoop:
		.cget 								; get next character
		cmp 	#KWC_EOL 					; end of line ?
		beq 	_LCExit
		;
		cmp 	#16 						; 0-5 are the double punctuations
		bcc 	_LCDoubles
		cmp 	#32 						; 16-31 are shifted punctuation from 64-91
		bcc 	_LCShiftPunc
		cmp 	#64 						; 32-64 are as stored, punc and digits
		bcc 	_LCPunctuation
		cmp 	#128 						; 64-127 are variable identifiers.
		bcc 	_LCIdentifiers 
		cmp 	#254 						; 128-253 are tokenised words
		bcc 	_LCTokens
		jmp 	_LCData 					; 254-5 are data objects
		;
		;		Exit - do +ve indent here.
		;
_LCExit:		
		pla 								; get old indent adjust
		bmi 	_LCExit2
		clc 								; add to indent if +ve
		adc 	listIndent
		sta 	listIndent
_LCExit2:
		rts
		;	-------------------------------------------------------------------
		;
		;					  Doubles << >> <= >= <> (0-5)
		;
		;	-------------------------------------------------------------------

_LCDoubles:
		pha
		lsr 	a 							; put bit 2 into bit 1
		and 	#2
		ora 	#60 						; make < >
		jsr 	LCLWrite
		pla 								; restore, do lower bit
		and 	#3
		ora 	#60
		bra		_LCPunctuation 				; print, increment, loop

		;	-------------------------------------------------------------------
		;
		;				Upper punctuation (was 64-127) (16-31)
		;
		;	-------------------------------------------------------------------

_LCShiftPunc:
		tax 								; save in X
		and 	#7 							; lower 3 bits
		beq 	_LCNoAdd
		ora 	#24 						; adds $18 to it.
_LCNoAdd:		
		cpx 	#24 						; if >= 24 add $20
		bcc 	_LCNoAdd2
		ora 	#32 						; adds $20
_LCNoAdd2:
		ora 	#$40 						; shift into 64-127 range and fall through.				

		;	-------------------------------------------------------------------
		;
		;							Punctuation (32-63)
		;
		;	-------------------------------------------------------------------

_LCPunctuation:
		cmp 	#':' 						; check if :
		bne 	_LCPContinue
		jsr 	LCDeleteLastSpace
_LCPContinue:		
		iny 								; consume character
		jsr 	LCLWrite 					; write it out.
		bra 	_LCMainLoop 				; go round again.

		;	-------------------------------------------------------------------
		;
		;							Identifiers (64-127)
		;
		;	-------------------------------------------------------------------

_LCIdentifiers:
		clc 								; convert to physical address
		adc 	#((VariableSpace >> 8) - $40) & $FF		
		sta 	zTemp0+1
		iny
		.cget
		sta 	zTemp0
		iny
		phy 								; save position
		ldy 	#7 							; output the identifier.
_LCOutIdentifier:
		iny
		lda 	(zTemp0),y				
		and 	#$7F
		jsr 	LCLLowerCase
		jsr 	LCLWrite
		lda 	(zTemp0),y				 	; ends when bit 7 set.	
		bpl 	_LCOutIdentifier
		ply 								; restore position
		bra 	_LCMainLoop

		;	-------------------------------------------------------------------
		;
		;							Tokens (129-253)
		;
		;	-------------------------------------------------------------------

_LCTokens:
		tax 								; token in X
		.set16 	zTemp0,KeywordSet2 			; identify keyword set
		cpx 	#$82
		beq 	_LCUseShift
		.set16 	zTemp0,KeywordSet1
		cpx 	#$81
		beq 	_LCUseShift
		.set16  zTemp0,KeywordSet0
		bra 	_LCNoShift
_LCUseShift:								; skip over token if using $81/$82 shifts
		iny
_LCNoShift:
		jsr 	LCCheckSpaceRequired 		; do we need a space ?
		.cget 								; get the token again
		tax 								; into X
_LCFindText:		
		dex
		bpl 	_LCFoundText 				; found text.
		lda 	(zTemp0) 					; length of text
		inc 	a 							; one extra for size
		sec 								; one extra for checksum
		adc 	zTemp0 						; go to next token
		sta 	zTemp0
		bcc 	_LCFindText
		inc 	zTemp0+1
		bra 	_LCFindText
_LCFoundText:				
		phy 								; save List position
		lda 	(zTemp0)					; count to print
		tax
		ldy 	#2
_LCCopyToken:								; copy token out.
		lda 	(zTemp0),y
		jsr 	LCLLowerCase
		jsr 	LCLWrite
		iny
		dex
		bne 	_LCCopyToken
		cmp 	#"(" 						; if last char not ( print a space
		beq 	_LCNoSpace
		lda 	#' '
		jsr 	LCLWrite
_LCNoSpace:
		ply 								; restore position.
		iny 								; consume token
		jmp 	_LCMainLoop 				; and go around again.			

		;	-------------------------------------------------------------------
		;
		;							Data (254-5)
		;
		;	-------------------------------------------------------------------

_LCData:
		pha 								; save type $FE/$FF
		ldx 	#'$' 						; figure out $ or "
		cmp 	#$FE
		beq 	_LCHaveOpener
		ldx 	#'"'
_LCHaveOpener:
		txa 								; output prefix (# or ")
		jsr 	LCLWrite
		iny 								; get count
		.cget
		tax
		iny 								; point at first character				
_LCOutData:
		.cget 								; get next
		cmp 	#0
		beq 	_LCNoPrint
		jsr 	LCLWrite
_LCNoPrint:
		iny
		dex
		bne 	_LCOutData
		pla 								; closing " required ?
		cmp 	#$FF 						
		bne 	_LCNoQuote
		lda 	#'"'
		jsr 	LCLWrite
_LCNoQuote:		
		jmp 	_LCMainLoop

; ************************************************************************************************
;
;									Write to token buffer
;
; ************************************************************************************************

LCLWrite:
		phx
		ldx 	tbOffset
		sta 	tokenBuffer,x
		stz 	tokenBuffer+1,x
		inc 	tbOffset
		plx
		rts

; ************************************************************************************************
;
;								 If last space then delete it.
;
; ************************************************************************************************

LCDeleteLastSpace:
		pha
		phx
		ldx 	tbOffset
		beq 	_LCDLSExit
		lda 	tokenBuffer-1,x
		cmp 	#' '
		bne 	_LCDLSExit
		dec 	tbOffset
_LCDLSExit:
		plx
		pla
		rts		

; ************************************************************************************************
;
;							Is a space required, if so print it
;
; ************************************************************************************************

LCCheckSpaceRequired:
		ldx 	tbOffset		
		lda 	tokenBuffer-1,x 			; previous character
		cmp 	#'$' 						; $ # and ) require that token space.
		beq 	_LCCSRSpace
		cmp 	#')'
		beq 	_LCCSRSpace
		cmp 	#'#'
		beq 	_LCCSRSpace
		jsr 	LCLLowerCase 				; saves a little effort
		cmp 	#"0" 						; check if it was 0-9 A-Z a-z if so need space.
		bcc 	_LCCSRExit
		cmp 	#"9"+1
		bcc 	_LCCSRSpace
		cmp 	#"a"
		bcc 	_LCCSRExit
		cmp 	#"z"+1
		bcs 	_LCCSRExit
_LCCSRSpace: 								; output the space
		lda 	#' '
		jsr 	LCLWrite

_LCCSRExit:
		rts		
; ************************************************************************************************
;
;										Convert to L/C or U/C
;
; ************************************************************************************************

LCLLowerCase:
		cmp 	#"A"
		bcc 	_LCLLCOut
		cmp 	#"Z"+1
		bcs 	_LCLLCOut
		adc 	#$20
_LCLLCOut:
		rts

LCLUpperCase:
		cmp 	#"a"
		bcc 	_LCLUCOut
		cmp 	#"z"+1
		bcs 	_LCLUCOut
		sbc 	#$1F
_LCLUCOut:
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
