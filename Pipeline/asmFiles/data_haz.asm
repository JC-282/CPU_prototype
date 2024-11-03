// author: Xinyuan Cai
// email: cai282@purdue.edu
// file type: assambly file
// description: data hazard unit test

org 0x000

ori $2, $zero, 0xaa
ori $3, $zero, 0xbb
ori $4, $zero, 0xcc
ori $5, $zero, 0xdd

sub $2,$3,$4

sw $5, 200($0)
lw $6, 200($0)

halt

