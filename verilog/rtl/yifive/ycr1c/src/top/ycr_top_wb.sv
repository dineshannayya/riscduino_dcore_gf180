//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021, Dinesh Annayya                           ////
//                                                                        ////
// Licensed under the Apache License, Version 2.0 (the "License");        ////
// you may not use this file except in compliance with the License.       ////
// You may obtain a copy of the License at                                ////
//                                                                        ////
//      http://www.apache.org/licenses/LICENSE-2.0                        ////
//                                                                        ////
// Unless required by applicable law or agreed to in writing, software    ////
// distributed under the License is distributed on an "AS IS" BASIS,      ////
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.///
// See the License for the specific language governing permissions and    ////
// limitations under the License.                                         ////
// SPDX-License-Identifier: Apache-2.0                                    ////
// SPDX-FileContributor: Dinesh Annayya <dinesha@opencores.org>           ////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
////                                                                      ////
////  yifive Single core RISCV Top                                        ////
////                                                                      ////
////  This file is part of the yifive cores project                       ////
////  https://github.com/dineshannayya/ycr1cr.git                           ////
////                                                                      ////
////  Description:                                                        ////
////     integrated 1 Risc core with instruction/data memory & wb         ////
////                                                                      ////
////  To Do:                                                              ////
////    nothing                                                           ////
////                                                                      ////
////  Authors:                                                            ////
////     - syntacore, https://github.com/syntacore/scr1                   ////
////     - Dinesh Annayya, dinesha@opencores.org                          ////
////                                                                      ////
////  CPU Memory Map:                                                     ////
////            0x0000_0000 to 0x07FF_FFFF (128MB) - ICACHE               ////
////            0x0800_0000 to 0x0BFF_FFFF (64MB)  - DCACHE               ////
////            0x0C48_0000 to 0x0C48_FFFF (64K)   - TCM SRAM             ////
////            0x0C49_0000 to 0x0C49_000F (16)    - TIMER                ////
////                                                                      ////
////  Revision :                                                          ////
////     0.0:    June 7, 2021, Dinesh A                                   ////
////             wishbone integration                                     ////
////     0.1:    June 17, 2021, Dinesh A                                  ////
////             core and wishbone clock domain are seperated             ////
////             Async fifo added in imem and dmem path                   ////
////     0.2:    July 7, 2021, Dinesh A                                   ////
////            64bit debug signal added                                  ////
////     0.3:    Aug 23, 2021, Dinesh A                                   ////
////            timer_irq connective bug fix                              ////
////     1.0:   Jan 20, 2022, Dinesh A                                    ////
////            128MB icache integrated in address range 0x0000_0000 to   ////
////            0x07FF_FFFF                                               ////
////     1.1:   Jan 22, 2022, Dinesh A                                    ////
////            64MB dcache added in the address range 0x0800_0000 to     ////
////            0x0BFF_FFFF                                               ////
////     1.2:   Jan 30, 2022, Dinesh A                                    ////
////            global register newly added in timer register to control  ////
////            icache/dcache operation                                   ////
////     1.3:   Feb 14, 2022, Dinesh A                                    ////
////            Burst Access support added to imem prefetch logic         ////
////            Burst Prefetech support only towards imem address range   ////
////            0x0000_0000 to 0x07FFF_FFFF                               ////
////     1.4:   Feb 16, 2022, Dinesh A                                    ////
////            As SRAM from Sky130A is not qualified, we have changed    ////
////            cache and tcm interface to DFFRAM                         ////
////     1.5:   Feb 20, 2022, Dinesh A                                    ////
////            Total Risc core parameter added                           ////
////     1.6:   Mar 14, 2022, Dinesh A                                    ////
////            fuse_mhartid is internally tied                           ////
////     1.8:   Mar 28, 2022, Dinesh A                                    ////
////            Pipe line imem request generation is removed in           ////
////            ycr_pipe_ifu.sv and when ever there there is clash between////
////            current request and new change of addres request, new     ////
////            address will be holded and updated only at the end of     ////
////            pending transaction                                       ////
////     1.9:   Mar 29, 2022, Dinesh A                                    ////
////            To break the timing path, once cycle gap assumed between  ////
////            core request to slave ack, following files are modified   ////
////     	    src/cache/src/core/dcache_top.sv                          ////
////     	    src/cache/src/core/icache_top.sv                          ////
////     	    src/core/pipeline/ycr_pipe_ifu.sv                         ////
////     	    src/top/ycr_dmem_router.sv                                ////
////     	    src/top/ycr_dmem_wb.sv                                    ////
////     	    src/top/ycr_tcm.sv                                        ////
////            Synth and sta script are clean-up                         ////
////     2.0:  April 1, 2022, Dinesh A                                    ////
////           As sky130 SRAM timining library are not accurate, added    ////
////           Write interface lanuch phase selection                     ////  
////     2.1:  May 23, 2022, Dinesh A                                     ////
////           To improve the timing, request re-timing are added at      ////
////           iconnect block, In MPW-6 shows Riscv core meeting timing   ////
////           for 100Mhz                                                 ////
////     2.2:  June 3, 2022, Dinesh A                                     ////
////           Replaced DFFRAM with SRAM Memory                           ////
////     2.3:  June 12, 2022, Dinesh A                                    ////
////           icache and dcache bypass config added                      ////
////     2.4:  Aug 20, 2022, Dinesh A                                     ////
////           Increase total external interrupt from 16 to 32            ////
////     2.5:  Nov 7, 2022, Dinesh A                                      ////
////           Added Interface to integrate AES core                      ////
////           Added Interface to integrate FPU core                      ////
////     2.6:  Mar 4, 2023, Dinesh A                                      ////
////           Tap access is enabled                                      ////
////     2.7:  Mar 10, 2023, Dinesh A                                     ////
////            all cpu clock is branch are routed through iconnect       ////
////     2.8:  May 1, 2023, Dinesh A                                      ////
////           cpu clock gating feature added                             ////
////     2.9:  June 1, 2023, Dinesh A                                     ////
////            Bug fix in Tap reset connectivity                         ////
////                                                                      ////
////                                                                      ////
//////////////////////////////////////////////////////////////////////////////

