// author: Xiangyu Guo
// email: guo552@purdue.edu
// file type: asm file
// description: test for ihit and dhit at the same time
org 0x0000

ori $8, $0, 0x5600
ori $9, $0, 0xdeadbeef

sw $9, 0($8)
ori $10, $0, 0
ori $11, $0,0x10

for:
    lw $10, 0($8)
    addi $10,$10,1
    bne $10, $11, done

done:
    halt
