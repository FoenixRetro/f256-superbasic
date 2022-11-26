; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		multiply.asm
;		Purpose:	32x32 bit integer multiplication, 32 bit result with rounding and shift
;		Created:	21st September 2022
;		Reviewed: 	27th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

MulInteger: 	;; [*]
		plx
		.dispatcher FloatingPointMultiply,NotDoneError
		jsr 	MultiplyShort
		cmp 	#0
		beq 	_MIExit
		.error_range
_MIExit:
		rts		

; ************************************************************************************************
;
;		Multiply stack entry X by stack entry X+1. If necessary right shifts. Returns on 
;		exit the number of left shifts required to fix it up. Calculates sign of result.
;
;		Does not change exponent.
;
; ************************************************************************************************

MultiplyShort:
		phy 								; save Y
		jsr 	NSMShiftUpTwo 				; copy S[X] to S[X+2]
		jsr 	NSMSetZeroMantissaOnly 		; set mantissa S[X] to zero
		ldy 	#0 							; Y is the shift count.
		;
		;		Main multiply loop.
		;				
_I32MLoop:
		lda 	NSMantissa0+2,x 			; check S[X+2] is zero
		ora 	NSMantissa1+2,x
		ora 	NSMantissa2+2,x
		ora 	NSMantissa3+2,x
		beq 	_I32MExit 					; exit if zero

		lda 	NSMantissa0+2,x 			; check LSB of n1 
		and 	#1
		beq 	_I32MNoAdd
		;
		jsr 	AddTopTwoStack 				; if so add S[X+1] to S[X+0]
		;
		lda 	NSMantissa3,x 				; has MantissaA overflowed ?
		bpl 	_I32MNoAdd
		;
		;		Overflow. Shift result right, increment the shift count, keeping the
		; 		result in 31 bits - now we lose some precision though.
		;
_I32ShiftRight:		
		jsr 	NSMShiftRight 				; shift S[X] right
		iny 								; increment shift count
		bra 	_I32MShiftUpper 			; n2 is doubled by default.
		;
_I32MNoAdd:
		bit 	NSMantissa3+1,x				; if we can't shift S[X+1] left, shift everything right
		bvs 	_I32ShiftRight 				; instead.

		inx
		jsr 	NSMShiftLeft 				; shift additive S[X+1] left
		dex

_I32MShiftUpper:
		inx 								; shift S[X+2] right
		inx
		jsr 	NSMShiftRight
		dex
		dex

		bra 	_I32MLoop 					; try again.

_I32MExit:
		jsr 	CalculateSign
		tya 								; shift in A
		ply 								; restore Y and exit
		rts

; ************************************************************************************************
;
;								Calculate sign from the two signs
;
; ************************************************************************************************

CalculateSign:
		lda 	NSStatus,x 					; sign of result is 0 if same, 1 if different.
		asl 	NSStatus,x 					; shift result left
		eor 	NSStatus+1,x
		asl 	a 							; shift bit 7 into carry
		ror 	NSStatus,x 					; shift right into status byte.
		rts

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