`include "ycr_arch_description.svh"
`include "ycr_memif.svh"
`include "ycr_wb.svh"
`ifdef YCR_IPIC_EN
`include "ycr_ipic.svh"
`endif // YCR_IPIC_EN

`ifdef YCR_TCM_EN
 `define YCR_IMEM_ROUTER_EN
`endif // YCR_TCM_EN

module ycr_top_wb (

`ifdef USE_POWER_PINS
         input logic                          vdd,    // User area 1 1.8V supply
         input logic                          vss,    // User area 1 digital ground
`endif

    // RISCV Clock Skew Control
    input  logic   [3:0]                      cfg_ccska_riscv_icon,
    input  logic   [3:0]                      cfg_ccska_riscv_core0,
    input  logic                              core_clk_int,

    // Control
    input   logic                             pwrup_rst_n,            // Power-Up Reset
    input   logic                             rst_n,                  // Regular Reset signal
    input   logic                             cpu_core_rst_n,         // CPReset (Core Reset )
    input   logic                             cpu_intf_rst_n,         // CPU interface reset
    input   logic                             rtc_clk,                // Real-time clock
    output  logic [63:0]                      riscv_debug,


    // IRQ
`ifdef YCR_IPIC_EN
    input   logic [YCR_IRQ_LINES_NUM-1:0]irq_lines,              // IRQ lines to IPIC
