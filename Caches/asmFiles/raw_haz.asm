// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: assambly file
// description: data hazard unit test

org 0x0000

ori $5, $0, 0xaa
ori $6, $0, 0x00F0

lw $5, 0($6)
sw $5, 200($0)

halt



org 0x00F0
cfw 0xaabb
