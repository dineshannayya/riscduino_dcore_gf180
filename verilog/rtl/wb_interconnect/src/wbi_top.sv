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
////  Wishbone Interconnect                                       ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////      - Dinesh Annayya, dinesh.annayya@gmail.com              ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 1 Dec 2023, Dinesh A                                ////
////          initial version                                     ////
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
//------------------------------
// RISC Data Memory Map
// 0x0000_0000 to 0x0FFF_FFFF  - QSPIM MEMORY
// 0x1000_0000 to 0x1000_00FF  - QSPIM REG
// 0x1001_0000 to 0x1001_003F  - UART0
// 0x1001_0040 to 0x1001_007F  - I2
// 0x1001_0080 to 0x1001_00BF  - USB
// 0x1001_00C0 to 0x1001_00FF  - SSPIM
// 0x1001_0100 to 0x1001_013F  - UART1
// 0x1002_0000 to 0x1002_00FF  - PINMUX
// 0x1003_0000 to 0x1003_00FF  - WBI
//-----------------------------



module wbi_top 
         (
`ifdef USE_POWER_PINS
         input logic            vccd1,    // User area 1 1.8V supply
         input logic            vssd1,    // User area 1 digital ground
`endif

         // Clock Skew Adjust
         input logic [3:0]      cfg_cska_wi,
         input logic            wbd_clk_int,
	     output logic           wbd_clk_wi,

         input logic            mclk_raw, // clock without any clk skew
         input logic		    clk_i, 
         input logic            rst_n,

         // Master 0 Interface
         output  logic          m0_mclk,
         input   logic	[31:0]	m0_wbd_dat_i,
         input   logic  [31:0]	m0_wbd_adr_i,
         input   logic  [3:0]	m0_wbd_sel_i,
         input   logic  	    m0_wbd_we_i,
         input   logic  	    m0_wbd_cyc_i,
         input   logic  	    m0_wbd_stb_i,
         output  logic	[31:0]	m0_wbd_dat_o,
         output  logic		    m0_wbd_ack_o,
         output  logic		    m0_wbd_lack_o,
         output  logic		    m0_wbd_err_o,
         
         
         // Slave 0 Interface
         output logic           s0_mclk,
         input  logic           s0_idle,
         input	logic [31:0]	s0_wbd_dat_i,
         input	logic 	        s0_wbd_ack_i,
         input	logic 	        s0_wbd_lack_i,
       //input	logic 	        s0_wbd_err_i, - unused
         output	logic [31:0]	s0_wbd_dat_o,
         output	logic [31:0]	s0_wbd_adr_o,
         output	logic [3:0]	    s0_wbd_sel_o,
         output	logic [9:0]	    s0_wbd_bl_o,
         output	logic 	        s0_wbd_bry_o,
         output	logic 	        s0_wbd_we_o,
         output	logic 	        s0_wbd_cyc_o,
         output	logic 	        s0_wbd_stb_o,
         
         // Slave 1 Interface
         output logic           s1_mclk,
         input	logic [31:0]	s1_wbd_dat_i,
         input	logic 	        s1_wbd_ack_i,
      // input	logic 	        s1_wbd_err_i, - unused
         output	logic [31:0]	s1_wbd_dat_o,
         output	logic [8:0]	    s1_wbd_adr_o, // Uart
         output	logic [3:0]	    s1_wbd_sel_o,
         output	logic 	        s1_wbd_we_o,
         output	logic 	        s1_wbd_cyc_o,
         output	logic 	        s1_wbd_stb_o,
         
         // Slave 2 Interface
         output logic           s2_mclk,
         input	logic [31:0]	s2_wbd_dat_i,
         input	logic 	        s2_wbd_ack_i,
      // input	logic 	        s2_wbd_err_i, - unused
         output	logic [31:0]	s2_wbd_dat_o,
         output	logic [10:0]	s2_wbd_adr_o, // glbl reg need only 9 bits
         output	logic [3:0]	    s2_wbd_sel_o,
         output	logic 	        s2_wbd_we_o,
         output	logic 	        s2_wbd_cyc_o,
         output	logic 	        s2_wbd_stb_o

	);

////////////////////////////////////////////////////////////////////
//
// Type define
////////////////////////////////////////////////////////////////////

parameter M_WB_HOST = 4'b0001;


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
} type_wb_rd_intf;

