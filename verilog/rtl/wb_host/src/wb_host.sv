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
////  Wishbone host Interface                                     ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////      This block does async Wishbone from one clock to other  ////
////      clock domain                                            ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 25th Feb 2021, Dinesh A                             ////
////          initial version                                     ////
////    0.2 - Nov 14 2021, Dinesh A                               ////
////          Reset connectivity bug fix clk_ctl in u_sdramclk    ////
////          u_cpuclk,u_rtcclk,u_usbclk                          ////
////    0.3 - Nov 16 2021, Dinesh A                               ////
////          Wishbone out are register for better timing         ////   
////    0.4 - Mar 15 2021, Dinesh A                               ////
////          1. To fix the bug in caravel mgmt soc address range ////
////          reduction to 0x3000_0000 to 0x300F_FFFF             ////
////          Address Map has changes as follows                  ////
////          0x3008_0000 to 0x3008_00FF - Local Wishbone Reg     ////
////          0x3000_0000 to 0x3007_FFFF - SOC access with        ////
////              indirect Map {Bank_Sel[15:3], wbm_adr_i[18:0]}  ////
////          2.wbm_cyc_i need to qualified with wbm_stb_i        //// 
////                                                              ////
////    0.5 - Aug 30 2022, Dinesh A                               ////
////          A. System strap related changes, reset_fsm added    ////
////          B. rtc and usb clock moved to pinmux                ////
////    0.6 - July 31, 2023, Dinesh A                             ////
////          Seperated Stop bit for uart tx and rx               ////
////          recomended setting rx = 0, tx = 1                   ////
////                                                              //// 
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

`include "user_reg_map.v"
`include "user_params.svh"

