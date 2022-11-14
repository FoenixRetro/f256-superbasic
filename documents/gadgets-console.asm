; OpenKERNAL - a clean-room implementation of the C64's KERNAL ABI.
; Copyright 2022 Jessie Oberreuter <Gadget@HackwrenchLabs.com>.
; SPDX-License-Identifier: GPL-3.0-only

; Low level Console driver.
; TODO: move screen editor to kernel.

            .cpu    "w65c02"

            .namespace  platform
console     .namespace

* = $c000
            .binary     "platform/jr/Bm437_PhoenixEGA_8x8.bin"


ROWS = 60
COLS = 80
TABS = 4


; IO PAGE 0
TEXT_LUT_FG      = $D800
TEXT_LUT_BG	 = $D840
; Text Memory
TEXT_MEM         = $C000 	; IO Page 2
COLOR_MEM        = $C000 	; IO Page 3

            .section    dp
src         .word   ?
dest        .word   ?
count       .word   ?

cur_x       .byte   ?
cur_y       .byte   ?
ptr         .word   ?
color       .byte   ?
rev         .byte   ?
            .send


            .section    kernel

init
            jsr     TinyVky_Init
            lda     #$e6
            sta     color
            stz     rev
            jsr     cls

            clc
            rts


TinyVky_Init:
            stz     $1

            stz     MASTER_CTRL_REG_L       ; Everything off during init.
            stz     MASTER_CTRL_REG_H       ; 640x480

            lda     #Mstr_Ctrl_Text_Mode_En;
            sta     MASTER_CTRL_REG_L
            
            jsr     init_text_palette
            jsr     init_border
            jsr     init_font
            jsr     init_graphics_palettes

          ; We'll manage our own cursor
            stz     VKY_TXT_CURSOR_CTRL_REG

            rts

init_text_palette

            ldx     #0
_loop       lda     _palette,x
            sta     TEXT_LUT_FG,x
            sta     TEXT_LUT_BG,x
            inx
            cpx     #64
            bne     _loop
            rts
_palette
            .dword  $000000
            .dword  $ffffff
            .dword  $880000
            .dword  $aaffee
            .dword  $cc44cc
            .dword  $00cc55
            .dword  $0000aa
            .dword  $dddd77
            .dword  $dd8855
            .dword  $664400
            .dword  $ff7777
            .dword  $333333
            .dword  $777777
            .dword  $aaff66
            .dword  $0088ff
            .dword  $bbbbbb

init_graphics_palettes

            phx
            phy

          ; Save I/O page
            ldy     $1

          ; Switch to I/O Page 1 (font and color LUTs)
            lda     #1
            sta     $1

          ; Init ptr
            stz     ptr+0
            lda     #$d0
            sta     ptr+1

            ldx     #0          ; Starting color byte.
_loop
          ; Write the next color entry
            jsr     write_bgra
            inx

          ; Advance the pointer; X will wrap around on its own

            lda     ptr
            adc     #4
            sta     ptr
            bne     _loop

            lda     ptr+1
            inc     a
            sta     ptr+1
            cmp     #$e0
            bne     _loop

          ; Restore I/O page
            sty     $1
            
            ply
            plx
            rts

write_bgra
    ; X = rrrgggbb
    ; A palette entry consists of four consecutive bytes: B, G, R, A.

            phy
            ldy     #3  ; Working backwards: A,R,G,B

          ; Write the Alpha value        
            lda     #255
            jsr     _write
            
          ; Write the RGB values
            txa
_loop       dey
            bmi     _done
            jsr     _write            
            bra     _loop
            
_done       ply
            clc
            rts
            
_write      
          ; Write the upper bits to (ptr),y
            pha
            and     #%111_00000
            sta     (ptr),y
            pla

          ; Shift in the next set of bits (blue truncated, alpha zero).
            asl     a
            asl     a
            asl     a

            rts
            
init_border
            stz     BORDER_CTRL_REG
            stz     BORDER_COLOR_R
            stz     BORDER_COLOR_G
            stz     BORDER_COLOR_B
            rts


init_font:
            lda     $1
            pha

            lda     #1
            sta     $1
            jsr     _install
            
            pla
            sta     $1

            clc
            rts
            
