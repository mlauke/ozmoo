
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
darkmode	!byte 0

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
	Transparent	   	=$00
	Black	      	=$01	;0	0	0		"black"
	Medium_Green	=$02 ;35	203	50		"23
	Light_Green	   	=$03	;96	221	108
	Dark_Blue      	=$04 ;84	78	255		"544EFF"
	Light_Blue     	=$05 ;125 112 255	"7D70FF"
	Dark_Red       	=$06 ;210 84	66		"D25442"
	Cyan           	=$07 ;69 232	255		(Aqua Blue)
	Medium_Red	   	=$08 ;250 89	72 		"FA5948"
	Light_Red		=$09 ;255 124 108	"FF7C6C"
	Dark_Yellow    	=$0a ;211 198 60		"D3C63C"
	Light_Yellow   	=$0b ;229 210 109	"E5D26D"
	Dark_Green     	=$0c ;35 178	44
	Magenta		   	=$0d ;200 90	198 	"C85AC6" (Purple)
	Gray           	=$0e ;204 204 204	"CCCCCC"
	White          	=$0f ;255 255 255	"white"

	v_reg7   = $80+7
	a_vdp	 = $0220
	a_vram	 = a_vdp
	a_vreg	 = a_vdp+1
	a_vregpal = a_vdp+2
	a_vregi	= a_vdp+3

	php
	sei
	lda #Light_Red<<4|Gray
	sta a_vreg
; Toggle darkmode
	lda darkmode
	eor #1
	sta darkmode
	
	lda #v_reg7
	sta a_vreg
	plp
	rts

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
	rts

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
+ 	cmp #$F5	; 
	bne +
	lda #$7c	; pipe-sign
+	cmp #$12 	; reverse on
	beq .ignore
	cmp #$92	; reverse off
	beq .ignore	
+	cmp #147
	bne +
	jmp krn_textui_clrscr_ptr
+	cmp #$41		; lower case petscii
	bcc .out
	cmp #$5a+1
	bcs +
.space
	ora #$20
	bra .out
+  	cmp #$c1
	bcc .out
	cmp #$da+1
	bcs .dbg
	and #$7f
.out
	jmp krn_chrout
.dbg
	+dbg
	cli
.ignore:
	rts

!ifdef Z5PLUS {
z_ins_set_colour
	; set_colour foreground background [window]
	; (window is not used in Ozmoo)
}