typedef struct packed { 
  logic	[31:0]	wbd_dat;
  logic  [31:0]	wbd_adr;
  logic  [3:0]	wbd_sel;
  logic  [9:0]	wbd_bl;
  logic  	    wbd_we;
  logic  	    wbd_wval;
  logic [3:0] 	wbd_tid;
} type_wb_cmd_data_intf;

typedef struct packed { 
  logic     	wbd_wrdy; 
} type_wb_cmd_ctrl_intf;

typedef struct packed { 
  logic	[31:0]	wbd_dat;
  logic  	    wbd_ack;
  logic  	    wbd_lack;
  logic  	    wbd_err;
  logic[3:0]  	wbd_tid;
  logic  	    wbd_rval;
} type_wb_res_data_intf;

typedef struct packed { 
  logic     	wbd_rrdy; 
} type_wb_res_ctrl_intf;

// M0
type_wb_wr_intf m0_wb_wr;
type_wb_rd_intf m0_wb_rd;

type_wb_cmd_data_intf m0p_cmd_data;
type_wb_res_data_intf m0p_res_data;

type_wb_cmd_ctrl_intf m0p_cmd_ctrl;
type_wb_res_ctrl_intf m0p_res_ctrl;

type_wb_cmd_data_intf m0d_cmd_data;
type_wb_res_data_intf m0d_res_data;

type_wb_cmd_ctrl_intf m0d_cmd_ctrl;
type_wb_res_ctrl_intf m0d_res_ctrl;

// S0
type_wb_wr_intf s0_wb_wr;
type_wb_rd_intf s0_wb_rd;

type_wb_cmd_data_intf s0p_cmd_data;
type_wb_res_data_intf s0p_res_data;

type_wb_cmd_ctrl_intf s0p_cmd_ctrl;
type_wb_res_ctrl_intf s0p_res_ctrl;

type_wb_cmd_data_intf s0d_cmd_data;
type_wb_res_data_intf s0d_res_data;

type_wb_cmd_ctrl_intf s0d_cmd_ctrl;
type_wb_res_ctrl_intf s0d_res_ctrl;

// S1
type_wb_wr_intf s1_wb_wr;
type_wb_rd_intf s1_wb_rd;

type_wb_cmd_data_intf s1p_cmd_data;
type_wb_res_data_intf s1p_res_data;

type_wb_cmd_ctrl_intf s1p_cmd_ctrl;
type_wb_res_ctrl_intf s1p_res_ctrl;

type_wb_cmd_data_intf s1d_cmd_data;
type_wb_res_data_intf s1d_res_data;

type_wb_cmd_ctrl_intf s1d_cmd_ctrl;
type_wb_res_ctrl_intf s1d_res_ctrl;

// S2
type_wb_wr_intf s2_wb_wr;
type_wb_rd_intf s2_wb_rd;

type_wb_cmd_data_intf s2p_cmd_data;
type_wb_res_data_intf s2p_res_data;

type_wb_cmd_ctrl_intf s2p_cmd_ctrl;
type_wb_res_ctrl_intf s2p_res_ctrl;

type_wb_cmd_data_intf s2d_cmd_data;
type_wb_res_data_intf s2d_res_data;

type_wb_cmd_ctrl_intf s2d_cmd_ctrl;
type_wb_res_ctrl_intf s2d_res_ctrl;


//--------------------------------------



// Wishbone interconnect clock skew control
clk_skew_adjust u_skew_wi
       (
`ifdef USE_POWER_PINS
               .vccd1      (vccd1                      ),// User area 1 1.8V supply
               .vssd1      (vssd1                      ),// User area 1 digital ground
`endif
	       .clk_in         (wbd_clk_int                 ), 
	       .sel            (cfg_cska_wi                 ), 
	       .clk_out        (wbd_clk_wi                  ) 
       );


/////////////////////////////////////////////////
// Master-0 Mapping
// ---------------------------------------------
assign m0_mclk           =  mclk_raw;
assign m0_wb_wr.wbd_dat  = m0_wbd_dat_i;
assign m0_wb_wr.wbd_adr  = m0_wbd_adr_i;
assign m0_wb_wr.wbd_sel  = m0_wbd_sel_i;
assign m0_wb_wr.wbd_bl   = 'h0;
assign m0_wb_wr.wbd_bry  = 1'b1;
assign m0_wb_wr.wbd_we   = m0_wbd_we_i;
assign m0_wb_wr.wbd_cyc  = m0_wbd_cyc_i;
assign m0_wb_wr.wbd_stb  = m0_wbd_stb_i;
assign m0_wb_wr.wbd_tid  = M_WB_HOST;

