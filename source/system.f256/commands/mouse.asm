; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		mouse.asm
;		Purpose:	Mouse Cammand
;		Created:	28th January 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

MouseStatus:	;; [mouse]
        ldx     #0
_MouseCommandLoop:
        phx                                 ; save slot.
        jsr     EvaluateExpressionAt0       ; evaluate a reference.
        lda     NSStatus                    ; check it's a reference.
        cmp     #NSBIsReference 
        bne     _MouseNotRef
        .cget                               ; skip following comma if any
        cmp     #KWD_COMMA
        bne     _MouseNoSkipComma
        iny
_MouseNoSkipComma:
        plx                                 ; restore X
        phy                                 ; save Y
        ;
        lda     NSMantissa0                 ; copy address to zTemp0
        sta     zTemp0
        lda     NSMantissa1
        sta     zTemp0+1
        ;
        ldy     #4                          ; set exponent, m3, m2 , m1 , m0
        lda     #0
        sta     (zTemp0),y                  ; exponent
        dey
        sta     (zTemp0),y                  ; m3
        dey
        sta     (zTemp0),y                  ; m2 
        dey
        lda     MouseDeltaX,x
        sta     (zTemp0)                    ; m0
        lda     MouseDeltaX+1,x             
        sta     (zTemp0),y                  ; m1
        bpl     _MouseDataPos               ; signed 16 bit value, so fix up if -ve.

        sec                                 ; negate the mantissa 2 bytes
        lda     #0
        sbc     (zTemp0)
        sta     (zTemp0)
        lda     #0
        sbc     (zTemp0),y
        sta     (zTemp0),y
        ;
        ldy     #3
        lda     (zTemp0),y                  ; set upper bit of mantissa
        ora     #$80
        sta     (zTemp0),y

_MouseDataPos:
        ply                                 ; restore Y.
        stz     MouseDeltaX,x               ; clear entry in current table
        stz     MouseDeltaX+1,x
        inx                                 ; next entry
        inx
        cpx     #6*2                        ; done 6 reads to variables.
        bne     _MouseCommandLoop
        rts

_MouseNotRef:
        .error_argument
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
