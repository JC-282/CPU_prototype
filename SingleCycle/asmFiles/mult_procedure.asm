// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: assembly language
// description: This program is to place two operands on the stack then call the multiply
//              sub routine and return back to the main program

org 0x0000

main:
    ori $29, $0, 0
    ori $29, $0, 0xfffc
    ori $11, $0, 0xfffc
    ori $12, $0, 0x4
    sub $11, $11, $12
    ori $2, $0, 0x4
    ori $3, $0, 0x5
    ori $4, $0, 0x6
    ori $5, $0, 0x7

    push $2
    push $3
    push $4
    push $5
mustack:
    beq $29, $11, term
    jal multiply
    j mustack

term:

halt

multiply:
    pop $3
    pop $2
    ori $4, $0, 0x1
    or $5, $0, $3
    sub $2, $2, $4

loop:
    beq $2, $0, done
    sub $2, $2, $4
    add $3, $3, $5
    j loop
done:
    push $3
    JR $31