assign m0_wbd_dat_o  = m0_wb_rd.wbd_dat;
assign m0_wbd_ack_o  = m0_wb_rd.wbd_ack;
assign m0_wbd_lack_o = m0_wb_rd.wbd_lack;
assign m0_wbd_err_o  = m0_wb_rd.wbd_err;



//----------------------------------------
// Slave-0 Port Mapping
// -------------------------------------
assign  s0_mclk      =  mclk_raw;
assign  s0_wbd_dat_o =  s0_wb_wr.wbd_dat ;
assign  s0_wbd_adr_o =  s0_wb_wr.wbd_adr ;
assign  s0_wbd_sel_o =  s0_wb_wr.wbd_sel ;
assign  s0_wbd_bl_o  =  s0_wb_wr.wbd_bl ;
assign  s0_wbd_bry_o =  s0_wb_wr.wbd_bry ;
assign  s0_wbd_we_o  =  s0_wb_wr.wbd_we  ;
assign  s0_wbd_cyc_o =  s0_wb_wr.wbd_cyc ;
assign  s0_wbd_stb_o =  s0_wb_wr.wbd_stb ;
                     
assign s0_wb_rd.wbd_dat   = s0_wbd_dat_i ;
assign s0_wb_rd.wbd_ack   = s0_wbd_ack_i ;
assign s0_wb_rd.wbd_lack  = s0_wbd_lack_i ;
assign s0_wb_rd.wbd_err  = 1'b0; // s0_wbd_err_i ; - unused

//----------------------------------------
// Slave-1 Port Mapping
// -------------------------------------
assign  s1_mclk      =  mclk_raw;
assign  s1_wbd_dat_o =  s1_wb_wr.wbd_dat ;
assign  s1_wbd_adr_o =  s1_wb_wr.wbd_adr[8:0] ;
assign  s1_wbd_sel_o =  s1_wb_wr.wbd_sel ;
assign  s1_wbd_we_o  =  s1_wb_wr.wbd_we  ;
assign  s1_wbd_cyc_o =  s1_wb_wr.wbd_cyc ;
assign  s1_wbd_stb_o =  s1_wb_wr.wbd_stb ;

assign s1_wb_rd.wbd_dat  = s1_wbd_dat_i ;
assign s1_wb_rd.wbd_ack  = s1_wbd_ack_i ;
assign s1_wb_rd.wbd_lack  = s1_wbd_ack_i ;
assign s1_wb_rd.wbd_err  = 1'b0; // s1_wbd_err_i ; - unused
                      
//----------------------------------------
// Slave-2 Port Mapping
// -------------------------------------
assign  s2_mclk      =  mclk_raw;
assign  s2_wbd_dat_o =  s2_wb_wr.wbd_dat ;
assign  s2_wbd_adr_o =  s2_wb_wr.wbd_adr[10:0] ; // Global Reg Need 8 bit
assign  s2_wbd_sel_o =  s2_wb_wr.wbd_sel ;
assign  s2_wbd_we_o  =  s2_wb_wr.wbd_we  ;
assign  s2_wbd_cyc_o =  s2_wb_wr.wbd_cyc ;
assign  s2_wbd_stb_o =  s2_wb_wr.wbd_stb ;

assign s2_wb_rd.wbd_dat  = s2_wbd_dat_i ;
assign s2_wb_rd.wbd_ack  = s2_wbd_ack_i ;
assign s2_wb_rd.wbd_lack = s2_wbd_ack_i ;
assign s2_wb_rd.wbd_err  = 1'b0; // s2_wbd_err_i ; - unused


//------------------------------------------
// Command Daisy Chain
//------------------------------------------

// M0 => S0
assign s0p_cmd_data = m0d_cmd_data;
assign m0d_cmd_ctrl = s0p_cmd_ctrl;

assign m0d_res_data = s0p_res_data;
assign s0p_res_ctrl = m0d_res_ctrl;

// S0 => S1
assign s1p_cmd_data = s0d_cmd_data;
assign s0d_cmd_ctrl = s1p_cmd_ctrl;

assign s0d_res_data = s1p_res_data;
assign s1p_res_ctrl = s0d_res_ctrl;

// S1 => S2
assign s2p_cmd_data = s1d_cmd_data;
assign s1d_cmd_ctrl = s2p_cmd_ctrl;

