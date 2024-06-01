vcom -2008 echo_counter.vhdl HC_SR04.vhdl hcdriver-Man-Nar-tb.vhdl hcdriver-Man-Nar.vhdl trig_gen.vhdl

vsim hcdriver_tb -voptargs=+acc -fsmdebug -t ps
add wave *
run -all
wave zoom full

