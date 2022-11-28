; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		assignstring.asm
;		Purpose:	Assign a string value
;		Created:	30th September 2022
;		Reviewed: 	28th November 2022
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
		phy
		;
		;		Copy new string address to zTemp1, and the address to write the reference to to zTemp0
		;
		lda 	NSMantissa0+1,x
		sta 	zTemp1
		lda 	NSMantissa1+1,x
		sta 	zTemp1+1
		;
		lda 	NSMantissa0,x
		sta 	zTemp0
		lda 	NSMantissa1,x
		sta 	zTemp0+1		
		;
		;
		;		See if there's a concrete string in the target already.
		;
		ldy 	#1 							; the high byte of the target address
		lda 	(zTemp0),y
		beq 	_ASNewStringRequired 		; if zero, a new string is required.
		;
		;		If so does it fit in the space available.
		;
		sec 								; put Address-2 in zsTemp - this is the size/status/string record		
		lda 	(zTemp0) 					; of concreted strings
		sbc 	#2
		sta 	zsTemp
		ldy 	#1
		lda 	(zTemp0),y
		sbc 	#0
		sta 	zsTemp+1
		;
		ldy 	#$FF 						; get length of new string
_ASGetLength:
		iny
		lda 	(zTemp1),y
		bne 	_ASGetLength
		tya 								; is this length <= current length
		cmp 	(zsTemp)
		bcc 	_ASCopyString
		beq 	_ASCopyString
		;
		lda 	#$80 						; mark as unused.
		ldy 	#1
		sta 	(zsTemp),y
		;
		; 		Concrete new if required
		;
_ASNewStringRequired:	
		inx 								; concrete the new string.
		jsr 	StringConcrete				; (breaks zTemp1/2, not zTemp0 and zsTemp)
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
		; 		Copy the string at zTemp1 to zsTemp (skipping the header bit.)
		;
_ASCopyString:
		ldy 	#0
_ASCopyLoop:
		lda 	(zTemp1),y
		iny
		iny
		sta 	(zsTemp),y
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
