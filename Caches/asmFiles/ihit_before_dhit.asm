// author: Xiangyu Guo
// email: guo552@purdue.edu
// file type:asm file
// description: test for ihit before dhit during a lw, sw

org 0x0000


ori $8,$0,0x4ab00
ori $9,$0,0x8ab00


ori $10, $0, 0xdeadbeef
ori $11, $0, 0xdeadaaaa
sw $10, 0($8)

ori $12, $0, 0
ori $13, $0,0x5
for:
    lw $15, 0($8)
    lw $16, 0($9)
    addi $12,$12,1
    bne $12, $13, done

done:
    halt