assign s1d_res_data = s2p_res_data;
assign s2p_res_ctrl = s1d_res_ctrl;

//S2 => M0 (Last chain to First chain)
assign m0p_cmd_data = s2d_cmd_data;
assign s2d_cmd_ctrl = m0p_cmd_ctrl;

assign s2d_res_data = m0p_res_data;
assign m0p_res_ctrl = s2d_res_ctrl;

//----------------------------------------------------------
// M0: WISHBONE HOST MASTER
//----------------------------------------------------------

wbi_master_port u_m0 (
       .reset_n           (rst_n                       ),  // Regular Reset signal
       .mclk              (clk_i                       ),  // System clock
                             
       // Wb I/F - Entry             
       .wbm_cyc_i         (m0_wb_wr.wbd_cyc            ),  // strobe/request
       .wbm_stb_i         (m0_wb_wr.wbd_stb            ),  // strobe/request
       .wbm_adr_i         (m0_wb_wr.wbd_adr            ),  // address
       .wbm_we_i          (m0_wb_wr.wbd_we             ),  // write
       .wbm_dat_i         (m0_wb_wr.wbd_dat            ),  // data output
       .wbm_sel_i         (m0_wb_wr.wbd_sel            ),  // byte enable
       .wbm_tid_i         (m0_wb_wr.wbd_tid            ),
       .wbm_bl_i          (m0_wb_wr.wbd_bl             ),  // Burst Count
       .wbm_bry_i         (m0_wb_wr.wbd_bry            ),  // Burst Ready

       .wbm_dat_o         (m0_wb_rd.wbd_dat            ),  // data input
       .wbm_ack_o         (m0_wb_rd.wbd_ack            ),  // acknowlegement
       .wbm_lack_o        (m0_wb_rd.wbd_lack           ),  // Last Burst access
       .wbm_err_o         (m0_wb_rd.wbd_err            ),  // error
                                          
       // Previous chain - CMD                                  
       .wbp_cmd_wrdy_o    (m0p_cmd_ctrl.wbd_wrdy       ),  // Ready path Ready to accept the data
       .wbp_cmd_wval_i    (m0p_cmd_data.wbd_wval       ),
       .wbp_cmd_adr_i     (m0p_cmd_data.wbd_adr        ),  // address
       .wbp_cmd_we_i      (m0p_cmd_data.wbd_we         ),  // write
       .wbp_cmd_dat_i     (m0p_cmd_data.wbd_dat        ),  // data output
       .wbp_cmd_sel_i     (m0p_cmd_data.wbd_sel        ),  // byte enable
       .wbp_cmd_tid_i     (m0p_cmd_data.wbd_tid        ),
       .wbp_cmd_bl_i      (m0p_cmd_data.wbd_bl         ),  // Burst Count
                                          
       // Previous chain - RES                                  
       .wbp_res_rrdy_i    (m0p_res_ctrl.wbd_rrdy       ),  // Ready path Ready to accept the data
       .wbp_res_rval_o    (m0p_res_data.wbd_rval       ),
       .wbp_res_dat_o     (m0p_res_data.wbd_dat        ),  // data input
       .wbp_res_ack_o     (m0p_res_data.wbd_ack        ),  // acknowlegement
       .wbp_res_lack_o    (m0p_res_data.wbd_lack       ),  // Last Burst access
       .wbp_res_err_o     (m0p_res_data.wbd_err        ),  // error
       .wbp_res_tid_o     (m0p_res_data.wbd_tid        ),
                       
       // Next Daisy chain - CMD                   
       .wbd_cmd_wrdy_i    (m0d_cmd_ctrl.wbd_wrdy        ),  // Ready path Ready to accept the data
       .wbd_cmd_wval_o    (m0d_cmd_data.wbd_wval        ),
       .wbd_cmd_adr_o     (m0d_cmd_data.wbd_adr         ),  // address
       .wbd_cmd_we_o      (m0d_cmd_data.wbd_we          ),  // write
       .wbd_cmd_dat_o     (m0d_cmd_data.wbd_dat         ),  // data output
       .wbd_cmd_sel_o     (m0d_cmd_data.wbd_sel         ),  // byte enable
       .wbd_cmd_tid_o     (m0d_cmd_data.wbd_tid         ),
       .wbd_cmd_bl_o      (m0d_cmd_data.wbd_bl          ),  // Burst Count
                                          
       // Next Daisy chain - RES                   
       .wbd_res_rrdy_o    (m0d_res_ctrl.wbd_rrdy        ),  // Ready path Ready to accept the data
       .wbd_res_rval_i    (m0d_res_data.wbd_rval        ),
       .wbd_res_dat_i     (m0d_res_data.wbd_dat         ),  // data input
       .wbd_res_ack_i     (m0d_res_data.wbd_ack         ),  // acknowlegement
       .wbd_res_lack_i    (m0d_res_data.wbd_lack        ),  // Last Burst access
       .wbd_res_err_i     (m0d_res_data.wbd_err         ),  // error
       .wbd_res_tid_i     (m0d_res_data.wbd_tid         )
    );

