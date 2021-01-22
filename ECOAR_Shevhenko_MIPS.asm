.eqv BMP_SIZE   230522
.eqv BMP_COLOR  0x00000000


.data
.align 2 

bmp_path:       .align 2
                .asciiz "source_full_test.bmp"

bmp_file:       .align 2
                .space BMP_SIZE


.text

j   main

.macro exit
    jal func_exit
.end_macro

func_exit:
    li      $v0, 10
    syscall # exit
    jr      $ra

.macro text (%text) # passing the label
    la      $a0, %text
    jal     func_print_text
.end_macro

.macro str (%string) # passing const string 
    .data
    text_string:   .asciiz %string
    .text
    text (text_string)
.end_macro

.macro ln ()
    str ("\n")
.end_macro

.macro strln (%string) # output a line and move to a new line
    str (%string)
    ln ()
.end_macro

.macro textln (%text) # we display the text from the label and go to a new line 
    text (%text)
    ln ()
.end_macro

func_print_text:
    li      $v0, 4
    syscall # print text
    jr      $ra

.macro int (%int)
    add     $a0, $zero, %int
    jal     func_print_int
.end_macro

.macro intln (%int)
    int (%int)
    ln ()
.end_macro

func_print_int:
    li      $v0, 1
    syscall # print int
    jr      $ra

.macro hex (%hex)
    add     $a0, $zero, %hex
    jal     func_print_hex
.end_macro

.macro hexln (%hex)
    hex (%hex)
    ln ()
.end_macro

func_print_hex:
    li      $v0, 34
    syscall # print hex
    jr      $ra

.macro bmp (%error, %path, %space, %size) # 
    la      $a0, %error
    la      $a1, %path
    la      $a2, %space
    add     $a3, $zero, %size
    jal     func_bmp
.end_macro

func_bmp:
    sub     $sp, $sp, 4
    sw      $ra, ($sp)
    sub     $sp, $sp, 4
    sw      $s0, ($sp)
    sub     $sp, $sp, 4
    sw      $s1, ($sp)
    sub     $sp, $sp, 4
    sw      $s2, ($sp)
    sub     $sp, $sp, 4
    sw      $s3, ($sp)
    sub     $sp, $sp, 4
    sw      $s4, ($sp)
    sub     $sp, $sp, 4
    sw      $s5, ($sp)
    #
    move    $s0, $a0 # error
    move    $s1, $a1 # path
    move    $s2, $a2 # space
    move    $s3, $a3 # size
    #
    move    $a0, $s1
    li      $a1, 0
    li      $a2, 0
    li      $v0, 13
    syscall # file open
    bltz    $v0, func_bmp_error # file opened ($v0<0 - error)
    #
    move    $s4, $v0 # file descriptor
    #
    move    $a0, $s4
    move    $a1, $s2
    move    $a2, $s3
    li      $v0, 14
    syscall # file load
    #
    move    $a0, $s4
    li      $v0, 16
    syscall # file close
    #
    lhu     $s5, ($s2)
    sub     $s5, $s5, 0x4D42
    bnez    $s5, func_bmp_error # file head is BMP
    #
    #lhu     $s5, 18($s2) # width (offset of 18)
    #sub     $s5, $s5, 320
    #bnez    $s5, func_bmp_error # bmp width == 320
    #
    #lhu     $s5, 22($s2) # height (offset of 22)
    #sub     $s5, $s5, 240
    #bnez    $s5, func_bmp_error # bmp height == 240
    # 
    lw      $s5, ($sp)
    add     $sp, $sp, 4
    lw      $s4, ($sp)
    add     $sp, $sp, 4
    lw      $s3, ($sp)
    add     $sp, $sp, 4
    lw      $s2, ($sp)
    add     $sp, $sp, 4
    lw      $s1, ($sp)
    add     $sp, $sp, 4
    lw      $s0, ($sp)
    add     $sp, $sp, 4
    lw      $ra, ($sp)
    add     $sp, $sp, 4
    jr      $ra
    func_bmp_error:
    move    $a0, $s0 # error
    move    $v0, $zero
    lw      $s5, ($sp)
    add     $sp, $sp, 4
    lw      $s4, ($sp)
    add     $sp, $sp, 4
    lw      $s3, ($sp)
    add     $sp, $sp, 4
    lw      $s2, ($sp)
    add     $sp, $sp, 4
    lw      $s1, ($sp)
    add     $sp, $sp, 4
    lw      $s0, ($sp)
    add     $sp, $sp, 4
    lw      $ra, ($sp)
    add     $sp, $sp, 4
    jr      $a0