_install
            phx
            phy

            stz     src+0
            stz     dest+0
            lda     #$c0
            sta     src+1
            lda     #$c4
            sta     dest+1
            
            ldx     #4
            ldy     #0
_loop       
            smb     2,$1
            lda     (src),y            
            rmb     2,$1
            lsr     a           ; Jr is dropping the first pixel.
            sta     (src),y
            eor     #$ff
            sta     (dest),y
            iny
            bne     _loop
            inc     src+1
            inc     dest+1
            dex
            bne     _loop                       

            ply
            plx
            rts

long_move            
            phx
            phy

            ldy     #0
            ldx     count+1
            beq     _small

_large      lda     (src),y
            sta     (dest),y
            iny
            bne     _large
            inc     src+1
            inc     dest+1
            dex
            bne     _large
            bra     _small

_loop       lda     (src),y
            sta     (dest),y

            iny
_small      cpy     count
            bne     _loop

            ply
            plx
            rts

cls
            pha
            phx
            phy

            lda     #2
            sta     $1
            lda     #' '
            jsr     _fill

            lda     #3
            sta     $1    
            lda     color
            jsr     _fill
            
            ldx     #0
            ldy     #0
            jsr     gotoxy

            ply
            plx
            pla
            rts

_fill
            stz     ptr+0
            ldy     #$c0
            sty     ptr+1
            ldx     #$14
            ldy     #0
_loop       sta     (ptr),y
            iny
            bne     _loop
            inc     ptr+1
            dex
            bne     _loop
            rts
            
                        
gotoxy
            stx     cur_x
            sty     cur_y

    ; 80 = 64 + 16 = 0101 0000
    
            stz     ptr+1
            tya
            cpy     #60
            bcc     _ok
            ldy     #59
_ok
            asl     a           ; x2
            asl     a           ; x4
            rol     ptr+1
            adc     cur_y       ; x5
            bcc     _nc
            inc     ptr+1
_nc         asl     a           ; x10
            rol     ptr+1
            asl     a           ; x20
            rol     ptr+1
            asl     a           ; x40
            rol     ptr+1
            asl     a           ; x80
            rol     ptr+1
            sta     ptr+0

            lda     ptr+1
            adc     #$c0
            sta     ptr+1
            
          ; Save/restore the state of the i/o bit
          ; while moving the cursor.
            lda     $1
            pha
            lda     #2
            sta     $1
            jsr     cursor
            pla
            sta     $1
            rts

cursor
        ldy     cur_x

        ldx     #3      ; color memory
        stx     $1
        lda     (ptr),y
        stz     $1
        sta     VKY_TXT_CURSOR_COLR_REG

        ldx     #2      ; text memory
        stx     $1
        lda     (ptr),y
        eor     #$80
        stz     $1
        sta     VKY_TXT_CURSOR_CHAR_REG

        lda     cur_x
        sta     VKY_TXT_CURSOR_X_REG_L
        stz     VKY_TXT_CURSOR_X_REG_H

        lda     cur_y
        sta     VKY_TXT_CURSOR_Y_REG_L
        stz     VKY_TXT_CURSOR_Y_REG_H

        lda     #Vky_Cursor_Enable | Vky_Cursor_Flash_Rate0 | 8
        sta     VKY_TXT_CURSOR_CTRL_REG
        stz     VKY_TXT_START_ADD_PTR

        ldx     #2
        stx     $1

        rts


puts
putc
        pha
        phx
        phy

        ldx     $1
        phx

        ldx     #2
        stx     $1

        jsr     _putc
        ldx     cur_x
        ldy     cur_y
        jsr     gotoxy

        plx
        stx     $1

        ply
        plx
        pla
        rts

_putc

   ldx  cur_x
   ldy  cur_y
   pha
   jsr  gotoxy  ; Init line ptr; TODO: just init line ptr
   pla

        cmp     #$20
        bcc     _ctrl

        cmp     #$80
        bcs     cbm

        jmp     insert

_ctrl
        cmp #5  ; CBM white; occludes ^e->eol below
        beq cbm
        cmp     #17
        bcc     _indexed
        cmp     #27     ; esc
        bne     cbm
        jmp     esc        

_indexed
        asl     a
        tax
        jmp     (_table,x)
