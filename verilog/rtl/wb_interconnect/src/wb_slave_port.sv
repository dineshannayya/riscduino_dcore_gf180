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
////  Wishbone interconnect for slave port                        ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////	1. This block implement simple round robine request       ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - Mar 2, 2022, Dinesh A                               ////
//////////////////////////////////////////////////////////////////////



module wb_slave_port  #(
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
        parameter ADDR_MATCH_PATTERN4  = 32'hFFFF_FFFF,

         )(
         input logic		    clk_i, 
         input logic            rst_n,

         // Master In Interface
         input	logic [31:0]	m_wbd_dat_i,
         input	logic [31:0]	m_wbd_adr_i,
         input	logic [3:0]	    m_wbd_sel_i,
         input	logic [9:0]	    m_wbd_bl_i,
         input	logic    	    m_wbd_bry_i,
         input	logic 	        m_wbd_we_i,
         input	logic 	        m_wbd_cyc_i,
         input	logic 	        m_wbd_stb_i,
         input  logic [3:0]     m_wbd_tid_i,
         output	logic [31:0]	m_wbd_dat_o,
         output	logic 	        m_wbd_ack_o,
         output	logic 	        m_wbd_lack_o,
         output	logic 	        m_wbd_err_o,
         
         // Master out Interface
         output	logic [31:0]	m_wbd_adr_o,
         output	logic [3:0]	    m_wbd_sel_o,
         output	logic [9:0]	    m_wbd_bl_o,
         output	logic    	    m_wbd_bry_o,
         output	logic 	        m_wbd_we_o,
         output	logic 	        m_wbd_cyc_o,
         output	logic 	        m_wbd_stb_o,
         output logic [3:0]     m_wbd_tid_o,
         input	logic [31:0]	m_wbd_dat_i,
         input	logic 	        m_wbd_ack_i,
         input	logic 	        m_wbd_lack_i,
         input	logic 	        m_wbd_err_i,
         
         // Slave 0 Interface
         input	logic [31:0]	s_wbd_dat_i,
         input	logic 	        s_wbd_ack_i,
         input	logic 	        s_wbd_lack_i,
         output	logic [31:0]	s_wbd_dat_o,
         output	logic [31:0]	s_wbd_adr_o,
         output	logic [3:0]	    s_wbd_sel_o,
         output	logic [9:0]	    s_wbd_bl_o,
         output	logic 	        s_wbd_bry_o,
         output	logic 	        s_wbd_we_o,
         output	logic 	        s_wbd_cyc_o,
         output	logic 	        s_wbd_stb_o

	);

typedef enum logic {
    ADDR_NO_MATCH,
    ADDR_MATCH
} type_sel_e;


// WishBone Wr Interface
typedef struct packed { 
  logic	[31:0]	wbd_dat;
  logic  [31:0]	wbd_adr;
  logic  [3:0]	wbd_sel;
  logic  [9:0]	wbd_bl;
  logic  	    wbd_bry;
  logic  	    wbd_we;
  logic  	    wbd_cyc;
  logic  	    wbd_stb;
  logic [3:0] 	wbd_tid; // target id
} type_wb_wr_intf;

// WishBone Rd Interface
typedef struct packed { 
  logic	[31:0]	wbd_dat;
  logic  	    wbd_ack;
  logic  	    wbd_lack;
  logic  	    wbd_err;
  logic [3:0] 	wbd_tid; // target id
} type_wb_rd_intf;


type_wb_wr_intf  m_bus_wr;  // Multiplexed Master I/F
type_wb_rd_intf  m_bus_rd;  // Multiplexed Slave I/F

