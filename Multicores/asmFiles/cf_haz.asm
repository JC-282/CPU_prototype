// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: assambly file
// description: control flow hazard unit test

org 0x0000

    ori $1, $0, 0x1234
    ori $2, $0, 0x5678
    ori $5, $0, 0xff0

    ori $6, $0, 0xaa
    ori $7, $0, 0xaa
    ori $8, $0, 0xbb

    jal jump1
    sw  $2, 8($5)
    j branch_t
    halt
jump1:
    sw  $2, 0($5)
    j jump2
    halt

jump2:
    sw  $2, 4($5)
    jr  $31
    halt

branch_t:
    beq $6,$7,yesyes

nono:
    sw $1, 100($0)

yesyes:
    sw $2, 200($0)

    bne $6,$7,nono

done:
    sw $8, 400($0)
    halt //true end

nono2:
    sw $2, 208($0)





