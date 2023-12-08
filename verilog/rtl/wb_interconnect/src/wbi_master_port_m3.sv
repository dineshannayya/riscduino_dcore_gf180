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

module wbi_master_port_m3 
     #(parameter AW  = 32,
       parameter BW  = 4,
       parameter BL  = 10,
       parameter DW  = 32,
       parameter CDP = 4,
       parameter RDP = 2
       )
       (
       input   logic               reset_n         ,  // Regular Reset signal
       input   logic               mclk            ,  // System clock

       input   logic               wbm_cyc_i   ,  // strobe/request
       input   logic               wbm_stb_i   ,  // strobe/request
       input   logic [AW-1:0]      wbm_adr_i   ,  // address
       input   logic               wbm_we_i    ,  // write
       input   logic [DW-1:0]      wbm_dat_i   ,  // data output
       input   logic [BW-1:0]      wbm_sel_i   ,  // byte enable
       input   logic [3:0]         wbm_tid_i   ,
       input   logic [BL-1:0]      wbm_bl_i    ,  // Burst Count
       input   logic               wbm_bry_i   ,  // Burst Ready
       output  logic [DW-1:0]      wbm_dat_o   ,  // data input
       output  logic               wbm_ack_o   ,  // acknowlegement
       output  logic               wbm_lack_o  ,  // Last Burst access
       output  logic               wbm_err_o   ,  // error


    // Master Command Port- from Previous Master Port
       output  logic               wbp_cmd_wrdy_o  ,  // Ready path Ready to accept the data
       input   logic               wbp_cmd_wval_i  ,
       input   logic [AW-1:0]      wbp_cmd_adr_i   ,  // address
       input   logic               wbp_cmd_we_i    ,  // write
       input   logic [DW-1:0]      wbp_cmd_dat_i   ,  // data output
       input   logic [BW-1:0]      wbp_cmd_sel_i   ,  // byte enable
       input   logic [3:0]         wbp_cmd_tid_i   ,
       input   logic [BL-1:0]      wbp_cmd_bl_i    ,  // Burst Count

    // Master Response Port- from Previous Master Port
       input   logic               wbp_res_rrdy_i  ,  // Ready path Ready to accept the data
       output  logic               wbp_res_rval_o  ,
       output  logic [DW-1:0]      wbp_res_dat_o   ,  // data input
       output  logic               wbp_res_ack_o   ,  // acknowlegement
       output  logic               wbp_res_lack_o  ,  // Last Burst access
       output  logic               wbp_res_err_o   ,  // error
       output  logic [3:0]         wbp_res_tid_o   ,

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
       input   logic [3:0]         wbd_res_tid_i   


    );



// Master Command Port- from Previous Master Port
logic               wbm_cmd_wrdy_i  ;  // Ready path Ready to accept the data
logic               wbm_cmd_wval_o  ;
logic [AW-1:0]      wbm_cmd_adr_o   ;  // address
logic               wbm_cmd_we_o    ;  // write
logic [DW-1:0]      wbm_cmd_dat_o   ;  // data output
logic [BW-1:0]      wbm_cmd_sel_o   ;  // byte enable
logic [3:0]         wbm_cmd_tid_o   ;
logic [BL-1:0]      wbm_cmd_bl_o    ;  // Burst Count

logic               stg_cmd_wrdy_o  ;
logic               stg_cmd_wval_i  ;
logic [AW-1:0]      stg_cmd_adr_i   ;  // address
logic               stg_cmd_we_i    ;  // write
logic [DW-1:0]      stg_cmd_dat_i   ;  // data output
logic [BW-1:0]      stg_cmd_sel_i   ;  // byte enable
logic [3:0]         stg_cmd_tid_i   ;
logic [BL-1:0]      stg_cmd_bl_i    ;  // Burst Count

