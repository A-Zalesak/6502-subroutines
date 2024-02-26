; Spiral by Andrew Zalesak
; Finished Feb 26, 2024

; addresses
  define coord_LSB $00
  define coord_MSB $01
  define step_size $02
  define hitting_stack_flag $03
  define current_color $04
  define color_pointer $05

; constants
  define initial_step_size $01
  define max_step_size $20
  define center_LSB $0f
  define center_MSB $04

  define magenta $04
  define darkred $02
  define salmon $0a
  define orange $08
  define yellow $07
  define yellowgreen $0d
  define green $05
  define seafoam $03
  define blue $0e
  define darkblue $06

; main
  JSR save_colors_to_memory
  JSR init_color_pointer
  JSR color_loop
  BRK

save_colors_to_memory:
  LDX #$01
  LDA #magenta
  STA color_pointer, X
  INX
  LDA #darkred
  STA color_pointer, X
  INX
  LDA #salmon
  STA color_pointer, X
  INX
  LDA #orange
  STA color_pointer, X
  INX
  LDA #yellow
  STA color_pointer, X
  INX
  LDA #yellowgreen
  STA color_pointer, X
  INX
  LDA #green
  STA color_pointer, X
  INX
  LDA #seafoam
  STA color_pointer, X
  INX
  LDA #blue
  STA color_pointer, X
  INX
  LDA #darkblue
  STA color_pointer, X
  INX

init_color_pointer: 
  LDX #$01
  STX color_pointer

color_loop:
  JSR reset_coord_step_and_flag
  LDX color_pointer
  LDA color_pointer, X
  STA current_color
  LDX #$00
  STA ($00,X) ; paint central dot
  JSR big_loop
  
  LDX color_pointer
  INX
  STX color_pointer
  CPX #$0a
  BNE color_loop
  LDX #$01
  STX color_pointer
  BVC color_loop
  RTS ; never end!

reset_coord_step_and_flag:
  LDA #center_MSB
  STA coord_MSB
  LDA #center_LSB
  STA coord_LSB
  LDY #initial_step_size
  STY step_size
  LDX #$00 ; reset flag
  STX hitting_stack_flag
  RTS

big_loop_done:
  RTS
big_loop:
  LDY #$00
  JSR small_right_loop
  LDX step_size
  INX
  CPX #max_step_size
  BEQ big_loop_done
  STX step_size

  LDY #$00
  JSR small_up_loop
  LDX step_size
  INX
  CPX #max_step_size
  BEQ big_loop_done
  STX step_size

  LDY #$00
  JSR small_left_loop
  LDX hitting_stack_flag
  CPX #$01
  BEQ big_loop_done
  LDX step_size
  INX
  CPX #max_step_size
  BEQ big_loop_done
  STX step_size

  LDY #$00
  JSR small_down_loop
  LDX step_size
  INX
  STX step_size
  CPX #max_step_size
  BNE big_loop
  RTS

check_hitting_stack:
  TAY ; temp storage of LSB
  LDX coord_MSB
  CPX #01
  BNE done
  STX hitting_stack_flag
  BVC done

small_right_loop:
  JSR go_right
  LDA current_color
  LDX #$00
  STA ($00,X)
  INY
  CPY step_size
  BNE small_right_loop
  RTS

small_left_loop:
  JSR go_left
  CMP #$ff
  BEQ check_hitting_stack ; finish without write
  LDX #$00
  LDA current_color
  STA ($00,X)
  INY
  CPY step_size
  BNE small_left_loop
  RTS

small_up_loop:
  JSR go_up
  LDA current_color
  LDX #$00
  STA ($00,X)
  INY
  CPY step_size
  BNE small_up_loop
  RTS

small_down_loop:
  JSR go_down
  LDA current_color
  LDX #$00
  STA ($00,X)
  INY
  CPY step_size
  BNE small_down_loop
  RTS

done:
  RTS
go_right:
  CLC
  LDA coord_LSB
  ADC #$01
  STA coord_LSB
  BCC done
  LDX coord_MSB
  INX
  STX coord_MSB
  RTS
go_left:
  LDA coord_LSB
  SEC
  SBC #$01
  STA coord_LSB
  BCS done
  LDX coord_MSB
  DEX
  STX coord_MSB
  RTS
go_up:
  LDA coord_LSB
  SEC
  SBC #$20
  STA coord_LSB
  BCS done
  LDX coord_MSB
  DEX
  STX coord_MSB
  RTS
go_down:
  CLC
  LDA coord_LSB
  ADC #$20
  STA coord_LSB
  BCC done
  LDX coord_MSB
  INX
  STX coord_MSB
  RTS
