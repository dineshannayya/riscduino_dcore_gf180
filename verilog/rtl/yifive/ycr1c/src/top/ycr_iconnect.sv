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
////  yifive multi-core interface block                                   ////
////                                                                      ////
////  This file is part of the yifive cores project                       ////
////  https://github.com/dineshannayya/ycr2c.git                          ////
////                                                                      ////
////  Description:                                                        ////
////     connect the multi-core to common icache/dcache/tcm/timer         ////
////     Instruction memory router                                        ////
////                                                                      ////
////  To Do:                                                              ////
////    nothing                                                           ////
////                                                                      ////
////  Author(s):                                                          ////
////      - Dinesh Annayya, dinesha@opencores.org                         ////
////                                                                      ////
////  Revision :                                                          ////
////     v0:    Feb 21, 2021, Dinesh A                                    ////
////             Initial version                                          ////
////     v1:    Mar 10, 2023, Dinesh A                                    ////
////            all cpu clock is branch are routed through iconnect       ////
////                                                                      ////
//////////////////////////////////////////////////////////////////////////////

`include "user_reg_map.v"

`include "ycr_arch_description.svh"
`include "ycr_memif.svh"
`include "ycr_wb.svh"
`ifdef YCR_IPIC_EN
`include "ycr_ipic.svh"
`endif // YCR_IPIC_EN

`ifdef YCR_TCM_EN
 `define YCR_IMEM_ROUTER_EN
`endif // YCR_TCM_EN

module ycr_iconnect (
`ifdef USE_POWER_PINS
    input logic                          vccd1,    // User area 1 1.8V supply
    input logic                          vssd1,    // User area 1 digital ground
`endif

    // Control
    input   logic [3:0]                  cfg_ccska     ,
    input   logic                        core_clk_int  ,
    output  logic                        core_clk_skew ,

    input   logic                        core_clk,               // Core clock
    input   logic                        rtc_clk,                // Real-time clock
    input   logic                        pwrup_rst_n,            // Power-Up Reset
    input   logic                        cpu_intf_rst_n,        // CPU interface reset

    input   logic [YCR_IRQ_LINES_NUM-1:0] core_irq_lines_i,     // External interrupt request lines
    input   logic                         core_irq_soft_i,         // Software generated interrupt request

    output  logic [63:0]                 riscv_debug,


    // CORE-0
    output   logic                          core0_clk                 ,
    output   logic                          core0_sleep               , // core0 sleep indication
    input    logic   [48:0]                 core0_debug               ,
    output   logic     [1:0]                core0_uid                 ,
    output   logic [63:0]                   core0_timer_val           , // Machine timer value
    output   logic                          core0_timer_irq           ,
    output   logic [YCR_IRQ_LINES_NUM-1:0]  core0_irq_lines           , // External interrupt request lines
    output   logic                          core0_irq_soft            , // Software generated interrupt request
    // Instruction Memory Interface
    output   logic                          core0_imem_req_ack        , // IMEM request acknowledge
    input    logic                          core0_imem_req            , // IMEM request
    input    logic                          core0_imem_cmd,            // IMEM command
    input    logic [`YCR_IMEM_AWIDTH-1:0]   core0_imem_addr           , // IMEM address
    input    logic [`YCR_IMEM_BSIZE-1:0]    core0_imem_bl             , // IMEM burst size
    output   logic [`YCR_IMEM_DWIDTH-1:0]   core0_imem_rdata          , // IMEM read data
    output   logic [1:0]                    core0_imem_resp           , // IMEM response


    // Data Memory Interface
    output   logic                          core0_dmem_req_ack        , // DMEM request acknowledge
    input    logic                          core0_dmem_req            , // DMEM request
    input    logic                          core0_dmem_cmd            , // DMEM command
    input    logic[1:0]                     core0_dmem_width          , // DMEM data width
    input    logic [`YCR_DMEM_AWIDTH-1:0]   core0_dmem_addr           , // DMEM address
    input    logic [`YCR_DMEM_DWIDTH-1:0]   core0_dmem_wdata          , // DMEM write data
    output   logic [`YCR_DMEM_DWIDTH-1:0]   core0_dmem_rdata          , // DMEM read data
    output   logic [1:0]                    core0_dmem_resp,           // DMEM response


    //------------------------------------------------------------------
    // Toward Wb
    // -----------------------------------------------------------------
    input  logic   [3:0]                    cfg_wcska                 ,
    input  logic                            wbd_clk_int               ,
    output logic                            wbd_clk_skew              ,

    input   logic                           wb_rst_n                  , // Wish bone reset
    input   logic                           wb_clk                    , // wish bone clock
    // Data Memory Interface
    output  logic  [3:0]                    wbd_mid_o                 , // Master ID
    output  logic                           wbd_dmem_stb_o            , // strobe/request
    output  logic                           wbd_dmem_cyc_o            , // strobe/request
    output  logic   [YCR_WB_WIDTH-1:0]      wbd_dmem_adr_o            , // address
    output  logic                           wbd_dmem_we_o             , // write
    output  logic   [YCR_WB_WIDTH-1:0]      wbd_dmem_dat_o            , // data output
    output  logic   [3:0]                   wbd_dmem_sel_o            , // byte enable
    output  logic   [9:0]                   wbd_dmem_bl_o             , // byte enable
    output  logic                           wbd_dmem_bry_o            , // burst ready
    input   logic   [YCR_WB_WIDTH-1:0]      wbd_dmem_dat_i            , // data input
    input   logic                           wbd_dmem_ack_i            , // acknowlegement
    input   logic                           wbd_dmem_lack_i           , // last ack
    input   logic                           wbd_dmem_err_i              // error




);
//-------------------------------------------------------------------------------
// Local parameters
//-------------------------------------------------------------------------------
localparam int unsigned YCR_CLUSTER_TOP_RST_SYNC_STAGES_NUM            = 2;

