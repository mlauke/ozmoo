
s_screen_width !byte 0
s_screen_height !byte 0
s_screen_width_plus_one !byte 0
;s_screen_width_minus_one !byte 0
;s_screen_height_minus_one !byte 0
s_screen_size !byte <(SCREEN_WIDTH*SCREEN_HEIGHT), >(SCREEN_WIDTH*SCREEN_HEIGHT)

; colours		!byte 144,5,28,159,156,30,31,158,129,149,150,151,152,153,154,155
zcolours	!byte $ff,$ff ; current/default colour
			!byte COL2,COL3,COL4,COL5  ; black, red, green, yellow
			!byte COL6,COL7,COL8,COL9  ; blue, magenta, cyan, white

current_cursor_colour !byte CURSORCOL
cursor_character !byte CURSORCHAR

s_plot
	; y=column (0-(SCREEN_WIDTH-1))
	; x=row (0- (SCREEN_HEIGHT-1))
	bcc .set_cursor_pos
	; get_cursor
	ldx zp_screenrow
	ldy zp_screencolumn
	rts
.set_cursor_pos
	stx zp_screenrow
	sty zp_screencolumn
	jmp krn_textui_update_crs_ptr

s_erase_line
	; registers: a,x,y
;	+dbg
	stz zp_screencolumn
s_erase_line_from_cursor
	lda #SCREEN_WIDTH
	sec
	sbc zp_screencolumn
	tax
	stz zp_screencolumn
-	lda #' '
	jsr s_printchar
	dex
	bne -
	cli
	rts

!ifndef NODARKMODE {
toggle_darkmode

!ifdef Z5PLUS {
	; TODO
} else { ; This is z3 or z4

!ifdef USE_INPUTCOL {

}

}
; update colour memory with new colours
!ifndef Z4PLUS {
}
!ifndef Z5PLUS {
}

} ; ifndef NODARKMODE

testscreen
	rts

s_init
	; set up screen_width and screen_width_minus_one
	lda #SCREEN_WIDTH
	sta s_screen_width
	sta s_screen_width_plus_one
	inc s_screen_width_plus_one

	; set up screen_height and screen_width_minus_one
	lda #SCREEN_HEIGHT
	sta s_screen_height
	;sta s_screen_height_minus_one
	;dec s_screen_height_minus_one

	rts


SETBORDERMACRO_DEFINED = 1
!macro SetBorderColour {
	;jmp vdp_bgcolor
}
!macro SetBackgroundColour {
	;!byte $db
	;jsr vdp_bgcolor
}

s_set_text_colour
	sta s_colour
	rts

s_delete_cursor
	lda #' '
	jmp krn_putchar

; currently ozmoo uses petscii internally and output spread across the entire code
; ... to achieve DRY we map back to steckschwein output :/
; TODO ozmoo should use zscii code internally and the target plattform should map accordingly. get rid of the acme ifdef cascades
s_printchar:
	; input: A = byte to write (PETASCII)
	; output: -
	; used registers: -
	; https://sites.google.com/site/h2obsession/CBM/petscii
	cmp #KEY_CR
	bne +
	lda #KEY_LF
	bra .out
+	cmp #147
	bne +
	jmp krn_textui_clrscr_ptr
+	cmp #$41		; lower case petscii
	bcc +
	cmp #$5a+1
	bcs +
	ora #$20
	bra .out
+  cmp #$c1
	bcc .out
	cmp #$da+1
	bcs .out
	and #$7f
.out
	jmp krn_chrout
.ignore:
	rts

!ifdef Z5PLUS {

z_ins_set_colour
	; set_colour foreground background [window]
	; (window is not used in Ozmoo)
}
