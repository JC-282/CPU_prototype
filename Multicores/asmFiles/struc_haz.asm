// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: assamblely file
// description:structural hazar unit test

org 0x0000

ori $2,$zero,0xaa
ori $3,$zero,0xbb
ori $4,$zero,0xcc
ori $5,$zero,0xdd
ori $6,$zero,0xee
ori $7,$zero,0xff

sw $2, 200($0)
sw $3, 204($0)
sw $4, 208($0)
sw $5, 212($0)
sw $6, 216($0)
sw $7, 220($0)

halt

