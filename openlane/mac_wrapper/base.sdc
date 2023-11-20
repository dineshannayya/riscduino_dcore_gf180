###############################################################################
# Created by write_sdc
# Thu Dec 22 09:17:52 2022
###############################################################################
current_design mac_wrapper
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name  app_clk -period 10.0000 [get_ports {app_clk}]
create_clock -name  phy_tx_clk -period 40.0000 [get_ports {phy_tx_clk}]
create_clock -name  phy_rx_clk -period 40.0000 [get_ports {phy_rx_clk}]
create_clock -name  mdio_clk -period 100.0000 [get_ports {mdio_clk}]

set_clock_transition 0.1500 [all_clocks]
set_clock_uncertainty -setup 0.5000 [all_clocks]
set_clock_uncertainty -hold 0.2500 [all_clocks]
set_propagated_clock [all_clocks]


set ::env(SYNTH_TIMING_DERATE) 0.05
puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 10}] %"
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]

set_clock_groups -name async_clock -asynchronous \
 -group [get_clocks {app_clk}]      \
 -group [get_clocks {phy_tx_clk}]     \
 -group [get_clocks {phy_rx_clk}]     \
 -group [get_clocks {mdio_clk}] \
 -comment {Async Clock group}

### ClkSkew Adjust
set_case_analysis 0 [get_ports {cfg_cska_mac[0]}]
set_case_analysis 0 [get_ports {cfg_cska_mac[1]}]
set_case_analysis 0 [get_ports {cfg_cska_mac[2]}]
set_case_analysis 0 [get_ports {cfg_cska_mac[3]}]

# Set max delay for clock skew
set_max_delay   3.5 -from [get_ports {wbd_clk_int}]
set_max_delay   2 -to   [get_ports {wbd_clk_skew}]
set_max_delay 3.5 -from wbd_clk_int -to wbd_clk_skew


set_false_path -from [get_ports {reset_n}]

########################################
# mdio Clock Domain
########################################
set_input_delay  -max 6.0000  -clock [get_clocks {mdio_clk}] -add_delay [get_ports {mdio_in}]
set_input_delay  -min -2.0000  -clock [get_clocks {mdio_clk}] -add_delay [get_ports {mdio_in}]


set_output_delay -max 6.0000 -clock [get_clocks {mdio_clk}] -add_delay [get_ports {mdio_out}]
set_output_delay -max 6.0000 -clock [get_clocks {mdio_clk}] -add_delay [get_ports {mdio_out_en}]
set_output_delay -min -2.0000 -clock [get_clocks {mdio_clk}] -add_delay [get_ports {mdio_out}]
set_output_delay -min -2.0000 -clock [get_clocks {mdio_clk}] -add_delay [get_ports {mdio_out_en}]

########################################
# phy_rx_clk Clock Domain
########################################
set_input_delay -max 20.0000 -clock [get_clocks {phy_rx_clk}] -add_delay [get_ports {phy_crs}]
set_input_delay -max 20.0000 -clock [get_clocks {phy_rx_clk}] -add_delay [get_ports {phy_rx_dv}]
set_input_delay -max 20.0000 -clock [get_clocks {phy_rx_clk}] -add_delay [get_ports {phy_rx_er}]
set_input_delay -max 20.0000 -clock [get_clocks {phy_rx_clk}] -add_delay [get_ports {phy_rxd[*]}]

set_input_delay -min -2.0000 -clock [get_clocks {phy_rx_clk}] -add_delay [get_ports {phy_crs}]
set_input_delay -min -2.0000 -clock [get_clocks {phy_rx_clk}] -add_delay [get_ports {phy_rx_dv}]
set_input_delay -min -2.0000 -clock [get_clocks {phy_rx_clk}] -add_delay [get_ports {phy_rx_er}]
set_input_delay -min -2.0000 -clock [get_clocks {phy_rx_clk}] -add_delay [get_ports {phy_rxd[*]}]


########################################
# phy_tx_clk Clock Domain
########################################

