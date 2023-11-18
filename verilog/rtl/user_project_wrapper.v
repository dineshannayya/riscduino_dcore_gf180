/////////////////////////////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021 , Dinesh Annayya                                                 ////
//                                                                                               ////
// Licensed under the Apache License, Version 2.0 (the "License");                               ////
// you may not use this file except in compliance with the License.                              ////
// You may obtain a copy of the License at                                                       ////
//                                                                                               ////
//      http://www.apache.org/licenses/LICENSE-2.0                                               ////
//                                                                                               ////
// Unless required by applicable law or agreed to in writing, software                           ////
// distributed under the License is distributed on an "AS IS" BASIS,                             ////
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.                      ////
// See the License for the specific language governing permissions and                           ////
// limitations under the License.                                                                ////
// SPDX-License-Identifier: Apache-2.0                                                           ////
// SPDX-FileContributor: Created by Dinesh Annayya <dinesh.annayya@gmail.com>                    ////
//                                                                                               ////
/////////////////////////////////////////////////////////////////////////////////////////////////////
////                                                                                             ////
////  Digital core                                                                               ////
////                                                                                             ////
////  This file is part of the riscduino cores project                                           ////
////                                                                                             ////
////  Description                                                                                ////
////      This is digital core and integrate all the main block                                  ////
////      here.  Following block are integrated here                                             ////
////                                                                                             ////
////  To Do:                                                                                     ////
////    nothing                                                                                  ////
////                                                                                             ////
////  Author(s):                                                                                 ////
////      - Dinesh Annayya, dinesh.annayya@gmail.com                                             ////
////                                                                                             ////
////  Revision :                                                                                 ////
////    0.1 - 18th Nov 2023, Dinesh A                                                            ////
////          Initial integration 
////                                                                                             ////
////                                                                                             ////
/////////////////////////////////////////////////////////////////////////////////////////////////////
////                                                                                             ////
////          Copyright (C) 2000 Authors and OPENCORES.ORG                                       ////
////                                                                                             ////
////          This source file may be used and distributed without                               ////
////          restriction provided that this copyright statement is not                          ////
////          removed from the file and that any derivative work contains                        ////
////          the original copyright notice and the associated disclaimer.                       ////
////                                                                                             ////
////          This source file is free software; you can redistribute it                         ////
////          and/or modify it under the terms of the GNU Lesser General                         ////
////          Public License as published by the Free Software Foundation;                       ////
////          either version 2.1 of the License, or (at your option) any                         ////
////          later version.                                                                     ////
////                                                                                             ////
////          This source is distributed in the hope that it will be                             ////
////          useful, but WITHOUT ANY WARRANTY; without even the implied                         ////
////          warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR                            ////
////          PURPOSE.  See the GNU Lesser General Public License for more                       ////
////          details.                                                                           ////
////                                                                                             ////
////          You should have received a copy of the GNU Lesser General                          ////
////          Public License along with this source; if not, download it                         ////
////          from http://www.opencores.org/lgpl.shtml                                           ////
////                                                                                             ////
/////////////////////////////////////////////////////////////////////////////////////////////////////


`include "user_params.svh"

module user_project_wrapper #(parameter WB_WIDTH = 32) (
`ifdef USE_POWER_PINS
    inout vdd,		// User area 5.0V supply
    inout vss,		// User area ground