// Master Response Port- from Previous Master Port
logic               wbm_res_rrdy_o  ;  // Ready path Ready to accept the data
logic               wbm_res_rval_i  ;
logic [DW-1:0]      wbm_res_dat_i   ;  // data input
logic               wbm_res_ack_i   ;  // acknowlegement
logic               wbm_res_lack_i  ;  // Last Burst access
logic               wbm_res_err_i   ;  // error
logic [3:0]         wbm_res_tid_i   ;

logic               stg_res_rrdy_i  ;  // Ready path Ready to accept the data
logic               stg_res_rval_o  ;
logic [DW-1:0]      stg_res_dat_o   ;  // data input
logic               stg_res_ack_o   ;  // acknowlegement
logic               stg_res_lack_o  ;  // Last Burst access
logic               stg_res_err_o   ;  // error
logic [3:0]         stg_res_tid_o   ;


wbi_arb2 u_wbi_arb(
	.clk      (mclk ), 
	.rstn     (reset_n), 
	.req      ({wbp_cmd_wval_i,wbm_cmd_wval_o}), 
	.gnt      (wbi_grnt)
        );


assign stg_cmd_wval_i = (wbi_grnt == 1'b0) ? wbm_cmd_wval_o : wbp_cmd_wval_i;
assign stg_cmd_adr_i  = (wbi_grnt == 1'b0) ? wbm_cmd_adr_o  : wbp_cmd_adr_i;
assign stg_cmd_we_i   = (wbi_grnt == 1'b0) ? wbm_cmd_we_o   : wbp_cmd_we_i;
assign stg_cmd_dat_i  = (wbi_grnt == 1'b0) ? wbm_cmd_dat_o  : wbp_cmd_dat_i;
assign stg_cmd_sel_i  = (wbi_grnt == 1'b0) ? wbm_cmd_sel_o  : wbp_cmd_sel_i;
assign stg_cmd_tid_i  = (wbi_grnt == 1'b0) ? wbm_cmd_tid_o  : wbp_cmd_tid_i;
assign stg_cmd_bl_i   = (wbi_grnt == 1'b0) ? wbm_cmd_bl_o   : wbp_cmd_bl_i;

assign wbp_cmd_wrdy_o = (wbi_grnt == 1'b1) ? stg_cmd_wrdy_o : 1'b0;
assign wbm_cmd_wrdy_i = (wbi_grnt == 1'b0) ? stg_cmd_wrdy_o : 1'b0;

// Current Master Port
assign  wbm_port_match  = stg_res_rval_o && (stg_res_tid_o == wbm_tid_i);
assign  wbm_res_rval_i  = wbm_port_match;
assign  wbm_res_dat_i   = stg_res_dat_o;    
assign  wbm_res_ack_i   = stg_res_ack_o;     
assign  wbm_res_lack_i  = stg_res_lack_o;    
assign  wbm_res_err_i   = stg_res_err_o;
assign  wbm_res_tid_i   = stg_res_tid_o;

// Previous Port
assign  wbp_res_rval_o   = stg_res_rval_o && (stg_res_tid_o != wbm_tid_i);
assign  wbp_res_dat_o    = stg_res_dat_o;    
assign  wbp_res_ack_o    = stg_res_ack_o;     
assign  wbp_res_lack_o   = stg_res_lack_o;    
assign  wbp_res_err_o    = stg_res_err_o;
assign  wbp_res_tid_o    = stg_res_tid_o;


assign stg_res_rrdy_i    = (wbm_port_match) ? wbm_res_rrdy_o : wbp_res_rrdy_i;
        
//-------------------------------------------
// Command Path control generation
//--------------------------------------------

//-------------------------------------------
// Response Path Control Generation
//--------------------------------------------


wbi_master_node #(.CDP(CDP),.RDP(RDP)) u_master (
       .reset_n           (reset_n              ),  // Regular Reset signal
       .mclk              (mclk                 ),  // System clock

    // Master Port
       .wbm_cyc_i         (wbm_cyc_i            ),  // strobe/request
       .wbm_stb_i         (wbm_stb_i            ),  // strobe/request
       .wbm_adr_i         (wbm_adr_i            ),  // address
       .wbm_we_i          (wbm_we_i             ),  // write
       .wbm_dat_i         (wbm_dat_i            ),  // data output
       .wbm_sel_i         (wbm_sel_i            ),  // byte enable
       .wbm_tid_i         (wbm_tid_i            ),
       .wbm_bl_i          (wbm_bl_i             ),  // Burst Count
       .wbm_bry_i         (wbm_bry_i            ),  // Burst Ready
       .wbm_dat_o         (wbm_dat_o            ),  // data input
       .wbm_ack_o         (wbm_ack_o            ),  // acknowlegement
       .wbm_lack_o        (wbm_lack_o           ),  // Last Burst access
       .wbm_err_o         (wbm_err_o            ),  // error


    // Master Command Port
       .wbm_cmd_wrdy_i    (wbm_cmd_wrdy_i       ),  // Ready path Ready to accept the data
       .wbm_cmd_wval_o    (wbm_cmd_wval_o       ),
       .wbm_cmd_adr_o     (wbm_cmd_adr_o        ),  // address
       .wbm_cmd_we_o      (wbm_cmd_we_o         ),  // write
       .wbm_cmd_dat_o     (wbm_cmd_dat_o        ),  // data output
       .wbm_cmd_sel_o     (wbm_cmd_sel_o        ),  // byte enable
       .wbm_cmd_tid_o     (wbm_cmd_tid_o        ),
       .wbm_cmd_bl_o      (wbm_cmd_bl_o         ),  // Burst Count

    // Master Response Port
       .wbm_res_rrdy_o    (wbm_res_rrdy_o       ),  // Ready path Ready to accept the data
       .wbm_res_rval_i    (wbm_res_rval_i       ),
       .wbm_res_dat_i     (wbm_res_dat_i        ),  // data input
       .wbm_res_ack_i     (wbm_res_ack_i        ),  // acknowlegement
       .wbm_res_lack_i    (wbm_res_lack_i       ),  // Last Burst access
       .wbm_res_err_i     (wbm_res_err_i        ),  // error
       .wbm_res_tid_i     (wbm_res_tid_i        )

    );


//------------------------------------------------------
// Command/Response Stagging for Next Daisy chain
//-----------------------------------------------------

wbi_stagging  u_stagging (
       .reset_n                (reset_n            ),  // Regular Reset signal
       .mclk                   (mclk               ),  // System clock

    // Master Command Port
       .wbp_cmd_wrdy_o        (stg_cmd_wrdy_o      ),  // Ready path Ready to accept the data
       .wbp_cmd_wval_i        (stg_cmd_wval_i      ),
       .wbp_cmd_adr_i         (stg_cmd_adr_i       ),  // address
       .wbp_cmd_we_i          (stg_cmd_we_i        ),  // write
       .wbp_cmd_dat_i         (stg_cmd_dat_i       ),  // data output
       .wbp_cmd_sel_i         (stg_cmd_sel_i       ),  // byte enable
       .wbp_cmd_tid_i         (stg_cmd_tid_i       ),
       .wbp_cmd_bl_i          (stg_cmd_bl_i        ),  // Burst Count

    // Master Response Port
       .wbp_res_rrdy_i        (stg_res_rrdy_i      ),  // Ready path Ready to accept the data
       .wbp_res_rval_o        (stg_res_rval_o      ),
       .wbp_res_dat_o         (stg_res_dat_o       ),  // data input
       .wbp_res_ack_o         (stg_res_ack_o       ),  // acknowlegement
       .wbp_res_lack_o        (stg_res_lack_o      ),  // Last Burst access
       .wbp_res_err_o         (stg_res_err_o       ),  // error
       .wbp_res_tid_o         (stg_res_tid_o       ),

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




endmodule

