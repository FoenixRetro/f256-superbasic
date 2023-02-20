;;;
;;; An example showing how tiles work
;;;

.include "../common/f256jr.asm"         ; Include register definitions for the F256jr
.include "../common/f256_tiles.asm"     ; Include the registers for the tiles

;
; Definitions
;

; Point the reset vector to the start of code to kick start it


;
; Define some variables
;

* = $0080

ptr_src     .word ?                     ; A pointer to data to read
ptr_dst     .word ?                     ; A pointer to data to write

* = $2000

start:      
			bra     boot                        ; jump round the marker
			.text   "BT65"  

z0 = $30
boot:
			sei

			;
			; Set up TinyVicky to display tiles
			;
			lda #$20+$10+$04+$08        ; Sprites , Tiles Graphics Bitmaps
			;lda #$10+$30
			sta VKY_MSTR_CTRL_0
			stz VKY_MSTR_CTRL_1         ; 320x240 @ 60Hz

			lda #$40                    ; Layer 0 = Bitmap 0, Layer 1 = Tile map 0
			sta VKY_LAYER_CTRL_0
			lda #$15                    ; Layer 2 = Tile Map 1
			sta VKY_LAYER_CTRL_1

			stz VKY_BRDR_CTRL           ; No border

			lda #1 						; Bitmap.
			sta 	$D100
			stz     $D101
			stz     $D102
			lda 	#1
			sta     $D103

			lda #8
			sta 8+3

Fill1:		stz 	z0
			lda 	#$60
			sta 	z0+1
Fill2:		lda 	z0
			bmi 	Fill4
			lsr 	a
			bcc 	Fill3
Fill4:			
			lda 	#0
Fill3:			
			sta 	(z0)
			inc 	z0
			bne 	Fill2
			inc 	z0+1
			bpl 	Fill2
			inc 	8+3
			lda 	8+3
			cmp 	#16
			bne 	Fill1


			lda #$19                    ; Background: midnight blue
			sta VKY_BKG_COL_R
			lda #$19
			sta VKY_BKG_COL_G
			lda #$0
			sta VKY_BKG_COL_B

			lda 	#$00
			stz 	$D901 				; sprites.
			lda 	#$02
			sta 	$D902
			lda 	#$03
			sta 	$D903

			lda 	#1
			sta 	$D900

			lda 	#64
			sta 	$D904
			stz 	$D905
			sta 	$D906
			stz 	$D907
			;
			; Load the tile set LUT into memory
			;

			lda #$01                    ; Switch to I/O Page #1
			sta MMU_IO_CTRL

			lda #<tiles_clut_start      ; Set the source pointer to the palette data
			sta ptr_src
			lda #>tiles_clut_start
			sta ptr_src+1

			lda #<VKY_GR_CLUT_0         ; Set the destination pointer to Graphics CLUT 1
			sta ptr_dst
			lda #>VKY_GR_CLUT_0
			sta ptr_dst+1

			ldx #0                      ; X is a counter for the number of colors copied
color_loop: ldy #0                      ; Y is a pointer to the component within a CLUT color
comp_loop:  lda (ptr_src),y             ; Read a byte from the code
;			sta (ptr_dst),y             ; And write it to the CLUT
			iny                         ; Move to the next byte
			cpy #4
			bne comp_loop               ; Continue until we have copied 4 bytes

			inx                         ; Move to the next color
			cmp #20
			beq done_lut                ; Until we have copied all 20

			clc                         ; Advance ptr_src to the next source color entry
			lda ptr_src
			adc #4
			sta ptr_src
			lda ptr_src+1
			adc #0
			sta ptr_src+1

			clc                         ; Advance ptr_dst to the next destination color entry
			lda ptr_dst
			adc #4
			sta ptr_dst
			lda ptr_dst+1
			adc #0
			sta ptr_dst+1

			bra color_loop              ; And start copying that new color

done_lut:   stz MMU_IO_CTRL             ; Go back to I/O Page 0

			;
			; Set tile set #0 to our image
			;

			lda #$00
			sta VKY_TS0_ADDR_L
			lda #$60
			sta VKY_TS0_ADDR_M
			lda #$02
			sta VKY_TS0_ADDR_H

			;
			; Set tile map #0
			;

			lda #$11                    ; 8x8 tiles, enable
			sta VKY_TM0_CTRL			
			stz VKY_TM1_CTRL            ; Make sure the other tile maps are off
			stz VKY_TM2_CTRL

			lda #42                     ; Our tile map is 42x32
			sta VKY_TM0_SIZE_X
			lda #32
			sta VKY_TM0_SIZE_Y

			lda #$00              ; Point to the tile map
			sta VKY_TM0_ADDR_L
			lda #$40
			sta VKY_TM0_ADDR_M
			lda #$02
			sta VKY_TM0_ADDR_H

			lda #tile_map & $FF       ; Point to the tile map
			sta VKY_TM0_ADDR_L
			lda #tile_map >> 8
			sta VKY_TM0_ADDR_M
			lda #$00
			sta VKY_TM0_ADDR_H

			lda #0                    ; Set scrolling X = 8
			sta VKY_TM0_POS_X_L
			stz VKY_TM0_POS_X_H

			lda #0
			sta VKY_TM0_POS_Y_L         ; Set scrolling Y = 0
			stz VKY_TM0_POS_Y_H

lock:       inc a
			and #7
			ora #16
			lda #0
			sta VKY_TM0_POS_Y_L
			sta VKY_TM0_POS_X_L
delay:		dex
			bne 	delay
			dey			
			bne 	delay
			bra 	lock

.include "tiles_pal.asm"
.include "tile_map.asm"