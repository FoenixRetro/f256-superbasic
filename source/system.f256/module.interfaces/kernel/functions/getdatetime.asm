; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		getdatetime.asm
;		Purpose:	Extract date/time from RTC as string
;		Created:	11th January 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
; 				Get Date/Time use same code but have different addresses in the
;				RTC at $D690	
;
; ************************************************************************************************

UnaryGetTime: ;; [gettime$(]
		lda 	#0
		bra 	UGDTMain
UnaryGetDate: ;; [getdate$(]		
		lda 	#3
UGDTMain:
		plx 								; get stack position back

		pha 								; save table offset
		jsr 	Evaluate8BitInteger			; ignored parameter
		jsr 	CheckRightBracket 			; closing )
		pla 								; table offset in A

		phy 								; saving Y
		tay 								; table offset in Y
		;
		lda 	#8							; allocate space for 8 chars DD:MM:YY
		jsr 	StringTempAllocate
		;
		lda 	1 							; save I/O table and switch to I/O page 0
		pha
		stz 	1
		;
		jsr 	UGDTDigit 					; do XX:YY:ZZ
		jsr 	UGDTColonDigit		
		jsr 	UGDTColonDigit		

		pla 								; restore I/O select
		sta 	1

		ply  								; restore code position
		rts

UGDTColonDigit:
		lda 	#':'		
		jsr 	StringTempWrite
UGDTDigit:		
		phx 								; save X
		lda 	RTCROffset,y 				; get offset in RTC register
		tax
		lda 	$D690,x 					; read RTC register
		and 	RTCRMask,y 					; and with Mask.		
		plx

		pha 								; output in BCD
		lsr 	a
		lsr 	a
		lsr 	a
		lsr 	a
		ora 	#48
		jsr 	StringTempWrite
		pla
		and 	#15		
		ora 	#48
		jsr 	StringTempWrite

		iny
		rts

RTCROffset: 								; offset in table
		.byte 	4,2,0,6,9,10
RTCRMask:		 							; mask out unwanted bits. (e.g. AM/PM flag)
		.byte 	$3F,$7F,$7F,$3F,$1F,$7F
		
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
