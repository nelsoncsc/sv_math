define_design_lib WORK -path ./design
analyze -format sverilog SQRTLOG.sv
elaborate SQRTLOG
create_clock -period 500 {clock}
compile
write_sdc "SQRTLOG.sdc"
report_timing > "time.rpt"
report_area > "area.rpt"
report_power > "power.rpt"
quit
