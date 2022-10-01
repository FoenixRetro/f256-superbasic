; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		assignstring.asm
;		Purpose:	Assign a string value
;		Created:	30th September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;							Assign a string value, concreting it 
;
; ************************************************************************************************

AssignString:
		.debug
		phy
		;
		;		Copy new string address to zTemp1
		;
		lda 	NSMantissa0+1,x
		sta 	zTemp1
		lda 	NSMantissa1+1,x
		sta 	zTemp1+1
		;
		;		See if there's a concrete string in the target already.
		;
		lda 	NSMantissa1,x 				; the high byte of the target address
		beq 	_ASNewStringRequired 		; if zero, a new string is required.
		;
		;		If so does it fit in the space available.
		;
		sec 								; put Address-2 in zTemp0 - this is the size/status/string record
		lda 	NSMantissa0,x 				; of concreted strings
		sbc 	#2
		sta 	zTemp0
		lda 	NSMantissa1,x
		sbc 	#0
		sta 	zTemp0+1
		;
		ldy 	#$FF 						; get length of new string
_ASGetLength:
		iny
		lda 	(zTemp1),y
		bne 	_ASGetLength
		tya 								; is this length <= current length
		cmp 	(zTemp0)
		bcc 	_ASCopyString
		beq 	_ASCopyString
		;
		lda 	#$80 						; mark as unused.
		ldy 	#1
		sta 	(zTemp0),y
		;
		; 		Concrete new if required
		;
_ASNewStringRequired:	
		inx 								; concrete the new string.
		jsr 	StringConcrete				; (breaks zTemp1/2, not zTemp0)
		dex	
		clc
		lda 	NSMantissa0+1,x 			; copy that new address to the reference.
		adc 	#2 							; add two to point at the data.
		sta 	(zTemp0)
		lda 	NSMantissa1+1,x
		adc 	#0
		ldy 	#1
		sta 	(zTemp0),y
		bra 	_ASExit
		;
		; 		Copy the string at zTemp1 to zTemp0+2 (skipping the header bit.)
		;
_ASCopyString:
		ldy 	#0
_ASCopyLoop:
		lda 	(zTemp1),y
		iny
		iny
		sta 	(zTemp0),y
		dey
		dey
		cmp 	#0
		bne 	_ASCopyLoop		
_ASExit:
		ply
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
