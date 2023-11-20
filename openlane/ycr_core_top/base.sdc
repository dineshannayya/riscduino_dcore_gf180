###############################################################################
# Timing Constraints
###############################################################################
create_clock -name core_clk -period 10.0000 [get_ports {clk}]
create_clock -name tap_clk -period 100.0000 [get_ports {tapc_tck}]

set_clock_transition 0.1500 [all_clocks]
set_clock_uncertainty -setup 0.5000 [all_clocks]
set_clock_uncertainty -hold  0.3000 [all_clocks]

set ::env(SYNTH_TIMING_DERATE) 0.05
puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 10}] %"
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]

#set_dont_touch { u_skew_core_clk.* }


set_clock_groups -name async_clock -asynchronous \
 -group [get_clocks {core_clk}]      \
 -group [get_clocks {tap_clk}]     \
 -comment {Async Clock group}


#IMEM Constraints
set_output_delay -max 4.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2imem_cmd_o}]
set_output_delay -max 4.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2imem_req_o}]
set_output_delay -max 4.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2imem_addr_o[*]}]
set_output_delay -max 4.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2imem_bl_o[*]}]

set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2imem_cmd_o}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2imem_req_o}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2imem_addr_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2imem_bl_o[*]}]

set_input_delay -max 4.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {imem2core_req_ack_i}]
set_input_delay -max 4.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {imem2core_rdata_i[*]}]
set_input_delay -max 4.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {imem2core_resp_i[*]}]

set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {imem2core_req_ack_i}]
set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {imem2core_rdata_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {imem2core_resp_i[*]}]

#DMEM Constraints
set_output_delay -max 4.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_cmd_o}]
set_output_delay -max 4.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_req_o}]
set_output_delay -max 4.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_addr_o[*]}]
set_output_delay -max 4.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_wdata_o[*]}]
set_output_delay -max 4.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_width_o[*]}]

set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_cmd_o}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_req_o}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_addr_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_wdata_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_width_o[*]}]

set_input_delay -max 4.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {dmem2core_req_ack_i}]
set_input_delay -max 4.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {dmem2core_rdata_i[*]}]
set_input_delay -max 4.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {dmem2core_resp_i[*]}]

set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {dmem2core_req_ack_i}]
set_input_delay -min 2.5000 -clock [get_clocks {core_clk}] -add_delay [get_ports {dmem2core_rdata_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {dmem2core_resp_i[*]}]

###############################################################################
# Environment
###############################################################################
set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"

###############################################################################
# Design Rules
###############################################################################
set_max_transition 1.00 [current_design]
set_max_capacitance 0.2 [current_design]
set_max_fanout 10 [current_design]
