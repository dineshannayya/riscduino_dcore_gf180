###############################################################################
# Created by write_sdc
# Wed Nov 10 16:52:52 2021
###############################################################################
current_design wbi_slave_s2
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name mclk -period 20.0000 [get_ports {mclk}]


set_clock_transition 0.1500 [all_clocks]
set_clock_uncertainty -setup 0.5000 [all_clocks]
set_clock_uncertainty -hold 0.2500 [all_clocks]

set ::env(SYNTH_TIMING_DERATE) 0.05
puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 10}] %"
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]


set_output_delay -min -1.0000 -clock [get_clocks {mclk}] -add_delay [all_outputs]
set_output_delay -max 4.0000 -clock [get_clocks {mclk}] -add_delay [all_outputs]

set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [all_inputs]
set_input_delay -max 4.0000 -clock [get_clocks {mclk}] -add_delay [all_inputs]


###############################################################################
# Environment
###############################################################################
set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

set_max_transition 1.00 [current_design]
set_max_capacitance 0.2 [current_design]
set_max_fanout 10 [current_design]

###############################################################################
# Design Rules
###############################################################################

