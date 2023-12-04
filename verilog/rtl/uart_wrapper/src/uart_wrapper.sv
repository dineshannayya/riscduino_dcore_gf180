
//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021 , Dinesh Annayya                          
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0
// SPDX-FileContributor: Created by Dinesh Annayya <dinesha@opencores.org>
//
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  integrated  multiple UART                                   ////
////                                                              ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description: This module integarte Uart                     ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////         0.2 - 7 April 2022, Dinesh-A                         ////
////               2nd Uart Integrated                            ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////


`include "user_params.svh"

module uart_wrapper 

     (  
`ifdef USE_POWER_PINS
   input logic         vccd1,// User area 1 1.8V supply
   input logic         vssd1,// User area 1 digital ground
`endif
   input logic         reset_n, // global reset
    // clock skew adjust
   input logic [3:0]   cfg_cska_uart,
   input logic	       wbd_clk_int,
   output logic	       wbd_clk_uart,

   input logic  [2:0]  uart_rstn  , // async reset
   input logic         app_clk     ,

        // Reg Bus Interface Signal
   input logic         reg_cs,
   input logic         reg_wr,
   input logic [10:0]  reg_addr,
   input logic [31:0]  reg_wdata,
   input logic [3:0]   reg_be,

        // Outputs
   output logic [31:0] reg_rdata,
   output logic        reg_ack,

   // Wb Master I/F
   output  logic        wbm_uart_cyc_o       ,  // strobe/request
   output  logic        wbm_uart_stb_o       ,  // strobe/request
   output  logic [31:0] wbm_uart_adr_o       ,  // address
   output  logic        wbm_uart_we_o        ,  // write
   output  logic [31:0] wbm_uart_dat_o       ,  // data output
   output  logic [3:0]  wbm_uart_sel_o       ,  // byte enable
   input   logic [31:0] wbm_uart_dat_i       ,  // data input
   input   logic        wbm_uart_ack_i       ,  // acknowlegement
   input   logic        wbm_uart_err_i       ,  // error



   // UART I/F
   input  logic  [2:0] uart_rxd               , 
   output logic  [2:0] uart_txd               

     );

// uart clock skew control
clk_skew_adjust u_skew_uart
       (
`ifdef USE_POWER_PINS
               .vccd1      (vccd1                      ),// User area 1 1.8V supply
               .vssd1      (vssd1                      ),// User area 1 digital ground
`endif
	       .clk_in     (wbd_clk_int                 ), 
	       .sel        (cfg_cska_uart               ), 
	       .clk_out    (wbd_clk_uart                ) 
       );




//----------------------------------------
//  Register Response Path Mux
//  --------------------------------------
logic [7:0]   reg_uart0_rdata;
logic [7:0]   reg_uart1_rdata;
logic [7:0]   reg_uart2_rdata;
logic         reg_uart0_ack;
logic         reg_uart1_ack;
logic         reg_uart2_ack;

//------------------------------
// Reset Sync
//------------------------------
logic         reset_ssn             ;  // Sync Reset
reset_sync  u_rst_sync (
	      .scan_mode  (1'b0         ),
          .dclk       (app_clk      ), // Destination clock domain
	      .arst_n     (reset_n      ), // active low async reset
          .srst_n     (reset_ssn    )
          );
//-------------------------------------------------
// Register Block Selection Logic, to break address => Ack timing path
//-------------------------------------------------
reg [2:0] reg_blk_sel;

always @(posedge app_clk or negedge reset_ssn)
begin
   if(reset_ssn == 1'b0) begin
     reg_blk_sel <= 'h0;
   end
   else begin
      if(reg_cs) reg_blk_sel <= reg_addr[8:6];
   end
end



assign reg_rdata = (reg_blk_sel == `SEL_UART0) ? {24'h0,reg_uart0_rdata} : 
	               (reg_blk_sel == `SEL_UART1) ? {24'h0,reg_uart1_rdata} : 
	               (reg_blk_sel == `SEL_UART2) ? {24'h0,reg_uart2_rdata} : 'h0;
assign reg_ack   = (reg_blk_sel == `SEL_UART0) ? reg_uart0_ack   : 
	               (reg_blk_sel == `SEL_UART1) ? reg_uart1_ack   : 
	               (reg_blk_sel == `SEL_UART2) ? reg_uart2_ack   : 1'b0;

wire reg_uart0_cs  = (reg_blk_sel == `SEL_UART0) ? reg_cs : 1'b0;
wire reg_uart1_cs  = (reg_blk_sel == `SEL_UART1) ? reg_cs : 1'b0;
wire reg_uart2_cs  = (reg_blk_sel == `SEL_UART2) ? reg_cs : 1'b0;

uart_core  u_uart0_core (  

        .arst_n      (uart_rstn[0]     ), // async reset
        .app_clk     (app_clk          ),

        // Reg Bus Interface Signal
        .reg_cs      (reg_uart0_cs     ),
        .reg_wr      (reg_wr           ),
        .reg_addr    (reg_addr[5:2]    ),
        .reg_wdata   (reg_wdata[7:0]   ),
        .reg_be      (reg_be[0]        ),

        // Outputs
        .reg_rdata   (reg_uart0_rdata[7:0]),
        .reg_ack     (reg_uart0_ack    ),

            // Pad Control
        .rxd          (uart_rxd[0]     ),
        .txd          (uart_txd[0]     )
     );

uart_core  u_uart1_core (  

        .arst_n      (uart_rstn[1]     ), // async reset
        .app_clk     (app_clk          ),

        // Reg Bus Interface Signal
        .reg_cs      (reg_uart1_cs     ),
        .reg_wr      (reg_wr           ),
        .reg_addr    (reg_addr[5:2]    ),
        .reg_wdata   (reg_wdata[7:0]   ),
        .reg_be      (reg_be[0]        ),

        // Outputs
        .reg_rdata   (reg_uart1_rdata[7:0]),
        .reg_ack     (reg_uart1_ack    ),

            // Pad Control
        .rxd          (uart_rxd[1]     ),
        .txd          (uart_txd[1]     )
     );



uartms_top u_uart2_core (  
        .arst_n      (uart_rstn[2]     ), // async reset
        .app_clk     (app_clk          ),

        // Reg Bus Interface Signal
        .reg_cs      (reg_uart2_cs     ),
        .reg_wr      (reg_wr           ),
        .reg_addr    (reg_addr[5:2]    ),
        .reg_wdata   (reg_wdata[7:0]   ),
        .reg_be      (reg_be[0]        ),

        // Outputs
        .reg_rdata   (reg_uart2_rdata[7:0]),
        .reg_ack     (reg_uart2_ack    ),


    // Master Port
        .wbm_cyc_o       (wbm_uart_cyc_o      ),  // strobe/request
        .wbm_stb_o       (wbm_uart_stb_o      ),  // strobe/request
        .wbm_adr_o       (wbm_uart_adr_o      ),  // address
        .wbm_we_o        (wbm_uart_we_o       ),  // write
        .wbm_dat_o       (wbm_uart_dat_o      ),  // data output
        .wbm_sel_o       (wbm_uart_sel_o      ),  // byte enable
        .wbm_dat_i       (wbm_uart_dat_i      ),  // data input
        .wbm_ack_i       (wbm_uart_ack_i      ),  // acknowlegement
        .wbm_err_i       (wbm_uart_err_i      ),  // error

       // Line Interface
        .rxd          (uart_rxd[2]     ),
        .txd          (uart_txd[2]     )

     );


endmodule
