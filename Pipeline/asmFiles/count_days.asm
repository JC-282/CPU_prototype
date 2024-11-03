// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: assembly language file
// description: This program will roughly calculate the number of days since the year 2000

org 0x0000
ori $29, $0, 0
ori $29, $0, 0xfffc

main:
    ori $11, $0, 2022 // year
    ori $12, $0, 8 // month
    ori $13, $0, 23 // day

    // 30 * (month - 1)
    ori $2, $0, 0x1
    sub $12, $12, $2
    ori $2, $0, 30
    push $12
    push $2
    jal multiply

    // 365 * (year - 2000)
    ori $2, $0, 2000
    sub $11, $11, $2
    ori $2, $0, 365
    push $11
    push $2
    jal multiply


    // add together
    pop $11
    pop $12
    add $20, $11, $12
    add $20, $20, $13
    push $20

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
