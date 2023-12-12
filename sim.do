quit -sim
file delete -force work
vlib work

do compile.do

vsim tb -novopt

do  wave.do
