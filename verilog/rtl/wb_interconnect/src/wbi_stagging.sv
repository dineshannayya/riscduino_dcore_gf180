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
////  Slave node arbiter                                          ////
////                                                              ////
////                                                              ////
////  Description                                                 ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////      - Dinesh Annayya, dinesh.annayya@gmail.com              ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 01 Dec 2023, Dinesh A                               ////
////          initial version                                     ////
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

module wbi_stagging 
     #(parameter AW  = 32,
       parameter BW  = 4,
       parameter BL  = 10,
       parameter DW  = 32

       )
       (
       input   logic               reset_n         ,  // Regular Reset signal
       input   logic               mclk            ,  // System clock

    // Master Command Port
       output  logic               wbm_cmd_wrdy_o  ,  // Ready path Ready to accept the data
       input   logic               wbm_cmd_wval_i  ,
       input   logic [AW-1:0]      wbm_cmd_adr_i   ,  // address
       input   logic               wbm_cmd_we_i    ,  // write
       input   logic [DW-1:0]      wbm_cmd_dat_i   ,  // data output
       input   logic [BW-1:0]      wbm_cmd_sel_i   ,  // byte enable
       input   logic [3:0]         wbm_cmd_tid_i   ,
       input   logic [BL-1:0]      wbm_cmd_bl_i    ,  // Burst Count

    // Master Response Port
       input   logic               wbm_res_rrdy_i  ,  // Ready path Ready to accept the data
       output  logic               wbm_res_rval_o  ,
       output  logic [DW-1:0]      wbm_res_dat_o   ,  // data input
       output  logic               wbm_res_ack_o   ,  // acknowlegement
       output  logic               wbm_res_lack_o  ,  // Last Burst access
       output  logic               wbm_res_err_o   ,  // error
       output  logic [3:0]         wbm_res_tid_o   ,

   // Next Daisy Chain Command
       input    logic              wbd_cmd_wrdy_i  ,  // Ready path Ready to accept the data
       output   logic              wbd_cmd_wval_o  ,
       output   logic [AW-1:0]     wbd_cmd_adr_o   ,  // address
       output   logic              wbd_cmd_we_o    ,  // write
       output   logic [DW-1:0]     wbd_cmd_dat_o   ,  // data output
       output   logic [BW-1:0]     wbd_cmd_sel_o   ,  // byte enable
       output   logic [3:0]        wbd_cmd_tid_o   ,
       output   logic [BL-1:0]     wbd_cmd_bl_o    ,  // Burst Count

    // Next Daisy Chain Response Port
       output  logic                wbd_res_rrdy_o  ,  // Ready path Ready to accept the data
       input   logic                wbd_res_rval_i  ,
       input   logic [DW-1:0]       wbd_res_dat_i   ,  // data input
       input   logic                wbd_res_ack_i   ,  // acknowlegement
       input   logic                wbd_res_lack_i  ,  // Last Burst access
       input   logic                wbd_res_err_i   ,  // error
       input   logic [3:0]          wbd_res_tid_i   


    );


//----------------------------------------
// Command Stagging
//----------------------------------------
logic wbd_cmd_hold;

assign wbm_cmd_wrdy_o = (wbd_cmd_hold == 0) || (wbd_cmd_wrdy_i && wbd_cmd_wval_o);
assign wbd_cmd_wval_o = (wbd_cmd_hold == 1);

always @ (posedge mclk or negedge reset_n)
begin 
   if (reset_n == 1'b0) begin
      wbd_cmd_adr_o    <= 'h0;
      wbd_cmd_we_o     <= 1'b0;
      wbd_cmd_dat_o    <= 'h0;
      wbd_cmd_sel_o    <= 'h0;
      wbd_cmd_tid_o    <= 'h0;
      wbd_cmd_bl_o     <= 'h0;
      wbd_cmd_hold     <= 1'b0;
   end else if (wbm_cmd_wval_i && wbm_cmd_wrdy_o) begin
      wbd_cmd_adr_o    <= wbm_cmd_adr_i; 
      wbd_cmd_we_o     <= wbm_cmd_we_i;  
      wbd_cmd_dat_o    <= wbm_cmd_dat_i; 
      wbd_cmd_sel_o    <= wbm_cmd_sel_i; 
      wbd_cmd_tid_o    <= wbm_cmd_tid_i; 
      wbd_cmd_bl_o     <= wbm_cmd_bl_i;  
      wbd_cmd_hold     <= 1'b1;    
   end else if (wbd_cmd_wrdy_i && wbd_cmd_wval_o) begin
      wbd_cmd_hold     <= 1'b0;    
   end                             
end                            


//----------------------------------------
// response Stagging
//----------------------------------------
logic wbm_res_hold;

assign wbd_res_rrdy_o = (wbm_res_hold == 0) || (wbm_res_rrdy_i && wbm_res_rval_o);
assign wbm_res_rval_o = (wbm_res_hold == 1);

always @ (posedge mclk or negedge reset_n)
begin 
   if (reset_n == 1'b0) begin
      wbm_res_dat_o     <= 'h0;
      wbm_res_ack_o     <= 1'b0;
      wbm_res_lack_o    <= 1'b0;
      wbm_res_err_o     <= 1'b0;
      wbm_res_tid_o     <= 'h0;
      wbm_res_hold      <= 1'b0;
   end else if (wbd_res_rval_i && wbd_res_rrdy_o) begin
      wbm_res_dat_o    <= wbd_res_dat_i;    
      wbm_res_ack_o    <= wbd_res_ack_i;    
      wbm_res_lack_o   <= wbd_res_lack_i;   
      wbm_res_err_o    <= wbd_res_err_i;    
      wbm_res_tid_o    <= wbd_res_tid_i;    
      wbm_res_hold     <= 1'b1;    
   end else if (wbd_cmd_wrdy_i && wbd_cmd_wval_o) begin
      wbm_res_hold     <= 1'b0;    
   end                             
end                                
                                   
                                   




endmodule

