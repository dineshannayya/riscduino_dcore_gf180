# SPDX-FileCopyrightText: 2020 Efabless Corporation
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

# Base Configurations. Don't Touch
set verilog_root $::env(DESIGN_DIR)/../../verilog/
set lef_root $::env(DESIGN_DIR)/../../lef/
set gds_root $::env(DESIGN_DIR)/../../gds/
# section begin

set ::env(PDK) "gf180mcuD"
set ::env(DESIGN_NAME) "user_project_wrapper"
set ::env(STD_CELL_LIBRARY) "gf180mcu_fd_sc_mcu7t5v0"
set ::env(FP_DEF_TEMPLATE) "$::env(DESIGN_DIR)/fixed_dont_change/user_project_wrapper.def"


# User Configurations
#

## Source Verilog Files
set ::env(VERILOG_FILES) "\
	$verilog_root/rtl/user_project_wrapper.v \
	$verilog_root/rtl/wb_interconnect/src/wbi_top.sv \
	$verilog_root/rtl/yifive/ycr1c/src/top/ycr_top_wb.sv"


## Clock configurations
set ::env(CLOCK_PORT) "user_clock2 wb_clk_i"
set ::env(CLOCK_PERIOD) "10"

## Internal Macros
### Macro Placement
set ::env(MACRO_PLACEMENT_CFG) $::env(DESIGN_DIR)/macro.cfg

#set ::env(PDN_CFG) $::env(DESIGN_DIR)/pdn_cfg.tcl

set ::env(BASE_SDC_FILE) $::env(DESIGN_DIR)/base.sdc
set ::env(SIGNOFF_SDC_FILE) $::env(DESIGN_DIR)/base.sdc


### Black-box verilog and views
set ::env(VERILOG_FILES_BLACKBOX) "\
	    $::env(DESIGN_DIR)/../../verilog/gl/sspi_i2c_wrapper.v \
	    $::env(DESIGN_DIR)/../../verilog/gl/uart_wrapper.v \
	    $::env(DESIGN_DIR)/../../verilog/gl/qspim_top.v \
	    $::env(DESIGN_DIR)/../../verilog/gl/usb_wrapper.v \
	    $::env(DESIGN_DIR)/../../verilog/gl/wbi_master_port_m0.v \
	    $::env(DESIGN_DIR)/../../verilog/gl/wbi_master_port_m1.v \
	    $::env(DESIGN_DIR)/../../verilog/gl/wbi_master_port_m2.v \
	    $::env(DESIGN_DIR)/../../verilog/gl/wbi_master_port_m3.v \
	    $::env(DESIGN_DIR)/../../verilog/gl/wbi_slave_port_s0.v \
	    $::env(DESIGN_DIR)/../../verilog/gl/wbi_slave_port_s1.v \
	    $::env(DESIGN_DIR)/../../verilog/gl/wbi_slave_port_s2.v \
	    $::env(DESIGN_DIR)/../../verilog/gl/wbi_slave_port_s3.v \
	    $::env(DESIGN_DIR)/../../verilog/gl/wbi_slave_port_s4.v \
	    $::env(DESIGN_DIR)/../../verilog/gl/wbi_slave_port_s5.v \
	    $::env(DESIGN_DIR)/../../verilog/gl/pinmux_top.v \
	    $::env(DESIGN_DIR)/../../verilog/gl/peri_wrapper0.v \
	    $::env(DESIGN_DIR)/../../verilog/gl/wb_host.v \
	    $::env(DESIGN_DIR)/../../verilog/gl/ycr_core_top.v \
	    $::env(DESIGN_DIR)/../../verilog/gl/ycr_iconnect.v \
	    "

set ::env(EXTRA_LEFS) "\
	$lef_root/sspi_i2c_wrapper.lef \
	$lef_root/uart_wrapper.lef \
	$lef_root/qspim_top.lef \
	$lef_root/usb_wrapper.lef \
	$lef_root/wbi_master_port_right.lef \
	$lef_root/wbi_master_port_left.lef \
	$lef_root/wbi_master_port_m0.lef \
	$lef_root/wbi_master_port_m1.lef \
	$lef_root/wbi_master_port_m2.lef \
	$lef_root/wbi_master_port_m3.lef \
	$lef_root/wbi_slave_port_s0.lef \
	$lef_root/wbi_slave_port_s1.lef \
	$lef_root/wbi_slave_port_s2.lef \
	$lef_root/wbi_slave_port_s3.lef \
	$lef_root/wbi_slave_port_s4.lef \
	$lef_root/wbi_slave_port_s5.lef \
	$lef_root/pinmux_top.lef \
	$lef_root/peri_wrapper0.lef \
	$lef_root/wb_host.lef \
	$lef_root/ycr_core_top.lef \
	$lef_root/ycr_iconnect.lef \
	"

set ::env(EXTRA_GDS_FILES) "\
	$gds_root/sspi_i2c_wrapper.gds \
	$gds_root/uart_wrapper.gds \
	$gds_root/qspim_top.gds \
	$gds_root/usb_wrapper.gds \
	$gds_root/wbi_master_port_m0.gds \
	$gds_root/wbi_master_port_m1.gds \
	$gds_root/wbi_master_port_m2.gds \
	$gds_root/wbi_master_port_m3.gds \
	$gds_root/wbi_slave_port_s0.gds \
	$gds_root/wbi_slave_port_s1.gds \
	$gds_root/wbi_slave_port_s2.gds \
	$gds_root/wbi_slave_port_s3.gds \
	$gds_root/wbi_slave_port_s4.gds \
	$gds_root/wbi_slave_port_s5.gds \
	$gds_root/pinmux_top.gds \
	$gds_root/peri_wrapper0.gds \
	$gds_root/wb_host.gds \
	$gds_root/ycr_core_top.gds \
	$gds_root/ycr_iconnect.gds \
	"