//-------------------------------------------------------------------------------
// Local signal declaration
//-------------------------------------------------------------------------------
logic                                              cpu_intf_rst_n_sync;


// Data memory interface from router to WB bridge
logic                          core_dmem_req_ack         ;
logic                          core_dmem_req             ;
logic                          core_dmem_cmd             ;
logic [1:0]                    core_dmem_width           ;
logic [`YCR_DMEM_AWIDTH-1:0]   core_dmem_addr            ;
logic [`YCR_IMEM_BSIZE-1:0]    core_dmem_bl              ;
logic [`YCR_DMEM_DWIDTH-1:0]   core_dmem_wdata           ;
logic [`YCR_DMEM_DWIDTH-1:0]   core_dmem_rdata           ;
logic [1:0]                    core_dmem_resp            ;

// Data memory interface from router to memory-mapped timer
logic                                              timer_dmem_req_ack;
logic                                              timer_dmem_req;
logic                                              timer_dmem_cmd;
logic [1:0]                                        timer_dmem_width;
logic [`YCR_DMEM_AWIDTH-1:0]                       timer_dmem_addr;
logic [`YCR_DMEM_DWIDTH-1:0]                       timer_dmem_wdata;
logic [`YCR_DMEM_DWIDTH-1:0]                       timer_dmem_rdata;
logic [1:0]                                        timer_dmem_resp;

logic [31:0]                                       riscv_glbl_cfg          ;   
logic [23:0]                                       riscv_clk_cfg           ;   
logic [7:0]                                        riscv_sleep             ;
logic [7:0]                                        riscv_wakeup            ;
logic [63:0]                                       timer_val               ;                // Machine timer value
logic                                              timer_irq               ;


//---------------------------------------------------------------------------------
// Providing cpu clock feed through iconnect for better physical routing
//---------------------------------------------------------------------------------

assign      riscv_wakeup = 'h0;
assign      wbd_mid_o =  `WBI_MID_RISCV;
assign      core0_sleep = 1'b0;
assign      core0_clk   = core_clk_int;
//---------------------------------------------------------------------------------
// To improve the physical routing irq signal are buffer inside the block
// --------------------------------------------------------------------------------
assign core0_irq_lines  =  core_irq_lines_i         ; // External interrupt request lines
assign core0_irq_soft   =  core_irq_soft_i          ; // Software generated interrupt request
//---------------------------------------------------------------------------------
// To avoid core level power hook up, we have brought this signal inside, to
// avoid any cell at digital core level
// --------------------------------------------------------------------------------
assign test_mode = 1'b0;
assign test_rst_n = 1'b0;

wire [63:0]  riscv_debug0 = {core0_imem_req,core0_imem_req_ack,core0_imem_resp[1:0],
	                     core0_dmem_req,core0_dmem_req_ack,core0_dmem_resp[1:0],
	                     core_dmem_req,core_dmem_req_ack, 1'b0,1'b0,
	                     1'b0,1'b0, 1'b0, core0_debug };


assign core0_timer_val          = timer_val     ;                // Machine timer value
assign core0_timer_irq          = timer_irq     ;



//--------------------------------------------
// RISCV clock skew control
//--------------------------------------------
clk_skew_adjust u_skew_core_clk
       (
`ifdef USE_POWER_PINS
     .vccd1                   (vccd1                   ),// User area 1 1.8V supply
     .vssd1                   (vssd1                   ),// User area 1 digital ground
`endif
	    .clk_in               (core_clk_int            ), 
	    .sel                  (cfg_ccska               ), 
	    .clk_out              (core_clk_skew           ) 
       );

//-------------------------------------------------------------------------------
// Reset logic
//-------------------------------------------------------------------------------
// Power-Up Reset synchronizer

// CPU Reset synchronizer
ycr_reset_sync_cell #(
    .STAGES_AMOUNT       (YCR_CLUSTER_TOP_RST_SYNC_STAGES_NUM)
) i_cpu_intf_rstn_reset_sync (
    .rst_n          (pwrup_rst_n          ),
    .clk            (core_clk             ),
    .test_rst_n     (test_rst_n           ),
    .test_mode      (test_mode            ),
    .rst_n_in       (cpu_intf_rst_n       ),
    .rst_n_out      (cpu_intf_rst_n_sync  )
);

// Unique core it lower bits
assign core0_uid = 2'b00;

assign riscv_debug = riscv_debug0 ;
assign wbd_dmem_bl_o[9:3] = 'h0;

ycr_cross_bar u_crossbar (
    
    .rst_n                 (cpu_intf_rst_n_sync        ),
    .clk                   (core_clk                   ),

   

    .core0_imem_req_ack    (core0_imem_req_ack         ),
    .core0_imem_req        (core0_imem_req             ),
    .core0_imem_cmd        (core0_imem_cmd             ),
    .core0_imem_width      (YCR_MEM_WIDTH_WORD         ),
    .core0_imem_addr       (core0_imem_addr            ),
    .core0_imem_bl         (core0_imem_bl              ),             
    .core0_imem_wdata      ('h0                        ),
    .core0_imem_rdata      (core0_imem_rdata           ),
    .core0_imem_resp       (core0_imem_resp            ),
                                                 
                                                 
    .core0_dmem_req_ack    (core0_dmem_req_ack         ),
    .core0_dmem_req        (core0_dmem_req             ),
    .core0_dmem_cmd        (core0_dmem_cmd             ),
    .core0_dmem_width      (core0_dmem_width           ),
    .core0_dmem_addr       (core0_dmem_addr            ),
    .core0_dmem_bl         (3'h1                       ),             
    .core0_dmem_wdata      (core0_dmem_wdata           ),
    .core0_dmem_rdata      (core0_dmem_rdata           ),
    .core0_dmem_resp       (core0_dmem_resp            ),
                                                 
                                                 
    // Interface to WB bridge
    .port0_req_ack         (core_dmem_req_ack          ),
    .port0_req             (core_dmem_req              ),
    .port0_cmd             (core_dmem_cmd              ),
    .port0_width           (core_dmem_width            ),
    .port0_addr            (core_dmem_addr             ),
    .port0_bl              (core_dmem_bl               ), 
    .port0_wdata           (core_dmem_wdata            ),
    .port0_rdata           (core_dmem_rdata            ),
    .port0_resp            (core_dmem_resp             ),
    
    // Interface to memory-mapped timer
    .port4_req_ack         (timer_dmem_req_ack         ),
    .port4_req             (timer_dmem_req             ),
    .port4_cmd             (timer_dmem_cmd             ),
    .port4_width           (timer_dmem_width           ),
    .port4_addr            (timer_dmem_addr            ),
    .port4_bl              (                           ), // Not Supported
    .port4_wdata           (timer_dmem_wdata           ),
    .port4_rdata           (timer_dmem_rdata           ),
    .port4_resp            (timer_dmem_resp            )

);

//-------------------------------------------------------------------------------
// Memory-mapped timer instance
//-------------------------------------------------------------------------------
ycr_timer i_timer (
    // Common
    .rst_n          (cpu_intf_rst_n_sync  ),
    .clk            (core_clk             ),
    .rtc_clk        (rtc_clk              ),

    // Memory interface
    .dmem_req       (timer_dmem_req    ),
    .dmem_cmd       (timer_dmem_cmd    ),
    .dmem_width     (timer_dmem_width  ),
    .dmem_addr      (timer_dmem_addr   ),
    .dmem_wdata     (timer_dmem_wdata  ),
    .dmem_req_ack   (timer_dmem_req_ack),
    .dmem_rdata     (timer_dmem_rdata  ),
    .dmem_resp      (timer_dmem_resp   ),

    // Timer interface
    .timer_val      (timer_val         ),
    .timer_irq      (timer_irq         ),

    .riscv_glbl_cfg (riscv_glbl_cfg    ),
    .riscv_clk_cfg  (riscv_clk_cfg     ),
    .riscv_sleep    (riscv_sleep       ),
    .riscv_wakeup   (riscv_wakeup      )
);

//----------------------------------------------------------------------
//  Interface
//  -------------------------------------------------------------------

ycr_intf u_intf(
`ifdef USE_POWER_PINS
    .vccd1                     (vccd1), // User area 1 1.8V supply
    .vssd1                     (vssd1), // User area 1 digital ground
`endif

    .core_clk                 (core_clk        ), // Core clock


     // WB  clock skew control
    .cfg_wcska                (cfg_wcska                 ),
    .wbd_clk_int              (wbd_clk_int               ),
    .wbd_clk_skew             (wbd_clk_skew              ),


    // Control
    .pwrup_rst_n               (pwrup_rst_n               ), // Power-Up Reset
    .cpu_intf_rst_n            (cpu_intf_rst_n_sync       ), // CPU interface reset

    // Data memory interface from router to WB bridge
    .core_dmem_req_ack         (core_dmem_req_ack         ),
    .core_dmem_req             (core_dmem_req             ),
    .core_dmem_cmd             (core_dmem_cmd             ),
    .core_dmem_width           (core_dmem_width           ),
    .core_dmem_addr            (core_dmem_addr            ),
    .core_dmem_bl              (core_dmem_bl              ),
    .core_dmem_wdata           (core_dmem_wdata           ),
    .core_dmem_rdata           (core_dmem_rdata           ),
    .core_dmem_resp            (core_dmem_resp            ),
    //--------------------------------------------
    // Wishbone  
    // ------------------------------------------

    .wb_rst_n                  (wb_rst_n                  ), // Wish bone reset
    .wb_clk                    (wb_clk                    ), // wish bone clock

    // Data Memory Interface
    .wbd_dmem_cyc_o            (wbd_dmem_cyc_o            ), // strobe/request
    .wbd_dmem_stb_o            (wbd_dmem_stb_o            ), // strobe/request
    .wbd_dmem_adr_o            (wbd_dmem_adr_o            ), // address
    .wbd_dmem_we_o             (wbd_dmem_we_o             ), // write
    .wbd_dmem_dat_o            (wbd_dmem_dat_o            ), // data output
    .wbd_dmem_sel_o            (wbd_dmem_sel_o            ), // byte enable
    .wbd_dmem_bl_o             (wbd_dmem_bl_o[2:0]        ), // byte enable
    .wbd_dmem_bry_o            (wbd_dmem_bry_o            ), // burst ready
    .wbd_dmem_dat_i            (wbd_dmem_dat_i            ), // data input
    .wbd_dmem_ack_i            (wbd_dmem_ack_i            ), // acknowlegement
    .wbd_dmem_lack_i           (wbd_dmem_lack_i           ), // acknowlegement
    .wbd_dmem_err_i            (wbd_dmem_err_i            )  // error

);


endmodule : ycr_iconnect
