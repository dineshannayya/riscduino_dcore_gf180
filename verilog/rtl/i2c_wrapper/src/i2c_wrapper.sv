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
////  integrated  Master/Slave I2c                                ////
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
module i2c_wrapper 

     (  
`ifdef USE_POWER_PINS
   input logic         vccd1,// User area 1 1.8V supply
   input logic         vssd1,// User area 1 digital ground
`endif
   input logic         reset_n, // global reset
    // clock skew adjust
   input logic [3:0]   cfg_cska_i2c,
   input logic	       wbd_clk_int,
   output logic	       wbd_clk_skew,

   input logic  [1:0]  i2c_rstn    , // async reset
   input logic         app_clk     ,

   // Reg Bus Slave Interface Signal
   input logic         reg_slv_cs,
   input logic         reg_slv_wr,
   input logic [10:0]  reg_slv_addr,
   input logic [31:0]  reg_slv_wdata,
   input logic [3:0]   reg_slv_be,

   // Outputs
   output logic [31:0] reg_slv_rdata,
   output logic        reg_slv_ack,

   /////////////////////////////////////////////////////////
   // i2c interface
   ///////////////////////////////////////////////////////
   input logic         scl_pad_i              , // SCL-line input
   output logic        scl_pad_o              , // SCL-line output (always 1'b0)
   output logic        scl_pad_oen_o          , // SCL-line output enable (active low)
   
   input logic         sda_pad_i              , // SDA-line input
   output logic        sda_pad_o              , // SDA-line output (always 1'b0)
   output logic        sda_padoen_o           , // SDA-line output enable (active low)

   output logic        i2cm_intr_o            






     );

// sspi clock skew control
clk_skew_adjust u_skew_i2c
       (
`ifdef USE_POWER_PINS
               .vccd1      (vccd1                      ),// User area 1 1.8V supply
               .vssd1      (vssd1                      ),// User area 1 digital ground
`endif
	       .clk_in         (wbd_clk_int                ), 
	       .sel            (cfg_cska_i2c               ), 
	       .clk_out        (wbd_clk_skew               ) 
       );




//----------------------------------------
//  Register Response Path Mux
//  --------------------------------------
logic [7:0]  reg_i2cm_rdata;
logic         reg_i2cm_ack;

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



assign reg_slv_rdata   = (reg_blk_sel == `SEL_I2CM) ? {24'h0,reg_i2cm_rdata} : 'h0;
assign reg_slv_ack     = (reg_blk_sel == `SEL_I2CM) ? reg_i2cm_ack   : 1'b0;

wire reg_i2cm_cs  = (reg_blk_sel == `SEL_I2CM) ? reg_slv_cs : 1'b0;

i2cm_top  u_i2cm (
	// wishbone signals
	.wb_clk_i      (app_clk            ), // master clock input
	.sresetn       (1'b1               ), // synchronous reset
	.aresetn       (i2c_rstn[0]        ), // asynchronous reset
	.wb_adr_i      (reg_slv_addr[4:2]  ), // lower address bits
	.wb_dat_i      (reg_slv_wdata[7:0] ), // databus input
	.wb_dat_o      (reg_i2cm_rdata     ), // databus output
	.wb_we_i       (reg_slv_wr         ), // write enable input
	.wb_stb_i      (reg_i2cm_cs        ), // stobe/core select signal
	.wb_cyc_i      (reg_i2cm_cs        ), // valid bus cycle input
	.wb_ack_o      (reg_i2cm_ack       ), // bus cycle acknowledge output
	.wb_inta_o     (i2cm_intr_o        ), // interrupt request signal output

	// I2C signals
	// i2c clock line
	.scl_pad_i     (scl_pad_i          ), // SCL-line input
	.scl_pad_o     (scl_pad_o          ), // SCL-line output (always 1'b0)
	.scl_padoen_o  (scl_pad_oen_o      ), // SCL-line output enable (active low)

	// i2c data line
	.sda_pad_i     (sda_pad_i          ), // SDA-line input
	.sda_pad_o     (sda_pad_o          ), // SDA-line output (always 1'b0)
	.sda_padoen_o  (sda_padoen_o       )  // SDA-line output enable (active low)

         );


endmodule
