			.cpu    "65c02"

		* = $D0
		.dsection dp
		* = $8000
		.dsection code
		* = $0800
		.dsection data

		.include "api.asm"
		
			.section    code
;			ldx     #$FF
;			txs
			jsr     initputc
			lda 	#$00
			jsr 	puth
			jsr 	cmd
h1:			bra 	h1

			.send   code

			.section    dp
print_func   .word       ?
			.send

;
;       DOS Cmd_Read handler...
;
			.section    code
cmd
			lda     #<printfn
			sta     print_func+0
			lda     #>printfn
			sta     print_func+1

            lda     #<event
            sta     kernel.args.events+0
            lda     #>event
            sta     kernel.args.events+1

            lda 	#$55
			jsr  	puth

			lda     #0  ; Max read size
			ldx     #print_func
			jmp     read_file
			
printfn
			jmp     putc

            .section    data
buf         .fill       256     ; Used to fetch data from the kernel.
            .send

            .section    data
drive       .byte       ?                       ; Current selected (logical) drive #
event       .dstruct    kernel.event.event_t    ; Event data copied from the kernel
            .send

            .section    dp
eol         .byte       ?
drives      .byte       ?
tmp         .word       ?
            .send            

			.send
			
