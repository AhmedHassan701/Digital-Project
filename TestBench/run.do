vlib work
vlog *.v
vsim -voptargs=+acc work.CDC_processing_unit_top_TB
do wave.do
run -all 