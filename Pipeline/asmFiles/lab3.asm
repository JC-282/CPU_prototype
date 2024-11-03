// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: assembly file
// description: Unit test for branch, jump, and halt for lab3-4


org 0x0000
ori $29, $0, 0
ori $29, $0, 0xfffc

main:
    addi $10, $0, 0
    beq $10, $0, rusha

rusha:
// store 1128 to 5000
    addi $10, $0, 5000
    addi $11, $0, 1128
    sw $11, 0($10)
    addi $10, $0, 0
    addi $12, $0, 1
    beq $10, $12, rushb
    bne $12, $0, rushb
    bne $10, $12, rushc
    halt
rushb:
// not supposed to go here
// store 1128 to 5200
    addi $10, $0, 5200
    addi $11, $0, 1128
    sw $11, 0($10)
    halt

rushc:
// store 1128 to 5500
    addi $10, $0, 5500
    addi $11, $0, 1128
    sw $11, 0($10)
    J rushd
    halt

rushd:
// store 1128 to 5550
    addi $10, $0, 5550
    addi $11, $0, 1128
    sw $11, 0($10)
    jal rushhhh
    halt
rushhhh:
// store 1128 to 555540
    addi $10, $0, 555540
    addi $11, $0, 1128
    sw $11, 0($10)
    jr $31

rushe:
// not supposed to go here
// store 1128 to 55550
    addi $10, $0, 55550
    addi $11, $0, 1128
    sw $11, 0($10)
    halt
