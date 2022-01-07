!source "../../steckschwein-code/steckos/kernel/kernel_jumptable.inc"
!source "../../steckschwein-code/steckos/asminc/keyboard.inc"

; --- Kernel routines ---
kernal_reset          ; reset
   +dbg
   rts
kernal_delay_1ms      ; delay 1 ms
   +dbg
   phx
   phy
   ldx #$f0
-- ldy #$f0
-  dey
   bne -
   dex
   bne --
   ply
   phx
   rts

kernal_setlfs         ;= $ffba ; set file parameters
kernal_setnam         ;= $ffbd ; set file name
kernal_open           ;= $ffc0 ; open a file
kernal_close          ;= kernal_close ;$ffc3 ; close a file
   +dbg
   rts

kernal_chkin          ;= $ffc6 ; define file as default input
kernal_clrchn         ;= $ffcc ; close default input/output files
   +dbg
   rts

kernal_readchar       ; = krn_getkey; read byte from default input into a
;use streams_print_output instead of kernal_printchar
;($ffd2 only allowed for input/output in screen.asm and text.asm)
;kernal_printchar      = krn_chrout; write char in a
kernal_load           ;load file
kernal_save           ;save file
   +dbg
   rts

kernal_readtime:
;   +dbg
	lda rtc_systime_t+0
	ldx rtc_systime_t+1
	ldy rtc_systime_t+2
	rts

kernal_getchar       ; get a character
   jsr krn_getkey
   cmp #$F1
   bne +
   lda #133 ; charcode F1 PETSCII
+  rts

