# SPDX-FileCopyrightText:  2021 , Dinesh Annayya
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileContributor: Modified by Dinesh Annayya <dinesha@opencores.org>



set ::env(USER_ROOT)    ".."


set ::env(LIB_FASTEST) "$::env(PDK_ROOT)/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/liberty/gf180mcu_fd_sc_mcu7t5v0__ff_n40C_5v50.lib"
set ::env(LIB_TYPICAL) "$::env(PDK_ROOT)/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/liberty/gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib"
set ::env(LIB_SLOWEST) "$::env(PDK_ROOT)/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/liberty/gf180mcu_fd_sc_mcu7t5v0__ss_125C_4v50.lib"
set ::env(DESIGN_NAME) "user_project_wrapper"
set ::env(BASE_SDC_FILE) "base.sdc"
set ::env(SYNTH_DRIVING_CELL) "gf180mcu_fd_sc_mcu7t5v0__inv_1"
set ::env(SYNTH_DRIVING_CELL_PIN) "ZN"
set ::env(WIRE_RC_LAYER) "met1"
set ::env(CLOCK_WIRE_RC_LAYER) "Metal4"
set ::env(DATA_WIRE_RC_LAYER) "Metal2"






set_cmd_units -time ns -capacitance pF -current mA -voltage V -resistance kOhm -distance um
define_corners wc bc tt
read_liberty -corner bc $::env(LIB_FASTEST)
read_liberty -corner wc $::env(LIB_SLOWEST)
read_liberty -corner tt $::env(LIB_TYPICAL)

#read_lib  -corner tt   ../lib/sky130_sram_2kbyte_1rw1r_32x512_8_TT_1p8V_25C.lib



# User project netlist

read_verilog $::env(USER_ROOT)/verilog/gl/peri_wrapper0.v
read_verilog $::env(USER_ROOT)/verilog/gl/wbi_slave_port.v
read_verilog $::env(USER_ROOT)/verilog/gl/wbi_master_port.v
read_verilog $::env(USER_ROOT)/verilog/gl/pinmux_top.v
read_verilog $::env(USER_ROOT)/verilog/gl/usb_wrapper.v
read_verilog $::env(USER_ROOT)/verilog/gl/sspi_i2c_wrapper.v
read_verilog $::env(USER_ROOT)/verilog/gl/ycr_core_top.v
read_verilog $::env(USER_ROOT)/verilog/gl/wbi_slave_port_s0.v
read_verilog $::env(USER_ROOT)/verilog/gl/wbi_master_port_m1.v
read_verilog $::env(USER_ROOT)/verilog/gl/wbi_master_port_m0.v
read_verilog $::env(USER_ROOT)/verilog/gl/wbi_slave_port_s1.v
read_verilog $::env(USER_ROOT)/verilog/gl/wbi_slave_port_s2.v
read_verilog $::env(USER_ROOT)/verilog/gl/wbi_master_port_m2.v
read_verilog $::env(USER_ROOT)/verilog/gl/wbi_slave_port_s3.v
read_verilog $::env(USER_ROOT)/verilog/gl/wbi_slave_port_s4.v
read_verilog $::env(USER_ROOT)/verilog/gl/wbi_slave_port_s5.v
read_verilog $::env(USER_ROOT)/verilog/gl/wb_host.v
read_verilog $::env(USER_ROOT)/verilog/gl/uart_wrapper.v
read_verilog $::env(USER_ROOT)/verilog/gl/wbi_master_port_m3.v
read_verilog $::env(USER_ROOT)/verilog/gl/ycr_iconnect.v
read_verilog $::env(USER_ROOT)/verilog/gl/qspim_top.v
read_verilog $::env(USER_ROOT)/verilog/gl/user_project_wrapper.v

link_design  $::env(DESIGN_NAME)

read_spef -path  u_per_wrap0               ../spef/peri_wrapper0.spef
read_spef -path  u_pinmux                  ../spef/pinmux_top.spef
read_spef -path  u_usb_wrap                ../spef/usb_wrapper.spef
read_spef -path  u_sspi_wrap               ../spef/sspi_i2c_wrapper.spef
read_spef -path  u_riscv_top.i_core_top_0  ../spef/ycr_core_top.spef
read_spef -path  u_intercon.u_s0           ../spef/wbi_slave_port_s0.spef
read_spef -path  u_intercon.u_s1           ../spef/wbi_slave_port_s1.spef
read_spef -path  u_intercon.u_s2           ../spef/wbi_slave_port_s2.spef
read_spef -path  u_intercon.u_s3           ../spef/wbi_slave_port_s3.spef
read_spef -path  u_intercon.u_s4           ../spef/wbi_slave_port_s4.spef
read_spef -path  u_intercon.u_s5           ../spef/wbi_slave_port_s5.spef
read_spef -path  u_intercon.u_m0           ../spef/wbi_master_port_m0.spef
read_spef -path  u_intercon.u_m1           ../spef/wbi_master_port_m1.spef
read_spef -path  u_intercon.u_m2           ../spef/wbi_master_port_m2.spef
read_spef -path  u_intercon.u_m3           ../spef/wbi_master_port_m3.spef
read_spef -path  u_wb_host                 ../spef/wb_host.spef
read_spef -path  u_uart_wrapper            ../spef/uart_wrapper.spef
read_spef -path  u_riscv_top.u_connect     ../spef/ycr_iconnect.spef
read_spef -path  u_qspi_master             ../spef/qspim_top.spef
read_spef ../spef/user_project_wrapper.spef