set ::env(SYNTH_ELABORATE_ONLY) 0
set ::env(SYNTH_READ_BLACKBOX_LIB) 1
set ::env(SYNTH_DEFINES) [list SYNTHESIS GF180NM  USE_POWER_PINS]
set ::env(SYNTH_USE_PG_PINS_DEFINES) "USE_POWER_PINS"
set ::env(SYNTH_BUFFERING) "0"

set ::env(VERILOG_INCLUDE_DIRS) [glob $::env(DESIGN_DIR)/../../verilog/rtl/ $::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/includes ]

set ::env(GRT_ALLOW_CONGESTION) {1}


set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 2980.2 2980.2"
set ::env(CORE_AREA) "12 12 2968.2 2968.2"


## Internal Macros
### Macro PDN Connections
set ::env(FP_PDN_CHECK_NODES) 1
set ::env(FP_PDN_IRDROP) "1"
set ::env(RUN_IRDROP_REPORT) "1"
####################

set ::env(FP_PDN_ENABLE_MACROS_GRID) {1}
set ::env(FP_PDN_ENABLE_GLOBAL_CONNECTIONS) "0"
set ::env(FP_PDN_CHECK_NODES) 1
set ::env(FP_PDN_ENABLE_RAILS) 0
set ::env(FP_PDN_IRDROP) "1"

set ::env(FP_IO_VEXTEND) 4.8
set ::env(FP_IO_HEXTEND) 4.8
set ::env(FP_IO_VLENGTH) 2.4
set ::env(FP_IO_HLENGTH) 2.4
set ::env(FP_IO_VTHICKNESS_MULT)  4
set ::env(FP_IO_HTHICKNESS_MULT) 4
set ::env(FP_PDN_CORE_RING) 1
set ::env(FP_PDN_CORE_RING_VWIDTH) 3.1
set ::env(FP_PDN_CORE_RING_HWIDTH) 3.1
set ::env(FP_PDN_CORE_RING_VOFFSET) 14
set ::env(FP_PDN_CORE_RING_HOFFSET) 16
set ::env(FP_PDN_CORE_RING_VSPACING) 1.7
set ::env(FP_PDN_CORE_RING_HSPACING) 1.7
set ::env(FP_PDN_HOFFSET) 5
set ::env(FP_PDN_HPITCH_MULT) 1
set ::env(FP_PDN_HPITCH) 90
set ::env(FP_PDN_VWIDTH) 3.1
set ::env(FP_PDN_HWIDTH) 3.1
set ::env(FP_PDN_VSPACING) 15.5
set ::env(FP_PDN_HSPACING)  26.9


set ::env(VDD_NETS) {vdd }
set ::env(GND_NETS) {vss }

set ::env(DRT_OPT_ITERS) {32}


set ::env(FP_PDN_MACRO_HOOKS) " \
	u_wb_host                  vdd vss vccd1 vssd1,\
    u_intercon.u_m0            vdd vss vccd1 vssd1,\
    u_intercon.u_s0            vdd vss vccd1 vssd1,\
    u_qspi_master              vdd vss vccd1 vssd1,\
    u_intercon.u_m1            vdd vss vccd1 vssd1,\
    u_intercon.u_s1            vdd vss vccd1 vssd1,\
    u_uart_wrapper             vdd vss vccd1 vssd1,\
    u_intercon.u_s2            vdd vss vccd1 vssd1,\
    u_usb_wrap                 vdd vss vccd1 vssd1,\
    u_intercon.u_m2            vdd vss vccd1 vssd1,\
    u_intercon.u_s3            vdd vss vccd1 vssd1,\
    u_sspi_wrap                vdd vss vccd1 vssd1,\
    u_intercon.u_m3            vdd vss vccd1 vssd1,\
    u_riscv_top.i_core_top_0   vdd vss vccd1 vssd1,\
    u_riscv_top.u_connect      vdd vss vccd1 vssd1,\
    u_intercon.u_s4            vdd vss vccd1 vssd1,\
    u_pinmux                   vdd vss vccd1 vssd1,\
    u_intercon.u_s5            vdd vss vccd1 vssd1,\
    u_per_wrap0                vdd vss vccd1 vssd1 \
      	"


set ::env(RUN_CTS) {0}
set ::env(RUN_CVC) {0}

#Use GDS for SPEF extraction
set ::env(MAGIC_EXT_USE_GDS) "1"

# The following is because there are no std cells in the example wrapper project.
set ::env(PL_RANDOM_GLB_PLACEMENT) 1
set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 0
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0
set ::env(GLB_RESIZER_DESIGN_OPTIMIZATIONS) "0"
set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) "0"
set ::env(GLB_OPTIMIZE_MIRRORING) "0"
set ::env(DIODE_INSERTION_STRATEGY) 0
set ::env(RUN_FILL_INSERTION) 0
set ::env(RUN_TAP_DECAP_INSERTION) 0
set ::env(QUIT_ON_LVS_ERROR) "1"
set ::env(QUIT_ON_MAGIC_DRC) "0"
set ::env(QUIT_ON_NEGATIVE_WNS) "0"
set ::env(QUIT_ON_SLEW_VIOLATIONS) "0"
set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"

## Temp Masked due to long Run Time
set ::env(RUN_KLAYOUT_XOR) {0}

