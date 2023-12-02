###############################################################################
# Created by write_sdc
# Wed Nov 10 17:08:57 2021
###############################################################################
current_design i2c_wrapper
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name app_clk -period 20.0000 [get_ports {app_clk}]

set_clock_transition 0.1500 [all_clocks]
set_clock_uncertainty -setup 0.5000 [all_clocks]
set_clock_uncertainty -hold 0.3000 [all_clocks]


#set_dont_touch { u_skew_i2c.* }

### ClkSkew Adjust
set_case_analysis 0 [get_ports {cfg_cska_i2c[0]}]
set_case_analysis 0 [get_ports {cfg_cska_i2c[1]}]
set_case_analysis 0 [get_ports {cfg_cska_i2c[2]}]
set_case_analysis 0 [get_ports {cfg_cska_i2c[3]}]


#set_max_delay 5 -from [get_ports {wbd_clk_int}]
#set_max_delay 5 -to   [get_ports {wbd_clk_uart}]
#set_max_delay 5 -from wbd_clk_int -to wbd_clk_uart


set_input_delay  -max 4.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_addr[*]}]
set_input_delay  -max 4.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_be[*]}]
set_input_delay  -max 4.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_cs}]
set_input_delay  -max 4.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_wdata[*]}]
set_input_delay  -max 4.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_wr}]

set_input_delay  -min 2.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_addr[*]}]
set_input_delay  -min 2.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_be[*]}]
set_input_delay  -min 2.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_cs}]
set_input_delay  -min 2.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_wdata[*]}]
set_input_delay  -min 2.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_wr}]


set_output_delay -max 4.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_ack}]
set_output_delay -max 4.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_rdata[*]}]

set_output_delay -min -1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_ack}]
set_output_delay -min -1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_rdata[*]}]


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

set ::env(SYNTH_TIMING_DERATE) 0.05
puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 10}] %"
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]

###############################################################################
# Design Rules
###############################################################################