.macro pixel (%error, %space, %x, %y)
    la      $a0, %error
    la      $a1, %space
    add     $a2, $zero, %x
    add     $a3, $zero, %y
    jal     func_pixel
.end_macro

func_pixel:
    sub     $sp, $sp, 4
    sw      $ra, ($sp)
    sub     $sp, $sp, 4
    sw      $s0, ($sp)
    sub     $sp, $sp, 4
    sw      $s1, ($sp)
    sub     $sp, $sp, 4
    sw      $s2, ($sp)
    sub     $sp, $sp, 4
    sw      $s3, ($sp)
    sub     $sp, $sp, 4
    sw      $s4, ($sp)
    sub     $sp, $sp, 4
    sw      $s5, ($sp)
    #
    move    $s0, $a0 # error
    move    $s1, $a1 # space
    move    $s2, $a2 # x
    move    $s3, $a3 # y
    #
    sle     $s4, $zero, $s2
    beqz    $s4, func_pixel_error # 0 <= x
    #
    sle     $s4, $zero, $s3
    beqz    $s4, func_pixel_error # 0 <= y
    #
    lhu     $s4, 18($s1) # width
    slt     $s4, $s2, $s4
    beqz    $s4, func_pixel_error # x < width
    #
    lhu     $s4, 22($s1) # height
    slt     $s4, $s3, $s4
    beqz    $s4, func_pixel_error # y < height
    #
    lhu     $s4, 18($s1) # width
    mul     $s5, $s3, 3 # y * 3
    mul     $s4, $s4, $s5 # width * y * 3 (RRGGBB = 3 byte)
    mul     $s5, $s2, 3 # x * 3
    add     $s4, $s4, $s5 # width * y * 3 + x * 3 (RRGGBB = 3 byte)
    add     $s4, $s4, 54 # width * y * 3 + x * 3 + file header size
    add     $s4, $s4, $s1 # pixel
    #
    lbu     $s5, 0($s4)      # blue
    sll     $s5, $s5, 0      # blue << 0
    add     $v0, $zero, $s5  # $v0 <- blue
    #
    lbu     $s5, 1($s4)      # green
    sll     $s5, $s5, 8      # green << 8
    or      $v0, $v0, $s5    # $v0 <- green
    #
    lbu     $s5, 2($s4)      # red
    sll     $s5, $s5, 16     # red << 16
    or      $v0, $v0, $s5    # $v0 <- red
    # 
    lw      $s5, ($sp)
    add     $sp, $sp, 4
    lw      $s4, ($sp)
    add     $sp, $sp, 4
    lw      $s3, ($sp)
    add     $sp, $sp, 4
    lw      $s2, ($sp)
    add     $sp, $sp, 4
    lw      $s1, ($sp)
    add     $sp, $sp, 4
    lw      $s0, ($sp)
    add     $sp, $sp, 4
    lw      $ra, ($sp)
    add     $sp, $sp, 4
    jr      $ra
    func_pixel_error:
    move    $a0, $s0 # error
    move    $v0, $zero
    lw      $s5, ($sp)
    add     $sp, $sp, 4
    lw      $s4, ($sp)
    add     $sp, $sp, 4
    lw      $s3, ($sp)
    add     $sp, $sp, 4
    lw      $s2, ($sp)
    add     $sp, $sp, 4
    lw      $s1, ($sp)
    add     $sp, $sp, 4
    lw      $s0, ($sp)
    add     $sp, $sp, 4
    lw      $ra, ($sp)
    add     $sp, $sp, 4
    jr      $a0

