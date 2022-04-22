; Steckschwein constants
;
!macro dbg {
	sei
	!byte $db
}
; TEXTUI
rtc_systime_t = $0300
crs_x	= $028c
crs_y	= $028d


basic_reset           = $fff8 ; retvec
SCREEN_HEIGHT         = 24
SCREEN_WIDTH          = 80
SCREEN_ADDRESS        = $d000
COLOUR_ADDRESS        = $d800
;COLOUR_ADDRESS_DIFF   	= COLOUR_ADDRESS - SCREEN_ADDRESS
CURRENT_DEVICE        	= $ba
;keyboard_buff_len     	= $c6
;keyboard_buff         	= $800

;use_reu				  = $9b
window_start_row	  = $9c; 4 bytes
;ti_variable           = $a0; 3 bytes
num_rows 			  = $a3 ; !byte 0


; Screen kernal stuff. Must be kept together or update s_init in screenkernal.
s_ignore_next_linebreak = $b0 ; 3 bytes
s_reverse 			  = $b3 ; !byte 0

zp_temp               = $fb ; 5 bytes
savefile_zp_pointer   = $c1 ; 2 bytes
first_banked_memory_page = $e4
;reu_filled            = $0255 ; 4 bytes
;vmap_buffer_start     = $0334
;vmap_buffer_end       = $0400 ; Last byte + 1. Should not be more than vmap_buffer_start + 512

; --- ZERO PAGE --
; BASIC not much used, so many positions free to use
; memory bank control
zero_datadirection    = $00
zero_processorports   = $01
; available zero page variables (pseudo registers)
z_opcode              = $02
mempointer            = $03 ; 2 bytes
mem_temp              = $05 ; 2 bytes
z_extended_opcode	  = $07

mempointer_y          = $08 ; 1 byte
z_opcode_number       = $09
zp_pc_h               = $0a
zp_pc_l               = $0b
z_opcode_opcount      = $0c ; 0 = 0OP, 1=1OP, 2=2OP, 3=VAR
z_operand_count		  = $0d
zword				  = $0e ; 6 bytes

zp_mempos             = $14 ; 2 bytes

z_operand_value_high_arr = $16 ; !byte 0, 0, 0, 0, 0, 0, 0, 0
z_operand_value_low_arr = $1e ;  !byte 0, 0, 0, 0, 0, 0, 0, 0

;
; NOTE: This entire block of variables, except last byte of z_pc_mempointer
; and z_pc_mempointer_is_unsafe is included in the save/restore files
; and _have_ to be stored in a contiguous block of zero page addresses
;
	z_local_vars_ptr      = $26 ; 2 bytes
	z_local_var_count	  = $28
	stack_pushed_bytes	  = $29 ; !byte 0, 0
	stack_ptr             = $2b ; 2 bytes
	stack_top_value 	  = $2d ; 2 bytes !byte 0, 0
	stack_has_top_value   = $2f ; !byte 0
	z_pc				  = $30 ; 3 bytes (last byte shared with z_pc_mempointer)
	z_pc_mempointer		  = $32 ; 2 bytes (first byte shared with z_pc)
	zp_save_start = z_local_vars_ptr
	zp_bytes_to_save = z_pc + 3 - z_local_vars_ptr
;
; End of contiguous zero page block
;
;
vmap_max_entries	  	= $34

zchar_triplet_cnt	  	= $35
packed_text			  	= $36 ; 2 bytes
alphabet_offset		= $38
escape_char			  	= $39
escape_char_counter	= $3a
abbreviation_command	= $40

parse_array				= $41 ; 2 bytes
string_array         = $43 ; 2 bytes

z_address			  	= $45 ; 3 bytes
z_address_temp		  	= $48

object_tree_ptr		= $49 ; 2 bytes
object_num			  	= $4b ; 2 bytes
object_temp			  	= $4d ; 2 bytes

vmap_used_entries	  	= $4f

z_low_global_vars_ptr	= $50 ; 2 bytes
z_high_global_vars_ptr	= $52 ; 2 bytes
z_trace_index		  		= $54
z_exe_mode	  		  		= $55

stack_tmp			  		= $56; ! 5 bytes
default_properties_ptr 	= $5b ; 2 bytes
zchars				  		= $5d ; 3 bytes

vmap_quick_index_match	= $60
vmap_next_quick_index 	= $61
vmap_quick_index	  		= $62 ; Must follow vmap_next_quick_index!
vmap_quick_index_length = 6 ; Says how many bytes vmap_quick_index_uses

z_temp				  		= $68 ; 12 bytes

s_colour 			  		= $74 ; !byte 1 ; white as default

vmem_temp			  		= $75 ; 2 bytes
; alphabet_table		  	= $77 ; 2 bytes

current_window		  = $79 ; !byte 0

is_buffered_window	  = $7a;  !byte 1


s_stored_x			  = $7b ; !byte 0
s_stored_y			  = $7c ; !byte 0
s_current_screenpos_row = $7d ; !byte $ff

max_chars_on_line	  = $7e; !byte 0
buffer_index		  = $7f ; !byte 0
last_break_char_buffer_pos = $bf ; !byte 0

zp_cursorswitch       = $80
;zp_screenline         = $81 ; 2 bytes current line (pointer to screen memory)

zp_screencolumn       = crs_x; 1 byte current cursor column
zp_screenrow          = crs_y; 1 byte current cursor row

;zp_colourline         = $87 ; 2 bytes current line (pointer to colour memory)
cursor_row			  = $89 ; 2 bytes
cursor_column		  = $8b ; 2 bytes

print_buffer		  	 = $e000 ; SCREEN_WIDTH + 1 bytes
print_buffer2         = print_buffer + SCREEN_WIDTH + 1; SCREEN_WIDTH + 1 bytes

memory_buffer         =	print_buffer2 + SCREEN_WIDTH + 1;
memory_buffer_length  = 89

charset_switchable 	 = memory_buffer+memory_buffer_length

; --- I/O registers ---
reg_backgroundcolour  = charset_switchable+1
;reg_screen_char_mode  =
;reg_bordercolour      = reg_screen_char_mode+1
