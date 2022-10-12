
; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		gcommand.asm
;		Purpose:	GFX Drawing Commands
;		Created:	12th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									 Rectangles and Circles
;
; ************************************************************************************************

RectangleCommand: 	;; [RECT]
		lda 	#18*2 						; frame rectangle
		bra 	ShapeDrawCmd
CircleCommand: ;; [CIRCLE]
		lda 	#20*2 						; framed circle
ShapeDrawCmd:		
		jsr 	RunGraphicsCommand
		;
		;		Handle drawing command ()
		;
ShapeDraw:
		ora 	gxFillSolid  				; adjust AXY for solid fill.
		jmp 	ExecuteGraphicCommand	 	; and complete

; ************************************************************************************************
;
;									 		Line
;
; ************************************************************************************************

LineCommand: ;; [LINE]
		lda 	#17*2 						; command ID to use
		jsr 	RunGraphicsCommand

; ************************************************************************************************
;
;					Standard graphic command handler ; AX = X,Y = Y
;
; ************************************************************************************************

ExecuteGraphicCommand:
		ora 	gxCommandID 				; make a full command
		jsr 	GXGraphicDraw 				; draw it and exit
		bcs 	_EGCError
		rts
_EGCError:
		jmp 	SyntaxError

; ************************************************************************************************
;
;								  Run a graphics command sequence
;
; ************************************************************************************************

RunGraphicsCommand:
		sta 	gxCommandID					; save TODO graphics command.
		pla 								; pop handler address
		plx
		inc 	a
		bne 	_RGINoCarry
		inx
_RGINoCarry:
		sta 	GXHandler
		stx 	GXHandler+1
		;
		;		Now start processing commands
		;
_RGICommandLoop:
		.cget 								; next token
		iny
		cmp 	#KWD_TO						; is it TO x,y
		beq 	_RGI_To
		cmp 	#KWD_HERE 					; do it here.
		beq 	_RGI_Here
		cmp 	#KWC_EOL 					; EOL or : , exit		
		beq 	_RGI_Exit
		cmp 	#KWD_COLON
		beq 	_RGI_Exit
		cmp 	#KWD_OUTLINE 				; solid or outline
		beq 	_RGI_Frame
		cmp 	#KWD_SOLID
		beq 	_RGI_Solid
		cmp 	#KWD_BY 					; by offset
		beq 	_RGI_By
		cmp 	#KWD_FROM 					; from
		beq 	_RGI_Move
		cmp 	#KWD_DIM 					; dim (set scale)
		beq 	_RGI_Dim
		cmp 	#KWD_COLOUR 				; colour or Color
		beq 	_RGI_Colour
		cmp 	#KWD_COLOR
		beq 	_RGI_Colour
		;
		;		Just move.
		;
		dey 								; unpick get.
_RGI_Move:		
		jsr 	GCGetCoordinatePair 		; move to here
		jsr 	GCCopyPairToStore 			; save
		phy
		jsr 	GCLoadAXY 					; load in
		ora 	#16*2 						; move there	
		jsr 	GXGraphicDraw
		ply
		bra 	_RGICommandLoop 			; and go round

_RGI_Exit:
		dey 								; unpick : / EOL
		rts
		;
		;		Set Solid/Fill
		;
_RGI_Solid:
		lda 	#2
		sta 	gxFillSolid
		bra 	_RGICommandLoop		
_RGI_Frame:
		stz 	gxFillSolid
		bra 	_RGICommandLoop		
		;
		;		Draw, or whatever, at a coordinate pair
		;
_RGI_To:
		jsr 	GCGetCoordinatePair 		; get coordinate pair into slot #1,#2
		jsr 	GCCopyPairToStore
		;
		;		Draw, or whatever here.
		;
_RGI_Here:		
		phy
		jsr 	GCLoadAXY 					; load it into AXY
		jsr 	_RGICallHandler 			; go do whatever it is.
		ply
		bra 	_RGICommandLoop 			; and go round
		;
		;		By Offset
		;
_RGI_By:
		jsr 	GCGetCoordinatePair 		; get coordinate pair into slot #1,#2
		clc
		lda 	NSMantissa0+1 				; copy it into space.
		adc 	gxxPos
		sta 	gxXPos
		lda 	NSMantissa1+1
		adc 	gxxPos+1
		sta 	gxXPos+1
		lda 	NSMantissa0+2
		clc
		adc 	gxYPos
		sta 	gxYPos
		bra 	_RGI_Here
		;
		;		DIM Set Dimension
		;
_RGI_Dim:
		jsr 	Evaluate8BitInteger
		cmp 	#0
		beq 	_RGIRange
		cmp 	#8+1
		bcs		_RGIRange
		dec 	a
		.debug
		sta 	gxScale
		jmp 	_RGICommandLoop
		;
		; 		Handle Colour/Color
		;
_RGI_Colour:
		ldx 	#1 							; colour
		jsr 	Evaluate8BitInteger		
		ldx 	#2 							; default zero for 2nd parameter
		jsr 	NSMSetZero
		.cget
		cmp 	#KWD_COMMA 					; check , => mode.
		bne 	_RGICDefaultMode
		iny
		jsr 	Evaluate8BitInteger		
_RGICDefaultMode:		
		phy
		lda 	#4*2 						; set colour.
		ldx 	NSMantissa0+1
		ldy 	NSMantissa0+2
		jsr 	GXGraphicDraw
		ply
		jmp 	_RGICommandLoop 			; and go round

_RGIRange:
		jmp 	RangeError
_RGICallHandler:
		jmp 	(GXHandler)

; ************************************************************************************************
;
;						Get coordinate pair to Mantissa 1/2
;
; ************************************************************************************************

GCGetCoordinatePair:
		ldx 	#1
		jsr 	Evaluate16BitInteger
		jsr 	CheckComma
		inx
		jsr 	Evaluate16BitInteger
		rts
_GCCPRange:
		jmp 	RangeError		

; ************************************************************************************************
;
;							Copy current position to AXY
;
; ************************************************************************************************

GCLoadAXY:
		lda 	gxXPos+1
		ldx 	gxXPos
		ldy 	gxYPos
		rts

; ************************************************************************************************
;
;								Copy mantissa data to store
;
; ************************************************************************************************

GCCopyPairToStore:
		lda 	NSMantissa0+1 				; copy it into space.
		sta 	gxXPos
		lda 	NSMantissa1+1
		sta 	gxXPos+1
		lda 	NSMantissa0+2
		sta 	gxYPos
		rts


		.send code

		.section storage

gxCommandID: 								; current command
		.fill 	1
gxFillSolid: 								; 0 for frame, 2 for solid.
		.fill 	1		
gxXPos: 									; x position
		.fill 	2
gxYPos: 									; y position
		.fill 	1		
gxHandler: 									; handler address
		.fill 	2
gxDrawScale: 								; default scale 0-7
		.fill 	1		
		.send storage

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
