onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/CLK
add wave -noupdate /system_tb/nRST
add wave -noupdate /system_tb/DUT/CPU/DP/pc/CLK
add wave -noupdate /system_tb/DUT/CPU/DP/pc/nRST
add wave -noupdate -divider {ram signals}
add wave -noupdate /system_tb/DUT/RAM/ramif/ramREN
add wave -noupdate /system_tb/DUT/RAM/ramif/ramWEN
add wave -noupdate /system_tb/DUT/RAM/ramif/ramaddr
add wave -noupdate /system_tb/DUT/RAM/ramif/ramstore
add wave -noupdate /system_tb/DUT/RAM/ramif/ramload
add wave -noupdate /system_tb/DUT/RAM/ramif/ramstate
add wave -noupdate /system_tb/DUT/RAM/ramif/memREN
add wave -noupdate /system_tb/DUT/RAM/ramif/memWEN
add wave -noupdate /system_tb/DUT/RAM/ramif/memaddr
add wave -noupdate /system_tb/DUT/RAM/ramif/memstore
add wave -noupdate -divider dp_cacheControl
add wave -noupdate /system_tb/DUT/CPU/dcif/halt
add wave -noupdate /system_tb/DUT/CPU/dcif/ihit
add wave -noupdate /system_tb/DUT/CPU/dcif/imemREN
add wave -noupdate /system_tb/DUT/CPU/dcif/imemload
add wave -noupdate /system_tb/DUT/CPU/dcif/imemaddr
add wave -noupdate /system_tb/DUT/CPU/dcif/dhit
add wave -noupdate /system_tb/DUT/CPU/dcif/datomic
add wave -noupdate /system_tb/DUT/CPU/dcif/dmemREN
add wave -noupdate /system_tb/DUT/CPU/dcif/dmemWEN
add wave -noupdate /system_tb/DUT/CPU/dcif/flushed
add wave -noupdate /system_tb/DUT/CPU/dcif/dmemload
add wave -noupdate /system_tb/DUT/CPU/dcif/dmemstore
add wave -noupdate /system_tb/DUT/CPU/dcif/dmemaddr
add wave -noupdate /system_tb/DUT/CPU/DP/prev_d
add wave -noupdate /system_tb/DUT/CPU/DP/ndmem
add wave -noupdate /system_tb/DUT/CPU/DP/fordmem
add wave -noupdate -divider alu
add wave -noupdate /system_tb/DUT/CPU/DP/al/aluif/negative
add wave -noupdate /system_tb/DUT/CPU/DP/al/aluif/overflow
add wave -noupdate /system_tb/DUT/CPU/DP/al/aluif/zero
add wave -noupdate /system_tb/DUT/CPU/DP/al/aluif/aluop
add wave -noupdate /system_tb/DUT/CPU/DP/al/aluif/porta
add wave -noupdate /system_tb/DUT/CPU/DP/al/aluif/portb
add wave -noupdate /system_tb/DUT/CPU/DP/al/aluif/outport
add wave -noupdate -divider {control unit}
add wave -noupdate /system_tb/DUT/CPU/DP/conu/cuif/op
add wave -noupdate /system_tb/DUT/CPU/DP/conu/cuif/funcop
add wave -noupdate /system_tb/DUT/CPU/DP/conu/cuif/jal
add wave -noupdate /system_tb/DUT/CPU/DP/conu/cuif/branch
add wave -noupdate /system_tb/DUT/CPU/DP/conu/cuif/jump
add wave -noupdate /system_tb/DUT/CPU/DP/conu/cuif/memRead
add wave -noupdate /system_tb/DUT/CPU/DP/conu/cuif/memtoReg
add wave -noupdate /system_tb/DUT/CPU/DP/conu/cuif/memWrite
add wave -noupdate /system_tb/DUT/CPU/DP/conu/cuif/aluSrc
add wave -noupdate /system_tb/DUT/CPU/DP/conu/cuif/regDst
add wave -noupdate /system_tb/DUT/CPU/DP/conu/cuif/regWrite
add wave -noupdate /system_tb/DUT/CPU/DP/conu/cuif/aluOp
add wave -noupdate /system_tb/DUT/CPU/DP/conu/cuif/extender
add wave -noupdate -divider {register file}
add wave -noupdate /system_tb/DUT/CPU/DP/regf/rfif/WEN
add wave -noupdate /system_tb/DUT/CPU/DP/regf/rfif/wsel
add wave -noupdate /system_tb/DUT/CPU/DP/regf/rfif/rsel1
add wave -noupdate /system_tb/DUT/CPU/DP/regf/rfif/rsel2
add wave -noupdate /system_tb/DUT/CPU/DP/regf/rfif/wdat
add wave -noupdate /system_tb/DUT/CPU/DP/regf/rfif/rdat1
add wave -noupdate /system_tb/DUT/CPU/DP/regf/rfif/rdat2
add wave -noupdate -divider {program counter}
add wave -noupdate /system_tb/DUT/CPU/DP/pc/ihit
add wave -noupdate /system_tb/DUT/CPU/DP/pc/zero
add wave -noupdate /system_tb/DUT/CPU/DP/pc/imme
add wave -noupdate /system_tb/DUT/CPU/DP/pc/data1
add wave -noupdate /system_tb/DUT/CPU/DP/pc/jaddr
add wave -noupdate /system_tb/DUT/CPU/DP/pc/imemaddr
add wave -noupdate /system_tb/DUT/CPU/DP/pc/npc
add wave -noupdate /system_tb/DUT/CPU/DP/pc/branchSel
add wave -noupdate /system_tb/DUT/CPU/DP/pc/s_jaddr
add wave -noupdate /system_tb/DUT/CPU/DP/pc/n_imemaddr
add wave -noupdate /system_tb/DUT/CPU/DP/pc/nextaddr
add wave -noupdate /system_tb/DUT/CPU/DP/pc/j_addr
add wave -noupdate /system_tb/DUT/CPU/DP/pc/b_addr
add wave -noupdate /system_tb/DUT/CPU/DP/pc/s_baddr
add wave -noupdate /system_tb/DUT/CPU/DP/pc/result_b_addr
add wave -noupdate -divider {request unit}
add wave -noupdate /system_tb/DUT/CPU/DP/requ/CLK
add wave -noupdate /system_tb/DUT/CPU/DP/requ/nRST
add wave -noupdate /system_tb/DUT/CPU/DP/requ/n_imemRen
add wave -noupdate /system_tb/DUT/CPU/DP/requ/n_dmemWen
add wave -noupdate /system_tb/DUT/CPU/DP/requ/n_dmemRen
add wave -noupdate /system_tb/DUT/CPU/DP/ruif/op
add wave -noupdate /system_tb/DUT/CPU/DP/ruif/ihit
add wave -noupdate /system_tb/DUT/CPU/DP/ruif/dhit
add wave -noupdate /system_tb/DUT/CPU/DP/ruif/memRead
add wave -noupdate /system_tb/DUT/CPU/DP/ruif/memWrite
add wave -noupdate /system_tb/DUT/CPU/DP/ruif/dmemWen
add wave -noupdate /system_tb/DUT/CPU/DP/ruif/dmemRen
add wave -noupdate /system_tb/DUT/CPU/DP/ruif/imemRen
add wave -noupdate /system_tb/DUT/CPU/DP/ruif/halt
add wave -noupdate -divider {register data}
add wave -noupdate -expand /system_tb/DUT/CPU/DP/regf/register
add wave -noupdate /system_tb/DUT/CPU/DP/regf/nxt_register
add wave -noupdate -divider memc
add wave -noupdate /system_tb/DUT/CPU/ccif/iwait
add wave -noupdate /system_tb/DUT/CPU/ccif/dwait
add wave -noupdate /system_tb/DUT/CPU/ccif/iREN
add wave -noupdate /system_tb/DUT/CPU/ccif/dREN
add wave -noupdate /system_tb/DUT/CPU/ccif/dWEN
add wave -noupdate /system_tb/DUT/CPU/ccif/iload
add wave -noupdate /system_tb/DUT/CPU/ccif/dload
add wave -noupdate /system_tb/DUT/CPU/ccif/dstore
add wave -noupdate /system_tb/DUT/CPU/ccif/iaddr
add wave -noupdate /system_tb/DUT/CPU/ccif/daddr
add wave -noupdate /system_tb/DUT/CPU/ccif/ccwait
add wave -noupdate /system_tb/DUT/CPU/ccif/ccinv
add wave -noupdate /system_tb/DUT/CPU/ccif/ccwrite
add wave -noupdate /system_tb/DUT/CPU/ccif/cctrans
add wave -noupdate /system_tb/DUT/CPU/ccif/ccsnoopaddr
add wave -noupdate /system_tb/DUT/CPU/ccif/ramWEN
add wave -noupdate /system_tb/DUT/CPU/ccif/ramREN
add wave -noupdate /system_tb/DUT/CPU/ccif/ramstate
add wave -noupdate /system_tb/DUT/CPU/ccif/ramaddr
add wave -noupdate /system_tb/DUT/CPU/ccif/ramstore
add wave -noupdate /system_tb/DUT/CPU/ccif/ramload
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {233842 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 80
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {616834 ps}
