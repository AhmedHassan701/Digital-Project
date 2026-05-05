onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /CDC_processing_unit_top_TB/W_CLK_tb
add wave -noupdate /CDC_processing_unit_top_TB/W_Enable_tb
add wave -noupdate /CDC_processing_unit_top_TB/R_CLK_tb
add wave -noupdate /CDC_processing_unit_top_TB/rst_n_tb
add wave -noupdate -radix unsigned /CDC_processing_unit_top_TB/WR_DATA_tb
add wave -noupdate /CDC_processing_unit_top_TB/Cin_tb
add wave -noupdate /CDC_processing_unit_top_TB/FULL_tb
add wave -noupdate -radix unsigned /CDC_processing_unit_top_TB/Sum_tb
add wave -noupdate /CDC_processing_unit_top_TB/i
add wave -noupdate /CDC_processing_unit_top_TB/j
add wave -noupdate -expand -group FSM /CDC_processing_unit_top_TB/DUT/fsm_u/A_operand
add wave -noupdate -expand -group FSM /CDC_processing_unit_top_TB/DUT/fsm_u/B_operand
add wave -noupdate -expand -group FSM /CDC_processing_unit_top_TB/DUT/fsm_u/A_operand_reg
add wave -noupdate -expand -group FSM /CDC_processing_unit_top_TB/DUT/fsm_u/clk
add wave -noupdate -expand -group FSM -color Gold /CDC_processing_unit_top_TB/DUT/fsm_u/current_state
add wave -noupdate -expand -group FSM /CDC_processing_unit_top_TB/DUT/fsm_u/o_read_enable
add wave -noupdate -expand -group FSM -color Cyan /CDC_processing_unit_top_TB/DUT/fsm_u/i_operands
add wave -noupdate -expand -group FSM -color Magenta /CDC_processing_unit_top_TB/DUT/fsm_u/i_empty
add wave -noupdate -expand -group FSM /CDC_processing_unit_top_TB/DUT/fsm_u/IDLE
add wave -noupdate -expand -group FSM /CDC_processing_unit_top_TB/DUT/fsm_u/next_state
add wave -noupdate -expand -group FSM /CDC_processing_unit_top_TB/DUT/fsm_u/READ_A
add wave -noupdate -expand -group FSM /CDC_processing_unit_top_TB/DUT/fsm_u/READ_B
add wave -noupdate -expand -group FSM /CDC_processing_unit_top_TB/DUT/fsm_u/rst_n
add wave -noupdate -group FIFO /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/ADDR_WIDTH
add wave -noupdate -group FIFO /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/DATA_DEPTH
add wave -noupdate -group FIFO /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/DATA_WIDTH
add wave -noupdate -group FIFO /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/EMPTY
add wave -noupdate -group FIFO /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/FULL
add wave -noupdate -group FIFO /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/R_CLK
add wave -noupdate -group FIFO /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/R_Enable
add wave -noupdate -group FIFO /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/RD_addr
add wave -noupdate -group FIFO /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/RD_DATA
add wave -noupdate -group FIFO /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/RD_ptr
add wave -noupdate -group FIFO /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/Rq2_Wptr
add wave -noupdate -group FIFO /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/RST_n
add wave -noupdate -group FIFO /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/W_CLK
add wave -noupdate -group FIFO /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/W_Enable
add wave -noupdate -group FIFO /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/Wq2_Rptr
add wave -noupdate -group FIFO /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/WR_addr
add wave -noupdate -group FIFO /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/WR_DATA
add wave -noupdate -group FIFO /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/WR_ptr
add wave -noupdate -group Adder /CDC_processing_unit_top_TB/DUT/adder_top_u/A
add wave -noupdate -group Adder /CDC_processing_unit_top_TB/DUT/adder_top_u/B
add wave -noupdate -group Adder /CDC_processing_unit_top_TB/DUT/adder_top_u/Cin
add wave -noupdate -group Adder /CDC_processing_unit_top_TB/DUT/adder_top_u/Sum
add wave -noupdate -group MEMOEY /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/FIFO/ADDR_WIDTH
add wave -noupdate -group MEMOEY /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/FIFO/DATA_DEPTH
add wave -noupdate -group MEMOEY /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/FIFO/DATA_WIDTH
add wave -noupdate -group MEMOEY /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/FIFO/FIFO_MEM
add wave -noupdate -group MEMOEY /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/FIFO/i
add wave -noupdate -group MEMOEY /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/FIFO/RD_addr
add wave -noupdate -group MEMOEY /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/FIFO/RD_DATA
add wave -noupdate -group MEMOEY /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/FIFO/RST_n
add wave -noupdate -group MEMOEY /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/FIFO/W_CLK
add wave -noupdate -group MEMOEY /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/FIFO/W_Enable
add wave -noupdate -group MEMOEY /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/FIFO/W_Full
add wave -noupdate -group MEMOEY /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/FIFO/WR_addr
add wave -noupdate -group MEMOEY /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/FIFO/WR_CLK_en
add wave -noupdate -group MEMOEY /CDC_processing_unit_top_TB/DUT/ASYNC_FIFO_u/FIFO/WR_DATA
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {916519 ps} 0}
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1312500 ps}
