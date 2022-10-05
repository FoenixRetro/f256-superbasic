; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		local.asm
;		Purpose:	LOCAL command
;		Created:	5th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************

; ************************************************************************************************
;
;									Local - non array values
;
; ************************************************************************************************

		.section code

Command_LOCAL: ;; [local]
		ldx 	#0 							; at level 0
		jsr 	LocaliseNextTerm 			; convert term to a local.
		.cget 								; followed by comma ?
		iny
		cmp 	#KWD_COMMA
		beq 	Command_LOCAL
		dey 								; unpick pre-get
		rts

; ************************************************************************************************
;
;				Get a term reference and push its value on BASIC stack, using Stack[x]
;
; ************************************************************************************************

LocaliseNextTerm:
		jsr 	EvaluateTerm 				; evaluate the term
		lda 	NSStatus,x
		and 	#NSBIsReference 			; check it is a reference
		beq		_LNTError
		;
		lda 	NSMantissa0,x 				; copy address of variable to zTemp0
		sta 	zTemp0
		lda 	NSMantissa1,x
		sta  	zTemp0+1
		;
		lda 	NSStatus,x
		and 	#NSBIsString
		bne 	_LNTPushString
		;
		;		Push number
		;
		phy
		ldy 	#0 							; push 0 to 4 inclusive, the number values, on the stack, and zero them as you go.
_LNTPushNumLoop:
		lda		(zTemp0),y
		jsr 	StackPushByte
		lda 	#0
		sta 	(zTemp0),y
		iny
		cpy 	#5			
		bne 	_LNTPushNumLoop
		;
		lda 	zTemp0 						; push the actual target address to write on the stack
		jsr 	StackPushByte
		lda 	zTemp0+1
		jsr 	StackPushByte
		;
		lda 	#STK_LOCALN 				; push local-number marker.
		jsr 	StackPushByte
		ply
		rts
		;
		;		Push string
		;
_LNTPushString:
		.debug

_LNTError:
		jmp 	SyntaxError
		.send code

; ************************************************************************************************
;
;								Pop a local off the stack
;
; ************************************************************************************************

LocalPopValue:
		jsr 	StackPopByte
		cmp 	#STK_LOCALN 				; if not local-N
		bne 	_LPVString
		;
		;		Remove number
		;
		jsr 	StackPopByte 				; address
		sta 	zTemp0+1
		jsr 	StackPopByte
		sta 	zTemp0
		phy
		ldy 	#4 							; copy back
_LPVNumberCopy:
		jsr 	StackPopByte
		sta 	(zTemp0),y
		dey
		bpl 	_LPVNumberCopy
		ply 								; and complete		
		rts
		;
		;		Remove string
		;
_LPVString:
		.debug

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
