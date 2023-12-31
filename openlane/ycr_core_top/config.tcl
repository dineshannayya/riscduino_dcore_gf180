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

set script_dir [file dirname [file normalize [info script]]]

set ::env(PDK) "gf180mcuD"
set ::env(STD_CELL_LIBRARY) "gf180mcu_fd_sc_mcu7t5v0"
set ::env(ROUTING_CORES) "6"

set ::env(DESIGN_NAME) ycr_core_top
set ::env(DESIGN_IS_CORE) "0"
set ::env(FP_PDN_CORE_RING) "0"

set ::env(CLOCK_PERIOD) "20"
set ::env(CLOCK_PORT) "clk"



set ::env(VERILOG_FILES) "\
    $::env(DESIGN_DIR)/../../verilog/rtl/lib/clk_skew_adjust.gv                  \
    $::env(DESIGN_DIR)/../../verilog/rtl/lib/ctech_cells.sv                      \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr_pipe_top.sv           \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/ycr_core_top.sv                    \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/ycr_dm.sv                          \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/ycr_tapc_synchronizer.sv           \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/ycr_clk_ctrl.sv                    \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/ycr_scu.sv                         \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/ycr_tapc.sv                        \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/ycr_tapc_shift_reg.sv              \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/ycr_dmi.sv                         \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/primitives/ycr_reset_cells.sv      \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr_pipe_ifu.sv           \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr_pipe_idu.sv           \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr_pipe_exu.sv           \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr_pipe_mprf.sv          \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr_pipe_csr.sv           \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr_pipe_ialu.sv          \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr_pipe_mul.sv           \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr_pipe_div.sv           \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr_pipe_lsu.sv           \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr_pipe_hdu.sv           \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr_pipe_tdu.sv           \
	$::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/core/pipeline/ycr_ipic.sv               \
        $::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/top/ycr_req_retiming.sv               \
        $::env(DESIGN_DIR)/../../verilog/rtl/yifive/ycr1c/src/lib/sync_fifo2.sv                     \
	"
set ::env(VERILOG_INCLUDE_DIRS) [glob $::env(DESIGN_DIR)/../../verilog/rtl/yifive/includes ]
set ::env(SYNTH_READ_BLACKBOX_LIB) 1
set ::env(SYNTH_DEFINES) [list SYNTHESIS GF180NM ]


set ::env(SDC_FILE) $::env(DESIGN_DIR)/base.sdc
set ::env(BASE_SDC_FILE) $::env(DESIGN_DIR)/base.sdc

set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]

## Floorplan
set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 1175 1125 "

set ::env(PL_TARGET_DENSITY) 0.57
set ::env(GPL_CELL_PADDING) "4"
set ::env(GRT_ALLOW_CONGESTION) {1}

## Routing
#set ::env(GRT_ADJUSTMENT) 0.2

set ::env(PL_TIME_DRIVEN) "1"

set ::env(RT_MAX_LAYER) {Metal4}

#LVS Issue - DEF Base looks to having issue
set ::env(MAGIC_EXT_USE_GDS) {1}


set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
set ::env(QUIT_ON_MAGIC_DRC) "1"
set ::env(QUIT_ON_LVS_ERROR) "1"
set ::env(QUIT_ON_SLEW_VIOLATIONS) "0"

#Need to cross-check why global timing opimization creating setup vio with hugh hold fix
set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) "1"
set ::env(GLB_OPTIMIZE_MIRRORING) {1}
set ::env(PL_OPTIMIZE_MIRRORING) {1}
set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) {1}
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) {0}

#PDN
set ::env(FP_PDN_VPITCH) 100
set ::env(FP_PDN_HPITCH) 100
set ::env(FP_PDN_VWIDTH) 6.2
set ::env(FP_PDN_HWIDTH) 6.2


#Temp masked for gf180nm due to long run time or hanging
set ::env(RUN_LVS) "0"
