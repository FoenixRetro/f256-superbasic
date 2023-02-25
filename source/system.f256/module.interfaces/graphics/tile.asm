; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		tile.asm
;		Purpose:	Tile draw/read commands
;		Created:	25th February 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;											TILE command
;
; ************************************************************************************************

TileCommand: ;; [tile]
		.cget 
		iny
		cmp 	#KWD_AT
		beq 	_TileSetPos
		cmp 	#KWD_PLOT
		beq 	_TilePlot
		cmp 	#KWD_TO
		beq 	_TileScroll
		dey
		rts
		;
		;		Handle AT x,y
		;
_TileSetPos:
		ldx 	#0 							; location to XA
		jsr 	TileGetPair
		phy 								; call routine
		tay
		lda 	#GCMD_TilePos
		jsr 	GXGraphicDraw
		ply
		bra 	TileCommand 				; loop round
		;
		;		Handle PLOT n [LINE x], ....
		;
_TilePlot:
		ldx 	#0
		jsr 	Evaluate8BitInteger 		; tile to print
		lda 	#1
		sta 	NSMantissa0+1 				; default repeat count.
		ldx 	#1
		.cget 								; is it LINE x
		cmp 	#KWD_LINE
		bne 	_TileNoRepeat
		iny 								; skip LINE
		jsr 	Evaluate8BitInteger 		; evaluate count
_TileNoRepeat:
		;
		;		Write tile out given number of times (0-255)
		;
_TileOutLoop:
		lda 	NSMantissa0+1 				; complete ?
		beq 	_TileCheckAgain 			; check , <repeats>		
		dec 	NSMantissa0+1 				; dec count
		lda 	#GCMD_TileWrite				; set up to write tile.
		ldx 	NSMantissa0 
		phy 								; call preserving Y
		jsr 	GXGraphicDraw
		ply
		bra 	_TileOutLoop
		;
		;		Retry if comma
		;
_TileCheckAgain:
		.cget 								; , follows, more tile data
		cmp 	#KWD_COMMA
		bne 	TileCommand 				; no, do again
		iny 								; consume comma
		bra 	_TilePlot 					; and loop round.
		;
		;		Handle SCROLL x,y
		;
_TileScroll:
		lda 	#GCMD_TileScrollX 			; do X
		jsr 	_TileSetScroll
		jsr 	CheckComma
		lda 	#GCMD_TileScrollY 			; do Y
		jsr 	_TileSetScroll
		bra 	TileCommand
;
;		Set Scroll using command A.
;		
_TileSetScroll:
		pha 								; save command on stack
		ldx 	#0 							; get value to scroll to
		jsr 	Evaluate16BitInteger
		pla 								; restore command
		phy 								; save Y code pos
		ldx 	NSMantissa0 				; YX = scroll value
		ldy 	NSMantissa1
		jsr 	GXGraphicDraw 				; do command
		ply 								; restore code pos
		rts
;
;		Get coordinate pair to X A
;
TileGetPair:
		jsr 	Evaluate8BitInteger
		pha
		jsr 	CheckComma
		jsr 	Evaluate8BitInteger
		plx
		rts

; ************************************************************************************************
;
;										Tile unary function
;
; ************************************************************************************************

TileRead: ;; [tile(]
		plx 								; current stack pos (where the result goes)
		phx 								; save it back again
		inx   								; space to evaluate coordinates
		jsr 	TileGetPair 				; X A are the coordinates
		phy 								; save code position
		tay 								; X Y are the coordinates.
		lda 	#GCMD_TilePos 				; set the read position.
		jsr 	GXGraphicDraw
		lda 	#GCMD_TileRead 				; read the tile there
		jsr 	GXGraphicDraw
		ply 								; restore code and stack positions
		plx
		jsr 	NSMSetByte 					; set the result.
		jsr 	CheckRightBracket 			; check for )
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
