; screen update routines
; TRACE_WINDOW = 1

.num_rows !byte 0
.current_window !byte 0
.cursor_position !byte 0,0

clear_num_rows
    lda #0
    sta .num_rows
    rts

increase_num_rows
    inc .num_rows
    rts

printchar
    jsr kernel_printchar
    lda zp_screencolumn
    bne .printchar_exit
    inc .num_rows
    lda .num_rows
    cmp #12 ; zp_screencolumn can be 1-2 rows on the screen, so assume the worst
    bcc .printchar_exit
    jsr clear_num_rows
    ldx #0
-   lda .more_text,x
    beq .printchar_pressanykey
    jsr kernel_printchar
    inx
    bne -
.printchar_pressanykey
-   jsr kernel_getchar
    cmp #$0d
    bne -
    ldx #0
-   lda .more_text,x
    beq .printchar_exit
    lda #20 ; delete
    jsr kernel_printchar
    inx
    bne -
.printchar_exit
+   rts
.more_text !pet "[More]",0

set_cursor
    ; input: y=column (0-39)
    ;        x=row (0-24)
    clc
    jmp kernel_plot

save_cursor
    sec
    jsr kernel_plot
    stx .cursor_position
    sty .cursor_position + 1
    rts

restore_cursor
    ldx .cursor_position
    ldy .cursor_position + 1
    jmp set_cursor


!ifdef Z3 {
z_ins_show_status
    jmp draw_status_line

draw_status_line
    ; save z_operand* (will be destroyed by print_num)
    lda z_operand_value_low_arr
    pha
    lda z_operand_value_high_arr
    pha
    lda z_operand_value_low_arr + 1
    pha
    lda z_operand_value_high_arr + 1
    pha
    jsr save_cursor
    ldx #0
    ldy #0
    jsr set_cursor
    lda #18 ; reverse on
    jsr kernel_printchar
    ;
    ; Room name
    ; 
    ; name of the object whose number is in the first global variable
    ldx #16
    jsr z_get_variable_value
    jsr print_obj
    ;jsr print_addr
    ;
    ; fill the rest of the line with spaces
    ;
-   lda zp_screencolumn
    cmp #40
    beq +
    lda #$20
    jsr kernel_printchar
    jmp -
    ;
    ; score or time game?
    ;
+   lda story_start + header_flags_1
    and #$40
    bne .timegame
    ; score game
    ldx #0
    ldy #20
    jsr set_cursor
    ldy #0
-   lda .score_str,y
    beq +
    jsr kernel_printchar
    iny
    bne -
+   ldx #17
    jsr z_get_variable_value
    stx z_operand_value_low_arr
    sta z_operand_value_high_arr
    jsr z_ins_print_num
    ldx #0
    ldy #30
    jsr set_cursor
    ldy #0
-   lda .moves_str,y
    beq +
    jsr kernel_printchar
    iny
    bne -
+   ldx #18
    jsr z_get_variable_value
    stx z_operand_value_low_arr
    sta z_operand_value_high_arr
    jsr z_ins_print_num
    jmp .statusline_done
.timegame
    ; time game
    ldx #0
    ldy #20
    jsr set_cursor
    ldy #0
-   lda .time_str,y
    beq +
    jsr kernel_printchar
    iny
    bne -
+   ldx #17 ; hour
    jsr z_get_variable_value
    stx z_operand_value_low_arr
    sta z_operand_value_high_arr
    jsr z_ins_print_num
    lda #58 ; :
    jsr kernel_printchar
    ldx #18 ; hour
    jsr z_get_variable_value
    stx z_operand_value_low_arr
    sta z_operand_value_high_arr
    jsr z_ins_print_num
.statusline_done
    lda #146 ; reverse off
    jsr kernel_printchar
    pla
    sta z_operand_value_high_arr + 1
    pla
    sta z_operand_value_low_arr + 1
    pla
    sta z_operand_value_high_arr
    pla
    sta z_operand_value_low_arr
    jmp restore_cursor
.score_str !pet "Score ",0
.moves_str !pet "Moves ",0
.time_str !pet "Time ",0
}

z_ins_split_window
    ; split_window lines
!ifdef TRACE_WINDOW {
    jsr print_following_string
    !pet "split_window: ",0
    ldx z_operand_value_low_arr
    jsr printx
    jsr newline
}
    ; TODO: find out how to protect top lines from scrolling
    rts

z_ins_set_window
    ;  set_window window
!ifdef TRACE_WINDOW {
    jsr print_following_string
    !pet "set_window: ",0
    ldx z_operand_value_low_arr
    jsr printx
    jsr newline
}
    lda z_operand_value_low_arr
    sta .current_window
    bne +
    ; this is the main text screen, restore cursor position
    jmp restore_cursor
+   ; this is the status line window
    ; store cursor position so it can be restored later
    ; when set_window 0 is called
    jmp save_cursor

!ifdef Z4PLUS {
z_ins_set_text_style
!ifdef TRACE_WINDOW {
    jsr print_following_string
    !pet "set_text_style: ",0
    ldx z_operand_value_low_arr
    jsr printx
    jsr newline
}
    lda z_operand_value_low_arr
    bne .t0
    ; roman
    lda #146 ; reverse off
    jmp kernel_printchar
.t0 cmp #1
    bne .t1
    lda #18 ; reverse on
    jmp kernel_printchar
.t1 rts

z_ins_set_cursor
    ; set_cursor line column
!ifdef TRACE_WINDOW {
    jsr print_following_string
    !pet "set_cursor: ",0
    ldx z_operand_value_low_arr
    jsr printx
    jsr space
    ldx z_operand_value_low_arr + 1
    jsr printx
    jsr newline
}
    ldx z_operand_value_low_arr
    ldy z_operand_value_low_arr + 1
    dex
    dey
    jmp set_cursor
}
