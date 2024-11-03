onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /memory_control_tb/CLK
add wave -noupdate /memory_control_tb/nRST
add wave -noupdate -divider ccif
add wave -noupdate -expand /memory_control_tb/ccif/iwait
add wave -noupdate -expand /memory_control_tb/ccif/dwait
add wave -noupdate -expand /memory_control_tb/ccif/iREN
add wave -noupdate -expand /memory_control_tb/ccif/dREN
add wave -noupdate -expand /memory_control_tb/ccif/dWEN
add wave -noupdate /memory_control_tb/ccif/iload
add wave -noupdate /memory_control_tb/ccif/dload
add wave -noupdate /memory_control_tb/ccif/dstore
add wave -noupdate /memory_control_tb/ccif/iaddr
add wave -noupdate /memory_control_tb/ccif/daddr
add wave -noupdate /memory_control_tb/ccif/ramWEN
add wave -noupdate /memory_control_tb/ccif/ramREN
add wave -noupdate /memory_control_tb/ccif/ramstate
add wave -noupdate /memory_control_tb/ccif/ramaddr
add wave -noupdate /memory_control_tb/ccif/ramstore
add wave -noupdate /memory_control_tb/ccif/ramload
add wave -noupdate -divider cif0
add wave -noupdate /memory_control_tb/cif0/iload
add wave -noupdate /memory_control_tb/cif0/iwait
add wave -noupdate /memory_control_tb/cif0/dwait
add wave -noupdate /memory_control_tb/cif0/iREN
add wave -noupdate /memory_control_tb/cif0/dREN
add wave -noupdate /memory_control_tb/cif0/dWEN
add wave -noupdate /memory_control_tb/cif0/dload
add wave -noupdate /memory_control_tb/cif0/dstore
add wave -noupdate /memory_control_tb/cif0/daddr
add wave -noupdate /memory_control_tb/cif0/iaddr
add wave -noupdate -divider memory_control
add wave -noupdate -expand /memory_control_tb/DUT/stat
add wave -noupdate -expand /memory_control_tb/DUT/ccif/dREN
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {37036 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 420
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {14181 ps}
