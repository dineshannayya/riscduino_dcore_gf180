###############################################################################
# Created by write_sdc
# Wed Nov 10 17:08:57 2021
###############################################################################
current_design sspi_wrapper
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name app_clk -period 20.0000 [get_ports {app_clk}]

set_clock_transition 0.1500 [all_clocks]
set_clock_uncertainty -setup 0.5000 [all_clocks]
set_clock_uncertainty -hold 0.2500 [all_clocks]




#set_dont_touch { u_skew_uart.* }

### ClkSkew Adjust
set_case_analysis 0 [get_ports {cfg_cska_sspi[0]}]
set_case_analysis 0 [get_ports {cfg_cska_sspi[1]}]
set_case_analysis 0 [get_ports {cfg_cska_sspi[2]}]
set_case_analysis 0 [get_ports {cfg_cska_sspi[3]}]


#set_max_delay 5 -from [get_ports {wbd_clk_int}]
#set_max_delay 5 -to   [get_ports {wbd_clk_uart}]
#set_max_delay 5 -from wbd_clk_int -to wbd_clk_uart

#--------------------------
# Register Slave
#--------------------------

set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_slv_addr[*]}]
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_slv_be[*]}]
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_slv_cs}]
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_slv_wdata[*]}]
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_slv_wr}]

set_input_delay  -min 2.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_slv_addr[*]}]
set_input_delay  -min 2.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_slv_be[*]}]
set_input_delay  -min 2.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_slv_cs}]
set_input_delay  -min 2.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_slv_wdata[*]}]
set_input_delay  -min 2.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_slv_wr}]


set_output_delay -max 4.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_slv_ack}]
set_output_delay -max 4.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_slv_rdata[*]}]

set_output_delay -min -1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_slv_ack}]
set_output_delay -min -1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {reg_slv_rdata[*]}]


# Wb Master
set_output_delay  -max 4.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_sspis_cyc_o}]
set_output_delay  -max 4.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_sspis_stb_o}]
set_output_delay  -max 4.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_sspis_adr_o[*]}]
set_output_delay  -max 4.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_sspis_we_o}]
set_output_delay  -max 4.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_sspis_dat_o[*]}]
set_output_delay  -max 4.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_sspis_sel_o[*]}]

set_output_delay  -min -1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_sspis_cyc_o}]
set_output_delay  -min -1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_sspis_stb_o}]
set_output_delay  -min -1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_sspis_adr_o[*]}]
set_output_delay  -min -1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_sspis_we_o}]
set_output_delay  -min -1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_sspis_dat_o[*]}]
set_output_delay  -min -1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_sspis_sel_o[*]}]

set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_sspis_dat_i[*]}]
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_sspis_ack_i}]
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_sspis_err_i}]

set_input_delay  -min 2.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_sspis_dat_i[*]}]
set_input_delay  -min 2.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_sspis_ack_i}]
set_input_delay  -min 2.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_sspis_err_i}]

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
