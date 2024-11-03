
#----------------------------------------------------------
# First Processor
#----------------------------------------------------------
  org   0x0000              # first processor p0
  ori   $sp, $zero, 0x3ffc  # stack may need change!!!!!!!!!!!!!!!!
  jal   mainp0              # go to program
  halt

# pass in an address to lock function in argument register 0
# returns when lock is available
lock:
aquire:
  ll    $t0, 0($a0)         # load lock location
  bne   $t0, $0, aquire     # wait on lock to be open
  addiu $t0, $t0, 1
  sc    $t0, 0($a0)
  beq   $t0, $0, lock       # if sc failed retry
  jr    $ra


# pass in an address to unlock function in argument register 0
# returns when lock is free
unlock:
  sw    $0, 0($a0)
  jr    $ra

# main function does something ugly but demonstrates beautifully
mainp0:
  push  $ra                 # save return address
  ori $k0, $0, 0
loop1:
  ori $k1, $0, 256
  beq $k0, $k1, endloop1
  ori   $a0, $zero, lockaddr      # move lock to arguement register
  jal   lock                # try to aquire the lock
  # generate random crc
  ##################load the previous crc value
  ori $t0,$0,crc
  lw $a0, 0($t0)
  jal crc32
  ##################store the current crc
  ori $t0,$0,crc
  sw $v0, 0($t0)
  ##################push to buffer
  or $a0, $0, $v0
  jal write
  # critical code segment
  ori   $a0, $zero, lockaddr      # move lock to arguement register
  jal   unlock              # release the lock
  addi $k0, $k0, 1
  j loop1
endloop1:

  pop   $ra                 # get return address
  push  $0
  pop   $0
  jr    $ra                 # return to caller

# USAGE random0 = crc(seed), random1 = crc(random0)
#       randomN = crc(randomN-1)
#------------------------------------------------------
# $v0 = crc32($a0)
crc32:
  lui $t1, 0x04C1
  ori $t1, $t1, 0x1DB7
  or $t2, $0, $0
  ori $t3, $0, 32

l1:
  slt $t4, $t2, $t3
  beq $t4, $zero, l2

  ori $t5, $0, 31
  srlv $t4, $t5, $a0
  ori $t5, $0, 1
  sllv $a0, $t5, $a0
  beq $t4, $0, l3
  xor $a0, $a0, $t1
l3:
  addiu $t2, $t2, 1
  j l1
l2:
  or $v0, $a0, $0
  jr $ra
#------------------------------------------------------
#------------------------------------------------------
#write the data to common stack
write:
  ori $t0, $0, head
  lw $t1, 0($t0)
  #update pointer
  addi $t1, $t1, -4
  sw $t1, 0($t0)
  add $t2, $t1, $t0
  sw $a0, 0($t2)
  jr $ra
#------------------------------------------------------
lockaddr:
  cfw 0x0
crc:
  cfw 0x578d578c


#----------------------------------------------------------
# Second Processor
#----------------------------------------------------------
  org   0x200               # second processor p1
  ori   $sp, $zero, 0x7ffc  # stack
  jal   mainp1              # go to program
  halt

# main function does something ugly but demonstrates beautifully
mainp1:
  push  $ra                 # save return address
  ori $k0, $0, 0
loop2:
  ori $k1, $0, 256
  beq $k0, $k1, endloop2
consume:
  ori   $a0, $zero, lockaddr      # move lock to arguement register
  jal   lock                # try to aquire the lock
  #read data
  jal read

  # critical code segment
  ori   $a0, $zero, lockaddr      # move lock to arguement register
  jal   unlock              # release the lock

  beq $v1, $0, consume
  ################musk the v0
  ori $t6, $0, 0xffff
  and $v0,$v0,$t6
  ################calculate sum
  ori $t0, $0, sum
  lw $t1, 0($t0)
  add $t1,$t1,$v0
  sw $t1, 0($t0)
  ################calculate min
  ori $t0, $0, min_val
  lw $a0, 0($t0)
  or $a1, $0, $v0
  push $v0
  jal min
  ori $t0, $0, min_val
  sw $v0, 0($t0)
  ################calculate max
  pop $a0
  push $0
  pop  $0
  ori $t0, $0, max_val
  lw $a1, 0($t0)
  jal max
  ori $t0, $0, max_val
  sw $v0, 0($t0)
  addiu $k0, $k0, 1
  j loop2

