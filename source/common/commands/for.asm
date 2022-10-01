; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		for.asm
;		Purpose:	For/Next loop
;		Created:	1st October 2022
;		Reviewed: 	
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
;
;		+15 		Step (1 or 255)
;		+11..+14	Terminal value ((in 2's complement format.)
;		+7..+10 	Value of index variable (in 2's complement format.)
;		+5..+6 		Address of index variable
;		+0..4 		Loop back address
;
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;										For command
;
; ************************************************************************************************

ForCommand: ;; [for]
		lda 	#STK_FOR+8 					; allocate 16 bytes on the return stack.
		jsr 	StackOpen 
		;
		;		Get an integer reference to Stack[0]
		;
		ldx 	#0
		jsr 	EvaluateTerm
		lda 	NSStatus,x
		cmp 	#NSBIsReference+NSTInteger 	; do we have an integer 4 byte reference.
		bne		_FCError
		;
		;		= character
		;
		lda 	#KWD_EQUAL 					; = 
		jsr 	CheckNextA
		;
		;		The Initial value to Stack[1]
		;
		inx
		jsr 	EvaluateInteger 			; <from> in +1
		;
		;		TO or DOWNTO put on stack
		;
		.cget 								; next should be DOWNTO or TO
		iny 								; consume it
		pha 								; save on stack for later
		cmp 	#KWD_DOWNTO
		beq 	_FCNoSyntax
		cmp 	#KWD_TO
		bne 	_FCSyntaxError
_FCNoSyntax:
		;
		;		The Terminal value to Stack[2]
		;
		inx
		jsr 	EvaluateInteger 			
		;
		;		Now set up the FOR Structure, starting with the code position
		;
		jsr 	STKSaveCodePosition 		; save loop back position
		;
		;		Now the TO or DOWNTO
		;
		pla 								; restore DOWNTO or TO
		phy 								; save Y on the stack
		eor 	#KWD_DOWNTO 				; 0 if DOWNTO, #0 if TO
		beq 	_FCNotDownTo
		lda 	#2 							
_FCNotDownTo: 								; 0 if DOWNTO 2 if TO
		dec 	a 							; 255 if DOWNTO, 1 if TO
		ldy 	#15
		sta 	(basicStack),y 				; copy that out to the Basic Stack.
		;
		;		Copy the reference where the index goes.
		;
		ldy 	#5
		lda 	NSMantissa0
		sta 	(basicStack),y
		lda 	NSMantissa1
		iny
		sta 	(basicStack),y
		;
		;		Copy the initial and terminal values in 2's complement
		;
		ldy 	#7 							; set initial index value
		ldx 	#1
		jsr 	FCIntegerToStack
		ldy 	#11 						; set the terminal value
		ldx 	#2
		jsr 	FCIntegerToStack
		;
		;		Now copy the current value to the index reference, in standard format.
		;
		jsr 	CopyIndexToReference
		ply 								; restore position
		rts

_FCError:
		jmp 	TypeError
_FCSyntaxError:
		jmp 	SyntaxError

; ************************************************************************************************
;
;						Copy stack element X to BasicStack offset Y
;
; ************************************************************************************************

FCIntegerToStack:
		bit 	NSStatus,x 					; is the value negative
		bpl	 	_FCNotNegative
		jsr 	NSMNegateMantissa 			; if so 2's complement the mantissa
_FCNotNegative:
		lda 	NSMantissa0,x 				; copy out to the basic stack
		sta 	(basicStack),y		
		iny
		lda 	NSMantissa1,x
		sta 	(basicStack),y
		iny
		lda 	NSMantissa2,x
		sta 	(basicStack),y
		iny
		lda 	NSMantissa3,x
		sta 	(basicStack),y
		rts

; ************************************************************************************************
;
;					Copy the index register out to the variable referenced.
;
; ************************************************************************************************

CopyIndexToReference:
		phy
		; 
		ldy 	#5 							; copy address-7 to write to zTemp0
		sec 								; (because we copy from offset 7)
		lda 	(basicStack),y
		sbc 	#7
		sta 	zTemp0
		iny
		lda 	(basicStack),y
		sbc 	#0
		sta 	zTemp0+1
		;
		ldx 	#4 							; this is the copy counter/
		;
		ldy 	#7+3 		 				; the MSB of the mantissa
		lda 	(basicStack),y
		asl 	a 							; into carry

		ldy 	#7 							; where to copy from.
		bcc 	_CITRNormal		
		;
		sec
_CITRNegative:								; copy and negate simultaneously.
		lda 	#0
		sbc 	(basicStack),y
		sta 	(zTemp0),y
		iny
		dex 
		bne 	_CITRNegative		
		dey 								; look at MSB of mantissa

		lda 	(zTemp0),y 					; set the MSB as negative packed.
		ora 	#$80
		sta 	(zTemp0),y
		ply
		rts

_CITRNormal:
		lda 	(basicStack),y 				; copy without negation.
		sta 	(zTemp0),y
		iny
		dex 
		bne 	_CITRNormal
		ply 								; and exit.
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
