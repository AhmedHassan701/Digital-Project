vlib work
vlog *.sv +cover -covercells
vsim -voptargs=+acc work.system_tb_top -cover
coverage save -onexit cov.ucdb
do wave.do
run -all
coverage report -details -output coverage_report.txt