`endif
    input   wire                       wb_clk_i        ,  // System clock
    input   wire                       user_clock2     ,  // user Clock
    input   wire                       wb_rst_i        ,  // Regular Reset signal

    input   wire                       wbs_cyc_i       ,  // strobe/request
    input   wire                       wbs_stb_i       ,  // strobe/request
    input   wire [WB_WIDTH-1:0]        wbs_adr_i       ,  // address
    input   wire                       wbs_we_i        ,  // write
    input   wire [WB_WIDTH-1:0]        wbs_dat_i       ,  // data output
    input   wire [3:0]                 wbs_sel_i       ,  // byte enable
    output  wire [WB_WIDTH-1:0]        wbs_dat_o       ,  // data input
    output  wire                       wbs_ack_o       ,  // acknowlegement

 
    // Logic Analyzer Signals
    input  wire [63:0]                la_data_in      ,
    output wire [63:0]                la_data_out     ,
    input  wire [63:0]                la_oenb         ,
 

    // IOs
    input  wire  [37:0]                io_in           ,
    output wire  [37:0]                io_out          ,
    output wire  [37:0]                io_oeb          ,

    output wire  [2:0]                 user_irq             

);

////////////// clock skew ///////////////////
wire     wbd_wh_clk_skew,wbb_wh_clk;
wire     e_reset_n;
wire     p_reset_n;
wire     s_reset_n;
wire [31:0] system_strap;

wire               wbd_wh_cyc_i        ;  // strobe/request
wire               wbd_wh_stb_i        ;  // strobe/request
wire [31:0]        wbd_wh_adr_i        ;  // address
wire               wbd_wh_we_i         ;  // write
wire [31:0]        wbd_wh_dat_i        ;  // data output
wire [3:0]         wbd_wh_sel_i        ;  // byte enable

wire [31:0]        wbd_wh_dat_o      =la_data_out[63:32]   ;  // data input
wire               wbd_wh_ack_o      =la_data_out[32]      ;  // acknowlegement
wire               wbd_wh_err_o      =la_data_out[32]      ;  // error


assign io_out[37:0] = {cfg_clk_skew_ctrl1[13:8], cfg_clk_skew_ctrl2[31:0]};
assign io_oeb[35:0] = {wbd_wh_adr_i[31:0],wbd_wh_sel_i[3:0]};

assign la_data_out = {system_strap[31:0],wbd_wh_dat_i[31:0]};


////////////////////////////////////////////////////////
wire [31:0] cfg_clk_skew_ctrl1;

//wire [3:0] cfg_wcska_wi          = cfg_clk_skew_ctrl1[3:0];
wire [3:0] cfg_wcska_wh          = cfg_clk_skew_ctrl1[7:4];
//wire [3:0] cfg_wcska_riscv       = cfg_clk_skew_ctrl1[11:8];
//wire [3:0] cfg_wcska_qspi        = cfg_clk_skew_ctrl1[15:12];
//wire [3:0] cfg_wcska_uart        = cfg_clk_skew_ctrl1[19:16];
//wire [3:0] cfg_wcska_pinmux      = cfg_clk_skew_ctrl1[23:20];
//wire [3:0] cfg_wcska_qspi_co     = cfg_clk_skew_ctrl1[27:24];
//wire [3:0] cfg_wcska_peri        = cfg_clk_skew_ctrl1[31:28];

/////////////////////////////////////////////////////////
// RISCV Clock skew control
/////////////////////////////////////////////////////////
wire [31:0] cfg_clk_skew_ctrl2;

wire [3:0]   cfg_ccska_riscv_intf   = cfg_clk_skew_ctrl2[3:0];
wire [3:0]   cfg_ccska_riscv_icon   = cfg_clk_skew_ctrl2[7:4];
wire [3:0]   cfg_ccska_riscv_core0  = cfg_clk_skew_ctrl2[11:8];
wire [3:0]   cfg_ccska_riscv_core1  = cfg_clk_skew_ctrl2[15:12];
wire [3:0]   cfg_ccska_riscv_core2  = cfg_clk_skew_ctrl2[19:16];
wire [3:0]   cfg_ccska_riscv_core3  = cfg_clk_skew_ctrl2[23:20];
wire [3:0]   cfg_ccska_aes          = cfg_clk_skew_ctrl2[27:24];
wire [3:0]   cfg_ccska_fpu          = cfg_clk_skew_ctrl2[31:28];


/***********************************************
 Wishbone HOST
*************************************************/
wire uartm_txd;
wire uartm_rxd  = la_data_in[20];
wire sspis_sck  = la_data_in[21];       
wire sspis_ssn  = la_data_in[22];
wire sspis_si   = la_data_in[23];


wb_host u_wb_host(
`ifdef USE_POWER_PINS
          .vccd1                   (vdd                     ),// User area 1 1.8V supply
          .vssd1                   (vss                     ),// User area 1 digital ground
`endif

          .cfg_fast_sim            (                        ),
          .user_clock1             (wb_clk_i                ),
          .user_clock2             (user_clock2             ),

          .cpu_clk                 (                        ),

       // to/from Pinmux
          .xtal_clk                (wb_clk_i                ),  // need to connect to xtal-clk from pin mux - Dinesh
	      .e_reset_n               (user_irq[0]               ),  // external reset - Dinesh
	      .p_reset_n               (user_irq[1]               ),  // power-on reset - Dinesh
          .s_reset_n               (user_irq[2]               ),  // soft reset - Dinesh
          .cfg_strap_pad_ctrl      (                        ),
	      .system_strap            (system_strap            ),
	      .strap_sticky            (la_data_in[31:0]        ),

          .wbd_int_rst_n           (                        ),

    // Master Port
          .wbm_rst_i               (wb_rst_i                ),  
          .wbm_clk_i               (wb_clk_i                ),  
          .wbm_cyc_i               (wbs_cyc_i               ),  
          .wbm_stb_i               (wbs_stb_i               ),  
          .wbm_adr_i               (wbs_adr_i               ),  
          .wbm_we_i                (wbs_we_i                ),  
          .wbm_dat_i               (wbs_dat_i               ),  
          .wbm_sel_i               (wbs_sel_i               ),  
          .wbm_dat_o               (wbs_dat_o               ),  
          .wbm_ack_o               (wbs_ack_o               ),  
          .wbm_err_o               (                        ),  

    // Clock Skeq Adjust
          .wbd_clk_int             (wbb_wh_clk             ),
          .wbd_clk_wh              (wbd_wh_clk_skew        ),  
          .cfg_cska_wh             (cfg_wcska_wh           ),

    // Slave Port
          .wbs_clk_out             (wbb_wh_clk             ),
          .wbs_clk_i               (wbd_wh_clk_skew        ),  
          .wbs_cyc_o               (wbd_wh_cyc_i           ),  
          .wbs_stb_o               (io_oeb[37]             ),  
          .wbs_adr_o               (wbd_wh_adr_i           ),  
          .wbs_we_o                (io_oeb[36]             ),  
          .wbs_dat_o               (wbd_wh_dat_i           ),  
          .wbs_sel_o               (wbd_wh_sel_i           ),  
          .wbs_dat_i               (wbd_wh_dat_o           ),  
          .wbs_ack_i               (wbd_wh_ack_o           ),  
          .wbs_err_i               (wbd_wh_err_o           ),  

          .cfg_clk_skew_ctrl1      (cfg_clk_skew_ctrl1      ),
          .cfg_clk_skew_ctrl2      (cfg_clk_skew_ctrl2      ),

          .la_data_in              (la_data_in[19:0]        ),

          .uartm_rxd               (uartm_rxd               ),
          .uartm_txd               (uartm_txd               ),

          .sclk                    (sspis_sck               ),
          .ssn                     (sspis_ssn               ),
          .sdin                    (sspis_si                ),
          .sdout                   (sspis_so                ),
          .sdout_oen               (                        )

    );




endmodule : user_project_wrapper
