onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group DUT -radix unsigned /fifo_tb_top/dut/W_CLK
add wave -noupdate -expand -group DUT -radix unsigned /fifo_tb_top/dut/R_CLK
add wave -noupdate -expand -group DUT -radix unsigned /fifo_tb_top/dut/RST_n
add wave -noupdate -expand -group DUT -radix unsigned /fifo_tb_top/dut/W_Enable
add wave -noupdate -expand -group DUT -radix unsigned /fifo_tb_top/dut/R_Enable
add wave -noupdate -expand -group DUT -radix hex      /fifo_tb_top/dut/WR_DATA
add wave -noupdate -expand -group DUT -radix hex      /fifo_tb_top/dut/RD_DATA
add wave -noupdate -expand -group DUT -radix unsigned /fifo_tb_top/dut/FULL
add wave -noupdate -expand -group DUT -radix unsigned /fifo_tb_top/dut/EMPTY
add wave -noupdate -expand -group DUT -radix unsigned /fifo_tb_top/dut/Write_Control/WR_addr
add wave -noupdate -expand -group DUT -radix unsigned /fifo_tb_top/dut/Read_Control/RD_addr
add wave -noupdate -expand -group DUT -radix hex      /fifo_tb_top/dut/Write_Control/WR_ptr
add wave -noupdate -expand -group DUT -radix hex      /fifo_tb_top/dut/Read_Control/RD_ptr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {64001 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {0 ps} {600000 ps}
