.define PPUCTRL $2000
.define PPUMASK $2001
.define PPUSTATUS $2002
.define OAMADDR $2003
.define OAMDATA $2004
.define PPUSCROLL $2005
.define PPUADDR $2006
.define PPUDATA $2007

.define PALETTE_BG $3F00
.define PALETTE_SPRITE $3F10

.define COLOR_PINK $24
.define COLOR_SIMIL_RED $16
.define COLOR_ORANGE $27
.define COLOR_GREEN $18

.define p1_lf_x $0303
.define p1_lf_att $0302
.define p1_lf_spr $0301
.define p1_lf_y $0300

.define p1_rt_x $0307
.define p1_rt_att $0306
.define p1_rt_spr $0305
.define p1_rt_y $0304

.define p2_lf_x $030B
.define p2_lf_att $030A
.define p2_lf_spr $0309
.define p2_lf_y $0308

.define p2_rt_x $030F
.define p2_rt_att $030E
.define p2_rt_spr $030D
.define p2_rt_y $030C

.define DMA $4014

.define my_oma $0300

.define player_1_input_map $01
.define player_1_sprite_frame $02
.define player_1_input $41

.define player_2_input_map $11
.define player_2_sprite_frame $12
.define player_2_input $51

.define old_a_data $FF
.define old_x_data $FE
.define old_y_data $FD 

.define frame_passed $F0
.define frame_counter $F1
.define passed_one_second $F2
.define sprite_frame $F3
.define sprite_updated $F4

.define JOYPAD1 $4016
.define JOYPAD2 $4017
.define DEBUG_ADDRESS $0621

.db "NES", $1A, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
;INIZIO con il registro 8000
.org $8000

;;DEFINE Constant Values
_palettes:
    .db $29, $10, $20, $3F
    .db $28, $19, $16, $3F
    .db $27, $18, $16, $22
    .db $3F, $16, $19, $28
    .db $29, $27, $3C, $30
    .db $28, $19, $16, $3F
    .db $27, $18, $16, $22
    .db $3F, $16, $19, $28

separation_between_left_and_right:
    .db $04

;DX, SX, DW, UP
; _player_lt_default_direction:
;     .db, $1c, $04, $14, $28
; _player_rt_default_direction:
;     .db, $1e, $06, $16, $2a


_player_lt_facing_left_sprite:
    .db $04, $08, $0c
_player_rt_facing_left_sprite:
    .db $06, $0a, $0e

_player_lt_facing_right_sprite:
    .db $1c, $20, $24
_player_rt_facing_right_sprite:
    .db $1e, $22, $26

_player_lt_facing_up_sprite:
    .db $28, $2c, $30
_player_rt_facing_up_sprite:
    .db $2a, $2e, $32

_player_lt_facing_down_sprite:
    .db $10, $14, $18
_player_rt_facing_down_sprite:
    .db $12, $16, $1a

reset:
    SEI   
    CLD

start:
    
    LDX #$FF
    TXS

    ;SPENGO NMI
    LDX #%00000000
    STX PPUCTRL

    
    STX PPUMASK           ;SETTO 0 NELLA PPU COSI NON DISEGNA NULLA PER EVITARE GLITCH GRAFICI AD INIZIO GIOCO

    wait_for_vblank:
        LDA PPUSTATUS
        AND #%10000000
        BEQ wait_for_vblank

    init_palette:

        ;INIZIALIZZO PALETTE PER BACKGROUND
        LDA #>PALETTE_BG
        STA PPUADDR
        LDA #<PALETTE_BG
        STA PPUADDR

        LDX #0
        load_palette_01:
            LDA _palettes, X
            STA PPUDATA
            INX
            TXA
            CMP #$20
            BNE load_palette_01

    LDX #%00011000
    STX PPUMASK 

    LDA #0
    STA p1_lf_att
    STA p1_rt_att

    LDA #1
    STA p2_lf_att
    STA p2_rt_att
    
;Build a sprite
    LDA #$01
    STA p1_lf_spr
    STA p2_lf_spr

    LDA #$03
    STA p1_rt_spr
    STA p2_rt_spr

;Init player 1
    LDA #$40
    STA p1_lf_x
    STA p1_lf_y

    STA p1_rt_y
    LDA #$48
    STA p1_rt_x

;Init Player 2    
    LDA #$A0
    STA p2_lf_x
    STA p2_lf_y

    STA p2_rt_y
    LDA #$A8
    STA p2_rt_x





    LDA #%10101000
    STA PPUCTRL

    LDY #0
