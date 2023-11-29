###############################################################################
# Created by write_sdc
# Wed Nov 10 17:08:57 2021
###############################################################################
current_design uart_i2c_usb_spi_top
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name app_clk -period 10.0000 [get_ports {app_clk}]
create_clock -name usb_clk -period 100.0000 [get_ports {usb_clk}]

set_clock_transition 0.1500 [all_clocks]
set_clock_uncertainty -setup 0.5000 [all_clocks]
set_clock_uncertainty -hold 0.2500 [all_clocks]



set_clock_groups -name async_clock -asynchronous \
 -group [get_clocks {app_clk}]\
 -group [get_clocks {usb_clk}]\
 -comment {Async Clock group}

#set_dont_touch { u_skew_usb.* }

### ClkSkew Adjust
set_case_analysis 0 [get_ports {cfg_cska_usb[0]}]
set_case_analysis 0 [get_ports {cfg_cska_usb[1]}]
set_case_analysis 0 [get_ports {cfg_cska_usb[2]}]
set_case_analysis 0 [get_ports {cfg_cska_usb[3]}]



set_input_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {usb_rstn}]
set_input_delay -min 1.5000 -clock [get_clocks {app_clk}] -add_delay [get_ports {usb_rstn}]


set_input_delay  -max 5.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_addr[*]}]
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_be[*]}]
set_input_delay  -max 5.7500 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_cs}]
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_wdata[*]}]
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_wr}]

set_input_delay  -min 2.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_addr[*]}]
set_input_delay  -min 2.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_be[*]}]
set_input_delay  -min 2.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_cs}]
set_input_delay  -min 2.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_wdata[*]}]
set_input_delay  -min 2.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_wr}]


set_output_delay -max 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_ack}]
set_output_delay -max 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_rdata[*]}]

set_output_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_ack}]
set_output_delay -min -2.7500 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_rdata[*]}]

set_multicycle_path -setup  -from [get_ports {reg_addr[*]}] -to [get_ports {reg_ack}] 2
set_multicycle_path -setup  -from [get_ports {reg_addr[*]}] -to [get_ports {reg_rdata[*]}] 2

set_multicycle_path -hold  -from [get_ports {reg_addr[*]}] -to [get_ports {reg_ack}] 1
set_multicycle_path -hold  -from [get_ports {reg_addr[*]}] -to [get_ports {reg_rdata[*]}] 1

###############################################################################
# Environment
###############################################################################
set_driving_cell -lib_cell  $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
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
