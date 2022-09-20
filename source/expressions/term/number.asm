; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		number.asm
;		Purpose:	State machine inputting numbers
;		Created:	20th September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

ESTA_Low = 1 								; state 1 is 1 byte, switches when A >= 24.
ESTA_High = 2 								; loading up to 32 bit integer in the mantissa

; ************************************************************************************************
;
;		Encode Number. If CS, then start a new number. Returns CS if the number is okay,
;		CC if not.
;
; ************************************************************************************************

EncodeNumberStart:
		sec
		bra 	EncodeNumberContinue+1
EncodeNumberContinue:
		clc
		php 								; save reset.
		cmp 	#"." 						; only accept 0-9 and .
		beq 	_ENIsOkay
		cmp 	#"0"
		bcc 	_ENBadNumber
		cmp 	#"9"+1
		bcc 	_ENIsOkay
_ENBadNumber:		
		plp 								; throw saved reset
_ENFail:		
		clc 								; not allowed
		rts
;
_ENIsOkay:		
		plp 								; are we restarting
		bcc 	_ENNoRestart
		; --------------------------------------------------------------------
		;
		;		First initialise
		;
		; --------------------------------------------------------------------

_ENStartEncode:
		and 	#15 						; put digit in mantissa
		jsr 	NSMMantissaByte
		lda 	#ESTA_Low
_ENExitChange:
		sta 	EncodeState 				; save new state		
		sec
		rts
		; --------------------------------------------------------------------
		;
		;		Not restarting. Figure out what to do next
		;
		; --------------------------------------------------------------------
_ENNoRestart:		
		pha 								; save on stack.
		lda 	EncodeState 				; get current state
		cmp 	#ESTA_Low
		beq  	_ESTALowState	
		cmp 	#ESTA_High
		beq 	_ESTAHighState
		.debug


		; --------------------------------------------------------------------
		;
		;		Inputting to a single byte.
		;
		; --------------------------------------------------------------------

_ESTALowState:
		pla 								; get value back
		cmp 	#"."						; decimal point
		beq 	_ESTASwitchFloat 			; then we need to do the floating point bit
		and 	#15 						; make digit
		sta 	zTemp0 						; save it.
		;
		lda 	NSMantissa0,x 				; x mantissa0 x 10 and add it
		asl 	a
		asl 	a
		adc 	NSMantissa0,x
		asl 	a
		adc 	zTemp0
		sta 	NSMantissa0,x
		cmp 	#25 						; if >= 25 cannot guarantee next will be okay
		bcc 	_ESTANoSwitch 				; as could be 25 x 10 + 9
		lda 	#ESTA_High 					; so if so, switch to the high encoding state
		sta 	EncodeState
_ESTANoSwitch:
		sec
		rts		

		; --------------------------------------------------------------------
		;
		;		Inputting to a the whole 4 byte mantissa
		;
		; --------------------------------------------------------------------

_ESTAHighState:
		pla 								; get value back
		cmp 	#"." 						; if DP switch to dloat
		beq 	_ESTASwitchFloat
		jsr 	ESTAShiftDigitIntoMantissa 	; a routine does this.
		sec
		rts

		; --------------------------------------------------------------------
		;
		;		Entering decimal mode - still have then input digit on the stack
		;
		; --------------------------------------------------------------------

_ESTASwitchFloat:
		.debug

; ************************************************************************************************
;
;			Put digit A into the mantissa at X, e.g. mantissa = mantissa x 10 + digit
;
; ************************************************************************************************

ESTAShiftDigitIntoMantissa:
		and 	#15 						; save digit
		pha

		lda 	NSMantissa3,x 				; push mantissa on stack
		pha
		lda 	NSMantissa2,x 
		pha
		lda 	NSMantissa1,x 
		pha
		lda 	NSMantissa0,x 
		pha
		jsr 	NSMShiftLeft 				; x 2
		jsr 	NSMShiftLeft 				; x 4

		clc 								; pop mantissa and add
		pla 
		adc 	NSMantissa0,x
		sta 	NSMantissa0,x
		pla
		adc 	NSMantissa1,x
		sta 	NSMantissa1,x
		pla
		adc 	NSMantissa2,x
		sta 	NSMantissa2,x
		pla
		adc 	NSMantissa3,x
		sta 	NSMantissa3,x 				; x 5
		jsr 	NSMShiftLeft 				; x 10
		;
		pla 								; add digit
		clc
		adc 	NSMantissa0,x
		sta 	NSMantissa0,x
		bcc 	_ESTASDExit
		inc 	NSMantissa1,x
		bne 	_ESTASDExit
		inc 	NSMantissa2,x
		bne 	_ESTASDExit
		inc 	NSMantissa3,x
_ESTASDExit:
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
