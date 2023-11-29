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
////  integrated  Master/Slave SSPI                               ////
////                                                              ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description: This module integarte sspi                     ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////         0.1 - 29 Nov 2023, Dinesh-A                          ////
////               initial version                                ////
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
module sspi_wrapper 

     (  
`ifdef USE_POWER_PINS
   input logic         vccd1,// User area 1 1.8V supply
   input logic         vssd1,// User area 1 digital ground
`endif
   input logic         reset_n, // global reset
    // clock skew adjust
   input logic [3:0]   cfg_cska_sspi,
   input logic	       wbd_clk_int,
   output logic	       wbd_clk_sspi,

   input logic  [1:0]  sspi_rstn   , // async reset
   input logic         app_clk     ,

   // Reg Bus Slave Interface Signal
   input logic         reg_slv_cs,
   input logic         reg_slv_wr,
   input logic [8:0]   reg_slv_addr,
   input logic [31:0]  reg_slv_wdata,
   input logic [3:0]   reg_slv_be,

   // Outputs
   output logic [31:0] reg_slv_rdata,
   output logic        reg_slv_ack,


   // SPIM I/F
   output logic        sspim_sck, // clock out
   output logic        sspim_so,  // serial data out
   input  logic        sspim_si,  // serial data in
   output logic [3:0]  sspim_ssn,  // cs_n


   // Wb Master I/F
   output  logic        wbm_sspis_cyc_o       ,  // strobe/request
   output  logic        wbm_sspis_stb_o       ,  // strobe/request
   output  logic [31:0] wbm_sspis_adr_o       ,  // address
   output  logic        wbm_sspis_we_o        ,  // write
   output  logic [31:0] wbm_sspis_dat_o       ,  // data output
   output  logic [3:0]  wbm_sspis_sel_o       ,  // byte enable
   input   logic [31:0] wbm_sspis_dat_i       ,  // data input
   input   logic        wbm_sspis_ack_i       ,  // acknowlegement
   input   logic        wbm_sspis_err_i       ,  // error

  input  logic          sspis_sck             ,
  input  logic          sspis_ssn             ,
  input  logic          sspis_si              ,
  output logic          sspis_so              



     );

// sspi clock skew control
clk_skew_adjust u_skew_sspi
       (
`ifdef USE_POWER_PINS
               .vccd1      (vccd1                      ),// User area 1 1.8V supply
               .vssd1      (vssd1                      ),// User area 1 digital ground
`endif
	       .clk_in         (wbd_clk_int                ), 
	       .sel            (cfg_cska_sspi              ), 
	       .clk_out        (wbd_clk_sspi               ) 
       );




//----------------------------------------
//  Register Response Path Mux
//  --------------------------------------
logic [31:0]  reg_sspim_rdata;
logic         reg_sspim_ack;

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
      if(reg_slv_cs) reg_blk_sel <= reg_slv_addr[8:6];
   end
end



assign reg_slv_rdata   = (reg_blk_sel == `SEL_SPIM) ? reg_sspim_rdata : 'h0;
assign reg_slv_ack     = (reg_blk_sel == `SEL_SPIM) ? reg_sspim_ack   : 1'b0;

wire reg_sspim_cs  = (reg_blk_sel == `SEL_SPIM) ? reg_slv_cs : 1'b0;

//--------------------------------------
// SPI Master
//-------------------------------------
sspim_top u_sspim (
     .clk          (app_clk         ),
     .reset_n      (sspi_rstn[0]    ),          
           
           
     //---------------------------------
     // Reg Bus Interface Signal
     //---------------------------------
     .reg_cs      (reg_sspim_cs             ),
     .reg_wr      (reg_slv_wr               ),
     .reg_addr    ({2'b0,reg_slv_addr[5:0]} ),
     .reg_wdata   (reg_slv_wdata            ),
     .reg_be      (reg_slv_be               ),

     // Outputs
     .reg_rdata   (reg_sspim_rdata   ),
     .reg_ack     (reg_sspim_ack     ),
           
      //-------------------------------------------
      // Line Interface
      //-------------------------------------------
           
      .sck           (sspim_sck), // clock out
      .so            (sspim_so),  // serial data out
      .si            (sspim_si),  // serial data in
      .ssn           (sspim_ssn)  // cs_n

   );


//----------------------------------------
// SPI as ISP
//----------------------------------------

sspis_top u_spi2wb(

	     .sys_clk         (app_clk            ),
	     .rst_n           (sspi_rstn[1]       ),

         .sclk            (sspis_sck         ),
         .ssn             (sspis_ssn          ),
         .sdin            (sspis_si           ),
         .sdout           (sspis_so           ),
         .sdout_oen       (                   ),

          // WB Master Port
         .wbm_cyc_o       (wbm_sspis_cyc_o      ),  // strobe/request
         .wbm_stb_o       (wbm_sspis_stb_o      ),  // strobe/request
         .wbm_adr_o       (wbm_sspis_adr_o      ),  // address
         .wbm_we_o        (wbm_sspis_we_o       ),  // write
         .wbm_dat_o       (wbm_sspis_dat_o      ),  // data output
         .wbm_sel_o       (wbm_sspis_sel_o      ),  // byte enable
         .wbm_dat_i       (wbm_sspis_dat_i      ),  // data input
         .wbm_ack_i       (wbm_sspis_ack_i      ),  // acknowlegement
         .wbm_err_i       (wbm_sspis_err_i      )   // error
    );






endmodule
