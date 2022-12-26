; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		for.asm
;		Purpose:	For/Next loop
;		Created:	1st October 2022
;		Reviewed: 	1st December 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
;
;		+16 		Step (1 or 255)
;		+12..+15	Terminal value ((in 2's complement format.)
;		+8..+11 	Value of index variable (in 2's complement format.)
;		+6..+7 		Address of index variable
;		+1..5 		Loop back address
;
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;										For command
;
; ************************************************************************************************

ForCommand: ;; [for]
		lda 	#STK_FOR+9 					; allocate 18 bytes on the return stack (see above).
		jsr 	StackOpen 
		;
		;		Get an integer reference to Stack[0] - this is the loop variable.
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
		ldy 	#16
		sta 	(basicStack),y 				; copy that out to the Basic Stack.
		;
		;		Copy the reference where the index goes.
		;
		ldy 	#6 							; this is the address of the loop variable.
		lda 	NSMantissa0
		sta 	(basicStack),y
		lda 	NSMantissa1
		iny
		sta 	(basicStack),y
		;
		;		Copy the initial and terminal values in 2's complement
		;
		ldy 	#8 							; set initial index value
		ldx 	#1
		jsr 	FCIntegerToStack
		ldy 	#12 						; set the terminal value
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
		ldy 	#6 							; copy address-8 to write to zTemp0
		sec 								; (because we copy from offset 8)
		lda 	(basicStack),y
		sbc 	#8
		sta 	zTemp0
		iny
		lda 	(basicStack),y
		sbc 	#0
		sta 	zTemp0+1
		;
		ldx 	#4 							; this is the copy counter/
		;
		ldy 	#8+3 		 				; the MSB of the mantissa
		lda 	(basicStack),y
		asl 	a 							; into carry

		ldy 	#8 							; where to copy from.
		bcc 	_CITRNormal		
		;
		;		Copy out -ve
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
		;
		;		Copy out +ve
		;
_CITRNormal:
		lda 	(basicStack),y 				; copy without negation.
		sta 	(zTemp0),y
		iny
		dex 
		bne 	_CITRNormal
		ply 								; and exit.
		rts

; ************************************************************************************************
;
;										NEXT command
;
; ************************************************************************************************

NextCommand: ;; [next]
		lda 	#STK_FOR+9 					; check FOR is TOS
		ldx 	#ERRID_FOR 					; this error
		jsr 	StackCheckFrame		

		phy
		ldy 	#16 						; get the step count
		lda 	(basicStack),y
		sta 	zTemp0 						; this is the sign extend
		bmi 	_NCStepNeg
		stz 	zTemp0 						; which is 0 or 255
_NCStepNeg:
		;
		;		Bump the index, and update the index variable
		;
		ldy 	#8 							; offset to bump
		ldx 	#4 							; count to bump
		clc
_NCBump:
		adc 	(basicStack),y 				; add it
		sta 	(basicStack),y
		lda 	zTemp0 						; get sign extend for next time.
		iny 								; next byte
		dex 								; do four times
		bne 	_NCBump
		jsr		CopyIndexToReference		; copy it to the reference variable.
		;
		;		Compare the index and terminal value
		;
		;		if TO , exit if terminal < index (e.g. 10 < 11)
		;		if DOWNTO, exit if index < terminal (e.g. -3 < -2)
		;
		ldy 	#16 						; get step count again
		lda 	(basicStack),y
		asl 	a 							; sign bit to carry
		;
		lda 	#12 						; offset of LHS = terminal offset
		sta 	zTemp1
		bcc 	_NCCompRev 					; use if step is +ve
		lda 	#8 							; now the LHS = index value
_NCCompRev:
		sta 	zTemp1 						; so zTemp0 is the index for LHS
		eor 	#(8^12) 					; and zTemp0+1 is the index for RHS
		sta 	zTemp1+1
		ldx 	#4 							; bytes to compare
		sec

_NCCompare:		
		ldy 	zTemp1 						; do compare using the two indices
		lda 	(basicStack),y
		ldy 	zTemp1+1
		sbc 	(basicStack),y

		inc 	zTemp1 						; bump the indices (inc,dex do not change C or V)
		inc 	zTemp1+1
		dex 								; do it 4 times.
		bne 	_NCCompare
		;
		bvc 	_NCNoOverflow 				; convert to signed comparison
		eor 	#$80
_NCNoOverflow:
		ply 								; restore Y position
		asl 	a 							; is bit 7 set.
		bcc 	_NCLoopBack 				; if no , >= so loop back
		;
		jsr 	StackClose 					; exit the loop
		rts

_NCLoopBack:
		jsr 	STKLoadCodePosition 		; loop back
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
