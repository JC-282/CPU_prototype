onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dcache_tb/CLK
add wave -noupdate /dcache_tb/nRST
add wave -noupdate /dcache_tb/PROG/test_tag
add wave -noupdate -divider cifd
add wave -noupdate /dcache_tb/DUT/cifd/dwait
add wave -noupdate /dcache_tb/DUT/cifd/dREN
add wave -noupdate /dcache_tb/DUT/cifd/dWEN
add wave -noupdate /dcache_tb/DUT/cifd/dload
add wave -noupdate /dcache_tb/DUT/cifd/dstore
add wave -noupdate /dcache_tb/DUT/cifd/daddr
add wave -noupdate -divider dcifd
add wave -noupdate /dcache_tb/dcif/dhit
add wave -noupdate /dcache_tb/dcif/dmemREN
add wave -noupdate /dcache_tb/dcif/dmemWEN
add wave -noupdate /dcache_tb/dcif/flushed
add wave -noupdate /dcache_tb/dcif/dmemload
add wave -noupdate /dcache_tb/dcif/dmemstore
add wave -noupdate /dcache_tb/dcif/dmemaddr
add wave -noupdate /dcache_tb/dcif/halt
add wave -noupdate -divider dcache
add wave -noupdate /dcache_tb/DUT/entry
add wave -noupdate /dcache_tb/DUT/n_entry
add wave -noupdate /dcache_tb/DUT/state
add wave -noupdate /dcache_tb/DUT/n_state
add wave -noupdate /dcache_tb/DUT/count
add wave -noupdate /dcache_tb/DUT/count1
add wave -noupdate /dcache_tb/DUT/enable_counter
add wave -noupdate /dcache_tb/DUT/enable_counter1
add wave -noupdate /dcache_tb/DUT/invalidF
add wave -noupdate /dcache_tb/DUT/rollover8
add wave -noupdate /dcache_tb/DUT/lru
add wave -noupdate /dcache_tb/DUT/n_mru
add wave -noupdate /dcache_tb/DUT/mru
add wave -noupdate /dcache_tb/DUT/match
add wave -noupdate /dcache_tb/DUT/address
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1934 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {1205 ns} {2205 ns}
