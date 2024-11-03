    org 0x000
    ori $1, $0, 0x1234
    ori $2, $0, 0x5678
    ori $5, $0, 0xff0
    jal jump1
    sw  $2, 8($5) 
    halt
jump1:
    sw  $2, 0($5) 
    j jump2 
    halt
    
jump2: 
    sw  $2, 4($5) 
    jr  $31
    halt

    
