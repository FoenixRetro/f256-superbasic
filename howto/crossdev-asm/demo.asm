; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		demo.asm
;		Purpose:	Display pattern on text console top few lines
;		Created:	18th January 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

	* = $2000								; we start at $2000

; ************************************************************************************************
;
;											Header
;
; ************************************************************************************************

	bra 	Start 							; jump round the marker

	.text 	"BT65" 							; this marker identifies the code as runnable machine
											; code and goes in 2002-2005

; ************************************************************************************************
;
;										Main Program
;
; ************************************************************************************************

Start:	
	ldx 	#0 								; Y is character, X is colour foreground/background
	ldy 	#0

NewScreen:
	lda 	#0 								; $20 points to the screen
	sta 	$20
	lda 	#$C0
	sta 	$21

FillTop:	
	lda 	#2 								; switch to I/O block 2 where the text memory is
	sta 	1
	tya 									; write character Y there.	
	sta 	($20),y

	lda 	#3 								; switch to I/O block 3 where the colour memory is
	sta 	1
	txa 									; write colour X there
	sta 	($20),y

	lda 	#64 							; changing this makes it go faster/slower.
SlowMe:
	dec 	a
	bne 	SlowMe

	dey 									; do a page of 256 chars
	bne 	FillTop 						

	inc 	$21 							; next page
	lda 	$21
	cmp 	#$D2
	bne 	FillTop 						; done most of the page, if not go back.

	inx 									; next colour
	bra 	NewScreen