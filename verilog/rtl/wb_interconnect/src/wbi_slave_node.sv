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
////    pending: Burst Write Support                              ////
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

module wbi_slave_node 
     #(parameter AW  = 32,
       parameter BW  = 4,
       parameter BL  = 10,
       parameter DW  = 32,
       parameter CDP = 4, // CMD FIFO DEPTH
       parameter RDP = 2  // RESPONSE FIFO DEPTH
       )
       (

    // Master Port
       input   logic               rst_n           ,  // Regular Reset signal
       input   logic               clk_i           ,  // System clock

       output  logic               wbm_cmd_wrdy_o  ,  // Ready to accept the data
       input   logic               wbm_cmd_val_i   ,  // Port enable
       input   logic [AW-1:0]      wbm_cmd_adr_i   ,  // address
       input   logic               wbm_cmd_we_i    ,  // write
       input   logic [DW-1:0]      wbm_cmd_dat_i   ,  // data output
       input   logic [BW-1:0]      wbm_cmd_sel_i   ,  // byte enable
       input   logic [3:0]         wbm_cmd_tid_i   ,
       input   logic [BL-1:0]      wbm_cmd_bl_i    ,  // Burst Count

       input   logic               wbm_res_rrdy_i  ,  // Ready path Ready to accept the data
       output  logic               wbm_res_rval_o  ,
       output  logic [DW-1:0]      wbm_res_dat_o   ,  // data input
       output  logic               wbm_res_ack_o   ,  // acknowlegement
       output  logic               wbm_res_lack_o  ,  // Last Burst access
       output  logic               wbm_res_err_o   ,  // error
       output  logic [3:0]         wbm_res_tid_o   ,

    // Slave Port
       output  logic               wbs_cyc_o   ,  // strobe/request
       output  logic               wbs_stb_o   ,  // strobe/request
       output  logic [AW-1:0]      wbs_adr_o   ,  // address
       output  logic               wbs_we_o    ,  // write
       output  logic [DW-1:0]      wbs_dat_o   ,  // data output
       output  logic [BW-1:0]      wbs_sel_o   ,  // byte enable
       output  logic [3:0]         wbs_tid_o   ,
       output  logic [BL-1:0]      wbs_bl_o    ,  // Burst Count
       output  logic               wbs_bry_o   ,  // Busrt WData Avialble Or Ready To accept Rdata  
       input   logic [DW-1:0]      wbs_dat_i   ,  // data input
       input   logic               wbs_ack_i   ,  // acknowlegement
       input   logic               wbs_lack_i  ,  // Last Ack
       input   logic               wbs_err_i      // error

    );



parameter CFW = AW+DW+BW+BL+4+1 ; // COMMAND FIFO WIDTH
parameter RFW = 4+DW+1+1 ;        // RESPONSE FIFO WIDTH



//-------------------------------------------------
//  Master Interface
// -------------------------------------------------
logic           m_cmd_wr_en       ;
logic [CFW-1:0] m_cmd_wr_data     ;
logic           m_cmd_wr_full     ;
logic           m_cmd_wr_afull    ;

logic           m_resp_rd_empty    ;
logic           m_resp_rd_aempty   ;
logic           m_resp_rd_en       ;
logic [RFW-1:0] m_resp_rd_data     ;

// Master Write Interface

assign wbm_cmd_wrdy_o = !m_cmd_wr_full;

// avoid back to back strobe
assign m_cmd_wr_en   = wbm_cmd_val_i & !m_cmd_wr_full;
assign m_cmd_wr_data = {wbm_cmd_adr_i,wbm_cmd_we_i,wbm_cmd_dat_i,wbm_cmd_sel_i,wbm_cmd_tid_i,wbm_cmd_bl_i};


// Avoid back to back ack
assign wbm_res_rval_o = !m_resp_rd_empty;

