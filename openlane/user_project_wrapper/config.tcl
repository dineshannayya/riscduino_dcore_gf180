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
	$verilog_root/rtl/user_project_wrapper.v"


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
	    $::env(DESIGN_DIR)/../../verilog/gl/wb_host.v \
	    "

set ::env(EXTRA_LEFS) "\
	$lef_root//wb_host.lef \
	"

set ::env(EXTRA_GDS_FILES) "\
	$gds_root//wb_host.gds \
	"

set ::env(SYNTH_TOP_LEVEL) 0
set ::env(SYNTH_READ_BLACKBOX_LIB) 1
set ::env(SYNTH_DEFINES) [list SYNTHESIS GF180NM YCR_DBG_EN ]
set ::env(SYNTH_USE_PG_PINS_DEFINES) "USE_POWER_PINS"
set ::env(SYNTH_BUFFERING) "0"

set ::env(VERILOG_INCLUDE_DIRS) [glob $::env(DESIGN_DIR)/../../verilog/rtl/ ]

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
	u_wb_host                   vdd vss vccd1 vssd1 \
      	"


set ::env(RUN_CTS) {0}
set ::env(RUN_CVC) {0}

# The following is because there are no std cells in the example wrapper project.
set ::env(PL_RANDOM_GLB_PLACEMENT) 1
set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 0
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0
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