read_sdc -echo ./sdc/$::env(BASE_SDC_FILE)

# check for missing constraints
check_setup  -verbose > reports/unconstraints.rpt

set_operating_conditions -analysis_type single
# Propgate the clock
set_propagated_clock [all_clocks]

report_tns
report_wns
#report_power 
#
#echo "################ CORNER : WC (MAX) TIMING Report ###################"                                              > reports/timing_ss_max.rpt
report_checks -unique -slack_max -0.0 -path_delay max -group_count 100          -corner wc  -format full_clock_expanded >> reports/timing_ss_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  wbm_clk_i   -corner wc  -format full_clock_expanded >> reports/timing_ss_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  wbs_clk_i   -corner wc  -format full_clock_expanded >> reports/timing_ss_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  cpu_clk     -corner wc  -format full_clock_expanded >> reports/timing_ss_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  rtc_clk     -corner wc  -format full_clock_expanded >> reports/timing_ss_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  line_clk    -corner wc  -format full_clock_expanded >> reports/timing_ss_max.rpt
report_checks                         -path_delay max                           -corner wc                              >> reports/timing_ss_max.rpt

#echo "################ CORNER : WC (MIN) TIMING Report ###################"                                              > reports/timing_ss_min.rpt
report_checks -unique -slack_max -0.0 -path_delay min -group_count 100          -corner wc  -format full_clock_expanded >> reports/timing_ss_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  wbm_clk_i   -corner wc  -format full_clock_expanded >> reports/timing_ss_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  wbs_clk_i   -corner wc  -format full_clock_expanded >> reports/timing_ss_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  cpu_clk     -corner wc  -format full_clock_expanded >> reports/timing_ss_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  rtc_clk     -corner wc  -format full_clock_expanded >> reports/timing_ss_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  line_clk    -corner wc  -format full_clock_expanded >> reports/timing_ss_min.rpt
report_checks                         -path_delay min                           -corner wc                              >> reports/timing_ss_min.rpt

#echo "################ CORNER : BC (MAX) TIMING Report ###################"                                              > reports/timing_ff_max.rpt
report_checks -unique -slack_max -0.0 -path_delay max -group_count 100          -corner bc  -format full_clock_expanded >> reports/timing_ff_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  wbm_clk_i   -corner bc  -format full_clock_expanded >> reports/timing_ff_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  wbs_clk_i   -corner bc  -format full_clock_expanded >> reports/timing_ff_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  cpu_clk     -corner bc  -format full_clock_expanded >> reports/timing_ff_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  rtc_clk     -corner bc  -format full_clock_expanded >> reports/timing_ff_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  line_clk    -corner bc  -format full_clock_expanded >> reports/timing_ff_max.rpt
report_checks                         -path_delay max                           -corner bc                              >> reports/timing_ff_max.rpt

#echo "################ CORNER : BC (MIN) TIMING Report ###################"                                              > reports/timing_ff_min.rpt
report_checks -unique -slack_max -0.0 -path_delay min -group_count 100          -corner bc  -format full_clock_expanded >> reports/timing_ff_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  wbm_clk_i   -corner bc  -format full_clock_expanded >> reports/timing_ff_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  wbs_clk_i   -corner bc  -format full_clock_expanded >> reports/timing_ff_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  cpu_clk     -corner bc  -format full_clock_expanded >> reports/timing_ff_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  rtc_clk     -corner bc  -format full_clock_expanded >> reports/timing_ff_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  line_clk    -corner bc  -format full_clock_expanded >> reports/timing_ff_min.rpt
report_checks                         -path_delay min                           -corner bc                              >> reports/timing_ff_min.rpt


#echo "################ CORNER : TT (MAX) TIMING Report ###################"                                              > reports/timing_tt_max.rpt
report_checks -unique -slack_max -0.0 -path_delay max -group_count 100          -corner tt  -format full_clock_expanded >> reports/timing_tt_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  wbm_clk_i   -corner tt  -format full_clock_expanded >> reports/timing_tt_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  wbs_clk_i   -corner tt  -format full_clock_expanded >> reports/timing_tt_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  cpu_clk     -corner tt  -format full_clock_expanded >> reports/timing_tt_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  rtc_clk     -corner tt  -format full_clock_expanded >> reports/timing_tt_max.rpt
report_checks -group_count 100        -path_delay max  -path_group  line_clk    -corner tt  -format full_clock_expanded >> reports/timing_tt_max.rpt
report_checks                         -path_delay max                           -corner tt                              >> reports/timing_tt_max.rpt

#echo "################ CORNER : TT (MIN) TIMING Report ###################"                                              > reports/timing_tt_min.rpt
report_checks -unique -slack_max -0.0 -path_delay min -group_count 100          -corner tt  -format full_clock_expanded >> reports/timing_tt_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  wbm_clk_i   -corner tt  -format full_clock_expanded >> reports/timing_tt_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  wbs_clk_i   -corner tt  -format full_clock_expanded >> reports/timing_tt_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  cpu_clk     -corner tt  -format full_clock_expanded >> reports/timing_tt_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  rtc_clk     -corner tt  -format full_clock_expanded >> reports/timing_tt_min.rpt
report_checks -group_count 100        -path_delay min  -path_group  line_clk    -corner tt  -format full_clock_expanded >> reports/timing_tt_min.rpt
report_checks                         -path_delay min                           -corner tt                              >> reports/timing_tt_min.rpt


report_checks -path_delay min_max 

#exit