assign m_resp_rd_en = wbm_res_rrdy_i && !m_resp_rd_empty;
assign wbm_res_ack_o    = m_resp_rd_en;
assign wbm_res_tid_o    = m_resp_rd_data[3:0];
assign wbm_res_dat_o    = m_resp_rd_data[DW-1+4:4];
assign wbm_res_lack_o   = m_resp_rd_data[DW+4];
assign wbm_res_err_o    = m_resp_rd_data[DW+5];



//------------------------------------
// At Slave Interface
//------------------------------------
logic           s_cmd_rd_en       ;
logic [CFW-1:0] s_cmd_rd_data     ;
logic           s_cmd_rd_empty    ;
logic           s_cmd_rd_aempty   ;

logic           s_resp_wr_full    ;
logic           s_resp_wr_afull   ;
logic           s_resp_wr_en       ;
logic [RFW-1:0] s_resp_wr_data     ;

assign {wbs_adr_o,wbs_we_o,wbs_dat_o,wbs_sel_o,wbs_tid_o,wbs_bl_o} = (s_cmd_rd_empty) ? 'h0:   s_cmd_rd_data;
assign wbs_stb_o = !s_cmd_rd_empty;
assign wbs_cyc_o = !s_cmd_rd_empty;

// Generate bust ready only we have space inside response fifo
// In Write Phase, 
//      Generate burst ready, only when we have wdata & space in response fifo 
// In Read Phase 
//      Generate burst ready, only when space in response fifo 
//
assign wbs_bry_o = (wbs_we_o) ? ((s_cmd_rd_empty || (s_cmd_rd_en  && s_cmd_rd_aempty)) ? 1'b0: 1'b1) :
	                             (s_resp_wr_full || (s_resp_wr_en && s_resp_wr_afull)) ? 1'b0: 1'b1;

// During Write phase, cmd fifo will have wdata, so dequeue for every ack
// During Read Phase, cmd fifo will be written only one time, hold the bus
// untill last ack received
assign s_cmd_rd_en = (wbs_stb_o && wbs_we_o) ? wbs_ack_i: wbs_lack_i;

// Write Interface
// response send only for read logic
assign s_resp_wr_en   = wbs_stb_o & !wbs_we_o && wbs_ack_i ;
assign s_resp_wr_data = {wbs_err_i,wbs_lack_i,wbs_dat_i,wbs_tid_o};

sync_fifo2 #(.W(CFW), .DP(CDP),.WR_FAST(1), .RD_FAST(1)) u_cmd_if (
	           // Sync w.r.t WR clock
	               .clk           (clk_i             ),
                   .reset_n       (rst_n             ),
                   .wr_en         (m_cmd_wr_en       ),
                   .wr_data       (m_cmd_wr_data     ),
                   .full          (m_cmd_wr_full     ),                 
                   .afull         (m_cmd_wr_afull    ),                 

		   // Sync w.r.t RD Clock
                   .rd_en         (s_cmd_rd_en       ),
                   .empty         (s_cmd_rd_empty    ), // sync'ed to rd_clk
                   .aempty        (s_cmd_rd_aempty   ), // sync'ed to rd_clk
                   .rd_data       (s_cmd_rd_data     )
	     );


// Response used only for read path, 
// As cache access will be busrt of 512 location, To 
// support continous ack, depth is increase to 8 location
sync_fifo2 #(.W(RFW), .DP(RDP), .WR_FAST(1), .RD_FAST(1)) u_resp_if (
	           // Sync w.r.t WR clock
	           .clk           (clk_i              ),
                   .reset_n       (rst_n              ),
                   .wr_en         (s_resp_wr_en       ),
                   .wr_data       (s_resp_wr_data     ),
                   .full          (s_resp_wr_full     ),                 
                   .afull         (s_resp_wr_afull    ),                 

		   // Sync w.r.t RD Clock
                   .rd_en         (m_resp_rd_en       ),
                   .empty         (m_resp_rd_empty  ), // sync'ed to rd_clk
                   .aempty        (m_resp_rd_aempty   ), // sync'ed to rd_clk
                   .rd_data       (m_resp_rd_data     )
	     );



endmodule