`else // YCR_IPIC_EN
    input   logic                        ext_irq,                // External IRQ input
`endif // YCR_IPIC_EN
    input   logic                        soft_irq,               // Software IRQ input


    input  logic   [3:0]                 cfg_wcska_riscv_intf,
    input   logic                        wb_rst_n,       // Wish bone reset
    input   logic                        wb_clk,         // wish bone clock

    // WB Data Memory Interface
    output  logic   [3:0]                wbd_mid_o,      // Master ID
    output  logic                        wbd_dmem_cyc_o,
    output  logic                        wbd_dmem_stb_o, // strobe/request
    output  logic   [YCR_WB_WIDTH-1:0]   wbd_dmem_adr_o, // address
    output  logic                        wbd_dmem_we_o,  // write
    output  logic   [YCR_WB_WIDTH-1:0]   wbd_dmem_dat_o, // data output
    output  logic   [3:0]                wbd_dmem_sel_o, // byte enable
    output  logic   [9:0]                wbd_dmem_bl_o, // byte enable
    output  logic                        wbd_dmem_bry_o, // bursty ready
    input   logic   [YCR_WB_WIDTH-1:0]   wbd_dmem_dat_i, // data input
    input   logic                        wbd_dmem_ack_i, // acknowlegement
    input   logic                        wbd_dmem_lack_i, // acknowlegement
    input   logic                        wbd_dmem_err_i  // error

);

//-------------------------------------------------------------------------------
// Local parameters
//-------------------------------------------------------------------------------
localparam int unsigned YCR_CLUSTER_TOP_RST_SYNC_STAGES_NUM            = 2;

//-------------------------------------------------------------------------------
// Local signal declaration
//-------------------------------------------------------------------------------
// Reset logic
logic                                               pwrup_rst_n_sync;
logic                                               cpu_rst_n_sync;
logic [`YCR_NUMCORES-1:0]                           cpu_core_rst_n_sync;        // CPU Reset (Core Reset)

logic                                               wbd_clk_skew;
//----------------------------------------------------------------
// CORE-0 Specific Signals
// ---------------------------------------------------------------
logic                                              core0_clk;
logic                                              core0_sleep;
logic [48:0]                                       core0_debug;
logic [1:0]                                        core0_uid;
logic                                              core0_timer_irq;
logic [63:0]                                       core0_timer_val;
logic [YCR_IRQ_LINES_NUM-1:0]                      core0_irq_lines;  // IRQ lines to IPIC
logic                                              core0_soft_irq;  // IRQ lines to IPIC

// Instruction memory interface from core to router
logic                                              core0_imem_req_ack;
logic                                              core0_imem_req;
logic                                              core0_imem_cmd;
logic [`YCR_IMEM_AWIDTH-1:0]                       core0_imem_addr;
logic [`YCR_IMEM_BSIZE-1:0]                        core0_imem_bl;
logic [`YCR_IMEM_DWIDTH-1:0]                       core0_imem_rdata;
logic [1:0]                                        core0_imem_resp;

// Data memory interface from core to router
logic                                              core0_dmem_req_ack;
logic                                              core0_dmem_req;
logic                                              core0_dmem_cmd;
logic [1:0]                                        core0_dmem_width;
logic [`YCR_DMEM_AWIDTH-1:0]                       core0_dmem_addr;
logic [`YCR_DMEM_DWIDTH-1:0]                       core0_dmem_wdata;
logic [`YCR_DMEM_DWIDTH-1:0]                       core0_dmem_rdata;
logic [1:0]                                        core0_dmem_resp;

//----------------------------------------------------
// Data memory interface from router to WB bridge
// --------------------------------------------------
logic                                              core_dmem_req_ack;
logic                                              core_dmem_req;
logic                                              core_dmem_cmd;
logic [1:0]                                        core_dmem_width;
logic [`YCR_DMEM_AWIDTH-1:0]                       core_dmem_addr;
logic [`YCR_IMEM_BSIZE-1:0]                        core_dmem_bl;
logic [`YCR_DMEM_DWIDTH-1:0]                       core_dmem_wdata;
logic [`YCR_DMEM_DWIDTH-1:0]                       core_dmem_rdata;
logic [1:0]                                        core_dmem_resp;

//----------------------------------------------------
// icache interface from router to WB bridge
// --------------------------------------------------
logic                                              core_icache_req_ack;
logic                                              core_icache_req;
logic                                              core_icache_cmd;
logic [1:0]                                        core_icache_width;
logic [`YCR_DMEM_AWIDTH-1:0]                       core_icache_addr;
logic [2:0]                                        core_icache_bl;
logic [`YCR_DMEM_DWIDTH-1:0]                       core_icache_rdata;
logic [1:0]                                        core_icache_resp;

//----------------------------------------------------
// dcache interface from router to WB bridge
// --------------------------------------------------
logic                                              core_dcache_req_ack;
logic                                              core_dcache_req;
logic                                              core_dcache_cmd;
logic [1:0]                                        core_dcache_width;
logic [`YCR_DMEM_AWIDTH-1:0]                       core_dcache_addr;
logic [`YCR_DMEM_DWIDTH-1:0]                       core_dcache_wdata;
logic [`YCR_DMEM_DWIDTH-1:0]                       core_dcache_rdata;
logic [1:0]                                        core_dcache_resp;

