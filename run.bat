vlog -f files.f
vsim -c -novopt tb -do "run.do"
wlf2vcd vsim.wlf -o vsim.vcd