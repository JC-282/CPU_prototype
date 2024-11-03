// author: Xiangyu Guo
// email: guo552@purdue.edu
// file type: asm file
// description: associticity test
org 0x0000

ori $8,$0,0x800
ori $9,$0,0x400

ori $10, $0, 0xbeef
ori $11, $0, 0xdead

sw $10, 0($8)
sw $11, 0($9)

lw $13, 0($8)
lw $14, 0($9)

halt