set_output_delay -max 20.0000 -clock [get_clocks {phy_tx_clk}] -add_delay [get_ports {phy_tx_en}]
set_output_delay -max 20.0000 -clock [get_clocks {phy_tx_clk}] -add_delay [get_ports {phy_tx_er}]
set_output_delay -max 20.0000 -clock [get_clocks {phy_tx_clk}] -add_delay [get_ports {phy_txd[*]}]

set_output_delay -min -2.0000 -clock [get_clocks {phy_tx_clk}] -add_delay [get_ports {phy_tx_en}]
set_output_delay -min -2.0000 -clock [get_clocks {phy_tx_clk}] -add_delay [get_ports {phy_tx_er}]
set_output_delay -min -2.0000 -clock [get_clocks {phy_tx_clk}] -add_delay [get_ports {phy_txd[*]}]

########################################
# APP Clock Domain
########################################
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_grx_ack_i}]
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_grx_dat_i[*]}]
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_gtx_ack_i}]
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_gtx_dat_i[*]}]
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbs_grg_adr_i[*]}]
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbs_grg_cyc_i}]
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbs_grg_dat_i[*]}]
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbs_grg_sel_i[*]}]
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbs_grg_stb_i}]
set_input_delay  -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbs_grg_we_i}]

set_input_delay  -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_grx_ack_i}]
set_input_delay  -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_grx_dat_i[*]}]
set_input_delay  -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_gtx_ack_i}]
set_input_delay  -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_gtx_dat_i[*]}]
set_input_delay  -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbs_grg_adr_i[*]}]
set_input_delay  -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbs_grg_cyc_i}]
set_input_delay  -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbs_grg_dat_i[*]}]
set_input_delay  -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbs_grg_sel_i[*]}]
set_input_delay  -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbs_grg_stb_i}]
set_input_delay  -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbs_grg_we_i}]

set_output_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_grx_adr_o[*]}]
set_output_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_grx_cyc_o}]
set_output_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_grx_dat_o[*]}]
set_output_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_grx_sel_o[*]}]
set_output_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_grx_stb_o}]
set_output_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_grx_we_o}]
set_output_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_gtx_adr_o[*]}]
set_output_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_gtx_cyc_o}]
set_output_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_gtx_sel_o[*]}]
set_output_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_gtx_stb_o}]
set_output_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_gtx_we_o}]
set_output_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbs_grg_ack_o}]
set_output_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbs_grg_dat_o[*]}]

set_output_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_grx_adr_o[*]}]
set_output_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_grx_cyc_o}]
set_output_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_grx_dat_o[*]}]
set_output_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_grx_sel_o[*]}]
set_output_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_grx_stb_o}]
set_output_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_grx_we_o}]
set_output_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_gtx_adr_o[*]}]
set_output_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_gtx_cyc_o}]
set_output_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_gtx_sel_o[*]}]
set_output_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_gtx_stb_o}]
set_output_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbm_gtx_we_o}]
set_output_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbs_grg_ack_o}]
set_output_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {wbs_grg_dat_o[*]}]

set_output_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {cfg_rx_qbase_addr[*]}]
set_output_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {cfg_tx_qbase_addr[*]}]

set_output_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {cfg_rx_qbase_addr[*]}]
set_output_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {cfg_tx_qbase_addr[*]}]

set_input_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {mac_rx_qcnt_dec}]
set_input_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {mac_rx_qcnt_inc}]
set_input_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {mac_tx_qcnt_dec}]
set_input_delay -max 6.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {mac_tx_qcnt_inc}]

set_input_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {mac_rx_qcnt_dec}]
set_input_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {mac_rx_qcnt_inc}]
set_input_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {mac_tx_qcnt_dec}]
set_input_delay -min 1.0000 -clock [get_clocks {app_clk}] -add_delay [get_ports {mac_tx_qcnt_inc}]

###############################################################################
# Environment
###############################################################################
set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

###############################################################################
# Design Rules
###############################################################################
set_max_transition 1.00 [current_design]
set_max_capacitance 0.2 [current_design]
set_max_fanout 10 [current_design]
