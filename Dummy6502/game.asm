.org $8000
;Set some variables address
.define player_color $01
.define player_pos $02
.define bomb_placed $03
.define max_bombs $04
.define fire_placed $05
.define fire_power $06
.define current_health $07
.define max_health $08
.define upgrade_placed $09
.define bomb_color $0E
.define wall_color $0F

;Max 16 bombs [Don't use $10 - $2F]
.define bombs_array_position $10
.define bombs_array_timer $20

.define upgrade_array_position $30
.define upgrade_array_color $40

.define current_frame $F0
.define old_player_pos $F1
.define current_player_pos $F2
.define next_player_pos $F3
.define button_already_pressed $F4
.define boxes_broken $F5
.define upgrade_already_spawned $F6

.define pseudo_random_value $FB
.define fast_memory_temp $FC
.define old_y_value $FD
.define old_x_value $FE
.define old_a_value $FF
;Fast to graphics memory
.define graphics_card $0200
;Fast to third page (Used for map storage)
.define possible_movement_map $0300
.define fire_array $0400
.define bomb_sequence $0700
.define health_position $02F1
.define bomb_ui_position $02F9
.define fire_ui_position $021F
;Define color and constant values
;COLORS ->
;   01 - RED | 02 - GREEN | 03 - ORANGE | 04 - BLUE | 05 - Purple
;   06 - CYAN | 07 - LIGHT GRAY | 08 - GRAY | 09 - PEACH | 0A - LIME
;   0B - YELLOW | 0C - VIOLET | 0D - PINK | 0E - LIHGT BLUE | 0F - WHITE
.define _flame_upgrade_color #09
.define _bomb_upgrade_color #06
.define _wall_color_code #$07
.define _player_color #$01
.define _player_damage_color #$0E
.define _bomb_color #$08
.define _fire_color #$03
.define _box_color #$0B

.define _wall_collision_code #$01
.define _bomb_collision_code #$02
.define _fire_collision_code #$04
.define _box_collision_code #$08
.define _upgrade_collision #$10


.define _bomb_frames #$7
.define _max_possible_bombs #$05
.define _max_possible_fire #$0C
begin:
    LDA #0
    LDX #0
    LDY #0
fill_data:
    INX
    LDA #$8
    STA bomb_sequence, X
    INX
    LDA #$8
    STA bomb_sequence, X
    INX
    LDA #$8
    STA bomb_sequence, X
    INX
    LDA #$F
    STA bomb_sequence, X
    INX
    LDA #$8
    STA bomb_sequence, X
    INX
    LDA #$F
    STA bomb_sequence, X
    INX
    LDA #$8
    STA bomb_sequence, X
    INX
    LDA #$B
    STA bomb_sequence, X
    INX
    LDA #$3
    STA bomb_sequence, X


_clear_variables_page:
    LDX #0
    LDA #0
    LDY #0
_clear_graphics_card:
    STA $0, X
    STA graphics_card, X
    STA possible_movement_map, X
    STA fire_array, X
    INX
    BNE _clear_graphics_card
initizlization:
    ;Initialize some Variables
    LDA _player_color
    STA player_color

    LDA #$11
    STA player_pos
    
    LDA #$11
    STA old_player_pos
    
    LDA #$01
    STA max_bombs

    LDA #$1
    STA fire_power

    LDA #$5
    STA current_health
    STA max_health

    LDA #$01
    STA pseudo_random_value
;
load_map:
    ;pass every cell
    LDX #$00
    map_step:
    JSR update_pseudo_random_value
    TXA
    ;Upper Wall
    CMP #$10
    BCC color_wall
    ;Lower Wall
    CMP #$E0
    BCS color_wall
    ;Left Wall
    AND #$0F
    BEQ color_wall
    ;Right Wall
    EOR #$0E
    BEQ color_wall
    TXA
    AND #$0F
    EOR #$0F
    BEQ color_wall
    TXA
    ;Center Blocks
    AND #$11
    BEQ color_wall

    LDA pseudo_random_value
    CMP #$40
    BCS color_box

    return_color_tile:
    ;Store in a new page
    INX
    BEQ end_map



    JMP map_step

    color_wall:
        LDA _wall_color_code
        STA graphics_card, X
        LDA _wall_collision_code
        STA possible_movement_map, X
        JMP return_color_tile

    color_box:
        LDA _box_color
        STA graphics_card, X
        LDA _box_collision_code
        STA possible_movement_map, X
        JMP return_color_tile

end_map:
    JSR clear_corners
;
update_graphics:
    STA old_a_value

    LDA #$00
    LDX old_player_pos
    STA graphics_card, X

    LDY bomb_placed
    BEQ no_bomb

    repeat_for_each_bomb_draw:
        DEY
        STY fast_memory_temp
        LDX bombs_array_timer, Y
        LDA bomb_sequence, X
        LDX bombs_array_position, Y
        STA graphics_card, X
        LDY fast_memory_temp
        BNE repeat_for_each_bomb_draw


    no_bomb:

    LDY upgrade_placed
    BEQ no_upgrade_draw

    repeat_for_each_upgrade_draw:
        DEY
        STY fast_memory_temp
        LDA upgrade_array_color, Y
        LDX upgrade_array_position, Y
        STA graphics_card, X
        LDY fast_memory_temp
        BNE repeat_for_each_upgrade_draw
        
    no_upgrade_draw:

    JSR draw_fir_tile

    LDX max_health
    draw_health:
        DEX
        STX fast_memory_temp
        LDA #0
        STA health_position, X
        TXA
        CMP current_health
        BCS skip_heart
        LDA player_color
        STA health_position, X
        skip_heart:
        LDX fast_memory_temp
        BNE draw_health
    ;
    LDX _max_possible_bombs
    draw_bomb_ui:
        DEX
        STX fast_memory_temp
        LDA #0
        STA bomb_ui_position, X
        TXA
        CMP max_bombs
        BCS skip_bomb_ui
        LDA _bomb_color
        STA bomb_ui_position, X
        skip_bomb_ui:
        LDX fast_memory_temp
        BNE draw_bomb_ui
    ;
    LDY _max_possible_fire
    LDX #$D0
    draw_fire_ui:
        JSR move_x_cell_up
        STX fast_memory_temp
        LDA #0
        STA fire_ui_position, X
        TXA
        LSR A
        LSR A
        LSR A
        LSR A
        CMP fire_power
        BCS skip_fire_ui
        LDA _fire_color
        STA fire_ui_position, X
        skip_fire_ui:
        LDX fast_memory_temp
        BNE draw_fire_ui
    ; 
    LDA player_color
    LDX player_pos
    STA graphics_card, X
    LDA old_a_value
;
check_control:
    STA old_a_value

    LDA button_already_pressed
    BNE j_skip_frame

    LDA $4000
    BEQ end_check
    STA button_already_pressed

    AND #$08
    BNE j_move_right

    LDA button_already_pressed
    AND #$04
    BNE j_move_left

    LDA button_already_pressed
    AND #$01
    BNE j_move_up

    LDA button_already_pressed
    AND #$02
    BNE j_move_down

    end_mov:
    JMP gameplay_frame

    end_check:
    LDA old_a_value
    JMP check_control

    j_skip_frame:
    JMP skip_frame
    j_move_right:
    JMP move_right
    j_move_left:
    JMP move_left
    j_move_up:
    JMP move_up
    j_move_down:
    JMP move_down
;
gameplay_frame:

    LDX fire_placed
    BEQ return_remove_all_fire
    remove_all_fire:
        DEX
        STX fast_memory_temp
        LDY fire_array, X
        LDA #0
        STA fire_array, X
        STA graphics_card, Y
        STA possible_movement_map, Y
        LDX fast_memory_temp
        BEQ return_remove_all_fire
        JMP remove_all_fire
    
    return_remove_all_fire:
    LDA #0
    STA fire_placed

    LDY upgrade_placed
    BEQ j_no_upgrade_frame
    JMP repeat_for_each_upgrade_gameplay_frame

        j_no_upgrade_frame:
        JMP no_upgrade_frame

    repeat_for_each_upgrade_gameplay_frame:
        DEY
        STY fast_memory_temp
        LDX upgrade_array_position, Y
        LDA _upgrade_collision
        STA possible_movement_map, X

        LDY fast_memory_temp
        BEQ no_upgrade_frame
        JMP repeat_for_each_upgrade_gameplay_frame
    
    no_upgrade_frame:

    LDX bomb_placed
    BEQ j_no_gameplay_frame
    JMP repeat_for_each_bomb_gameplay_frame

    j_no_gameplay_frame:
        JMP no_bomb_gameplay_frame
    ;
    repeat_for_each_bomb_gameplay_frame:
        DEX
        STX fast_memory_temp
        INC bombs_array_timer, X
        LDY bombs_array_timer, X
        LDA bomb_sequence, Y
        BEQ delete_empty_bomb
            return_delete_empty_bomb:
        LDX fast_memory_temp
        BNE repeat_for_each_bomb_gameplay_frame
        JMP no_bomb_gameplay_frame

        delete_empty_bomb:
        ;X = Current Bomb
        JSR bomb_boom
        LDY bombs_array_position
        LDA #0
        STA possible_movement_map, Y
        STA graphics_card, Y
        LDA #0
        STA bombs_array_position
        STA bombs_array_timer
        DEC bomb_placed
        BNE shift_bombs
            return_shift_bombs:
        JMP return_delete_empty_bomb

        shift_bombs:
        LDX #0
        INC bomb_placed
            shift_one_bomb:
            TXA
            CMP bomb_placed
            BCC real_shift_bomb
                DEC bomb_placed
                JMP return_shift_bombs
            real_shift_bomb:
            INX
            LDA bombs_array_position, X
            LDY bombs_array_timer, X
            DEX
            STA bombs_array_position, X
            STY bombs_array_timer, X
            INX
                JMP shift_one_bomb
    
    ;
    no_bomb_gameplay_frame:

    LDA button_already_pressed
    AND #$10
    BNE j_place_bomb

    end_bomb:
    INC current_frame
    LDA _player_color
    STA player_color
    JSR check_damage

    JMP update_graphics

    j_place_bomb:
    JMP place_bomb
;
skip_frame:
    LDA $4000
    STA button_already_pressed
    JMP check_control
;
folder_movement:
    move_right:

        STA old_a_value
        LDX player_pos
        STX old_player_pos
        INX
        JMP check_possible_move

    move_left:
        STA old_a_value
        LDX player_pos
        STX old_player_pos
        DEX
        JMP check_possible_move

    move_up:
        STA old_a_value
        LDX player_pos
        ;Check movement
        STX old_player_pos
        JSR move_x_cell_up
        ; LDY #$10
        ; repeat_16_move_up:
        ;     DEX
        ;     DEY
        ;     BNE repeat_16_move_up
        JMP check_possible_move

    move_down:
        STA old_a_value
        LDX player_pos
        ;Check movement
        STX old_player_pos
        JSR move_x_cell_down
        ; LDY #$10
        ; repeat_16_move_down:
        ;     INX
        ;     DEY
        ;     BNE repeat_16_move_down
        JMP check_possible_move

    check_possible_move:
        LDA possible_movement_map, X
        EOR _wall_collision_code
        BEQ return_move
        LDA possible_movement_map, X
        EOR _bomb_collision_code
        BEQ return_move
        LDA possible_movement_map, X
        EOR _box_collision_code
        BEQ return_move
        STX player_pos
    
    return_move:
        JSR check_on_upgrade
        LDA old_a_value
        JMP end_mov
;
place_bomb:

    LDA bomb_placed
    CMP max_bombs
    BCS j_end_bomb

    LDY bomb_placed
    BEQ no_bomb_check_position
    repeat_for_each_bomb_check_position:
        LDA player_pos
        DEY
        STY fast_memory_temp
        EOR bombs_array_position, Y
        BEQ j_end_bomb
        LDY fast_memory_temp
        BNE repeat_for_each_bomb_check_position

    no_bomb_check_position:

    LDA player_pos
    LDX bomb_placed
    STA bombs_array_position, X
    LDA #$1
    STA bombs_array_timer, X
    LDY player_pos
    LDA _bomb_collision_code
    STA possible_movement_map, Y
    INX
    STX bomb_placed

    j_end_bomb:
    JMP end_bomb
;
bomb_boom:
    STX old_x_value
    LDX bombs_array_position
    JSR place_fire_x

    LDY fire_power
    place_fire_right:
        DEY
        STY fast_memory_temp
        INX
        JSR place_fire_x
        LDY fast_memory_temp
        BEQ end_place_fire_right
        JMP place_fire_right
    
    end_place_fire_right:

    LDX bombs_array_position
    LDY fire_power    
    place_fire_left:
        DEY
        STY fast_memory_temp
        DEX
        JSR place_fire_x
        LDY fast_memory_temp
        BEQ end_place_fire_left
        JMP place_fire_left
    end_place_fire_left:

    LDX bombs_array_position
    LDY fire_power    
    place_fire_up:
        DEY
        STY fast_memory_temp
        JSR move_x_cell_up
        JSR place_fire_x
        LDY fast_memory_temp
        BEQ end_place_fire_up
        JMP place_fire_up
    end_place_fire_up:

    LDX bombs_array_position
    LDY fire_power    
    place_fire_down:
        DEY
        STY fast_memory_temp
        JSR move_x_cell_down
        JSR place_fire_x
        LDY fast_memory_temp
        BEQ end_place_fire_down
        JMP place_fire_down
        
    end_place_fire_down:

    LDX old_x_value
    RTS
;
check_damage:
    LDX fire_placed
    BEQ return_check_damage
    check_a_tile_damage:
        DEX
        STX fast_memory_temp
        LDA fire_array, X
        EOR player_pos
        BEQ take_damage
            return_take_damage:
        LDX fast_memory_temp
        BEQ return_check_damage
        JMP check_a_tile_damage
    return_check_damage:
        RTS

    take_damage:
        DEC current_health
        LDA _player_damage_color
        STA player_color
        JMP return_take_damage
;
draw_fir_tile:
    LDY fire_placed
    BEQ return_draw_fire_tile
    draw_a_fire_tile:
        DEY
        STY fast_memory_temp
        LDX fire_array, Y
        LDA _fire_color
        STA graphics_card, X
        LDY fast_memory_temp
        BEQ return_draw_fire_tile
        JMP draw_a_fire_tile

    return_draw_fire_tile:
    RTS
;
place_fire_x:
    STX old_x_value ;Position to place fire
    LDA possible_movement_map, X
    EOR _wall_collision_code
    BEQ fire_wall_collision

    TXA
    LDY fire_placed
    STA fire_array, Y
    INC fire_placed

    LDA possible_movement_map, X
    EOR _box_collision_code
    BEQ fire_box_collision

    LDA possible_movement_map, X
    EOR _upgrade_collision
    BEQ fire_upgrade_collision

    LDX old_x_value
    RTS

    fire_upgrade_collision:
    JSR remove_x_upgrade
    JMP fire_wall_collision

    fire_box_collision:
    INC boxes_broken
    JSR spawn_upgrade

    fire_wall_collision:
    LDX old_x_value
    LDY #0
    STY fast_memory_temp
    RTS
;
spawn_upgrade:
    STY old_y_value
    LDA boxes_broken
    AND #$03
    EOR #$03
    BNE end_spawn_upgrade
    LDY upgrade_placed
    INC upgrade_placed
    LDA _upgrade_collision
    STA possible_movement_map, X
    STX upgrade_array_position, Y
    LDA upgrade_already_spawned
    AND #$03
    EOR #$01
    BEQ spawn_bomb_upgrade
    JMP spawn_fire_upgrade

    spawn_fire_upgrade:

        LDA _flame_upgrade_color
        STA upgrade_array_color, Y
        INC upgrade_already_spawned
        JMP end_spawn_upgrade

    spawn_bomb_upgrade:
        ; LDA _upgrade_collision
        ; STA possible_movement_map, X
        ; STX upgrade_array_position, Y
        LDA _bomb_upgrade_color
        STA upgrade_array_color, Y
        INC upgrade_already_spawned
        JMP end_spawn_upgrade
    
    end_spawn_upgrade:
    LDY old_y_value
    RTS
;
move_x_cell_up:
    STY old_y_value
    LDY #$10
    repeat_16_move_up:
        DEX
        DEY
        BNE repeat_16_move_up
    LDY old_y_value
    RTS
;
move_x_cell_down:
    STY old_y_value
    LDY #$10
    repeat_16_move_down:
        INX
        DEY
        BNE repeat_16_move_down
    LDY old_y_value
    RTS
;
update_pseudo_random_value:
    ;copied from internet
    STA old_a_value
    LDA pseudo_random_value
    ASL A
    BCC no_eor
        EOR #$1d
    no_eor: 
    STA pseudo_random_value
    
    LDA old_a_value
    RTS
;
clear_corners:
    LDA #0
    LDX #$11
    STA graphics_card, X
    STA possible_movement_map, X
    LDX #$12
    STA graphics_card, X
    STA possible_movement_map, X
    LDX #$21
    STA graphics_card, X
    STA possible_movement_map, X


    LDX #$C1
    STA graphics_card, X
    STA possible_movement_map, X
    LDX #$D1
    STA graphics_card, X
    STA possible_movement_map, X
    LDX #$D2
    STA graphics_card, X
    STA possible_movement_map, X

    LDX #$CD
    STA graphics_card, X
    STA possible_movement_map, X
    LDX #$DD
    STA graphics_card, X
    STA possible_movement_map, X
    LDX #$DC
    STA graphics_card, X
    STA possible_movement_map, X

    LDX #$1C
    STA graphics_card, X
    STA possible_movement_map, X
    LDX #$1D
    STA graphics_card, X
    STA possible_movement_map, X
    LDX #$2D
    STA graphics_card, X
    STA possible_movement_map, X

RTS
;
check_on_upgrade:
    STX old_x_value
    LDX upgrade_placed
    BEQ end_check_on_upgrade

    check_each_upgrade_array:
        DEX
        STX fast_memory_temp
        LDA upgrade_array_position, X
        EOR player_pos
        BEQ j_remove_x_upgrade
        LDX fast_memory_temp
        BEQ end_check_on_upgrade
        JMP check_each_upgrade_array

    end_check_on_upgrade:
    LDX old_y_value
    RTS

    j_remove_x_upgrade:
    LDA upgrade_array_color, X
    EOR _flame_upgrade_color
    BEQ add_fire
    LDA upgrade_array_color, X
    EOR _bomb_upgrade_color
    BEQ add_bomb

    end_added_effect:
    LDX player_pos
    JSR remove_x_upgrade
    JMP end_check_on_upgrade

    add_fire:
    INC fire_power
    JMP end_added_effect
    
    add_bomb:
    INC max_bombs
    JMP end_added_effect
;
remove_x_upgrade:
    STY old_y_value
    STA old_a_value
    STX old_x_value ; position to remove
    
    LDA upgrade_placed
    BEQ return_upgrade_placed_prevent_overflow
    ;LDY upgrade_placed
    LDY #0
    find_upgrade_to_remove:
        TYA
        EOR upgrade_placed
        BEQ return_upgrade_placed
        LDA upgrade_array_position, Y
        EOR old_x_value
        BEQ shift_y_upgrade
        INY
        JMP find_upgrade_to_remove

    shift_y_upgrade:
        INY
        LDA upgrade_array_position, Y
        STA fast_memory_temp
        LDA upgrade_array_color, Y
        DEY
        STA upgrade_array_color, Y
        LDA fast_memory_temp
        STA upgrade_array_position, Y
        INY
        TYA
        CMP upgrade_placed
        BCC shift_y_upgrade
        JMP return_upgrade_placed
        
    return_upgrade_placed:
    DEC upgrade_placed
    return_upgrade_placed_prevent_overflow:
    LDX old_x_value
    LDY old_y_value
    LDA old_a_value
    RTS
;
vsync:
    RTI

.goto $fffa
.dw vsync
.dw begin
.dw begin