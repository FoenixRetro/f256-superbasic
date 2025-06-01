;;
; Console data definitions
;;
		.section storage

EXTMemory = $C000
EXTTextPage = $02
EXTColourPage = $03

EXTDummySpace = 1 							; fake-space for CR character.
EXTCBlack = 0

;;
; Current cursor row position.
;
; Stores the current vertical position of the text cursor on the screen
; (`[0, EXTScreenHeight)`). Row numbering starts at 0 for the top line and
; increases downward.
;
; \size    1 byte
; \see     EXTColumn, EXTAddress, EXTScreenHeight, EXTHomeCursor
;;
EXTRow: 									; current row
		.fill 	1

;;
; Current cursor column position.
;
; Stores the current horizontal position of the text cursor on the screen
; (`[0, EXTScreenWidth)`). Column numbering starts at 0 for the leftmost
; position and increases rightward.
;
; \size    1 byte
; \see     EXTRow, EXTAddress, EXTScreenWidth, EXTHomeCursor
;;
EXTColumn: 									; current column
		.fill 	1

;;
; Current text color.
;
; Stores the color value used for newly printed characters. This value is
; written to the color memory when characters are displayed on screen.
;
; \size    1 byte
; \see     EXTColourPage, EXTRow, EXTColumn, EXTAddress
;;
EXTTextColour: 								; current color
		.fill 	1

;;
; Screen width in characters.
;
; Stores the number of character columns available on the screen . Used for
; line wrapping, cursor positioning, and screen memory calculations. Typically
; set to 40 or 80 characters.
;
; \size    1 byte
; \see     EXTScreenHeight, EXTColumn, EXTScreenRowOffsets
;;
EXTScreenWidth:	 							; screen width
		.fill 	1

;;
; Screen height in characters.
;
; Stores the number of character rows available on the screen. This value
; is used for scrolling, cursor positioning, and screen memory calculations.
; Typical values are 25, 30, 50 or 60 rows.
;
; \note    Typical values: 25, 30, or 50 rows
; \see     EXTScreenWidth, EXTRow, EXTScreenRowOffsets
;;
EXTScreenHeight:	 						; screen height
		.fill 	1

		.send storage

		.section zeropage

;;
; Current screen line address pointer.
;
; 16-bit pointer to the screen address marking the start of the current line.
; This address is calculated from `EXTMemory` + row offset and is used for
; fast character positioning and screen operations.
;
; \size    2 bytes
; \note    Located in zero page for efficient indirect addressing.
; \see     EXTMemory, EXTRow, EXTColumn, EXTScreenRowOffsets
;;
EXTAddress:
		.fill 	2					 	 	; start of the current line

		.send zeropage
