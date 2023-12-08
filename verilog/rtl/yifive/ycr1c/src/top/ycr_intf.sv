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
////  yifive interface block                                              ////
////                                                                      ////
////  This file is part of the yifive cores project                       ////
////  https://github.com/dineshannayya/ycr.git                            ////
////                                                                      ////
////  Description:                                                        ////
////     Holds interface block and icache/dcache logic                    ////
////                                                                      ////
////  To Do:                                                              ////
////    nothing                                                           ////
////                                                                      ////
////  Author(s):                                                          ////
////      - Dinesh Annayya, dinesha@opencores.org                         ////
////                                                                      ////
////  Revision :                                                          ////
////     v0:    June 7, 2021, Dinesh A                                    ////
////             Initial version                                          ////
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

module ycr_intf (
`ifdef USE_POWER_PINS
    input logic                             vccd1                     , // User area 1 1.8V supply
    input logic                             vssd1                     , // User area 1 digital ground
`endif

    input  logic   [3:0]                    cfg_wcska                 ,
    input  logic                            wbd_clk_int               ,
    output logic                            wbd_clk_skew              ,


    // Control
    input   logic                           pwrup_rst_n               , // Power-Up Reset
    // From clock gen
    input   logic [3:0]                     cfg_ccska                 ,
    input   logic                           core_clk_int              ,
    output  logic                           core_clk_skew             ,
    input   logic                           core_clk                  , // Core clock
    input   logic                           cpu_intf_rst_n            , // CPU interface reset


    // Data memory interface from router to WB bridge
    output   logic                          core_dmem_req_ack         ,
    output   logic [`YCR_DMEM_DWIDTH-1:0]   core_dmem_rdata           ,
    output   logic [1:0]                    core_dmem_resp            ,
    input    logic                          core_dmem_req             ,
    input    logic                          core_dmem_cmd             ,
    input    logic [1:0]                    core_dmem_width           ,
    input    logic [`YCR_DMEM_AWIDTH-1:0]   core_dmem_addr            ,
    input    logic [`YCR_IMEM_BSIZE-1:0]    core_dmem_bl              ,
    input    logic [`YCR_DMEM_DWIDTH-1:0]   core_dmem_wdata           ,
    //--------------------------------------------
    // Wishbone  
    // ------------------------------------------

    input   logic                           wb_rst_n                  , // Wish bone reset
    input   logic                           wb_clk                    , // wish bone clock
    // Data Memory Interface
    output  logic                           wbd_dmem_stb_o            , // strobe/request
    output  logic                           wbd_dmem_cyc_o            , // strobe/request
    output  logic   [YCR_WB_WIDTH-1:0]      wbd_dmem_adr_o            , // address
    output  logic                           wbd_dmem_we_o             , // write
    output  logic   [YCR_WB_WIDTH-1:0]      wbd_dmem_dat_o            , // data output
    output  logic   [3:0]                   wbd_dmem_sel_o            , // byte enable
    output  logic   [YCR_WB_BL_DMEM-1:0]    wbd_dmem_bl_o             , // byte enable
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

//--------------------------------------------
// WB clock skew control
//--------------------------------------------
clk_skew_adjust u_skew_wb_clk
       (
`ifdef USE_POWER_PINS
     .vccd1                   (vccd1                   ),// User area 1 1.8V supply
     .vssd1                   (vssd1                   ),// User area 1 digital ground
`endif
	    .clk_in               (wbd_clk_int             ), 
	    .sel                  (cfg_wcska               ), 
	    .clk_out              (wbd_clk_skew            ) 
       );
//---------------------------------------------------------------------------------
// To avoid core level power hook up, we have brought this signal inside, to
// avoid any cell at digital core level
// --------------------------------------------------------------------------------
assign test_mode = 1'b0;
assign test_rst_n = 1'b0;


//-------------------------------------------------------------------------------
// Reset logic
//-------------------------------------------------------------------------------

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


//-------------------------------------------------------------------------------
// Data memory WB bridge
//-------------------------------------------------------------------------------
ycr_dmem_wb i_dmem_wb (
    .core_rst_n     (cpu_intf_rst_n_sync   ),
    .core_clk       (core_clk           ),
    // Interface to dmem router
    .dmem_req_ack   (core_dmem_req_ack   ),
    .dmem_req       (core_dmem_req       ),
    .dmem_cmd       (core_dmem_cmd       ),
    .dmem_width     (core_dmem_width     ),
    .dmem_addr      (core_dmem_addr      ),
    .dmem_bl        (core_dmem_bl        ),
    .dmem_wdata     (core_dmem_wdata     ),
    .dmem_rdata     (core_dmem_rdata     ),
    .dmem_resp      (core_dmem_resp      ),
    // WB interface
    .wb_rst_n       (wb_rst_n          ),
    .wb_clk         (wb_clk            ),
    .wbd_cyc_o      (wbd_dmem_cyc_o    ), 
    .wbd_stb_o      (wbd_dmem_stb_o    ), 
    .wbd_adr_o      (wbd_dmem_adr_o    ), 
    .wbd_we_o       (wbd_dmem_we_o     ),  
    .wbd_dat_o      (wbd_dmem_dat_o    ), 
    .wbd_sel_o      (wbd_dmem_sel_o    ), 
    .wbd_bl_o       (wbd_dmem_bl_o     ), 
    .wbd_bry_o      (wbd_dmem_bry_o     ), 
    .wbd_dat_i      (wbd_dmem_dat_i    ), 
    .wbd_ack_i      (wbd_dmem_ack_i    ), 
    .wbd_lack_i     (wbd_dmem_lack_i    ), 
    .wbd_err_i      (wbd_dmem_err_i    )
);

endmodule : ycr_intf
