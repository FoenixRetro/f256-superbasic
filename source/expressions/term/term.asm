; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		term.asm
;		Purpose:	Evaluate a term
;		Created:	20th September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;					   			Evaluate a term on the stack at X
;
;		This can be:
;			a number (in ASCII)			$30-$39 	(0-9)
;			a quoted string 			$FF 		
;			a variable 					$40-$7F
; 			a text unary function 		defined by constants
;			a punctuation unary 		@ ?\!$ & ( -
;
; ************************************************************************************************

EvaluateTerm:
		.debug
		.cget 								; look at first character
		bmi 	_ETCheckUnary 				; unary function ? (text ones)
		cmp 	#$40 						; 40-7F => identifier reference
		bcs 	_ETVariable
		cmp 	#'0' 						; is it a number
		bcc 	_ETPuncUnary
		cmp 	#'9'+1 	
		bcs 	_ETPuncUnary

		; ----------------------------------------------------------------------------------------
		;
		;		A number 0-9 found
		;
		; ----------------------------------------------------------------------------------------

		jsr 	EncodeNumberStart 			; can't fail as it's 0-9 !
_ETNumber:
		iny 								; keep encoding until we have the numbers
		.cget
		jsr 	EncodeNumberContinue
		bcs 	_ETNumber
		rts

		; ----------------------------------------------------------------------------------------
		;
		;		Token found - check it's a unary function (non punctuation) like LEFT$
		;
		; ----------------------------------------------------------------------------------------

_ETCheckUnary:		
		cmp 	#KWC_STRING 				; string token
		beq 	_ETString
		cmp 	#KWC_FIRST_UNARY 			; check it actually is a unary function
		bcc 	_ETSyntaxError
		cmp 	#KWC_LAST_UNARY+1
		bcs 	_ETSyntaxError
		;
		phx 								; push X on the stack
		asl 	a 							; put vector x 2 into X
		tax
		jmp 	(VectorSet0,x) 				; and do it.

_ETSyntaxError:
		jmp 	SyntaxError

		; ----------------------------------------------------------------------------------------
		;
		;		String $FF
		;		
		; ----------------------------------------------------------------------------------------

_ETString:
		iny 								; look at length
		.cget 								; push length on stack.
		pha
		iny 								; first character
		jsr 	MemoryInline 				; put address of string at (codePtr),y on stack
		pla 								; restore count and save
		sta 	zTemp0 

		tya 								; add length + 1 to Y
		sec
		adc 	zTemp0
		tay

		lda 	#NSTString 					; mark as string
		sta 	NSStatus,x
		rts

		; ----------------------------------------------------------------------------------------
		;
		;		Variable reference 40-7F
		;
		; ----------------------------------------------------------------------------------------

_ETVariable:
		.debug 
		jmp 	$FFFF

		; ----------------------------------------------------------------------------------------
		;
		;		Punctuation Unary these are @ (deref) ?\!$ (indirection) & (hex) ( (parenthesis)
		;		and - (negation)
		;
		; ----------------------------------------------------------------------------------------

_ETPuncUnary:
		.debug

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