logic [3:0]                                        core_clk_out;

logic                                              cfg_dcache_force_flush;

logic                                              core_clk_icon_skew;
logic                                              core_clk_core0_skew;


assign wbd_dmem_cyc_o = wbd_dmem_stb_o;
//------------------------------------------------------------------------------
// Tap will be daisy chained Tap Input => <core0> => Tap Out
//------------------------------------------------------------------------------

//-------------------------------------------------------------------------------
// YCR Intf instance
//-------------------------------------------------------------------------------
ycr_iconnect u_connect (
`ifdef USE_POWER_PINS
          .vccd1                        (vdd                         ), // User area 1 1.8V supply
          .vssd1                        (vss                         ), // User area 1 digital ground
`endif
          
          .rtc_clk                      (rtc_clk                      ), // Core clock
	      .pwrup_rst_n                  (pwrup_rst_n                  ),
          .cpu_intf_rst_n               (cpu_intf_rst_n               ), // CPU reset

          .cfg_ccska                    (cfg_ccska_riscv_icon         ),
          .core_clk_int                 (core_clk_int                 ),
          .core_clk_skew                (core_clk_icon_skew          ),
          .core_clk                     (core_clk_icon_skew          ),

	      .riscv_debug                  (riscv_debug                  ),

          // Interrupt buffering      
          .core_irq_lines_i             (irq_lines                    ),
          .core_irq_soft_i              (soft_irq                     ),

    // CORE-0
          .core0_clk                    (core0_clk                    ),
          .core0_sleep                  (core0_sleep                  ),
          .core0_debug                  (core0_debug                  ),
          .core0_uid                    (core0_uid                    ),
          .core0_timer_val              (core0_timer_val              ), // Machine timer value
          .core0_timer_irq              (core0_timer_irq              ), // Machine timer value
          .core0_irq_lines              (core0_irq_lines              ),
          .core0_irq_soft               (core0_soft_irq               ),

    // Instruction Memory Interface
          .core0_imem_req_ack           (core0_imem_req_ack           ), // IMEM request acknowledge
          .core0_imem_req               (core0_imem_req               ), // IMEM request
          .core0_imem_cmd               (core0_imem_cmd               ), // IMEM command
          .core0_imem_addr              (core0_imem_addr              ), // IMEM address
          .core0_imem_bl                (core0_imem_bl                ), // IMEM address
          .core0_imem_rdata             (core0_imem_rdata             ), // IMEM read data
          .core0_imem_resp              (core0_imem_resp              ), // IMEM response

    // Data Memory Interface
          .core0_dmem_req_ack           (core0_dmem_req_ack           ), // DMEM request acknowledge
          .core0_dmem_req               (core0_dmem_req               ), // DMEM request
          .core0_dmem_cmd               (core0_dmem_cmd               ), // DMEM command
          .core0_dmem_width             (core0_dmem_width             ), // DMEM data width
          .core0_dmem_addr              (core0_dmem_addr              ), // DMEM address
          .core0_dmem_wdata             (core0_dmem_wdata             ), // DMEM write data
          .core0_dmem_rdata             (core0_dmem_rdata             ), // DMEM read data
          .core0_dmem_resp              (core0_dmem_resp              ), // DMEM response

          //--------------------------------------------
          // Wishbone  
          // ------------------------------------------
         // WB  clock skew control
          .cfg_wcska                    (cfg_wcska_riscv_intf        ),
          .wbd_clk_int                  (wb_clk                      ),
          .wbd_clk_skew                 (wbd_clk_skew                ),

          .wb_rst_n                     (wb_rst_n                    ), // Wish bone reset
          .wb_clk                       (wbd_clk_skew                ), // wish bone clock

          // Data Memory Interface
          .wbd_mid_o                    (wbd_mid_o                   ), // strobe/request
          .wbd_dmem_stb_o               (wbd_dmem_stb_o              ), // strobe/request
          .wbd_dmem_adr_o               (wbd_dmem_adr_o              ), // address
          .wbd_dmem_we_o                (wbd_dmem_we_o               ), // write
          .wbd_dmem_dat_o               (wbd_dmem_dat_o              ), // data output
          .wbd_dmem_sel_o               (wbd_dmem_sel_o              ), // byte enable
          .wbd_dmem_bl_o                (wbd_dmem_bl_o               ), // byte enable
          .wbd_dmem_bry_o               (wbd_dmem_bry_o              ), // burst ready
          .wbd_dmem_dat_i               (wbd_dmem_dat_i              ), // data input
          .wbd_dmem_ack_i               (wbd_dmem_ack_i              ), // acknowlegement
          .wbd_dmem_lack_i              (wbd_dmem_lack_i             ), // acknowlegement
          .wbd_dmem_err_i               (wbd_dmem_err_i              )  // error

);



