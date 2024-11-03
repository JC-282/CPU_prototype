org 0x0000
ori $8,$0,0x0400
ori $16, $0, 0xaaaa
lw $15, 0($8)
sw $16, 0($8)
nop
nop
nop
nop
nop
nop
ori $17, $0, 0xbbbb
sw $17, 4($8)

halt


org 0x0200
nop
nop
nop
nop
nop
nop
nop
nop

ori $8,$0,0x0400
ori $16, $0, 0xcccc
lw $15, 0($8)
sw $16, 0($8)
nop
nop
nop
nop
nop
nop
sw $16, 4($8)
halt

org 0x0400
cfw 0x7337
cfw 0xdead
cfw 0xbeaf
