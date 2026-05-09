onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group DUT -radix unsigned /system_tb_top/dut/W_Enable
add wave -noupdate -expand -group DUT -radix unsigned /system_tb_top/dut/rst_n
add wave -noupdate -expand -group DUT -radix unsigned /system_tb_top/dut/WR_DATA
add wave -noupdate -expand -group DUT -radix unsigned /system_tb_top/dut/Cin
add wave -noupdate -expand -group DUT -radix unsigned /system_tb_top/dut/W_CLK
add wave -noupdate -expand -group DUT -radix unsigned /system_tb_top/dut/R_CLK
add wave -noupdate -expand -group DUT -radix unsigned /system_tb_top/dut/FULL
add wave -noupdate -expand -group DUT -radix unsigned /system_tb_top/dut/Sum
add wave -noupdate -expand -group DUT /system_tb_top/tb/EMPTY
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 271
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
configure wave -timelineunits ps
update
WaveRestoreZoom {1214212 ps} {1215042 ps}