//-------------------------------------------------------------------------------
// YCR core_0 instance
//-------------------------------------------------------------------------------
ycr_core_top i_core_top_0 (
`ifdef USE_POWER_PINS
          .vccd1                        (vdd                         ), // User area 1 1.8V supply
          .vssd1                        (vss                         ), // User area 1 digital ground
`endif
    // Common
          .pwrup_rst_n                  (pwrup_rst_n                  ),
          .rst_n                        (rst_n                        ),
          .cpu_rst_n                    (cpu_core_rst_n               ),
          // Core clock skew control
          .cfg_ccska                    (cfg_ccska_riscv_core0        ),
          .core_clk_int                 (core0_clk                    ),
          .core_clk_skew                (core_clk_core0_skew          ),
          .clk                          (core_clk_core0_skew          ),


          .clk_o                        (core_clk_out[0]              ),
          .core_rst_n_o                 (                             ),
          .core_rdc_qlfy_o              (                             ),

          .core_sleep                    (core0_sleep                  ),

    // IRQ
`ifdef YCR_IPIC_EN
          .core_irq_lines_i             (core0_irq_lines              ),
`else // YCR_IPIC_EN
          .core_irq_ext_i               (ext_irq                      ),
`endif // YCR_IPIC_EN
          .core_irq_soft_i              (core0_soft_irq               ),

   //---- inter-connect
          .core_irq_mtimer_i            (core0_timer_irq              ),
          .core_mtimer_val_i            (core0_timer_val              ),
          .core_uid                     (core0_uid                    ),
          .core_debug                   (core0_debug                  ),
    // Instruction memory interface
          .imem2core_req_ack_i          (core0_imem_req_ack           ),
          .core2imem_req_o              (core0_imem_req               ),
          .core2imem_cmd_o              (core0_imem_cmd               ),
          .core2imem_addr_o             (core0_imem_addr              ),
          .core2imem_bl_o               (core0_imem_bl                ),
          .imem2core_rdata_i            (core0_imem_rdata             ),
          .imem2core_resp_i             (core0_imem_resp              ),

    // Data memory interface
          .dmem2core_req_ack_i          (core0_dmem_req_ack           ),
          .core2dmem_req_o              (core0_dmem_req               ),
          .core2dmem_cmd_o              (core0_dmem_cmd               ),
          .core2dmem_width_o            (core0_dmem_width             ),
          .core2dmem_addr_o             (core0_dmem_addr              ),
          .core2dmem_wdata_o            (core0_dmem_wdata             ),
          .dmem2core_rdata_i            (core0_dmem_rdata             ),
          .dmem2core_resp_i             (core0_dmem_resp              )
);







endmodule : ycr_top_wb


