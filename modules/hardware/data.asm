;;
; Console data definitions
;;

EXTMemory 		= $C000
EXTTextPage 	= $02
EXTColourPage 	= $03

		.section storage
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
EXTRow				.fill 	1

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
EXTColumn			.fill 	1

;;
; Current text color.
;
; Stores the color value used for newly printed characters. This value is
; written to the color memory when characters are displayed on screen.
;
; \size    1 byte
; \see     EXTColourPage, EXTRow, EXTColumn, EXTAddress
;;
EXTTextColour		.fill 	1

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
EXTScreenWidth		.fill 	1

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
EXTScreenHeight		.fill 	1

		.align 2
;;
; Precomputed row offset table.
;
; Contains precomputed memory offsets for each screen row to enable fast row
; address calculation. Each entry is a 16-bit offset from the screen base
; address (`EXTMemory`) to the start of that row. The table is filled during
; initialization by `EXTInitialise`.
;
; \size    128 entries × 2 bytes = 256 bytes total
; \see     EXTInitialise, EXTMemory, EXTAddress
;;
EXTScreenRowOffsets	.fill 	128 * 2

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
EXTAddress			.fill 	2

		.send zeropage
