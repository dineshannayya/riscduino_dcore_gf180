###############################################################################
# Created by write_sdc
# Thu Nov 11 07:50:51 2021
###############################################################################
current_design user_project_wrapper
###############################################################################
# Timing Constraints
###############################################################################
set ::env(SYNTH_TIMING_DERATE) 0.05
set ::env(SYNTH_CLOCK_SETUP_UNCERTAINITY) 0.50
set ::env(SYNTH_CLOCK_HOLD_UNCERTAINITY) 0.25
set ::env(SYNTH_CLOCK_TRANSITION) 0.15

create_clock -name user_clock2 -period 100.0000 [get_ports {user_clock2}]
create_clock -name wbm_clk_i -period 10.0000 [get_ports {wb_clk_i}]

create_clock -name wbs_clk_i -period 10.0000  [get_pins {u_wb_host/wbs_clk_out}]
create_clock -name cpu_clk -period 20.0000    [get_pins {u_wb_host/cpu_clk}]
create_clock -name rtc_clk -period 50.0000    [get_pins {u_pinmux/rtc_clk}]
create_clock -name usb_clk -period 20.0000    [get_pins {u_pinmux/usb_clk}]
create_clock -name uart0_clk -period 100.0000  [get_pins {u_uart_wrapper/u_uart0_core.u_lineclk_buf.genblk1.u_mux/Z}]
create_clock -name uart1_clk -period 100.0000  [get_pins {u_uart_wrapper/u_uart1_core.u_lineclk_buf.genblk1.u_mux/Z}]
create_clock -name uart2_clk -period 100.0000  [get_pins {u_uart_wrapper/u_uart2_core.u_core.u_uart_clk.genblk1.u_mux/Z}]

set_propagated_clock [all_clocks]
puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 10}] %"
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]

puts "\[INFO\]: Setting clock setup uncertainity to: $::env(SYNTH_CLOCK_SETUP_UNCERTAINITY)"
puts "\[INFO\]: Setting clock hold uncertainity to: $::env(SYNTH_CLOCK_HOLD_UNCERTAINITY)"
set_clock_uncertainty -setup $::env(SYNTH_CLOCK_SETUP_UNCERTAINITY) [all_clocks]
set_clock_uncertainty -hold $::env(SYNTH_CLOCK_HOLD_UNCERTAINITY) [all_clocks]


set_clock_groups -name async_clock -asynchronous \
 -group [get_clocks {cpu_clk}]\
 -group [get_clocks {uart0_clk}]\
 -group [get_clocks {uart1_clk}]\
 -group [get_clocks {uart2_clk}]\
 -group [get_clocks {usb_clk}]\
 -group [get_clocks {rtc_clk}]\
 -group [get_clocks {user_clock2}]\
 -group [get_clocks {wbm_clk_i}]\
 -group [get_clocks {wbs_clk_i}] -comment {Async Clock group}

#################################################################
## User Case analysis
#################################################################

set_case_analysis 0 [get_pins {u_qspi_master/cfg_cska_sp_co[3]}]
set_case_analysis 0 [get_pins {u_qspi_master/cfg_cska_sp_co[2]}]
set_case_analysis 0 [get_pins {u_qspi_master/cfg_cska_sp_co[1]}]
set_case_analysis 0 [get_pins {u_qspi_master/cfg_cska_sp_co[0]}]

set_case_analysis 0 [get_pins {u_pinmux/cfg_cska_pinmux[3]}]
set_case_analysis 0 [get_pins {u_pinmux/cfg_cska_pinmux[2]}]
set_case_analysis 0 [get_pins {u_pinmux/cfg_cska_pinmux[1]}]
set_case_analysis 0 [get_pins {u_pinmux/cfg_cska_pinmux[0]}]

set_case_analysis 0 [get_pins {u_uart_wrapper/cfg_cska_uart[3]}]
set_case_analysis 0 [get_pins {u_uart_wrapper/cfg_cska_uart[2]}]
set_case_analysis 0 [get_pins {u_uart_wrapper/cfg_cska_uart[1]}]
set_case_analysis 0 [get_pins {u_uart_wrapper/cfg_cska_uart[0]}]