module wb_host (

`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
    output logic                cfg_fast_sim     ,  // 0 -> Normal, 1 -> Fast Sim
    input logic                 user_clock1      ,
    input logic                 user_clock2      ,

    output logic                cpu_clk          ,

    // Global Reset control
    output logic                wbd_int_rst_n    ,


    // to/from Pinmux
    input   logic              xtal_clk          ,
	output  logic              e_reset_n         ,  // external reset
	output  logic              p_reset_n         ,  // power-on reset
    output  logic              s_reset_n         ,  // soft reset
    output  logic              cfg_strap_pad_ctrl,
	output  logic [31:0]       system_strap      ,
	input   logic [31:0]       strap_sticky      ,


    // Master Port
    input   logic               wbm_rst_i        ,  // Regular Reset signal
    input   logic               wbm_clk_i        ,  // System clock
    input   logic               wbm_cyc_i        ,  // strobe/request
    input   logic               wbm_stb_i        ,  // strobe/request
    input   logic [31:0]        wbm_adr_i        ,  // address
    input   logic               wbm_we_i         ,  // write
    input   logic [31:0]        wbm_dat_i        ,  // data output
    input   logic [3:0]         wbm_sel_i        ,  // byte enable
    output  logic [31:0]        wbm_dat_o        ,  // data input
    output  logic               wbm_ack_o        ,  // acknowlegement
    output  logic               wbm_err_o        ,  // error

    // Clock Skew Adjust
    input   logic               wbd_clk_int      , 
    output  logic               wbd_clk_wh       ,
    input   logic [3:0]         cfg_cska_wh      , // clock skew adjust for web host

    // Slave Port
    output  logic               wbs_clk_out      ,  // System clock
    input   logic               wbs_clk_i        ,  // System clock
    output  logic               wbs_cyc_o        ,  // strobe/request
    output  logic               wbs_stb_o        ,  // strobe/request
    output  logic [31:0]        wbs_adr_o        ,  // address
    output  logic               wbs_we_o         ,  // write
    output  logic [31:0]        wbs_dat_o        ,  // data output
    output  logic [3:0]         wbs_sel_o        ,  // byte enable

    output  logic [3:0]         wbs_mid_o        ,  // master id
    output  logic               wbs_bry_o        ,  // burst ready
    output  logic [9:0]         wbs_bl_o         ,  // burst length


    input   logic [31:0]        wbs_dat_i        ,  // data input
    input   logic               wbs_ack_i        ,  // acknowlegement
    input   logic               wbs_err_i        ,  // error

    output logic [31:0]         cfg_clk_skew_ctrl1    ,
    output logic [31:0]         cfg_clk_skew_ctrl2    





    );


//--------------------------------
// local  dec
//
//--------------------------------
logic               wbm_rst_n;
logic               wbs_rst_n;
logic               strap_uartm;

logic               reg_sel    ;
logic [31:0]        reg_rdata  ;
logic               reg_ack    ;
logic [15:0]        cfg_bank_sel;



// Selected Master Port
logic               wb_cyc_i              ;  // strobe/request
logic               wb_stb_i              ;  // strobe/request
logic [31:0]        wb_adr_i              ;  // address
logic               wb_we_i               ;  // write
logic [31:0]        wb_dat_i              ;  // data output
logic [3:0]         wb_sel_i              ;  // byte enable
logic [31:0]        wb_dat_o              ;  // data input
logic               wb_ack_o              ;  // acknowlegement
logic               wb_err_o              ;  // error
logic [31:0]        wb_adr_int            ;
logic               wb_stb_int            ;
logic [31:0]        wb_dat_int            ; // data input
logic               wb_ack_int            ; // acknowlegement
logic               wb_err_int            ; // error

logic               arst_n                ;
logic               soft_reboot           ;
logic               clk_enb               ;


assign    wbs_mid_o = `WBI_MID_WBHOST;
assign    wbs_bry_o = 1'b1; // Always Ready
assign    wbs_bl_o =  'h1;  // Single burst

assign	  e_reset_n              = wbm_rst_n ;  // sync external reset
assign    cfg_strap_pad_ctrl     = !p_reset_n;

wire      soft_boot_req     = strap_sticky[`STRAP_SOFT_REBOOT_REQ];


//--------------------------------------------------------------------------------
// Look like wishbone reset removed early than user Power up sequence
// To control the reset phase, we have added additional control through la[0]
// ------------------------------------------------------------------------------
assign    arst_n = !wbm_rst_i;
reset_sync  u_wbm_rst (
	          .scan_mode  (1'b0           ),
              .dclk       (wbm_clk_i      ), // Destination clock domain
	          .arst_n     (arst_n         ), // active low async reset
              .srst_n     (wbm_rst_n      )
          );


// Dummy clock gate to balence avoid clk-skew between two branch for simulation handling
logic wbs_clk_g;
ctech_clk_gate u_clkgate (.GATE (1'b1), . CLK(wbs_clk_i), .GCLK(wbs_clk_g));


reset_sync  u_wbs_rst (
	          .scan_mode  (1'b0           ),
              .dclk       (wbs_clk_g      ), // Destination clock domain
	          .arst_n     (s_reset_n      ), // active low async reset
              .srst_n     (wbs_rst_n      )
          );

//------------------------------------------
// Reset FSM
//------------------------------------------
// Keep WBS in Ref clock during initial boot to strap loading 
logic force_refclk;
wbh_reset_fsm u_reset_fsm (
	      .clk                 (wbm_clk_i   ),
	      .e_reset_n           (e_reset_n   ),  // external reset
          .cfg_fast_sim        (cfg_fast_sim),
          .soft_boot_req       (soft_boot_req),

	      .p_reset_n           (p_reset_n   ),  // power-on reset
	      .s_reset_n           (s_reset_n   ),  // soft reset
          .clk_enb             (clk_enb     ),
          .soft_reboot         (soft_reboot ),
          .force_refclk        (force_refclk)

);



//--------------------------------------------------
// Arbitor to select between external wb vs uart wb 
//---------------------------------------------------
wire [1:0] grnt;
wb_arb u_arb(
	.clk      (wbm_clk_i), 
	.rstn     (s_reset_n), 
	.req      ({1'b0,1'b0,1'b0,(wbm_stb_i & wbm_cyc_i)}), 
	.gnt      (grnt)
        );

// Select  the master based on the grant
assign wb_cyc_i = (grnt == 2'b00) ? wbm_cyc_i               :'h0; 
assign wb_stb_i = (grnt == 2'b00) ?(wbm_cyc_i & wbm_stb_i)  :'h0; 
assign wb_adr_i = (grnt == 2'b00) ? wbm_adr_i               :'h0; 
assign wb_we_i  = (grnt == 2'b00) ? wbm_we_i                :'h0; 
assign wb_dat_i = (grnt == 2'b00) ? wbm_dat_i               :'h0; 
assign wb_sel_i = (grnt == 2'b00) ? wbm_sel_i               :'h0; 

assign wbm_dat_o = (grnt == 2'b00) ? wb_dat_o : 'h0;
assign wbm_ack_o = (grnt == 2'b00) ? wb_ack_o : 'h0;
assign wbm_err_o = (grnt == 2'b00) ? wb_err_o : 'h0;






// wb_host clock skew control
clk_skew_adjust u_skew_wh
       (
`ifdef USE_POWER_PINS
               .vccd1      (vccd1                      ),// User area 1 1.8V supply
               .vssd1      (vssd1                      ),// User area 1 digital ground
`endif
	       .clk_in     (wbd_clk_int               ), 
	       .sel        (cfg_cska_wh               ), 
	       .clk_out    (wbd_clk_wh                ) 
       );


// To reduce the load/Timing Wishbone I/F, Strobe is register to create
// multi-cycle
wire [31:0]  wb_dat_o1   = (reg_sel) ? reg_rdata : wb_dat_int;  // data input
wire         wb_ack_o1   = (reg_sel) ? reg_ack   : wb_ack_int; // acknowlegement
wire         wb_err_o1   = (reg_sel) ? 1'b0      : wb_err_int;  // error

logic wb_req;
// Hold fix for STROBE
wire  wb_stb_d1,wb_stb_d2,wb_stb_d3;
ctech_delay_buf u_delay1_stb0 (.X(wb_stb_d1),.A(wb_stb_i));
ctech_delay_buf u_delay2_stb1 (.X(wb_stb_d2),.A(wb_stb_d1));
ctech_delay_buf u_delay2_stb2 (.X(wb_stb_d3),.A(wb_stb_d2));
always_ff @(negedge s_reset_n or posedge wbm_clk_i) begin
    if ( s_reset_n == 1'b0 ) begin
       wb_req    <= '0;
	   wb_dat_o <= '0;
	   wb_ack_o <= '0;
	   wb_err_o <= '0;
   end else begin
       wb_req   <= wb_stb_d3 && ((wb_ack_o == 0) && (wb_ack_o1 == 0)) ;
       wb_ack_o <= wb_ack_o1;
       wb_err_o <= wb_err_o1;
       if(wb_ack_o1) // Keep last data in the bus
          wb_dat_o <= wb_dat_o1;
   end
end


//-----------------------------------------------------------------------
// Local register decide based on address[19] == 1
//
// Locally there register are define to control the reset and clock for user
// area
//-----------------------------------------------------------------------
// caravel user space is 0x3000_0000 to 0x300F_FFFF
// So we have allocated 
// 0x3008_0000 - 0x3008_00FF - Assigned to WB Host Address Space
// Since We need more than 16MB Address space to access SDRAM/SPI we have
// added indirect MSB 13 bit address select option
// So Address will be {Bank_Sel[15:3], wbm_adr_i[18:0]}
// ---------------------------------------------------------------------
assign reg_sel       = wb_req & (wb_adr_i[19] == 1'b1);

wbh_reg  u_reg (
               // System Signals
               // Inputs
		       .mclk               (wbm_clk_i      ),
	           .e_reset_n          (e_reset_n      ),  // external reset
	           .p_reset_n          (p_reset_n      ),  // power-on reset
               .s_reset_n          (s_reset_n      ),  // soft reset

               .clk_enb            (clk_enb     ),
               .force_refclk       (force_refclk   ),
               .soft_reboot        (soft_reboot    ),
	           .system_strap       (system_strap   ),
	           .strap_sticky       (strap_sticky   ),
      
               .user_clock1        (user_clock1    ),
               .user_clock2        (user_clock2    ),
               .xtal_clk           (xtal_clk       ),

		       // Reg Bus Interface Signal
               .reg_cs             (reg_sel        ),
               .reg_wr             (wb_we_i        ),
               .reg_addr           (wb_adr_i[4:2]  ),
               .reg_wdata          (wb_dat_i       ),
               .reg_be             (wb_sel_i       ),

               // Outputs
               .reg_rdata          (reg_rdata      ),
               .reg_ack            (reg_ack        ),


               // Global Reset control
               .wbd_int_rst_n      (wbd_int_rst_n  ),

               // CPU Clock and Reset
               .cpu_clk            (cpu_clk        ),

               // WishBone Slave Clkout/in
               .wbs_clk_out        (wbs_clk_out    ),  // System clock

               .cfg_bank_sel       (cfg_bank_sel  ),
               .cfg_clk_skew_ctrl1 (cfg_clk_skew_ctrl1  ),
               .cfg_clk_skew_ctrl2 (cfg_clk_skew_ctrl2  ),

               .cfg_fast_sim       (cfg_fast_sim   )
    );



//-----------------------------------------------------------------
//  Wishbone Slave Interface Logic starts here
//-----------------------------------------------------------------

assign wb_stb_int = wb_req & !reg_sel;

// Since design need more than 16MB address space, we have implemented
// indirect access
assign wb_adr_int = {cfg_bank_sel[15:3],wb_adr_i[18:0]};  

async_wb u_async_wb(
// Master Port
       .wbm_rst_n   (s_reset_n     ),  
       .wbm_clk_i   (wbm_clk_i     ),  
       .wbm_cyc_i   (wb_cyc_i      ),  
       .wbm_stb_i   (wb_stb_int    ),  
       .wbm_adr_i   (wb_adr_int    ),  
       .wbm_we_i    (wb_we_i       ),  
       .wbm_dat_i   (wb_dat_i      ),  
       .wbm_sel_i   (wb_sel_i      ),  
       .wbm_dat_o   (wb_dat_int    ),  
       .wbm_ack_o   (wb_ack_int    ),  
       .wbm_err_o   (wb_err_int    ),  

// Slave Port
       .wbs_rst_n   (wbs_rst_n     ),  
       .wbs_clk_i   (wbs_clk_g     ),  
       .wbs_cyc_o   (wbs_cyc_o     ),  
       .wbs_stb_o   (wbs_stb_o     ),  
       .wbs_adr_o   (wbs_adr_o     ),  
       .wbs_we_o    (wbs_we_o      ),  
       .wbs_dat_o   (wbs_dat_o     ),  
       .wbs_sel_o   (wbs_sel_o     ),  
       .wbs_dat_i   (wbs_dat_i     ),  
       .wbs_ack_i   (wbs_ack_i     ),  
       .wbs_err_i   (wbs_err_i     )

    );

endmodule