.macro xy (%x, %y)
    str ("(x: ")
    int (%x)
    str ("; y: ")
    int (%y)
    str (")")
.end_macro

.macro rgb (%pixel)
    sub     $sp, $sp, 4
    sw      $t0, ($sp)
    sub     $sp, $sp, 4
    sw      $t1, ($sp)
    add     $t0, $zero, %pixel
    str ("(")
    andi    $t1, $t0, 0x00FF0000 # red
    srl     $t1, $t1, 16
    int ($t1)
    str ("; ")
    andi    $t1, $t0, 0x0000FF00 # green
    srl     $t1, $t1, 8
    int ($t1)
    str ("; ")
    andi    $t1, $t0, 0x000000FF # blue
    srl     $t1, $t1, 0
    int ($t1)
    str (")")
    lw      $t1, ($sp)
    add     $sp, $sp, 4
    lw      $t0, ($sp)
    add     $sp, $sp, 4
.end_macro

.macro bmp_loop_it (%x, %y)
    move    $a0, %x
    move    $a1, %y
    jal     func_bmp_loop_it
.end_macro

func_bmp_loop_it:
    sub     $sp, $sp, 4
    sw      $ra, ($sp)
    sub     $sp, $sp, 4
    sw      $s0, ($sp)
    sub     $sp, $sp, 4
    sw      $s1, ($sp)
    sub     $sp, $sp, 4
    sw      $s2, ($sp)
    sub     $sp, $sp, 4
    sw      $s3, ($sp)
    sub     $sp, $sp, 4
    sw      $s4, ($sp)
    sub     $sp, $sp, 4
    sw      $s5, ($sp)
    sub     $sp, $sp, 4
    sw      $s6, ($sp)
    sub     $sp, $sp, 4
    sw      $s7, ($sp)
    #
    move    $s0, $a0 # x
    move    $s1, $a1 # y
    li      $s2, 1 # depth
    li      $s3, 1 # figure width
    li      $s4, 1 # figure height
    #
    add     $t0, $s0, 0
    add     $t1, $s1, 0
    pixel (func_bmp_loop_it_done, bmp_file, $t0, $t1)
    move    $t2, $v0
    bne     $t2, BMP_COLOR, func_bmp_loop_it_done # color(x, y) == BMP_COLOR
    #
    add     $t0, $s0, -1
    add     $t1, $s1, +1
    pixel (func_bmp_loop_it_left_top, bmp_file, $t0, $t1)
    move    $t2, $v0
    beq     $t2, BMP_COLOR, func_bmp_loop_it_done # color(x-1, y+1) != BMP_COLOR
    func_bmp_loop_it_left_top:
    #
    add     $t0, $s0, -1
    add     $t1, $s1, 0
    pixel (func_bmp_loop_it_left, bmp_file, $t0, $t1)
    move    $t2, $v0
    beq     $t2, BMP_COLOR, func_bmp_loop_it_done # color(x-1, y) != BMP_COLOR
    func_bmp_loop_it_left:
    #
    add     $t0, $s0, 0
    add     $t1, $s1, +1
    pixel (func_bmp_loop_it_top, bmp_file, $t0, $t1)
    move    $t2, $v0
    beq     $t2, BMP_COLOR, func_bmp_loop_it_done # color(x, y+1) != BMP_COLOR
    func_bmp_loop_it_top:
    #
    # calc depth
    func_bmp_loop_it_depth_it:
    add     $t0, $s0, $s2
    sub     $t1, $s1, $s2
    pixel (func_bmp_loop_it_depth_done, bmp_file, $t0, $t1)
    move    $t2, $v0
    bne     $t2, BMP_COLOR, func_bmp_loop_it_depth_done # color(x + depth, y - depth) == BMP_COLOR
    add     $s2, $s2, 1
    j       func_bmp_loop_it_depth_it 
    func_bmp_loop_it_depth_done:
    #
    # calc figure height
    func_bmp_loop_it_figure_height_it:
    add     $t0, $s0, 0
    sub     $t1, $s1, $s4
    pixel (func_bmp_loop_it_figure_height_done, bmp_file, $t0, $t1)
    move    $t2, $v0
    bne     $t2, BMP_COLOR, func_bmp_loop_it_figure_height_done # color(x, y - figure height) == BMP_COLOR
    add     $s4, $s4, 1
    j       func_bmp_loop_it_figure_height_it 
    func_bmp_loop_it_figure_height_done:
    #
    # calc figure width
    func_bmp_loop_it_figure_width_it:
    add     $t0, $s0, $s3 # x + figure width
    sub     $t1, $s1, 0 # y -0
    pixel (func_bmp_loop_it_figure_width_done, bmp_file, $t0, $t1)
    move    $t2, $v0
    bne     $t2, BMP_COLOR, func_bmp_loop_it_figure_width_done # color(x + figure width, y) == BMP_COLOR
    add     $s3, $s3, 1
    j       func_bmp_loop_it_figure_width_it 
    func_bmp_loop_it_figure_width_done:
    #
    bge     $s2, $s3, func_bmp_loop_it_done # depth < figure height
    #
    mul     $t0, $s4, 2
    bne     $t0, $s3, func_bmp_loop_it_done # figure height * 2 = figure width
    #
    # thick vertical line is correct
    li      $s5, 0 # idepth
    func_bmp_loop_it_height_depth_it:
    bge     $s5, $s2, func_bmp_loop_it_height_depth_done # $s5(idepth) < $s2(depth)
    li      $s6, 0 # figure iheight
    func_bmp_loop_it_height_depth_height_it:
    bge     $s6, $s4, func_bmp_loop_it_height_depth_height_done # $s6(figure iheight) < $s4(figure height)
    add     $t0, $s0, $s5 # x + $s5 (idepth)
    sub     $t1, $s1, $s6 # y - $s6 (figure iheight)
    pixel (func_bmp_loop_it_done, bmp_file, $t0, $t1)
    move    $t2, $v0
    bne     $t2, BMP_COLOR, func_bmp_loop_it_done # color(x + $s5, y - $s6) == BMP_COLOR
    add     $s6, $s6, 1
    j       func_bmp_loop_it_height_depth_height_it 
    func_bmp_loop_it_height_depth_height_done:
    add     $s5, $s5, 1
    j       func_bmp_loop_it_height_depth_it 
    func_bmp_loop_it_height_depth_done:
    #
    # thick horizontal line is correct
    li      $s5, 0 # idepth
    func_bmp_loop_it_width_depth_it:
    bge     $s5, $s2, func_bmp_loop_it_width_depth_done # $s5(idepth) < $s2(depth)
    li      $s6, 0 # figure iwidth
    func_bmp_loop_it_width_depth_width_it:
    bge     $s6, $s3, func_bmp_loop_it_width_depth_width_done # $s6(figure iwidth) < $s3(figure width)
    add     $t0, $s0, $s6 # x + $s6 (figure iwidth)
    sub     $t1, $s1, $s5 # y - $s5 (figure idepth)
    pixel (func_bmp_loop_it_done, bmp_file, $t0, $t1)
    move    $t2, $v0
    bne     $t2, BMP_COLOR, func_bmp_loop_it_done # color(x + $s6, y - $s5) == BMP_COLOR
    add     $s6, $s6, 1
    j       func_bmp_loop_it_width_depth_width_it 
    func_bmp_loop_it_width_depth_width_done:
    add     $s5, $s5, 1
    j       func_bmp_loop_it_width_depth_it 
    func_bmp_loop_it_width_depth_done:
    #
    # outer left
    li      $s5, -1 # iheight
    add     $s6, $s4, 1 # figure height + 1
    func_bmp_loop_it_outer_left_it:
    bge     $s5, $s6, func_bmp_loop_it_outer_left_done # $s5(iheight) < $s6(figure height + 1)
    add     $t0, $s0, -1 # x - 1
    sub     $t1, $s1, $s5 # y - $s5 (iheight)
    pixel (func_bmp_loop_it_outer_left_done, bmp_file, $t0, $t1)
    move    $t2, $v0
    beq     $t2, BMP_COLOR, func_bmp_loop_it_done # color(x - 1, y - $s5) != BMP_COLOR
    add     $s5, $s5, 1
    j       func_bmp_loop_it_outer_left_it 
    func_bmp_loop_it_outer_left_done:
    #
    # outer top
    li      $s5, -1 # iwidth
    add     $s6, $s3, 2 # figure width + 1
    func_bmp_loop_it_outer_top_it:
    bge     $s5, $s6, func_bmp_loop_it_outer_top_done # $s5(iwidth) < $s6(figure width + 1)
    add     $t0, $s0, $s5 # x + $s5 (iwidth)
    sub     $t1, $s1, -1 # y - 1
    pixel (func_bmp_loop_it_outer_top_done, bmp_file, $t0, $t1)
    move    $t2, $v0
    beq     $t2, BMP_COLOR, func_bmp_loop_it_done # color(x + $s5, y - 1) != BMP_COLOR
    add     $s5, $s5, 1
    j       func_bmp_loop_it_outer_top_it 
    func_bmp_loop_it_outer_top_done:
    #
    # outer right
    li      $s5, -1 # iheight
    add     $s6, $s2, 1 # depth + 1
    func_bmp_loop_it_outer_right_it:
    bge     $s5, $s6, func_bmp_loop_it_outer_right_done # $s5(iheight) < $s6(depth + 1)
    add     $t0, $s0, $s3 # x + $s3 (figure width)
    sub     $t1, $s1, $s5 # y - $s5 (iheight)
    pixel (func_bmp_loop_it_outer_right_done, bmp_file, $t0, $t1)
    move    $t2, $v0
    beq     $t2, BMP_COLOR, func_bmp_loop_it_done # color(x + figure width, y - $s5) != BMP_COLOR
    add     $s5, $s5, 1
    j       func_bmp_loop_it_outer_right_it 
    func_bmp_loop_it_outer_right_done:
    #
    # outer bottom
    li      $s5, -1 # iwidth
    add     $s6, $s2, 1 # depth + 1
    func_bmp_loop_it_outer_bottom_it:
    bge     $s5, $s6, func_bmp_loop_it_outer_bottom_done # $s5(iwidth) < $s6(depth + 1)
    add     $t0, $s0, $s5 # x + $s5 (iwidth)
    sub     $t1, $s1, $s4 # y - $s4 (figure height)
    pixel (func_bmp_loop_it_outer_bottom_done, bmp_file, $t0, $t1)
    move    $t2, $v0
    beq     $t2, BMP_COLOR, func_bmp_loop_it_done # color(x + $s5, y - figure height) != BMP_COLOR
    add     $s5, $s5, 1
    j       func_bmp_loop_it_outer_bottom_it 
    func_bmp_loop_it_outer_bottom_done:
    #
    # inner right
    move    $s5, $s2 # iheight
    add     $s6, $s4, 1 # figure height + 1
    func_bmp_loop_it_inner_right_it:
    bge     $s5, $s6, func_bmp_loop_it_inner_right_done # $s5(iheight) < $s6(figure height + 1)
    add     $t0, $s0, $s2 # x + depth
    sub     $t1, $s1, $s5 # y - $s5 (iheight)
    pixel (func_bmp_loop_it_inner_right_done, bmp_file, $t0, $t1)
    move    $t2, $v0
    beq     $t2, BMP_COLOR, func_bmp_loop_it_done # color(x + depth, y - $s5) != BMP_COLOR
    add     $s5, $s5, 1
    j       func_bmp_loop_it_inner_right_it 
    func_bmp_loop_it_inner_right_done:
    #
    # inner bottom
    move    $s5, $s2 # iwidth
    add     $s6, $s2, 1 # depth + 1
    func_bmp_loop_it_inner_bottom_it:
    bge     $s5, $s6, func_bmp_loop_it_inner_bottom_done # $s5(iwidth) < $s6(depth + 1)
    add     $t0, $s0, $s5 # x + $s5 (iwidth)
    sub     $t1, $s1, $s2 # y - depth
    pixel (func_bmp_loop_it_inner_bottom_done, bmp_file, $t0, $t1)
    move    $t2, $v0
    beq     $t2, BMP_COLOR, func_bmp_loop_it_done # color(x + $s5, y - depth) != BMP_COLOR
    add     $s5, $s5, 1
    j       func_bmp_loop_it_inner_bottom_it 
    func_bmp_loop_it_inner_bottom_done:
    #
    xy ($s0, $s1)
    ln ()
    #
    func_bmp_loop_it_done:
    #
    lw      $s7, ($sp)
    add     $sp, $sp, 4
    lw      $s6, ($sp)
    add     $sp, $sp, 4
    lw      $s5, ($sp)
    add     $sp, $sp, 4
    lw      $s4, ($sp)
    add     $sp, $sp, 4
    lw      $s3, ($sp)
    add     $sp, $sp, 4
    lw      $s2, ($sp)
    add     $sp, $sp, 4
    lw      $s1, ($sp)
    add     $sp, $sp, 4
    lw      $s0, ($sp)
    add     $sp, $sp, 4
    lw      $ra, ($sp)
    add     $sp, $sp, 4
    jr      $ra

