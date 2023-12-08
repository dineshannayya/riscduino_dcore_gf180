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

set ::env(DESIGN_NAME) wbi_slave_port_saw11

set ::env(DESIGN_IS_CORE) "0"

# Timing configuration
set ::env(CLOCK_PERIOD) "20"
set ::env(CLOCK_PORT) "mclk"
set ::env(CLOCK_NET) "mclk"


# Sources
# -------

# Local sources + no2usb sources
set ::env(VERILOG_FILES) "\
     $::env(DESIGN_DIR)/../../verilog/rtl/lib/sync_fifo2.sv      \
     $::env(DESIGN_DIR)/../../verilog/rtl/wb_interconnect/src/wbi_arb2.sv  \
     $::env(DESIGN_DIR)/../../verilog/rtl/wb_interconnect/src/wbi_slave_port_saw11.sv   \
     $::env(DESIGN_DIR)/../../verilog/rtl/wb_interconnect/src/wbi_slave_node.sv   \
     $::env(DESIGN_DIR)/../../verilog/rtl/wb_interconnect/src/wbi_stagging.sv     \
     "
set ::env(VERILOG_INCLUDE_DIRS) [glob $::env(DESIGN_DIR)/../../verilog/rtl/ ]

set ::env(SYNTH_PARAMETERS) " CDP=2 RDP=2 SAW=11 BENB=0"

set ::env(SYNTH_READ_BLACKBOX_LIB) 1
set ::env(SYNTH_DEFINES) [list SYNTHESIS GF180NM ]
set ::env(SDC_FILE) $::env(DESIGN_DIR)/base.sdc
set ::env(BASE_SDC_FILE) $::env(DESIGN_DIR)/base.sdc

set ::env(LEC_ENABLE) 0

set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]


# Floorplanning
# -------------

set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 370 350"


# If you're going to use multiple power domains, then keep this disabled.
set ::env(RUN_CVC) 0


## Routing
#set ::env(GRT_ADJUSTMENT) 0.2

set ::env(PL_TIME_DRIVEN) 1
set ::env(PL_TARGET_DENSITY) "0.57"
set ::env(GRT_ALLOW_CONGESTION) {1}
set ::env(GPL_CELL_PADDING) "2"



#set ::env(FP_IO_VEXTEND) 4
#set ::env(FP_IO_HEXTEND) 4

set ::env(FP_PDN_VPITCH) 120
set ::env(FP_PDN_HPITCH) 120
set ::env(FP_PDN_VWIDTH) 5.2
set ::env(FP_PDN_HWIDTH) 5.2

set ::env(RT_MAX_LAYER) {Metal4}

#Lef 
set ::env(MAGIC_GENERATE_LEF) {1}
set ::env(MAGIC_WRITE_FULL_LEF) {0}



#LVS Issue - DEF Base looks to having issue
set ::env(MAGIC_EXT_USE_GDS) {1}


set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) "0"
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) "1"
set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) "1"
set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) "1"
set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
set ::env(QUIT_ON_MAGIC_DRC) "1"
set ::env(QUIT_ON_LVS_ERROR) "1"
set ::env(QUIT_ON_SLEW_VIOLATIONS) "0"

#Temp masked for gf180nm due to long run time or hanging
set ::env(RUN_LVS) "0"
