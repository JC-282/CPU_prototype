onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /icache_tb/CLK
add wave -noupdate /icache_tb/nRST
add wave -noupdate -divider cifi
add wave -noupdate /icache_tb/DUT/cifi/iwait
add wave -noupdate /icache_tb/DUT/cifi/iREN
add wave -noupdate /icache_tb/DUT/cifi/iload
add wave -noupdate /icache_tb/DUT/cifi/iaddr
add wave -noupdate -divider dcifi
add wave -noupdate /icache_tb/DUT/dcifi/ihit
add wave -noupdate /icache_tb/DUT/dcifi/imemREN
add wave -noupdate /icache_tb/DUT/dcifi/imemload
add wave -noupdate /icache_tb/DUT/dcifi/imemaddr
add wave -noupdate -divider icache
add wave -noupdate /icache_tb/DUT/tag_match
add wave -noupdate /icache_tb/DUT/data_out
add wave -noupdate /icache_tb/DUT/address
add wave -noupdate /icache_tb/DUT/validLoc
add wave -noupdate /icache_tb/DUT/state
add wave -noupdate /icache_tb/DUT/n_state
add wave -noupdate -expand /icache_tb/DUT/entry
add wave -noupdate /icache_tb/DUT/n_entry
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3 ns} 0}
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
WaveRestoreZoom {0 ns} {58 ns}