endloop2:
  #############calculate avg
  ori $t0, $0, sum
  lw $t1, 0($t0)
  ori $t2, $0, 8
  srlv $t3,$t2,$t1
  ori $t0, $0, avg
  sw $t3, 0($t0)

  pop   $ra                 # get return address
  push $0
  pop  $0
  jr    $ra                 # return to caller
##read from common stack
read:
  ori $t0, $0, head
  lw $t1, 0($t0)
  bne $t1, $0, read_s
  ori $v1, $0, 0
  jr $ra
read_s:
  add $t2, $t1, $t0
  lw $v0, 0($t2)
  ori $v1, $0, 1
  sw $0, 0($t2)
  #update pointer
  addi $t1, $t1, 4
  sw $t1, 0($t0)
  jr $ra
########################
#-max (a0=a,a1=b) returns v0=max(a,b)--------------
max:
  push  $ra
  push  $a0
  push  $a1
  or    $v0, $0, $a0
  slt   $t0, $a0, $a1
  beq   $t0, $0, maxrtn
  or    $v0, $0, $a1
maxrtn:
  pop   $a1
  push $0
  pop  $0
  pop   $a0
  push $0
  pop  $0
  pop   $ra
  push $0
  pop  $0
  jr    $ra
#--------------------------------------------------

#-min (a0=a,a1=b) returns v0=min(a,b)--------------
min:
  push  $ra
  push  $a0
  push  $a1
  or    $v0, $0, $a0
  slt   $t0, $a1, $a0
  beq   $t0, $0, minrtn
  or    $v0, $0, $a1
minrtn:
  pop   $a1
  push $0
  pop  $0
  pop   $a0
  push $0
  pop  $0
  pop   $ra
  push $0
  pop  $0
  jr    $ra
#--------------------------------------------------

#-divide(N=$a0,D=$a1) returns (Q=$v0,R=$v1)--------
divide:               # setup frame
  push  $ra           # saved return address
  push  $a0           # saved register
  push  $a1           # saved register
  or    $v0, $0, $0   # Quotient v0=0
  or    $v1, $0, $a0  # Remainder t2=N=a0
  beq   $0, $a1, divrtn # test zero D
  slt   $t0, $a1, $0  # test neg D
  bne   $t0, $0, divdneg
  slt   $t0, $a0, $0  # test neg N
  bne   $t0, $0, divnneg
divloop:
  slt   $t0, $v1, $a1 # while R >= D
  bne   $t0, $0, divrtn
  addiu $v0, $v0, 1   # Q = Q + 1
  subu  $v1, $v1, $a1 # R = R - D
  j     divloop
divnneg:
  subu  $a0, $0, $a0  # negate N
  jal   divide        # call divide
  subu  $v0, $0, $v0  # negate Q
  beq   $v1, $0, divrtn
  addiu $v0, $v0, -1  # return -Q-1
  j     divrtn
divdneg:
  subu  $a0, $0, $a1  # negate D
  jal   divide        # call divide
  subu  $v0, $0, $v0  # negate Q
divrtn:
  pop $a1
  push $0
  pop  $0
  pop $a0
  push $0
  pop  $0
  pop $ra
  push $0
  pop  $0
  jr  $ra
#-divide--------------------------------------------
##cmmon stack space
org 0xffe0
head:
  cfw 0x0
sum:
  cfw 0x0
min_val:
  cfw 0x7fff
max_val:
  cfw 0x8001
avg:
  cfw 0x0
test:
    cfw 0x0
###################