;

    game_loop:

        LDA frame_passed
        BEQ game_loop

        LDA #0
        STA frame_passed

        JSR readjoy_1
        JSR readjoy_2
        P1:
            LDA player_1_input
            CMP #$00
            BEQ p1_no_input
            
            STA player_1_input_map
            
            LDA player_1_input_map
            AND #%00000011

            CMP #$01
            BEQ j_p1_right
            CMP #$02
            BEQ j_p1_left

            p1_lr_input:
            LDA player_1_input_map
            AND #%00001100

            CMP #$04
            BEQ j_p1_down
            CMP #$08
            BEQ j_p1_up
            JMP p1_end_input

            p1_no_input:
                LDX #0
                INX
                STX p1_lf_spr, 
                LDX #2
                INX
                STX p1_rt_spr
                JMP p1_end_input

            j_p1_right:
                JMP p1_right
            j_p1_left:
                JMP p1_left
            j_p1_up:
            JMP p1_up
            j_p1_down:
                JMP p1_down

            p1_right:
                INC p1_lf_x
                INC p1_rt_x

                LDY sprite_frame
                LDX _player_lt_facing_right_sprite, Y
                INX
                STX p1_lf_spr
                LDX _player_rt_facing_right_sprite, Y
                INX
                STX p1_rt_spr

                JMP p1_lr_input
            
            p1_left:
                DEC p1_lf_x
                DEC p1_rt_x

                LDY sprite_frame
                LDX _player_lt_facing_left_sprite, Y
                INX
                STX p1_lf_spr
                LDX _player_rt_facing_left_sprite, Y
                INX
                STX p1_rt_spr


                JMP p1_lr_input

            p1_down:
                INC p1_lf_y
                INC p1_rt_y

                LDY sprite_frame
                LDX _player_lt_facing_down_sprite, Y
                INX
                STX p1_lf_spr
                LDX _player_rt_facing_down_sprite, Y
                INX
                STX p1_rt_spr


                JMP p1_end_input

            p1_up:
                DEC p1_lf_y
                DEC p1_rt_y
                
                LDY sprite_frame
                LDX _player_lt_facing_up_sprite, Y
                INX
                STX p1_lf_spr
                LDX _player_rt_facing_up_sprite, Y
                INX
                STX p1_rt_spr

                JMP p1_end_input  

        p1_end_input:
             
        
        P2:
            LDA player_2_input
            CMP #$00
            BEQ p2_no_input
            
            STA player_2_input_map
            
            LDA player_2_input_map
            AND #%00000011

            CMP #$01
            BEQ j_p2_right
            CMP #$02
            BEQ j_p2_left

            p2_lr_input:
            LDA player_2_input_map
            AND #%00001100

            CMP #$04
            BEQ j_p2_down
            CMP #$08
            BEQ j_p2_up
            JMP p2_end_input

            p2_no_input:
                LDX #0
                INX
                STX p2_lf_spr, 
                LDX #2
                INX
                STX p2_rt_spr
                JMP p2_end_input

            j_p2_right:
                JMP p2_right
            j_p2_left:
                JMP p2_left
            j_p2_up:
                JMP p2_up
            j_p2_down:
                JMP p2_down

            p2_right:
                INC p2_lf_x
                INC p2_rt_x

                LDY sprite_frame
                LDX _player_lt_facing_right_sprite, Y
                INX
                STX p2_lf_spr
                LDX _player_rt_facing_right_sprite, Y
                INX
                STX p2_rt_spr

                JMP p2_lr_input
            
            p2_left:
                DEC p2_lf_x
                DEC p2_rt_x

                LDY sprite_frame
                LDX _player_lt_facing_left_sprite, Y
                INX
                STX p2_lf_spr
                LDX _player_rt_facing_left_sprite, Y
                INX
                STX p2_rt_spr


                JMP p2_lr_input

            p2_down:
                INC p2_lf_y
                INC p2_rt_y

                LDY sprite_frame
                LDX _player_lt_facing_down_sprite, Y
                INX
                STX p2_lf_spr
                LDX _player_rt_facing_down_sprite, Y
                INX
                STX p2_rt_spr


                JMP p2_end_input

            p2_up:
                DEC p2_lf_y
                DEC p2_rt_y
                
                LDY sprite_frame
                LDX _player_lt_facing_up_sprite, Y
                INX
                STX p2_lf_spr
                LDX _player_rt_facing_up_sprite, Y
                INX
                STX p2_rt_spr

                JMP p2_end_input  

        p2_end_input:


        LDA frame_counter
        AND #%00001111
        EOR #%00000100
        BEQ update_sprite_frame
        JMP end_update_sprite_frame
        
        update_sprite_frame:
        INC sprite_frame
        LDA sprite_frame
        EOR #$03
        BEQ reset_sprite_frame
        JMP end_update_sprite_frame

        reset_sprite_frame:
        LDA #0
        STA sprite_frame
        end_update_sprite_frame:
        JMP game_loop


; At the same time that we strobe bit 0, we initialize the ring counter
; so we're hitting two birds with one stone here


readjoy_1:
        LDA #$01
        STA JOYPAD1
        LDA #$00
        STA JOYPAD1
        LDX #$08
    ReadController1Loop:
        LDA JOYPAD1
        LSR A
        ROL player_1_input
        DEX
        BNE ReadController1Loop
        RTS

readjoy_2:
        LDA #$01
        STA JOYPAD2
        LDA #$00
        STA JOYPAD2
        LDX #$08
    ReadController2Loop:
        LDA JOYPAD2
        LSR A
        ROL player_2_input
        DEX
        BNE ReadController2Loop
        RTS
;
nmi:
        STA old_a_data
        STX old_x_data
        STY old_y_data

        INC frame_passed
        INC frame_counter

        LDA #$03
        STA DMA

        LDA #%00000000
        STA PPUSCROLL
        LDA #%00000000
        STA PPUSCROLL

        LDA old_a_data
        LDX old_x_data
        LDY old_y_data
        
        RTI

irq:    
    RTI

increment_x_y_time:
    STY old_y_data
    INX
    DEY
    BNE increment_x_y_time
    LDY old_y_data
    RTS

.goto $FFFA
.dw nmi ;NMI
.dw reset ;RESET
.dw irq ;IRQ/BRQ

.incbin "bm_2.chr"
.incbin "bm_3.chr"




; .db %00011000
; .db %00011000
; .db %00011000
; .db %11111111
; .db %11111111
; .db %00011000
; .db %00011000
; .db %00011000

; .db %00011000
; .db %00011000
; .db %00011000
; .db %00000000
; .db %00000000
; .db %00011000
; .db %00011000
; .db %00011000