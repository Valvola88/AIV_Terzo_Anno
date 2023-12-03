
#Direction
lui $s0, 0xffff
ori $s0, $s0, 0x8010

#Leave Track
lui $s1, 0xffff
ori $s1, $s1, 0x8020

#Move - Always true
lui $s2, 0xffff
ori $s2, $s2, 0x8050

#Start By Moving

ori $t1, $t1, 1
sw $t1, ($s2)

#Set $v1 as 1
ori $v1, $v1, 1

loop:
  #Move 100 right
  ori $a0, $a0, 10
  jal goRight
  ori $a0, $a0, 20
  jal goDown
    ori $a0, $a0, 15
  jal goRight
    ori $a0, $a0, 20
  jal goDown
    ori $a0, $a0, 5
  jal goLeft
    ori $a0, $a0, 5
  jal goDown
    ori $a0, $a0, 50
  jal goRight
    ori $a0, $a0, 50
  jal goUp
  
  j end
  
goDown:
  sw $v1, ($s1)
  ori $t1, $t1, 180
  sw $t1, ($s0)   
  sw $v1, ($s2)
  loop_down:
    addiu $a0, $a0, -1
    bne $a0, 0, loop_down

  sw $zero, ($s1)  
  sw $zero, ($s2)
  andi $t1, $t1, 0
  jr $ra
  
goRight:
  sw $v1, ($s1)
  ori $t1, $t1, 90
  sw $t1, ($s0)   
  sw $v1, ($s2)
  loop_right:
    addiu $a0, $a0, -1
    bne $a0, 0, loop_right

  sw $zero, ($s1)  
  sw $zero, ($s2)  
  andi $t1, $t1, 0
  jr $ra
  
goLeft:
  sw $v1, ($s1)
  ori $t1, $t1, 270
  sw $t1, ($s0)   
  sw $v1, ($s2)
  loop_left:
    addiu $a0, $a0, -1
    bne $a0, 0, loop_left

  sw $zero, ($s1)   
  sw $zero, ($s2) 
  andi $t1, $t1, 0
  jr $ra
  
goUp:
  sw $v1, ($s1)
  ori $t1, $t1, 0
  sw $t1, ($s0)   
  sw $v1, ($s2)
  loop_up:
    addiu $a0, $a0, -1
    bne $a0, 0, loop_up

  sw $zero, ($s1)   
  sw $zero, ($s2) 
  andi $t1, $t1, 0
  jr $ra

end:
  j end
