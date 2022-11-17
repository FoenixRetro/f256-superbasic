; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		concat.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	30th September 2022
;		Reviewed :
;		Purpose :	String Concatenation
;
; ***************************************************************************************
; ***************************************************************************************

		.section code

; ***************************************************************************************
;
; 						+ operator, at least one string
;
; ***************************************************************************************

StringConcat:
		lda 	NSStatus,x 					; check both strings
		and 	NSStatus+1,x
		and 	#NSBTypeMask
		cmp 	#NSTString
		bne		_SCType

		stz 	zTemp1 						; counting total length
		inx
		jsr 	_SCSetupZ0 					; setup for second
		jsr 	_SCLengthZ0 				; length for second
		dex
		jsr 	_SCSetupZ0 					; setup for first
		jsr 	_SCLengthZ0 				; length for first

		lda 	zTemp1 						; allocate memory
		jsr 	StringTempAllocate 		

		jsr 	_SCCopy 					; copy first out, using zTemp0 from above
		inx
		jsr 	_SCSetupZ0 					; copy second out
		jsr 	_SCCopy
		dex
		rts

_SCSetupZ0: 								; set up zTemp0 to point to string
		lda 	NSMantissa0,x
		sta 	zTemp0
		lda 	NSMantissa1,x
		sta 	zTemp0+1
		rts

_SCLengthZ0: 								; length of current string add to total in zTemp1
		phy
		ldy 	#0
_SCLenLoop:
		lda 	(zTemp0),y
		beq 	_SCLExit
		iny
		inc 	zTemp1
		bpl		_SCLenLoop
		.error_string						
_SCLExit:
		ply
		rts

_SCCopy:									; copy string out.
		phy
		ldy 	#0
_SCCopyLoop:
		lda 	(zTemp0),y
		beq 	_SCCExit
		jsr 	StringTempWrite
		iny
		bra 	_SCCopyLoop
_SCCExit:
		ply
		rts


_SCType:
		jmp 	TypeError

		.send code

; ***************************************************************************************
;
;									Changes and Updates
;
; ***************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ***************************************************************************************