//----------------------------------------
// Master Mapping
// -------------------------------------
assign m_wb_wr.wbd_dat = m_wbd_dat_i;
assign m_wb_wr.wbd_adr = m_wbd_adr_i[31:2],2'b00};
assign m_wb_wr.wbd_sel = m_wbd_sel_i;
assign m_wb_wr.wbd_bl  = m_wbd_bl_i;
assign m_wb_wr.wbd_bry = m_wbd_bry_i;
assign m_wb_wr.wbd_we  = m_wbd_we_i;
assign m_wb_wr.wbd_cyc = m_wbd_cyc_i;
assign m_wb_wr.wbd_stb = m_stb_i;
assign m_wb_wr.wbd_tid = m_wbd_tid_i;

//

wire port_match = (func_check_match(m_bus_wr.wbd_stb,m_wbd_adr_i) == ADDR_MATCH);

// Generate Multiplexed Master Interface based on grant
always_comb begin
     case(port_match)
        1'h1:	   m_bus_wr = m_wb_wr;
        default:   m_bus_wr = 'h0;
     endcase			
end

// Stagging FF to break write and read timing path
sync_wbb u_sync_wbb(
         .clk_i            (clk_i               ), 
         .rst_n            (rst_n               ),
         // WishBone Input master I/P
         .wbm_dat_i        (m_bus_wr.wbd_dat    ),
         .wbm_adr_i        (m_bus_wr.wbd_adr    ),
         .wbm_sel_i        (m_bus_wr.wbd_sel    ),
         .wbm_bl_i         (m_bus_wr.wbd_bl     ),
         .wbm_bry_i        (m_bus_wr.wbd_bry    ),
         .wbm_we_i         (m_bus_wr.wbd_we     ),
         .wbm_cyc_i        (m_bus_wr.wbd_cyc    ),
         .wbm_stb_i        (m_bus_wr.wbd_stb    ),
         .wbm_tid_i        (m_bus_wr.wbd_tid    ),
         .wbm_dat_o        (m_bus_rd.wbd_dat    ),
         .wbm_ack_o        (m_bus_rd.wbd_ack    ),
         .wbm_lack_o       (m_bus_rd.wbd_lack   ),
         .wbm_err_o        (m_bus_rd.wbd_err    ),

         // Slave Interface
         .wbs_dat_i        (s_wbd_dat_i    ),
         .wbs_ack_i        (s_wbd_ack_i    ),
         .wbs_lack_i       (s_wbd_lack_i   ),
         .wbs_err_i        (s_wbd_err_i    ),
         .wbs_dat_o        (s_wbd_dat_o    ),
         .wbs_adr_o        (s_wbd_adr_o    ),
         .wbs_sel_o        (s_wbd_sel_o    ),
         .wbs_bl_o         (s_wbd_bl_o     ),
         .wbs_bry_o        (s_wbd_bry_o    ),
         .wbs_we_o         (s_wbd_we_o     ),
         .wbs_cyc_o        (s_wbd_cyc_o    ),
         .wbs_stb_o        (s_wbd_stb_o    ),
         .wbs_tid_o        (s_wbd_tid_o    )

);


function type_sel_e  func_check_match;
input        stb;
input [31:0] mem_addr;
begin
   func_check_match    = ADDR_NO_MATCH;
   if (ADDR_MATCH_VALID1 && stb && (mem_addr & ADDR_MATCH_MASK1) == ADDR_MATCH_PATTERN1)) begin
       func_check_match    = ADDR_MATCH;
   end else if (ADDR_MATCH_VALID2 && stb && (mem_addr & ADDR_MATCH_MASK2) == ADDR_MATCH_PATTERN2)) begin
       func_check_match    = ADDR_MATCH;
   end else if (ADDR_MATCH_VALID3 && stb && (mem_addr & ADDR_MATCH_MASK3) == ADDR_MATCH_PATTERN3)) begin
       func_check_match    = ADDR_MATCH;
   end else if (ADDR_MATCH_VALID4 && (mem_addr & ADDR_MATCH_MASK4) == ADDR_MATCH_PATTERN4)) begin
       func_check_match    = ADDR_MATCH;
   end
end
endfunction
endmodule
