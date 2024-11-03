    org 0x000
    ori $29, $0, 0xfffc
    ori $1, $0, 0x1234
    ori $2, $0, 0x5678
    ori $5, $0, 0xff0
    sw  $1, 0($5)
    halt
    sw  $2, 4($5)
    
