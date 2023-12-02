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

module wbi_slave_port 
     #(parameter AW  = 32,
       parameter BW  = 4,
       parameter BL  = 10,
       parameter DW  = 32,
       parameter ADDR_MATCH_VALID1    = 1'b1,
       parameter ADDR_MATCH_MASK1     = 32'hFFFF_FFFF,
       parameter ADDR_MATCH_PATTERN1  = 32'hFFFF_FFFF,

       parameter ADDR_MATCH_VALID2    = 1'b0,
       parameter ADDR_MATCH_MASK2     = 32'hFFFF_FFFF,
       parameter ADDR_MATCH_PATTERN2  = 32'hFFFF_FFFF,

       parameter ADDR_MATCH_VALID3    = 1'b0,
       parameter ADDR_MATCH_MASK3     = 32'hFFFF_FFFF,
       parameter ADDR_MATCH_PATTERN3  = 32'hFFFF_FFFF,

       parameter ADDR_MATCH_VALID4    = 1'b0,
       parameter ADDR_MATCH_MASK4     = 32'hFFFF_FFFF,
       parameter ADDR_MATCH_PATTERN4  = 32'hFFFF_FFFF

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
       input    logic               wbd_cmd_wrdy_i  ,  // Ready path Ready to accept the data
       output   logic               wbd_cmd_wval_o  ,
       output   logic [AW-1:0]      wbd_cmd_adr_o   ,  // address
       output   logic               wbd_cmd_we_o    ,  // write
       output   logic [DW-1:0]      wbd_cmd_dat_o   ,  // data output
       output   logic [BW-1:0]      wbd_cmd_sel_o   ,  // byte enable
       output   logic [3:0]         wbd_cmd_tid_o   ,
       output   logic [BL-1:0]      wbd_cmd_bl_o    ,  // Burst Count

    // Next Daisy Chain Response Port
       output  logic               wbd_res_rrdy_o  ,  // Ready path Ready to accept the data
       input   logic               wbd_res_rval_i  ,
       input   logic [DW-1:0]      wbd_res_dat_i   ,  // data input
       input   logic               wbd_res_ack_i   ,  // acknowlegement
       input   logic               wbd_res_lack_i  ,  // Last Burst access
       input   logic               wbd_res_err_i   ,  // error
       input   logic [3:0]         wbd_res_tid_i   ,

    // Slave Port
       output  logic               wbs_cyc_o      ,  // strobe/request
       output  logic               wbs_stb_o      ,  // strobe/request
       output  logic [AW-1:0]      wbs_adr_o      ,  // address
       output  logic               wbs_we_o       ,  // write
       output  logic [DW-1:0]      wbs_dat_o      ,  // data output
       output  logic [BW-1:0]      wbs_sel_o      ,  // byte enable
       output  logic [3:0]         wbs_tid_o      ,
       output  logic [BL-1:0]      wbs_bl_o       ,  // Burst Count
       output  logic               wbs_bry_o      ,  // Busrt WData Avialble Or Ready To accept Rdata  
       input   logic [DW-1:0]      wbs_dat_i      ,  // data input
       input   logic               wbs_ack_i      ,  // acknowlegement
       input   logic               wbs_lack_i     ,  // Last Ack
       input   logic               wbs_err_i         // error

    );

typedef enum logic {
    ADDR_NO_MATCH,
    ADDR_MATCH
} type_sel_e;


//-------------------------------------------
// Command Path control generation
//--------------------------------------------
logic  slv_cmd_wval_i;
logic  slv_cmd_wrdy_o;
logic  stg_cmd_wval_i;
logic  stg_cmd_wrdy_o;

assign slv_cmd_wval_i   = (func_check_match(wbm_cmd_wval_i,wbm_cmd_adr_i) == ADDR_MATCH);
assign stg_cmd_wval_i  = wbm_cmd_wval_i && !slv_cmd_wval_i;
assign wbm_cmd_wrdy_o  = slv_cmd_wval_i ?  slv_cmd_wrdy_o: stg_cmd_wrdy_o;