set_case_analysis 0 [get_pins {u_qspi_master/cfg_cska_spi[3]}]
set_case_analysis 0 [get_pins {u_qspi_master/cfg_cska_spi[2]}]
set_case_analysis 0 [get_pins {u_qspi_master/cfg_cska_spi[1]}]
set_case_analysis 0 [get_pins {u_qspi_master/cfg_cska_spi[0]}]

set_case_analysis 0 [get_pins {u_riscv_top.u_connect/cfg_wcska[3]}]
set_case_analysis 0 [get_pins {u_riscv_top.u_connect/cfg_wcska[2]}]
set_case_analysis 0 [get_pins {u_riscv_top.u_connect/cfg_wcska[1]}]
set_case_analysis 0 [get_pins {u_riscv_top.u_connect/cfg_wcska[0]}]

set_case_analysis 0 [get_pins {u_wb_host/cfg_cska_wh[3]}]
set_case_analysis 0 [get_pins {u_wb_host/cfg_cska_wh[2]}]
set_case_analysis 0 [get_pins {u_wb_host/cfg_cska_wh[1]}]
set_case_analysis 0 [get_pins {u_wb_host/cfg_cska_wh[0]}]

set_case_analysis 0 [get_pins {u_per_wrap0/cfg_cska_peri[3]}]
set_case_analysis 0 [get_pins {u_per_wrap0/cfg_cska_peri[2]}]
set_case_analysis 0 [get_pins {u_per_wrap0/cfg_cska_peri[1]}]
set_case_analysis 0 [get_pins {u_per_wrap0/cfg_cska_peri[0]}]

set_case_analysis 0 [get_pins {u_usb_wrap/cfg_cska_usb[3]}]
set_case_analysis 0 [get_pins {u_usb_wrap/cfg_cska_usb[2]}]
set_case_analysis 0 [get_pins {u_usb_wrap/cfg_cska_usb[1]}]
set_case_analysis 0 [get_pins {u_usb_wrap/cfg_cska_usb[0]}]

set_case_analysis 0 [get_pins {u_sspi_wrap/cfg_cska_sspi[3]}]
set_case_analysis 0 [get_pins {u_sspi_wrap/cfg_cska_sspi[2]}]
set_case_analysis 0 [get_pins {u_sspi_wrap/cfg_cska_sspi[1]}]
set_case_analysis 0 [get_pins {u_sspi_wrap/cfg_cska_sspi[0]}]


# clock skew cntrl-2
set_case_analysis 0 [get_pins {u_riscv_top.u_connect/cfg_ccska[3]}]
set_case_analysis 0 [get_pins {u_riscv_top.u_connect/cfg_ccska[2]}]
set_case_analysis 0 [get_pins {u_riscv_top.u_connect/cfg_ccska[1]}]
set_case_analysis 0 [get_pins {u_riscv_top.u_connect/cfg_ccska[0]}]

set_case_analysis 0 [get_pins {u_riscv_top.i_core_top_0/cfg_ccska[3]}]
set_case_analysis 0 [get_pins {u_riscv_top.i_core_top_0/cfg_ccska[2]}]
set_case_analysis 0 [get_pins {u_riscv_top.i_core_top_0/cfg_ccska[1]}]
set_case_analysis 0 [get_pins {u_riscv_top.i_core_top_0/cfg_ccska[0]}]


#Clock Control
set_case_analysis 0 [get_pins -of_objects [get_nets {u_wb_host/u_reg.cfg_clk_ctrl[0]}]]
set_case_analysis 0 [get_pins -of_objects [get_nets {u_wb_host/u_reg.cfg_clk_ctrl[1]}]]
set_case_analysis 0 [get_pins -of_objects [get_nets {u_wb_host/u_reg.cfg_clk_ctrl[2]}]]
set_case_analysis 0 [get_pins -of_objects [get_nets {u_wb_host/u_reg.cfg_clk_ctrl[3]}]]
set_case_analysis 0 [get_pins -of_objects [get_nets {u_wb_host/u_reg.cfg_clk_ctrl[4]}]]
set_case_analysis 0 [get_pins -of_objects [get_nets {u_wb_host/u_reg.cfg_clk_ctrl[5]}]]
set_case_analysis 0 [get_pins -of_objects [get_nets {u_wb_host/u_reg.cfg_clk_ctrl[6]}]]
set_case_analysis 0 [get_pins -of_objects [get_nets {u_wb_host/u_reg.cfg_clk_ctrl[7]}]]




