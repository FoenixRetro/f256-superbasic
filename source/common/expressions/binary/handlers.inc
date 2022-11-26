; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		handlers.inc
;		Purpose:	Dispatchers for binary operations
;		Created:	21st September 2022
;		Reviewed: 	27th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;							Dereference both values if required
;
; ************************************************************************************************

		.section code

dereferenceboth .macro
		lda 	NSStatus,x 					; OR the type data together
		ora 	NSStatus+1,x
		asl 	a 							; shift reference bit into sign bit
		asl 	a
		bpl 	_NotRef
		pha
		jsr 	DereferenceTopTwo 			; call the dereference code preserving A
		pla
_NotRef:
		.endm

; ************************************************************************************************
;
;			Drops through if one integer. \1 if at least one float, \2 if one is string
;
; ************************************************************************************************

dispatcher .macro
		.dereferenceboth 					; remove reference, A << 2 in A
		asl 	a 							; put MSB of type into A:7
		bmi 	_StringData 				; if the original bit 4 was set then do the string code.
		lda 	NSExponent,x 				; check if both exponents are zero, e.g. both integers
		ora 	NSExponent+1,x
		beq 	_IntegerCode 				; if clear, then we have two integers
		jmp 	\1 							; otherwise at least one float.
_StringData:
		jmp 	\2							; at least one string - don't know both are strings.
_IntegerCode:		
		.endm								

; ************************************************************************************************
;
;								Integer only dispatcher
;
; ************************************************************************************************

dispatchintegeronly .macro
		.dereferenceboth 					; remove reference, A << 2 in A
		asl 	a
		and 	#$C0 						; isolate the type bits which have been shifted
		ora 	NSExponent,x 				; check if both exponents are zero, e.g. both integers
		ora 	NSExponent+1,x
		beq 	_IntegerCode 				; if clear, then we have two integers
		jmp 	TypeError 					; anything else, type mismatch.
_IntegerCode:		
		.endm								

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
