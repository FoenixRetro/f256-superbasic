; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		items.asm
;		Purpose:	Split up strings using character
;		Created:	12th January 2023
;		Reviewed: 	No.
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
; 										ItemCount(str$,sep$)
;
; ************************************************************************************************

ItemCountUnary: 	;; [itemcount(]
		plx
		jsr 	EvaluateString
		inx
		jsr 	ICGetSeperator
		dex
		jsr 	ICSetPointer 				; zTemp0 = (string)
		jsr 	NSMSetZero 					; zero the result.
		phy
		ldy 	#$FF 						; loop counting seperators in mantissa
_ICULoop:
		iny
		lda 	(zTemp0),y
		cmp 	ICSeperator
		bne 	_ICUNoMatch
		inc 	NSMantissa0,x
_ICUNoMatch:
		cmp 	#0
		bne 	_ICULoop		
		inc 	NSMantissa0,x 				; +1
		ply
		rts

; ************************************************************************************************
;
; 								ItemGet$(str$,count,sep$)
;
; ************************************************************************************************

ItemGetUnary: 	;; [itemget$(]
		plx
		jsr 	EvaluateString 				; search string
		jsr 	CheckComma 
		inx 								; get count
		jsr 	Evaluate8BitInteger
		cmp 	#0 							; must be > 0, index starts at 1.
		beq 	ICGSRange
		inx 								; get seperator.
		jsr 	ICGetSeperator
		dex
		dex
		phy
		;
		;		Work out where the substring starts.
		;
		jsr 	ICSetPointer 				; zTemp0 points to string.
		ldy 	#0
		dec 	NSMantissa0+1,x 			; first element.
		beq 	_IGUFoundStart

_IGUFindNext:
		lda 	(zTemp0),y		 			; next
		beq 	ICGSRange 					; eol, not found.
		iny
		cmp 	ICSeperator 				; until found a seperator (or EOS)
		bne 	_IGUFindNext		
		dec 	NSMantissa0+1,x
		bne 	_IGUFindNext
		;
_IGUFoundStart:								; found start		
		sty 	zTemp1 						; save start
		;
		;		Work out how long the string is.
		;
		dey
_IGUFindLength:
		iny 								; forward till seperator/EOS
		lda 	(zTemp0),y		
		beq 	_IGUFoundLength
		cmp 	ICSeperator
		bne 	_IGUFindLength
_IGUFoundLength:		
		;
		;		Copy substring - first calculate length and create string space
		;
		sty 	zTemp1+1 					; save end of copy string
		tya 								; calculate length of new string.
		sec
		sbc 	zTemp1
		jsr 	StringTempAllocate 			; allocate bytes for it.
		;
		;		Copy string out
		;
		ldy 	zTemp1
_IGUCopySub:
		cpy 	zTemp1+1
		beq 	_IGUCopyOver
		lda 	(zTemp0),y
		jsr 	StringTempWrite
		iny
		bra 	_IGUCopySub
_IGUCopyOver:
		ply
		rts		
		.debug

; ************************************************************************************************
;
;										get ,<seperator>)
;
; ************************************************************************************************

ICGetSeperator:
		jsr 	CheckComma 					; preceding comma
		jsr 	EvaluateString 				; seperator string
		jsr 	ICSetPointer 				; access it
		lda 	(zTemp0) 					; get sep char
		sta 	ICSeperator
		beq 	ICGSRange 					; check LEN(seperator) = 1
		phy
		ldy 	#1
		lda 	(zTemp0),y
		bne 	ICGSRange
		ply
		jsr 	CheckRightBracket 			; check following )
		rts
ICGSRange:
		.error_range

; ************************************************************************************************
;
;										zTemp0 <= string
;
; ************************************************************************************************

ICSetPointer:
		lda 	NSMantissa0,x 				; set zTemp0 to point to it.
		sta 	zTemp0		
		lda 	NSMantissa1,x
		sta 	zTemp0+1
		rts

		.send code

		.section storage
ICSeperator:
		.fill 	1
		.send 	storage

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
