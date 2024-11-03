onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/CLK
add wave -noupdate /system_tb/nRST
add wave -noupdate /system_tb/DUT/CPU/CLK
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
add wave -noupdate -divider dcif0
add wave -noupdate /system_tb/DUT/CPU/DP0/sid/rfid/register
add wave -noupdate /system_tb/DUT/CPU/DP0/memif/memtoReg_out
add wave -noupdate /system_tb/DUT/CPU/CM0/dcif/halt
add wave -noupdate /system_tb/DUT/CPU/CM0/dcif/ihit
add wave -noupdate /system_tb/DUT/CPU/CM0/dcif/imemREN
add wave -noupdate /system_tb/DUT/CPU/CM0/dcif/imemload
add wave -noupdate /system_tb/DUT/CPU/CM0/dcif/imemaddr
add wave -noupdate /system_tb/DUT/CPU/CM0/dcif/dhit
add wave -noupdate /system_tb/DUT/CPU/CM0/dcif/datomic
add wave -noupdate /system_tb/DUT/CPU/CM0/dcif/dmemREN
add wave -noupdate /system_tb/DUT/CPU/CM0/dcif/dmemWEN
add wave -noupdate /system_tb/DUT/CPU/CM0/dcif/flushed
add wave -noupdate /system_tb/DUT/CPU/CM0/dcif/dmemload
add wave -noupdate /system_tb/DUT/CPU/CM0/dcif/dmemstore
add wave -noupdate /system_tb/DUT/CPU/CM0/dcif/dmemaddr
add wave -noupdate -divider dcache0
add wave -noupdate /system_tb/DUT/CPU/DP0/imemload_test
add wave -noupdate /system_tb/DUT/CPU/dcif0/datomic
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/linkreg
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/n_linkreg
add wave -noupdate -expand -subitemconfig {{/system_tb/DUT/CPU/CM0/DCAHCE/entry[1]} -expand {/system_tb/DUT/CPU/CM0/DCAHCE/entry[0]} -expand} /system_tb/DUT/CPU/CM0/DCAHCE/entry
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/n_entry
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/state
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/n_state
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/count
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/count1
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/enable_counter
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/enable_counter1
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/invalidF
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/rollover8
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/prev_roll
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/lru
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/n_mru
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/mru
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/match
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/match_snoop
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/address
add wave -noupdate /system_tb/DUT/CPU/CM0/DCAHCE/position
add wave -noupdate -divider dcif1
add wave -noupdate /system_tb/DUT/CPU/DP1/sid/rfid/register
add wave -noupdate /system_tb/DUT/CPU/dcif1/halt
add wave -noupdate /system_tb/DUT/CPU/dcif1/ihit
add wave -noupdate /system_tb/DUT/CPU/dcif1/imemREN
add wave -noupdate /system_tb/DUT/CPU/dcif1/imemload
add wave -noupdate /system_tb/DUT/CPU/dcif1/imemaddr
add wave -noupdate /system_tb/DUT/CPU/dcif1/dhit
add wave -noupdate /system_tb/DUT/CPU/dcif1/datomic
add wave -noupdate /system_tb/DUT/CPU/dcif1/dmemREN
add wave -noupdate /system_tb/DUT/CPU/dcif1/dmemWEN
add wave -noupdate /system_tb/DUT/CPU/dcif1/flushed
add wave -noupdate /system_tb/DUT/CPU/dcif1/dmemload
add wave -noupdate /system_tb/DUT/CPU/dcif1/dmemstore
add wave -noupdate /system_tb/DUT/CPU/dcif1/dmemaddr
add wave -noupdate -divider dcache1
add wave -noupdate /system_tb/DUT/CPU/DP1/imemload_test
add wave -noupdate /system_tb/DUT/CPU/dcif1/datomic
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/linkreg
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/n_linkreg
add wave -noupdate -expand -subitemconfig {{/system_tb/DUT/CPU/CM1/DCAHCE/entry[1]} -expand {/system_tb/DUT/CPU/CM1/DCAHCE/entry[0]} -expand} /system_tb/DUT/CPU/CM1/DCAHCE/entry
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/n_entry
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/state
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/n_state
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/count
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/count1
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/enable_counter
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/enable_counter1
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/invalidF
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/rollover8
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/prev_roll
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/lru
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/n_mru
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/mru
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/match
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/match_snoop
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/address
add wave -noupdate /system_tb/DUT/CPU/CM1/DCAHCE/position
add wave -noupdate -divider ccif
add wave -noupdate /system_tb/DUT/CPU/CC/state
add wave -noupdate /system_tb/DUT/CPU/CC/n_state
add wave -noupdate /system_tb/DUT/CPU/ccif/iwait
add wave -noupdate /system_tb/DUT/CPU/ccif/dwait
add wave -noupdate -expand /system_tb/DUT/CPU/ccif/iREN
add wave -noupdate /system_tb/DUT/CPU/ccif/dREN
add wave -noupdate /system_tb/DUT/CPU/ccif/dWEN
add wave -noupdate /system_tb/DUT/CPU/ccif/iload
add wave -noupdate /system_tb/DUT/CPU/ccif/dload
add wave -noupdate /system_tb/DUT/CPU/ccif/dstore
add wave -noupdate -expand /system_tb/DUT/CPU/ccif/iaddr
add wave -noupdate /system_tb/DUT/CPU/ccif/daddr
add wave -noupdate -expand /system_tb/DUT/CPU/ccif/ccwait
add wave -noupdate /system_tb/DUT/CPU/ccif/ccinv
add wave -noupdate -expand /system_tb/DUT/CPU/ccif/ccwrite
add wave -noupdate /system_tb/DUT/CPU/ccif/cctrans
add wave -noupdate -expand /system_tb/DUT/CPU/ccif/ccsnoopaddr
add wave -noupdate /system_tb/DUT/CPU/ccif/ramWEN
add wave -noupdate /system_tb/DUT/CPU/ccif/ramREN
add wave -noupdate /system_tb/DUT/CPU/ccif/ramstate
add wave -noupdate /system_tb/DUT/CPU/ccif/ramaddr
add wave -noupdate /system_tb/DUT/CPU/ccif/ramstore
add wave -noupdate /system_tb/DUT/CPU/ccif/ramload
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {134978484 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 220
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
WaveRestoreZoom {133194450 ps} {137005450 ps}
