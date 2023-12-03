
#.text 0x400000
lui $a0, 0x1001
ori $a0, $a0, 0x0000

ori $a1, $a1, 7
ori $a2, $a2, 2
lui $t7, 0x00FF
ori $t7, $t7, 0xFF00
 
addiu $a0, $a0, 0x44


loop:
  sw $t7, ($a0)
  addiu $a0, $a0, 8
  addiu $a1, $a1, -1
  bne $a1, 0, loop
  addiu $a1, $a1, 7
  addiu $a2, $a2, -1
  bne $a2, 0, odd
#  j even
  odd:
  addiu $a0, $a0, 0x48
  j loop
  
  even:
  addiu $a0, $a0, -4
  addiu $a2, $a2, 2
  j loop

  
.kdata 0x80000180
  mfc0 $s0, $14
  add $s0, $s0, 4
  mtc0 $s0, $14
  eret
    
  
  
