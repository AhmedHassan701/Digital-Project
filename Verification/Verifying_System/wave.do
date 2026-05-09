onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group TB -radix unsigned /system_tb_top/tb/current_state
add wave -noupdate -expand -group TB -radix unsigned /system_tb_top/tb/next_state
add wave -noupdate -expand -group TB -radix unsigned /system_tb_top/tb/NUM_TRANSACTIONS
add wave -noupdate -expand -group TB -radix unsigned /system_tb_top/tb/pkt
add wave -noupdate -expand -group TB -radix unsigned /system_tb_top/tb/pkt_id
add wave -noupdate -expand -group TB -radix unsigned /system_tb_top/tb/num_passes
add wave -noupdate -expand -group TB -radix unsigned /system_tb_top/tb/num_failures
add wave -noupdate /system_tb_top/tb/failed
add wave -noupdate -expand -group DUT -radix unsigned /system_tb_top/dut/W_Enable
add wave -noupdate -expand -group DUT -radix unsigned /system_tb_top/dut/rst_n
add wave -noupdate -expand -group DUT -radix unsigned /system_tb_top/dut/WR_DATA
add wave -noupdate -expand -group DUT -radix unsigned /system_tb_top/dut/Cin
add wave -noupdate -expand -group DUT -radix unsigned /system_tb_top/dut/W_CLK
add wave -noupdate -expand -group DUT -radix unsigned /system_tb_top/dut/R_CLK
add wave -noupdate -expand -group DUT -radix unsigned /system_tb_top/dut/FULL
add wave -noupdate -expand -group DUT -radix unsigned /system_tb_top/dut/Sum
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
WaveRestoreZoom {4964212 ps} {4965042 ps}