//-------------------------------------------
// Response Path Control Generation
//--------------------------------------------
logic               wbi_grnt        ;
logic               slv_res_rrdy_i  ;
logic [DW-1:0]      slv_res_dat_o   ;  // data input
logic               slv_res_ack_o   ;  // acknowlegement
logic               slv_res_lack_o  ;  // Last Burst access
logic               slv_res_err_o   ;  // error
logic [3:0]         slv_res_tid_o   ;

logic               stg_res_rrdy_i  ;
logic [DW-1:0]      stg_res_dat_o   ;  // data input
logic               stg_res_ack_o   ;  // acknowlegement
logic               stg_res_lack_o  ;  // Last Burst access
logic               stg_res_err_o   ;  // error
logic [3:0]         stg_res_tid_o   ;

wbi_arb2 u_wbi_arb(
	.clk      (mclk ), 
	.rstn     (reset_n), 
	.req      ({stg_res_rval_o,slv_res_rval_o}), 
	.gnt      (wbi_grnt)
        );


assign slv_res_rrdy_i = (wbi_grnt == 1'b0) ?  wbm_res_rrdy_i : 1'b0;
assign stg_res_rrdy_i = (wbi_grnt == 1'b1) ?  wbm_res_rrdy_i : 1'b0;
assign wbm_res_rval_o = (wbi_grnt == 1'b0) ?  slv_res_rval_o : stg_res_rval_o ;
assign wbm_res_dat_o  = (wbi_grnt == 1'b0) ?  slv_res_dat_o  : stg_res_dat_o  ; 
assign wbm_res_ack_o  = (wbi_grnt == 1'b0) ?  slv_res_ack_o  : stg_res_ack_o  ; 
assign wbm_res_lack_o = (wbi_grnt == 1'b0) ?  slv_res_lack_o : stg_res_lack_o ; 
assign wbm_res_err_o  = (wbi_grnt == 1'b0) ?  slv_res_err_o  : stg_res_err_o  ; 
assign wbm_res_tid_o  = (wbi_grnt == 1'b0) ?  slv_res_tid_o  : stg_res_tid_o  ; 



// Stagging FF to break write and read timing path
// Assumption, CMD and Response are independent path
wbi_slave_node u_node(
         .clk_i                (mclk                ), 
         .rst_n                (reset_n             ),
         // WishBone Input master I/P
         .wbm_cmd_wrdy_o       (slv_cmd_wrdy_o      ),
         .wbm_cmd_val_i        (slv_cmd_wval_i      ),
         .wbm_cmd_adr_i        (wbm_cmd_adr_i       ),
         .wbm_cmd_sel_i        (wbm_cmd_sel_i       ),
         .wbm_cmd_we_i         (wbm_cmd_we_i        ),
         .wbm_cmd_dat_i        (wbm_cmd_dat_i       ),
         .wbm_cmd_bl_i         (wbm_cmd_bl_i        ),
         .wbm_cmd_tid_i        (wbm_cmd_tid_i       ),

         .wbm_res_rrdy_i       (slv_res_rrdy_i      ),
         .wbm_res_rval_o       (slv_res_rval_o      ),
         .wbm_res_dat_o        (slv_res_dat_o       ),
         .wbm_res_ack_o        (slv_res_ack_o       ),
         .wbm_res_lack_o       (slv_res_lack_o      ),
         .wbm_res_err_o        (slv_res_err_o       ),
         .wbm_res_tid_o        (slv_res_tid_o       ),

         // Slave Interface
         .wbs_dat_i            (wbs_dat_i           ),
         .wbs_ack_i            (wbs_ack_i           ),
         .wbs_lack_i           (wbs_lack_i          ),
         .wbs_err_i            (wbs_err_i           ),
         .wbs_dat_o            (wbs_dat_o           ),
         .wbs_adr_o            (wbs_adr_o           ),
         .wbs_sel_o            (wbs_sel_o           ),
         .wbs_bl_o             (wbs_bl_o            ),
         .wbs_bry_o            (wbs_bry_o           ),
         .wbs_we_o             (wbs_we_o            ),
         .wbs_cyc_o            (wbs_cyc_o           ),
         .wbs_stb_o            (wbs_stb_o           ),
         .wbs_tid_o            (                    )

);

//------------------------------------------------------
// Command/Response Stagging for Next Daisy chain
//-----------------------------------------------------

wbi_stagging  u_stagging (
       .reset_n                (reset_n            ),  // Regular Reset signal
       .mclk                   (mclk               ),  // System clock

    // Master Command Port
       .wbm_cmd_wrdy_o        (stg_cmd_wrdy_o      ),  // Ready path Ready to accept the data
       .wbm_cmd_wval_i        (stg_cmd_wval_i      ),
       .wbm_cmd_adr_i         (wbm_cmd_adr_i       ),  // address
       .wbm_cmd_we_i          (wbm_cmd_we_i        ),  // write
       .wbm_cmd_dat_i         (wbm_cmd_dat_i       ),  // data output
       .wbm_cmd_sel_i         (wbm_cmd_sel_i       ),  // byte enable
       .wbm_cmd_tid_i         (wbm_cmd_tid_i       ),
       .wbm_cmd_bl_i          (wbm_cmd_bl_i        ),  // Burst Count

    // Master Response Port
       .wbm_res_rrdy_i        (stg_res_rrdy_i      ),  // Ready path Ready to accept the data
       .wbm_res_rval_o        (stg_res_rval_o      ),
       .wbm_res_dat_o         (stg_res_dat_o       ),  // data input
       .wbm_res_ack_o         (stg_res_ack_o       ),  // acknowlegement
       .wbm_res_lack_o        (stg_res_lack_o      ),  // Last Burst access
       .wbm_res_err_o         (stg_res_err_o       ),  // error
       .wbm_res_tid_o         (stg_res_tid_o       ),

   // Next Daisy Chain Command
       .wbd_cmd_wrdy_i        (wbd_cmd_wrdy_i      ),  // Ready path Ready to accept the data
       .wbd_cmd_wval_o        (wbd_cmd_wval_o      ),
       .wbd_cmd_adr_o         (wbd_cmd_adr_o       ),  // address
       .wbd_cmd_we_o          (wbd_cmd_we_o        ),  // write
       .wbd_cmd_dat_o         (wbd_cmd_dat_o       ),  // data output
       .wbd_cmd_sel_o         (wbd_cmd_sel_o       ),  // byte enable
       .wbd_cmd_tid_o         (wbd_cmd_tid_o       ),
       .wbd_cmd_bl_o          (wbd_cmd_bl_o        ),  // Burst Count

    // Next Daisy Chain Response Port
       .wbd_res_rrdy_o        (wbd_res_rrdy_o      ),  // Ready path Ready to accept the data
       .wbd_res_rval_i        (wbd_res_rval_i      ),
       .wbd_res_dat_i         (wbd_res_dat_i       ),  // data input
       .wbd_res_ack_i         (wbd_res_ack_i       ),  // acknowlegement
       .wbd_res_lack_i        (wbd_res_lack_i      ),  // Last Burst access
       .wbd_res_err_i         (wbd_res_err_i       ),  // error
       .wbd_res_tid_i         (wbd_res_tid_i       )


    );




//---------------------------------------------------------------------
// Check the Slave Address Matches with incomming command
//---------------------------------------------------------------------
function type_sel_e  func_check_match;
input        stb;
input [31:0] mem_addr;
begin
   func_check_match    = ADDR_NO_MATCH;
   if (ADDR_MATCH_VALID1 && stb && ((mem_addr & ADDR_MATCH_MASK1) == ADDR_MATCH_PATTERN1)) begin
       func_check_match    = ADDR_MATCH;
   end else if (ADDR_MATCH_VALID2 && stb && ((mem_addr & ADDR_MATCH_MASK2) == ADDR_MATCH_PATTERN2)) begin
       func_check_match    = ADDR_MATCH;
   end else if (ADDR_MATCH_VALID3 && stb && ((mem_addr & ADDR_MATCH_MASK3) == ADDR_MATCH_PATTERN3)) begin
       func_check_match    = ADDR_MATCH;
   end else if (ADDR_MATCH_VALID4 && ((mem_addr & ADDR_MATCH_MASK4) == ADDR_MATCH_PATTERN4)) begin
       func_check_match    = ADDR_MATCH;
   end
end
endfunction
endmodule

