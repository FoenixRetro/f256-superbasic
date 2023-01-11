; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		setdatetime.asm
;		Purpose:	SETDATE/SETTIME commands
;		Created:	11th January 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Set Date/Time command, common code.
;		
; ************************************************************************************************

CommandSetDate: ;; [setdate]
		lda 	#3
		bra 	CSDTMain
CommandSetTime: ;; [settime]
		lda 	#0
CSDTMain:									
		pha 								; save table offsets 0 or 3

		ldx 	#0 							; input 3 values.
		jsr 	Evaluate8BitInteger		
		jsr 	CheckComma
		inx
		jsr 	Evaluate8BitInteger		
		jsr 	CheckComma
		inx
		jsr 	Evaluate8BitInteger		

		pla 								; table offset in Y, saving Y
		phy
		tay
		ldx 	#0 							; first number

		lda 	1 							; save I/O page, switch to zero
		pha 
		stz 	1

_CSDTCopy:
		lda 	NSMantissa0,x 				; get first number

		cmp 	RTCWMinValues,y 			; check range
		bcc 	_CSDTRange
		cmp 	RTCWMaxValues,y
		bcs 	_CSDTRange

		jsr 	CSDTDecimalToBCD

		phx 								; save X
		ldx 	RTCWOffset,y 				; offset in RTC in X
		sta 	$D690,x 					; write to RTC
		plx 								; restore X

		inx 								; next number
		iny 								; next table entries
		cpx 	#3 							; until done all 3.
		bne 	_CSDTCopy

		pla 								; restore I/O space
		sta 	1

		ply 								; restore code pos and exit.
		rts

_CSDTRange:
		.error_range

; ************************************************************************************************
;
;										Convert A to BCD
;
; ************************************************************************************************

CSDTDecimalToBCD:
		phx 								; 10 count in X
		ldx 	#0
_CSDTDBLoop:
		cmp 	#10 						; < 10 evaluate result.
		bcc 	_CSDTDBExit		
		sbc 	#10 						; 10 from value
		inx 								; one more 10s.
		bra 	_CSDTDBLoop
_CSDTDBExit:
		sta 	zTemp0 						; units
		txa 								; 10s x 16
		asl 	a
		asl 	a
		asl 	a
		asl 	a
		ora 	zTemp0 						; BCD result and exit
		plx
		rts

RTCWOffset: 								; offset in table
		.byte 	4,2,0,6,9,10
RTCWMinValues:
		.byte 	0,0,0,1,1,0				
RTCWMaxValues:
		.byte 	24,60,60,32,13,100
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
