//author: Xinyuan Cai
//email: cai282@purdue.edu
//file type: assembly program
//description: the alu cannot perform multiplications, so we implement mutiplication here

org 0x0000

ori $29, $0, 0
ori $29, $0, 0xfffc
ori $2, $0, 0x3
ori $3, $0, 0x2

push $2
push $3

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

halt