//----------------------------------------------------------
// S0: QSPI
//----------------------------------------------------------
wbi_slave_port 
     #(
       .ADDR_MATCH_VALID1    ( 1'b1),
       .ADDR_MATCH_MASK1     ( 32'hFFFF_FFFF),
       .ADDR_MATCH_PATTERN1  ( 32'hFFFF_FFFF),

       .ADDR_MATCH_VALID2    ( 1'b0),
       .ADDR_MATCH_MASK2     ( 32'hFFFF_FFFF),
       .ADDR_MATCH_PATTERN2  ( 32'hFFFF_FFFF),

       .ADDR_MATCH_VALID3    ( 1'b0),
       .ADDR_MATCH_MASK3     ( 32'hFFFF_FFFF),
       .ADDR_MATCH_PATTERN3  ( 32'hFFFF_FFFF),

       .ADDR_MATCH_VALID4    ( 1'b0),
       .ADDR_MATCH_MASK4     ( 32'hFFFF_FFFF),
       .ADDR_MATCH_PATTERN4  ( 32'hFFFF_FFFF)

       ) u_s0 (
       .reset_n           ( rst_n                  ),  // Regular Reset signal
       .mclk              ( clk_i                  ),  // System clock
                                           
       .wbp_cmd_wrdy_o    ( s0p_cmd_ctrl.wbd_wrdy  ),  // Ready path Ready to accept the data
       .wbp_cmd_wval_i    ( s0p_cmd_data.wbd_wval  ),
       .wbp_cmd_adr_i     ( s0p_cmd_data.wbd_adr   ),  // address
       .wbp_cmd_we_i      ( s0p_cmd_data.wbd_we    ),  // write
       .wbp_cmd_dat_i     ( s0p_cmd_data.wbd_dat   ),  // data output
       .wbp_cmd_sel_i     ( s0p_cmd_data.wbd_sel   ),  // byte enable
       .wbp_cmd_tid_i     ( s0p_cmd_data.wbd_tid   ),
       .wbp_cmd_bl_i      ( s0p_cmd_data.wbd_bl    ),  // Burst Count
                                       
       .wbp_res_rrdy_i    ( s0p_res_ctrl.wbd_rrdy  ),  // Ready path Ready to accept the data
       .wbp_res_rval_o    ( s0p_res_data.wbd_rval  ),
       .wbp_res_dat_o     ( s0p_res_data.wbd_dat   ),  // data input
       .wbp_res_ack_o     ( s0p_res_data.wbd_ack   ),  // acknowlegement
       .wbp_res_lack_o    ( s0p_res_data.wbd_lack  ),  // Last Burst access
       .wbp_res_err_o     ( s0p_res_data.wbd_err   ),  // error
       .wbp_res_tid_o     ( s0p_res_data.wbd_tid   ),
                                           
       .wbd_cmd_wrdy_i    ( s0d_cmd_ctrl.wbd_wrdy  ),  // Ready path Ready to accept the data
       .wbd_cmd_wval_o    ( s0d_cmd_data.wbd_wval  ),
       .wbd_cmd_adr_o     ( s0d_cmd_data.wbd_adr   ),  // address
       .wbd_cmd_we_o      ( s0d_cmd_data.wbd_we    ),  // write
       .wbd_cmd_dat_o     ( s0d_cmd_data.wbd_dat   ),  // data output
       .wbd_cmd_sel_o     ( s0d_cmd_data.wbd_sel   ),  // byte enable
       .wbd_cmd_tid_o     ( s0d_cmd_data.wbd_tid   ),
       .wbd_cmd_bl_o      ( s0d_cmd_data.wbd_bl    ),  // Burst Count
                                        
       .wbd_res_rrdy_o    ( s0d_res_ctrl.wbd_rrdy  ),  // Ready path Ready to accept the data
       .wbd_res_rval_i    ( s0d_res_data.wbd_rval  ),
       .wbd_res_dat_i     ( s0d_res_data.wbd_dat   ),  // data input
       .wbd_res_ack_i     ( s0d_res_data.wbd_ack   ),  // acknowlegement
       .wbd_res_lack_i    ( s0d_res_data.wbd_lack  ),  // Last Burst access
       .wbd_res_err_i     ( s0d_res_data.wbd_err   ),  // error
       .wbd_res_tid_i     ( s0d_res_data.wbd_tid   ),
                                           
       .wbs_cyc_o         ( s0_wb_wr.wbd_cyc       ),  // strobe/request
       .wbs_stb_o         ( s0_wb_wr.wbd_stb       ),  // strobe/request
       .wbs_adr_o         ( s0_wb_wr.wbd_adr       ),  // address
       .wbs_we_o          ( s0_wb_wr.wbd_we        ),  // write
       .wbs_dat_o         ( s0_wb_wr.wbd_dat       ),  // data output
       .wbs_sel_o         ( s0_wb_wr.wbd_sel       ),  // byte enable
       .wbs_tid_o         ( s0_wb_wr.wbd_tid       ),
       .wbs_bl_o          ( s0_wb_wr.wbd_bl        ),  // Burst Count
       .wbs_bry_o         ( s0_wb_wr.wbd_bry       ),  // Busrt WData Avialble Or Ready To accept Rdata  

       .wbs_dat_i         ( s0_wb_rd.wbd_dat       ),  // data input
       .wbs_ack_i         ( s0_wb_rd.wbd_ack       ),  // acknowlegement
       .wbs_lack_i        ( s0_wb_rd.wbd_lack      ),  // Last Ack
       .wbs_err_i         ( s0_wb_rd.wbd_err       )   // error

    );

//----------------------------------------------------------
// S1: USB
//----------------------------------------------------------

wbi_slave_port 
     #(
       .ADDR_MATCH_VALID1    ( 1'b1),
       .ADDR_MATCH_MASK1     ( 32'hFFFF_FFFF),
       .ADDR_MATCH_PATTERN1  ( 32'hFFFF_FFFF),

       .ADDR_MATCH_VALID2    ( 1'b0),
       .ADDR_MATCH_MASK2     ( 32'hFFFF_FFFF),
       .ADDR_MATCH_PATTERN2  ( 32'hFFFF_FFFF),

       .ADDR_MATCH_VALID3    ( 1'b0),
       .ADDR_MATCH_MASK3     ( 32'hFFFF_FFFF),
       .ADDR_MATCH_PATTERN3  ( 32'hFFFF_FFFF),

       .ADDR_MATCH_VALID4    ( 1'b0),
       .ADDR_MATCH_MASK4     ( 32'hFFFF_FFFF),
       .ADDR_MATCH_PATTERN4  ( 32'hFFFF_FFFF)

       ) u_s1 (
       .reset_n           ( rst_n                  ),  // Regular Reset signal
       .mclk              ( clk_i                  ),  // System clock
                                           
       .wbp_cmd_wrdy_o    ( s1p_cmd_ctrl.wbd_wrdy  ),  // Ready path Ready to accept the data
       .wbp_cmd_wval_i    ( s1p_cmd_data.wbd_wval  ),
       .wbp_cmd_adr_i     ( s1p_cmd_data.wbd_adr   ),  // address
       .wbp_cmd_we_i      ( s1p_cmd_data.wbd_we    ),  // write
       .wbp_cmd_dat_i     ( s1p_cmd_data.wbd_dat   ),  // data output
       .wbp_cmd_sel_i     ( s1p_cmd_data.wbd_sel   ),  // byte enable
       .wbp_cmd_tid_i     ( s1p_cmd_data.wbd_tid   ),
       .wbp_cmd_bl_i      ( s1p_cmd_data.wbd_bl    ),  // Burst Count
                                      
       .wbp_res_rrdy_i    ( s1p_res_ctrl.wbd_rrdy  ),  // Ready path Ready to accept the data
       .wbp_res_rval_o    ( s1p_res_data.wbd_rval  ),
       .wbp_res_dat_o     ( s1p_res_data.wbd_dat   ),  // data input
       .wbp_res_ack_o     ( s1p_res_data.wbd_ack   ),  // acknowlegement
       .wbp_res_lack_o    ( s1p_res_data.wbd_lack  ),  // Last Burst access
       .wbp_res_err_o     ( s1p_res_data.wbd_err   ),  // error
       .wbp_res_tid_o     ( s1p_res_data.wbd_tid   ),
                                           
       .wbd_cmd_wrdy_i    ( s1d_cmd_ctrl.wbd_wrdy  ),  // Ready path Ready to accept the data
       .wbd_cmd_wval_o    ( s1d_cmd_data.wbd_wval  ),
       .wbd_cmd_adr_o     ( s1d_cmd_data.wbd_adr   ),  // address
       .wbd_cmd_we_o      ( s1d_cmd_data.wbd_we    ),  // write
       .wbd_cmd_dat_o     ( s1d_cmd_data.wbd_dat   ),  // data output
       .wbd_cmd_sel_o     ( s1d_cmd_data.wbd_sel   ),  // byte enable
       .wbd_cmd_tid_o     ( s1d_cmd_data.wbd_tid   ),
       .wbd_cmd_bl_o      ( s1d_cmd_data.wbd_bl    ),  // Burst Count
                                        
       .wbd_res_rrdy_o    ( s1d_res_ctrl.wbd_rrdy  ),  // Ready path Ready to accept the data
       .wbd_res_rval_i    ( s1d_res_data.wbd_rval  ),
       .wbd_res_dat_i     ( s1d_res_data.wbd_dat   ),  // data input
       .wbd_res_ack_i     ( s1d_res_data.wbd_ack   ),  // acknowlegement
       .wbd_res_lack_i    ( s1d_res_data.wbd_lack  ),  // Last Burst access
       .wbd_res_err_i     ( s1d_res_data.wbd_err   ),  // error
       .wbd_res_tid_i     ( s1d_res_data.wbd_tid   ),
                                          
       .wbs_cyc_o         ( s1_wb_wr.wbd_cyc       ),  // strobe/request
       .wbs_stb_o         ( s1_wb_wr.wbd_stb       ),  // strobe/request
       .wbs_adr_o         ( s1_wb_wr.wbd_adr       ),  // address
       .wbs_we_o          ( s1_wb_wr.wbd_we        ),  // write
       .wbs_dat_o         ( s1_wb_wr.wbd_dat       ),  // data output
       .wbs_sel_o         ( s1_wb_wr.wbd_sel       ),  // byte enable
       .wbs_tid_o         ( s1_wb_wr.wbd_tid       ),
       .wbs_bl_o          ( s1_wb_wr.wbd_bl        ),  // Burst Count
       .wbs_bry_o         ( s1_wb_wr.wbd_bry       ),  // Busrt WData Avialble Or Ready To accept Rdata  

       .wbs_dat_i         ( s1_wb_rd.wbd_dat       ),  // data input
       .wbs_ack_i         ( s1_wb_rd.wbd_ack       ),  // acknowlegement
       .wbs_lack_i        ( s1_wb_rd.wbd_lack      ),  // Last Ack
       .wbs_err_i         ( s1_wb_rd.wbd_err       )   // error

    );

//----------------------------------------------------------
// S2: UART
//----------------------------------------------------------

wbi_slave_port 
     #(
       .ADDR_MATCH_VALID1    ( 1'b1),
       .ADDR_MATCH_MASK1     ( 32'hFFFF_FFFF),
       .ADDR_MATCH_PATTERN1  ( 32'hFFFF_FFFF),

       .ADDR_MATCH_VALID2    ( 1'b0),
       .ADDR_MATCH_MASK2     ( 32'hFFFF_FFFF),
       .ADDR_MATCH_PATTERN2  ( 32'hFFFF_FFFF),

       .ADDR_MATCH_VALID3    ( 1'b0),
       .ADDR_MATCH_MASK3     ( 32'hFFFF_FFFF),
       .ADDR_MATCH_PATTERN3  ( 32'hFFFF_FFFF),

       .ADDR_MATCH_VALID4    ( 1'b0),
       .ADDR_MATCH_MASK4     ( 32'hFFFF_FFFF),
       .ADDR_MATCH_PATTERN4  ( 32'hFFFF_FFFF)

       ) u_s2 (
       .reset_n           ( rst_n                  ),  // Regular Reset signal
       .mclk              ( clk_i                  ),  // System clock
                                           
       .wbp_cmd_wrdy_o    ( s2p_cmd_ctrl.wbd_wrdy  ),  // Ready path Ready to accept the data
       .wbp_cmd_wval_i    ( s2p_cmd_data.wbd_wval  ),
       .wbp_cmd_adr_i     ( s2p_cmd_data.wbd_adr   ),  // address
       .wbp_cmd_we_i      ( s2p_cmd_data.wbd_we    ),  // write
       .wbp_cmd_dat_i     ( s2p_cmd_data.wbd_dat   ),  // data output
       .wbp_cmd_sel_i     ( s2p_cmd_data.wbd_sel   ),  // byte enable
       .wbp_cmd_tid_i     ( s2p_cmd_data.wbd_tid   ),
       .wbp_cmd_bl_i      ( s2p_cmd_data.wbd_bl    ),  // Burst Count
                                     
       .wbp_res_rrdy_i    ( s2p_res_ctrl.wbd_rrdy  ),  // Ready path Ready to accept the data
       .wbp_res_rval_o    ( s2p_res_data.wbd_rval  ),
       .wbp_res_dat_o     ( s2p_res_data.wbd_dat   ),  // data input
       .wbp_res_ack_o     ( s2p_res_data.wbd_ack   ),  // acknowlegement
       .wbp_res_lack_o    ( s2p_res_data.wbd_lack  ),  // Last Burst access
       .wbp_res_err_o     ( s2p_res_data.wbd_err   ),  // error
       .wbp_res_tid_o     ( s2p_res_data.wbd_tid   ),
                                          
       .wbd_cmd_wrdy_i    ( s2d_cmd_ctrl.wbd_wrdy  ),  // Ready path Ready to accept the data
       .wbd_cmd_wval_o    ( s2d_cmd_data.wbd_wval  ),
       .wbd_cmd_adr_o     ( s2d_cmd_data.wbd_adr   ),  // address
       .wbd_cmd_we_o      ( s2d_cmd_data.wbd_we    ),  // write
       .wbd_cmd_dat_o     ( s2d_cmd_data.wbd_dat   ),  // data output
       .wbd_cmd_sel_o     ( s2d_cmd_data.wbd_sel   ),  // byte enable
       .wbd_cmd_tid_o     ( s2d_cmd_data.wbd_tid   ),
       .wbd_cmd_bl_o      ( s2d_cmd_data.wbd_bl    ),  // Burst Count
                                       
       .wbd_res_rrdy_o    ( s2d_res_ctrl.wbd_rrdy  ),  // Ready path Ready to accept the data
       .wbd_res_rval_i    ( s2d_res_data.wbd_rval  ),
       .wbd_res_dat_i     ( s2d_res_data.wbd_dat   ),  // data input
       .wbd_res_ack_i     ( s2d_res_data.wbd_ack   ),  // acknowlegement
       .wbd_res_lack_i    ( s2d_res_data.wbd_lack  ),  // Last Burst access
       .wbd_res_err_i     ( s2d_res_data.wbd_err   ),  // error
       .wbd_res_tid_i     ( s2d_res_data.wbd_tid   ),
                                         
       .wbs_cyc_o         ( s2_wb_wr.wbd_cyc       ),  // strobe/request
       .wbs_stb_o         ( s2_wb_wr.wbd_stb       ),  // strobe/request
       .wbs_adr_o         ( s2_wb_wr.wbd_adr       ),  // address
       .wbs_we_o          ( s2_wb_wr.wbd_we        ),  // write
       .wbs_dat_o         ( s2_wb_wr.wbd_dat       ),  // data output
       .wbs_sel_o         ( s2_wb_wr.wbd_sel       ),  // byte enable
       .wbs_tid_o         ( s2_wb_wr.wbd_tid       ),
       .wbs_bl_o          ( s2_wb_wr.wbd_bl        ),  // Burst Count
       .wbs_bry_o         ( s2_wb_wr.wbd_bry       ),  // Busrt WData Avialble Or Ready To accept Rdata  

       .wbs_dat_i         ( s2_wb_rd.wbd_dat       ),  // data input
       .wbs_ack_i         ( s2_wb_rd.wbd_ack       ),  // acknowlegement
       .wbs_lack_i        ( s2_wb_rd.wbd_lack      ),  // Last Ack
       .wbs_err_i         ( s2_wb_rd.wbd_err       )   // error

    );

endmodule