set_input_delay 2.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wb_rst_i}]

set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[0]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[10]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[11]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[12]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[13]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[14]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[15]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[16]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[17]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[18]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[19]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[1]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[20]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[21]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[22]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[23]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[24]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[25]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[26]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[27]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[28]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[29]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[2]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[30]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[31]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[3]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[4]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[5]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[6]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[7]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[8]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[9]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_cyc_i}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[0]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[10]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[11]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[12]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[13]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[14]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[15]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[16]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[17]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[18]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[19]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[1]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[20]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[21]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[22]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[23]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[24]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[25]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[26]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[27]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[28]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[29]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[2]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[30]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[31]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[3]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[4]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[5]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[6]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[7]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[8]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[9]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_sel_i[0]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_sel_i[1]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_sel_i[2]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_sel_i[3]}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_stb_i}]
set_input_delay -max 5.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_we_i}]

set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[0]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[10]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[11]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[12]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[13]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[14]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[15]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[16]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[17]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[18]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[19]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[1]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[20]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[21]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[22]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[23]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[24]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[25]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[26]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[27]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[28]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[29]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[2]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[30]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[31]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[3]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[4]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[5]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[6]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[7]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[8]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_adr_i[9]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_cyc_i}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[0]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[10]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[11]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[12]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[13]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[14]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[15]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[16]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[17]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[18]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[19]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[1]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[20]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[21]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[22]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[23]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[24]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[25]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[26]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[27]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[28]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[29]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[2]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[30]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[31]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[3]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[4]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[5]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[6]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[7]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[8]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_i[9]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_sel_i[0]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_sel_i[1]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_sel_i[2]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_sel_i[3]}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_stb_i}]
set_input_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_we_i}]


set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_ack_o}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[0]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[10]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[11]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[12]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[13]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[14]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[15]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[16]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[17]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[18]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[19]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[1]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[20]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[21]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[22]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[23]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[24]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[25]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[26]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[27]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[28]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[29]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[2]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[30]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[31]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[3]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[4]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[5]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[6]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[7]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[8]}]
set_output_delay -max 4.5000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[9]}]

set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_ack_o}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[0]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[10]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[11]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[12]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[13]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[14]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[15]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[16]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[17]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[18]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[19]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[1]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[20]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[21]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[22]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[23]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[24]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[25]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[26]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[27]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[28]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[29]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[2]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[30]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[31]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[3]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[4]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[5]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[6]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[7]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[8]}]
set_output_delay -min 1.0000 -clock [get_clocks {wbm_clk_i}] -add_delay [get_ports {wbs_dat_o[9]}]


#All Reset Sync inside the blocks
set_false_path -through [get_pins u_pinmux/cpu_core_rst_n[*]]
set_false_path -through [get_pins u_pinmux/cpu_intf_rst_n]
set_false_path -through [get_pins u_pinmux/qspim_rst_n]
set_false_path -through [get_pins u_pinmux/sspi_rst_n[*]]
set_false_path -through [get_pins u_pinmux/i2c_rst_n[*]]
set_false_path -through [get_pins u_pinmux/usb_rst_n[*]]

set_false_path -through [get_pins u_pinmux/irq_lines[*]]
set_false_path -through [get_pins u_pinmux/soft_irq]
set_false_path -through [get_pins u_pinmux/user_irq]
set_false_path -through [get_pins u_pinmux/usbh_intr]
set_false_path -through [get_pins u_pinmux/usbd_intr]
set_false_path -through [get_pins u_pinmux/i2cm_intr]
set_false_path -through [get_pins u_pinmux/timer_intr[*]]


set_false_path -through [get_pins u_pinmux/pinmux_debug[*]]




###############################################################################
# Environment
###############################################################################