_table          
        .ctrl   '@', ignore
        .ctrl   'a', begin
        .ctrl   'b', left
        .ctrl   'c', ignore
        .ctrl   'd', ignore
        .ctrl   'e', end
        .ctrl   'f', right   
        .ctrl   'g', bell
        .ctrl   'h', backspace
        .ctrl   'i', tab
        .ctrl   'j', lf
        .ctrl   'k', kill
        .ctrl   'l', ff
        .ctrl   'm', cr
        .ctrl   'n', down
        .ctrl   'o', ignore
        .ctrl   'p', up

ignore  rts        

ctrl    .macro  key, function
        .word   \function   ; Key is only for documentation.
        .endm
        
cbm
      ; Slower, but I can far-jump
        ldx     #0
_loop   cmp     _table,x
        beq     _found
        inx
        inx
        inx
        cpx     #_end
        bne     _loop
        jmp     set_color   ; maybe it's a color command

_found  jmp     (_table+1,x)
        
_table
        .entry  $11, down
        .entry  $12, reverse
        .entry  $13, home
        .entry  $14, backspace
        .entry  $1d, right
        .entry  $91, lf
        .entry  $92, unreverse
        .entry  $93, cls
_end    = * - _table

entry   .macro  code, function
        .byte   \code
        .word   \function
        .endm

reverse
        ldx     #128
        stx     rev
        rts
        
unreverse
        stz     rev
        rts

lf      rts
       
cr
        stz     cur_x
_lf     
        ldy     cur_y
        iny
        cpy     #ROWS
        bne     _out
        jmp     scroll
_out
        sty     cur_y
        rts

esc
        rts     ; TODO: vt100 sequences

ff
        jmp     cls

home
        stz     cur_x
        stz     cur_y
        rts
 
left
        lda     cur_x
        beq     _out
        dec     cur_x
_out    rts

right
        lda     cur_x
        cmp     #COLS-1
        bcs     _out     
        inc     cur_x
_out    rts
        
up
        lda     cur_y
        dec     a
        bmi     _out
        sta     cur_y
_out    rts

down
        lda     cur_y
        inc     a
        cmp     #ROWS
        bne     _okay
        jmp     scroll 
_okay   sta     cur_y
        rts
       
begin
        stz     cur_x
        rts
        
end
        ldy     #COLS
_loop   dey
        beq     _done
        lda     (ptr),y
        cmp     #32
        beq     _loop
_done   sty     cur_x
        bra     right 

backspace
        jsr     left
        ldy     cur_x
        lda     #32
        sta     (ptr),y
        rts
        
bell
        rts     ; TODO: flash or support sound

tab
        lda     #32
        jsr     insert
        lda     cur_x
        and     #TABS-1
        bne     tab
        rts

insert
      ; ASCII for the rest
      ; Someone else can do PETSCII
        ldy     cur_x
        ora     rev
        sta     (ptr),y
        inc     $1
        lda     color
        sta     (ptr),y
        dec     $1
        iny
        cpy     #COLS
        beq     cr
        sty     cur_x
_done   rts

kill
        ldy     cur_x
        lda     #32
_loop   sta     (ptr),y
        iny
        cpy     #COLS
        bne     _loop
        rts

scroll
        lda     #$c0
        sta     src+1
        sta     dest+1

        lda     #80
        sta     src
        stz     dest

        lda     #<COLS*(ROWS)
        sta     count
        lda     #>COLS*(ROWS)
        sta     count+1

        jmp     long_move

set_color
        ldx     #0
_loop   cmp     _table,x
        beq     _found
        inx
        cpx     #_end
        bne     _loop
        rts
_found  
        txa
        asl     a
        asl     a
        asl     a
        asl     a
        ora     #6
        sta     color
        rts
_table  
        .byte   $90 ; color.black        
        .byte   $05 ; color.white
        .byte   $1c ; color.red
        .byte   $9f ; color.cyan
        .byte   $9c ; color.violet
        .byte   $1e ; color.green
        .byte   $1f ; color.blue
        .byte   $9e ; color.yellow
        .byte   $81 ; color.orange
        .byte   $95 ; color.brown
        .byte   $96 ; color.lred
        .byte   $97 ; color.grey1
        .byte   $98 ; color.grey2
        .byte   $99 ; color.lgreen
        .byte   $9a ; color.blue
        .byte   $9b ; color.grey3
_end    = * - _table                   

            .send
            .endn
            .endn
