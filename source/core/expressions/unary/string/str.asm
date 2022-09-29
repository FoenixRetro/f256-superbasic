; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		str.asm
;		Purpose:	Convert number to string
;		Created:	29th September 2022
;		Reviewed: 	
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;										str$() function
;
; ************************************************************************************************

Unary_Str: ;; [str$(]
		plx
		jsr 	EvaluateNumber  			; get number
		jsr 	CheckRightBracket 			; closing bracket
		lda 	#5 							; maximum decimals, from Basic816
		jsr 	ConvertNumberToString 		; do the conversion.

		lda		#33 						; create buffer
		jsr 	StringTempAllocate 			; allocate memory

		phx 
		ldx 	#0
_USCopy:
		lda 	DecimalBuffer,x
		jsr 	StringTempWrite
		inx
		lda 	DecimalBuffer,x
		bne 	_USCopy
		plx		
		rts

; ************************************************************************************************
;
;				Convert FPA to String in ConversionBuffer, return offset in X
;
; ************************************************************************************************

ConvertNumberToString:
		phy 								; save code position

		sta 	DecimalPlaces	 			; save number of DPs.
		stz 	dbOffset 					; offset into decimal buffer = start.
		jsr 	NSMShiftUpTwo 				; copy S[X] to S[X+2] - we will use S[X+2] for the intege part.		

		ply
		rts

; ************************************************************************************************
;
;		Make S[X+2] and integer, convert it to a string, and copy it to the decimal buffer
;		
; ************************************************************************************************

MakePlusTwoString:

		.send 	code
		
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
