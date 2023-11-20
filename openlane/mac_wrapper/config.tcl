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

# Global
# ------

set script_dir [file dirname [file normalize [info script]]]
# Name

set ::env(PDK) "gf180mcuD"
set ::env(STD_CELL_LIBRARY) "gf180mcu_fd_sc_mcu7t5v0"

set ::env(DESIGN_NAME) mac_wrapper

set ::env(DESIGN_IS_CORE) "0"
set ::env(FP_PDN_CORE_RING) "0"

# Timing configuration
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) { app_clk phy_tx_clk phy_rx_clk mdio_clk  }


set ::env(SYNTH_MAX_FANOUT) 4
set ::env(SYNTH_BUFFERING) {0}
#set ::env(SYNTH_AUTONAME) {1}
#set ::env(SYNTH_NO_FLAT) "1"

## CTS BUFFER
set ::env(CTS_CLK_MAX_WIRE_LENGTH) {250}
set ::env(CTS_SINK_CLUSTERING_SIZE) "16"
set ::env(CLOCK_BUFFER_FANOUT) "8"

# Sources
# -------

# Local sources + no2usb sources
set ::env(VERILOG_FILES) "\
     $::env(DESIGN_DIR)/../../verilog/rtl/lib/clk_skew_adjust.gv \
     $::env(DESIGN_DIR)/../../verilog/rtl/lib/ctech_cells.sv \
     $::env(DESIGN_DIR)/../../verilog/rtl/lib/wb_rd_mem2mem.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/lib/wb_wr_mem2mem.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/lib/async_fifo.sv \
     $::env(DESIGN_DIR)/../../verilog/rtl/lib/g_dpath_ctrl.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/lib/toggle_sync.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/lib/registers.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/lib/stat_counter.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/mac_wrapper/src/mac_wrapper.sv \
     $::env(DESIGN_DIR)/../../verilog/rtl/gmac/top/g_mac_top.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/gmac/mac/g_rx_top.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/gmac/mac/g_deferral_rx.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/gmac/mac/g_cfg_mgmt.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/gmac/mac/dble_reg.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/gmac/mac/s2f_sync.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/gmac/mac/g_rx_fsm.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/gmac/mac/g_mac_core.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/gmac/mac/byte_reg.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/gmac/mac/g_tx_top.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/gmac/mac/g_tx_fsm.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/gmac/mac/g_mii_intf.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/gmac/mac/g_md_intf.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/gmac/mac/g_deferral.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/gmac/ctrl/eth_parser.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/gmac/crc32/g_rx_crc32.v \
     $::env(DESIGN_DIR)/../../verilog/rtl/gmac/crc32/g_tx_crc32.v \
	 "

#set ::env(VERILOG_INCLUDE_DIRS) [glob $::env(DESIGN_DIR)/../../verilog/rtl/mbist/include ]


set ::env(SYNTH_READ_BLACKBOX_LIB) 1
set ::env(SYNTH_DEFINES) [list SYNTHESIS GF180NM ]
set ::env(SDC_FILE) "$::env(DESIGN_DIR)/base.sdc"
set ::env(BASE_SDC_FILE) "$::env(DESIGN_DIR)/base.sdc"

set ::env(LEC_ENABLE) 0
set ::env(GRT_ALLOW_CONGESTION) {1}

set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]


# Floorplanning
# -------------

set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 900 900"


# If you're going to use multiple power domains, then keep this disabled.
set ::env(RUN_CVC) 0

#set ::env(PDN_CFG) $script_dir/pdn.tcl


set ::env(PL_TIME_DRIVEN) 1
set ::env(PL_TARGET_DENSITY) "0.55"

# helps in anteena fix
#set ::env(USE_ARC_ANTENNA_CHECK) "1"

#set ::env(FP_IO_VEXTEND) 4
#set ::env(FP_IO_HEXTEND) 4

set ::env(FP_PDN_VPITCH) 100
set ::env(FP_PDN_HPITCH) 100
set ::env(FP_PDN_VWIDTH) 6.2
set ::env(FP_PDN_HWIDTH) 6.2

#set ::env(GLB_RT_MAXLAYER) 5
set ::env(RT_MAX_LAYER) {Metal4}

#Lef 
set ::env(MAGIC_GENERATE_LEF) {1}
set ::env(MAGIC_WRITE_FULL_LEF) {0}



#LVS Issue - DEF Base looks to having issue
set ::env(MAGIC_EXT_USE_GDS) {1}

set ::env(GLB_RESIZER_MAX_SLEW_MARGIN) {1.5}
set ::env(PL_RESIZER_MAX_SLEW_MARGIN) {1.5}

set ::env(GLB_RESIZER_MAX_CAP_MARGIN) {0.25}
set ::env(PL_RESIZER_MAX_CAP_MARGIN) {0.25}

set ::env(GLB_RESIZER_MAX_WIRE_LENGTH) {500}
set ::env(PL_RESIZER_MAX_WIRE_LENGTH) {500}

set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
set ::env(QUIT_ON_MAGIC_DRC) "1"
set ::env(QUIT_ON_LVS_ERROR) "1"
set ::env(QUIT_ON_SLEW_VIOLATIONS) "0"

#Temp masked for gf180nm due to long run time or hanging
set ::env(RUN_LVS) "0"

