
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
////  integrated USB1.1 Host & Device                             ////
////                                                              ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description: This module integarte                          ////
////   USB 1.1 Host/Device.                                       ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesh.annayya@gmail.com              ////
////                                                              ////
////  Revision :                                                  ////
////         0.1 - 24 Nov 2023, Dinesh-A                          ////
////                Initial Version                               ////
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
module usb_wrapper 

     (  
`ifdef USE_POWER_PINS
   input logic         vccd1,// User area 1 1.8V supply
   input logic         vssd1,// User area 1 digital ground
`endif
   input logic         reset_n, // global reset
    // clock skew adjust
   input logic [3:0]   cfg_cska_usb,
   input logic	       wbd_clk_int,
   output logic	       wbd_clk_skew,

   input logic         usbh_rstn  ,  // async reset
   input logic         usbd_rstn  ,  // async reset
   input logic         app_clk    ,
   input logic         usb_clk    ,   // 48Mhz usb clock

        // Reg Bus Interface Signal
   input logic         reg_cs,
   input logic         reg_wr,
   input logic [10:0]  reg_addr,
   input logic [31:0]  reg_wdata,
   input logic [3:0]   reg_be,

        // Outputs
   output logic [31:0] reg_rdata,
   output logic        reg_ack,

   // USB 1.1 HOST I/F
   input  logic        usbh_in_dp              ,
   input  logic        usbh_in_dn              ,

   output logic        usbh_out_dp             ,
   output logic        usbh_out_dn             ,
   output logic        usbh_out_tx_oen         ,
   
   output logic        usbh_intr_o            ,

   // USB 1.1 DEVICE I/F
   input  logic        usbd_in_dp              ,
   input  logic        usbd_in_dn              ,

   output logic        usbd_out_dp             ,
   output logic        usbd_out_dn             ,
   output logic        usbd_out_tx_oen         ,
   
   output logic        usbd_intr_o            


     );

// uart clock skew control
clk_skew_adjust u_skew_uart
       (
`ifdef USE_POWER_PINS
               .vccd1      (vccd1                      ),// User area 1 1.8V supply
               .vssd1      (vssd1                      ),// User area 1 digital ground
`endif
	       .clk_in     (wbd_clk_int                ), 
	       .sel        (cfg_cska_usb               ), 
	       .clk_out    (wbd_clk_skew                ) 
       );


//----------------------------------------
//  Register Response Path Mux
//  --------------------------------------
logic [31:0]  reg_usbh_rdata;
logic [31:0]  reg_usbd_rdata;
logic         reg_usbh_ack;
logic         reg_usbd_ack;


// Reset Sync
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

assign reg_rdata   = (reg_blk_sel == `SEL_USBH) ? reg_usbh_rdata : 
	                 (reg_blk_sel == `SEL_USBD) ? reg_usbd_rdata : 'h0;
assign reg_ack     = (reg_blk_sel == `SEL_USBH) ? reg_usbh_ack  :
	                 (reg_blk_sel == `SEL_USBD) ? reg_usbd_ack  : 1'b0;

wire reg_usbh_cs   = (reg_blk_sel == `SEL_USBH) ? reg_cs : 1'b0;
wire reg_usbd_cs   = (reg_blk_sel == `SEL_USBD) ? reg_cs : 1'b0;


//----------------------------------
// USB 1.1 HOST
//----------------------------------

usb1_host u_usb_host (
    .usb_clk_i      (usb_clk        ),
    .usb_rstn_i     (usbh_rstn      ),

    // USB D+/D-
    .in_dp          (usbh_in_dp     ),
    .in_dn          (usbh_in_dn     ),

    .out_dp         (usbh_out_dp    ),
    .out_dn         (usbh_out_dn    ),
    .out_tx_oen     (usbh_out_tx_oen),

    // Master Port
    .wbm_rst_n      (usbh_rstn      ),  // Regular Reset signal
    .wbm_clk_i      (app_clk        ),  // System clock
    .wbm_stb_i      (reg_usbh_cs    ),  // strobe/request
    .wbm_adr_i      (reg_addr[5:0]  ),  // address
    .wbm_we_i       (reg_wr         ),  // write
    .wbm_dat_i      (reg_wdata      ),  // data output
    .wbm_sel_i      (reg_be         ),  // byte enable
    .wbm_dat_o      (reg_usbh_rdata ),  // data input
    .wbm_ack_o      (reg_usbh_ack   ),  // acknowlegement
    .wbm_err_o      (               ),  // error

    // Outputs
    .usb_intr_o    ( usbh_intr_o    )

    );

//----------------------------------
// USB 1.1 Device
//----------------------------------

usb1bd_top  u_usb_device(
     .usb_clk      (usb_clk), 
     .app_clk      (app_clk), 
     .arst_n       (usbd_rstn),

     // Transciever Interface
     .usb_txoe     (usbd_out_tx_oen), // USB TX OEN, Output driven at txoe=0
     .usb_txdp     (usbd_out_dp),
     .usb_txdn     (usbd_out_dn),

     .usb_rxdp     (usbd_in_dp),
     .usb_rxdn     (usbd_in_dn),

	// Register Interface

     .app_reg_req     (reg_usbd_cs),
     .app_reg_addr    (reg_addr[5:2]),
     .app_reg_we      (reg_wr),
     .app_reg_be      (reg_be),
     .app_reg_wdata   (reg_wdata),

	 .app_reg_rdata   (reg_usbd_rdata),
	 .app_reg_ack     (reg_usbd_ack),

     .usb_irq         (usbd_intr_o)

        );      


endmodule