.macro bmp_loop ()
    jal     func_bmp_loop
.end_macro

func_bmp_loop:
    sub     $sp, $sp, 4
    sw      $ra, ($sp)
    sub     $sp, $sp, 4
    sw      $s0, ($sp)
    sub     $sp, $sp, 4
    sw      $s1, ($sp)
    sub     $sp, $sp, 4
    sw      $s2, ($sp)
    #
    #move    $s0, $a0 # space
    #move    $s1, $a1 # call
    #
    li      $s1, 1 # y (skip 0 line)
    func_bmp_loop_y_it:
    la      $s2, bmp_file
    lhu     $s2, 22($s2) # bmp height
    slt     $s2, $s1, $s2 # if(y<height)
    beqz    $s2, func_bmp_loop_y_done
    #
    li      $s0, 0 #x
    func_bmp_loop_x_it:
    la      $s2, bmp_file
    lhu     $s2, 18($s2) # bmp width
    slt     $s2, $s0, $s2 # if(x<width)
    beqz    $s2, func_bmp_loop_x_done
    #
    bmp_loop_it ($s0, $s1)
    #
    add     $s0, $s0, 1
    j       func_bmp_loop_x_it
    func_bmp_loop_x_done:
    #
    add     $s1, $s1, 1
    j       func_bmp_loop_y_it
    func_bmp_loop_y_done:
    #
    lw      $s2, ($sp)
    add     $sp, $sp, 4
    lw      $s1, ($sp)
    add     $sp, $sp, 4
    lw      $s0, ($sp)
    add     $sp, $sp, 4
    lw      $ra, ($sp)
    add     $sp, $sp, 4
    jr      $ra


main:
    bmp (main_done, bmp_path, bmp_file, BMP_SIZE)
    bmp_loop ()    
    exit ()

main_done:
    strln ("exit")
    exit ()
