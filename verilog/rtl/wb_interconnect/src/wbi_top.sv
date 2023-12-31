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

`include "user_reg_map.v"

module wbi_top 
         (
`ifdef USE_POWER_PINS
         input logic            vccd1,    // User area 1 1.8V supply
         input logic            vssd1,    // User area 1 digital ground
`endif
         input logic            mclk_raw,
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

         input   logic [3:0]  	m0_wbd_mid_i,   // Master ID
         input   logic  	    m0_wbd_bry_i,
         input   logic [9:0] 	m0_wbd_bl_i,
         
         output  logic	[31:0]	m0_wbd_dat_o,
         output  logic		    m0_wbd_ack_o,
         output  logic		    m0_wbd_lack_o,
         output  logic		    m0_wbd_err_o,
         
         
         // Slave 0 Interface
         output logic           s0_mclk,
         input  logic           s0_idle,
         input  logic [3:0]     s0_wbd_sid_i,
         input	logic [31:0]	s0_wbd_dat_i,
         input	logic 	        s0_wbd_ack_i,
         input	logic 	        s0_wbd_lack_i,
         input	logic 	        s0_wbd_err_i, 

         output	logic [31:0]	s0_wbd_dat_o,
         output	logic [31:0]	s0_wbd_adr_o,
         output	logic [3:0]	    s0_wbd_sel_o,
         output	logic [9:0]	    s0_wbd_bl_o,
         output	logic 	        s0_wbd_bry_o,
         output	logic 	        s0_wbd_we_o,
         output	logic 	        s0_wbd_cyc_o,
         output	logic 	        s0_wbd_stb_o,
         
         // Master 1 Interface - uart
         input   logic	[31:0]	m1_wbd_dat_i,
         input   logic  [31:0]	m1_wbd_adr_i,
         input   logic  [3:0]	m1_wbd_sel_i,
         input   logic  	    m1_wbd_we_i,
         input   logic  	    m1_wbd_cyc_i,
         input   logic  	    m1_wbd_stb_i,
         input   logic [3:0]  	m1_wbd_mid_i,   // Master ID
         input   logic  	    m1_wbd_bry_i,
         input   logic [9:0] 	m1_wbd_bl_i,

         output  logic	[31:0]	m1_wbd_dat_o,
         output  logic		    m1_wbd_ack_o,
         output  logic		    m1_wbd_lack_o,
         output  logic		    m1_wbd_err_o,

         // Slave 1 Interface - uart
         output logic           s1_mclk,
         input  logic [3:0]     s1_wbd_sid_i,
         input	logic [31:0]	s1_wbd_dat_i,
         input	logic 	        s1_wbd_ack_i,
         input	logic 	        s1_wbd_err_i, 
         output	logic [31:0]	s1_wbd_dat_o,
         output	logic [10:0]    s1_wbd_adr_o, 
         output	logic [3:0]	    s1_wbd_sel_o,
         output	logic 	        s1_wbd_we_o,
         output	logic 	        s1_wbd_cyc_o,
         output	logic 	        s1_wbd_stb_o,
         
         // Slave 2 Interface - usb
         output logic           s2_mclk,
         input  logic [3:0]     s2_wbd_sid_i,
         input	logic [31:0]	s2_wbd_dat_i,
         input	logic 	        s2_wbd_ack_i,
         input	logic 	        s2_wbd_err_i,
         output	logic [31:0]	s2_wbd_dat_o,
         output	logic [10:0]	s2_wbd_adr_o, 
         output	logic [3:0]	    s2_wbd_sel_o,
         output	logic 	        s2_wbd_we_o,
         output	logic 	        s2_wbd_cyc_o,
         output	logic 	        s2_wbd_stb_o,

         // Master 2 Interface - sspi
         input   logic	[31:0]	m2_wbd_dat_i,
         input   logic  [31:0]	m2_wbd_adr_i,
         input   logic  [3:0]	m2_wbd_sel_i,
         input   logic  	    m2_wbd_we_i,
         input   logic  	    m2_wbd_cyc_i,
         input   logic  	    m2_wbd_stb_i,
         input   logic [3:0]  	m2_wbd_mid_i,   // Master ID
         input   logic  	    m2_wbd_bry_i,
         input   logic [9:0] 	m2_wbd_bl_i,

         output  logic	[31:0]	m2_wbd_dat_o,
         output  logic		    m2_wbd_ack_o,
         output  logic		    m2_wbd_lack_o,
         output  logic		    m2_wbd_err_o,

         // Slave 3 Interface - sspi
         output logic           s3_mclk,
         input  logic [3:0]     s3_wbd_sid_i,
         input	logic [31:0]	s3_wbd_dat_i,
         input	logic 	        s3_wbd_ack_i,
         input	logic 	        s3_wbd_err_i,
         output	logic [31:0]	s3_wbd_dat_o,
         output	logic [10:0]	s3_wbd_adr_o,
         output	logic [3:0]	    s3_wbd_sel_o,
         output	logic 	        s3_wbd_we_o,
         output	logic 	        s3_wbd_cyc_o,
         output	logic 	        s3_wbd_stb_o,

         // Master 3 Interface - Riscv
         output  logic          m3_mclk,
         input   logic	[31:0]	m3_wbd_dat_i,
         input   logic  [31:0]	m3_wbd_adr_i,
         input   logic  [3:0]	m3_wbd_sel_i,
         input   logic  	    m3_wbd_we_i,
         input   logic  	    m3_wbd_cyc_i,
         input   logic  	    m3_wbd_stb_i,
         input   logic [3:0]  	m3_wbd_mid_i,   // Master ID
         input   logic  	    m3_wbd_bry_i,
         input   logic [9:0] 	m3_wbd_bl_i,

         output  logic	[31:0]	m3_wbd_dat_o,
         output  logic		    m3_wbd_ack_o,
         output  logic		    m3_wbd_lack_o,
         output  logic		    m3_wbd_err_o,

         // Slave 4 Interface - pinmux
         output logic           s4_mclk,
         input  logic [3:0]     s4_wbd_sid_i,
         input	logic [31:0]	s4_wbd_dat_i,
         input	logic 	        s4_wbd_ack_i,
         input	logic 	        s4_wbd_err_i,
         output	logic [31:0]	s4_wbd_dat_o,
         output	logic [10:0]	s4_wbd_adr_o,
         output	logic [3:0]	    s4_wbd_sel_o,
         output	logic 	        s4_wbd_we_o,
         output	logic 	        s4_wbd_cyc_o,
         output	logic 	        s4_wbd_stb_o,

         // Slave 5 Interface - peri
         output logic           s5_mclk,
         input  logic [3:0]     s5_wbd_sid_i,
         input	logic [31:0]	s5_wbd_dat_i,
         input	logic 	        s5_wbd_ack_i,
         input	logic 	        s5_wbd_err_i, 
         output	logic [31:0]	s5_wbd_dat_o,
         output	logic [10:0]	s5_wbd_adr_o,
         output	logic [3:0]	    s5_wbd_sel_o,
         output	logic 	        s5_wbd_we_o,
         output	logic 	        s5_wbd_cyc_o,
         output	logic 	        s5_wbd_stb_o
	);

////////////////////////////////////////////////////////////////////
//
// Type define
////////////////////////////////////////////////////////////////////

parameter M_WB_HOST   = 4'b0001;
parameter M_UART_HOST = 4'b0010;
parameter M_SSPI_HOST = 4'b0011;


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
  logic [3:0] 	wbd_sid; // slave  id
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

// M1
type_wb_wr_intf m1_wb_wr;
type_wb_rd_intf m1_wb_rd;

type_wb_cmd_data_intf m1p_cmd_data;
type_wb_res_data_intf m1p_res_data;

type_wb_cmd_ctrl_intf m1p_cmd_ctrl;
type_wb_res_ctrl_intf m1p_res_ctrl;

type_wb_cmd_data_intf m1d_cmd_data;
type_wb_res_data_intf m1d_res_data;

type_wb_cmd_ctrl_intf m1d_cmd_ctrl;
type_wb_res_ctrl_intf m1d_res_ctrl;

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

// M2
type_wb_wr_intf m2_wb_wr;
type_wb_rd_intf m2_wb_rd;

type_wb_cmd_data_intf m2p_cmd_data;
type_wb_res_data_intf m2p_res_data;

type_wb_cmd_ctrl_intf m2p_cmd_ctrl;
type_wb_res_ctrl_intf m2p_res_ctrl;

type_wb_cmd_data_intf m2d_cmd_data;
type_wb_res_data_intf m2d_res_data;

type_wb_cmd_ctrl_intf m2d_cmd_ctrl;
type_wb_res_ctrl_intf m2d_res_ctrl;

// S3
type_wb_wr_intf s3_wb_wr;
type_wb_rd_intf s3_wb_rd;

type_wb_cmd_data_intf s3p_cmd_data;
type_wb_res_data_intf s3p_res_data;

type_wb_cmd_ctrl_intf s3p_cmd_ctrl;
type_wb_res_ctrl_intf s3p_res_ctrl;

type_wb_cmd_data_intf s3d_cmd_data;
type_wb_res_data_intf s3d_res_data;

type_wb_cmd_ctrl_intf s3d_cmd_ctrl;
type_wb_res_ctrl_intf s3d_res_ctrl;

// M3
type_wb_wr_intf m3_wb_wr;
type_wb_rd_intf m3_wb_rd;

type_wb_cmd_data_intf m3p_cmd_data;
type_wb_res_data_intf m3p_res_data;

type_wb_cmd_ctrl_intf m3p_cmd_ctrl;
type_wb_res_ctrl_intf m3p_res_ctrl;

type_wb_cmd_data_intf m3d_cmd_data;
type_wb_res_data_intf m3d_res_data;

type_wb_cmd_ctrl_intf m3d_cmd_ctrl;
type_wb_res_ctrl_intf m3d_res_ctrl;

// S4
type_wb_wr_intf s4_wb_wr;
type_wb_rd_intf s4_wb_rd;

type_wb_cmd_data_intf s4p_cmd_data;
type_wb_res_data_intf s4p_res_data;

type_wb_cmd_ctrl_intf s4p_cmd_ctrl;
type_wb_res_ctrl_intf s4p_res_ctrl;

type_wb_cmd_data_intf s4d_cmd_data;
type_wb_res_data_intf s4d_res_data;

type_wb_cmd_ctrl_intf s4d_cmd_ctrl;
type_wb_res_ctrl_intf s4d_res_ctrl;

// S5
type_wb_wr_intf       s5_wb_wr;
type_wb_rd_intf       s5_wb_rd;

type_wb_cmd_data_intf s5p_cmd_data;
type_wb_res_data_intf s5p_res_data;

type_wb_cmd_ctrl_intf s5p_cmd_ctrl;
type_wb_res_ctrl_intf s5p_res_ctrl;

type_wb_cmd_data_intf s5d_cmd_data;
type_wb_res_data_intf s5d_res_data;

type_wb_cmd_ctrl_intf s5d_cmd_ctrl;
type_wb_res_ctrl_intf s5d_res_ctrl;


//--------------------------------------



// ---------------------------------------------
// Master-0 Mapping
// ---------------------------------------------
assign m0_mclk           = mclk_raw;
assign m0_wb_wr.wbd_bl   = m0_wbd_bl_i;
assign m0_wb_wr.wbd_bry  = m0_wbd_bry_i;
assign m0_wb_wr.wbd_tid  = m0_wbd_mid_i;
assign m0_wb_wr.wbd_dat  = m0_wbd_dat_i;
assign m0_wb_wr.wbd_adr  = m0_wbd_adr_i;
assign m0_wb_wr.wbd_sel  = m0_wbd_sel_i;
assign m0_wb_wr.wbd_we   = m0_wbd_we_i;
assign m0_wb_wr.wbd_cyc  = m0_wbd_cyc_i;
assign m0_wb_wr.wbd_stb  = m0_wbd_stb_i;

assign m0_wbd_dat_o      = m0_wb_rd.wbd_dat;
assign m0_wbd_ack_o      = m0_wb_rd.wbd_ack;
assign m0_wbd_lack_o     = m0_wb_rd.wbd_lack;
assign m0_wbd_err_o      = m0_wb_rd.wbd_err;



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

assign s0_wb_rd.wbd_sid   = s0_wbd_sid_i ;
assign s0_wb_rd.wbd_dat   = s0_wbd_dat_i ;
assign s0_wb_rd.wbd_ack   = s0_wbd_ack_i ;
assign s0_wb_rd.wbd_lack  = s0_wbd_lack_i ;
assign s0_wb_rd.wbd_err   = s0_wbd_err_i ; 

// ---------------------------------------------
// Master-1 Mapping
// ---------------------------------------------
assign m1_wb_wr.wbd_bl   = m1_wbd_bl_i;
assign m1_wb_wr.wbd_bry  = m1_wbd_bry_i;
assign m1_wb_wr.wbd_tid  = m1_wbd_mid_i;
assign m1_wb_wr.wbd_dat  = m1_wbd_dat_i;
assign m1_wb_wr.wbd_adr  = m1_wbd_adr_i;
assign m1_wb_wr.wbd_sel  = m1_wbd_sel_i;
assign m1_wb_wr.wbd_we   = m1_wbd_we_i;
assign m1_wb_wr.wbd_cyc  = m1_wbd_cyc_i;
assign m1_wb_wr.wbd_stb  = m1_wbd_stb_i;

assign m1_wbd_dat_o      = m1_wb_rd.wbd_dat;
assign m1_wbd_ack_o      = m1_wb_rd.wbd_ack;
assign m1_wbd_lack_o     = m1_wb_rd.wbd_lack;
assign m1_wbd_err_o      = m1_wb_rd.wbd_err;
//----------------------------------------
// Slave-1 Port Mapping
// -------------------------------------
assign  s1_mclk      =  mclk_raw;
assign  s1_wbd_dat_o =  s1_wb_wr.wbd_dat ;
assign  s1_wbd_adr_o =  s1_wb_wr.wbd_adr[10:0] ;
assign  s1_wbd_sel_o =  s1_wb_wr.wbd_sel ;
assign  s1_wbd_we_o  =  s1_wb_wr.wbd_we  ;
assign  s1_wbd_cyc_o =  s1_wb_wr.wbd_cyc ;
assign  s1_wbd_stb_o =  s1_wb_wr.wbd_stb ;

assign s1_wb_rd.wbd_sid   = s1_wbd_sid_i ;
assign s1_wb_rd.wbd_dat   = s1_wbd_dat_i ;
assign s1_wb_rd.wbd_ack   = s1_wbd_ack_i ;
assign s1_wb_rd.wbd_lack  = s1_wbd_ack_i ;
assign s1_wb_rd.wbd_err   = s1_wbd_err_i ;
                      
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

assign s2_wb_rd.wbd_sid  = s2_wbd_sid_i ;
assign s2_wb_rd.wbd_dat  = s2_wbd_dat_i ;
assign s2_wb_rd.wbd_ack  = s2_wbd_ack_i ;
assign s2_wb_rd.wbd_lack = s2_wbd_ack_i ;
assign s2_wb_rd.wbd_err  = s2_wbd_err_i ; 

// ---------------------------------------------
// Master-2 Mapping
// ---------------------------------------------
assign m2_wb_wr.wbd_bl   = m2_wbd_bl_i;
assign m2_wb_wr.wbd_bry  = m2_wbd_bry_i;
assign m2_wb_wr.wbd_tid  = m2_wbd_mid_i;
assign m2_wb_wr.wbd_dat  = m2_wbd_dat_i;
assign m2_wb_wr.wbd_adr  = m2_wbd_adr_i;
assign m2_wb_wr.wbd_sel  = m2_wbd_sel_i;
assign m2_wb_wr.wbd_we   = m2_wbd_we_i;
assign m2_wb_wr.wbd_cyc  = m2_wbd_cyc_i;
assign m2_wb_wr.wbd_stb  = m2_wbd_stb_i;

assign m2_wbd_dat_o      = m2_wb_rd.wbd_dat;
assign m2_wbd_ack_o      = m2_wb_rd.wbd_ack;
assign m2_wbd_lack_o     = m2_wb_rd.wbd_lack;
assign m2_wbd_err_o      = m2_wb_rd.wbd_err;
//--------------------------------------
// Slave-3 Port Mapping
// -------------------------------------
assign  s3_mclk           =  mclk_raw;
assign  s3_wbd_dat_o      =  s3_wb_wr.wbd_dat ;
assign  s3_wbd_adr_o      =  s3_wb_wr.wbd_adr[10:0] ; // Global Reg Need 8 bit
assign  s3_wbd_sel_o      =  s3_wb_wr.wbd_sel ;
assign  s3_wbd_we_o       =  s3_wb_wr.wbd_we  ;
assign  s3_wbd_cyc_o      =  s3_wb_wr.wbd_cyc ;
assign  s3_wbd_stb_o      =  s3_wb_wr.wbd_stb ;

assign  s3_wb_rd.wbd_sid  =  s3_wbd_sid_i ;
assign  s3_wb_rd.wbd_dat  =  s3_wbd_dat_i ;
assign  s3_wb_rd.wbd_ack  =  s3_wbd_ack_i ;
assign  s3_wb_rd.wbd_lack =  s3_wbd_ack_i ;
assign  s3_wb_rd.wbd_err  =  s3_wbd_err_i ; 

// ---------------------------------------------
// Master-3 Mapping
// ---------------------------------------------
assign m3_mclk           = mclk_raw;
assign m3_wb_wr.wbd_bl   = m3_wbd_bl_i;
assign m3_wb_wr.wbd_bry  = m3_wbd_bry_i;
assign m3_wb_wr.wbd_tid  = m3_wbd_mid_i;
assign m3_wb_wr.wbd_dat  = m3_wbd_dat_i;
assign m3_wb_wr.wbd_adr  = m3_wbd_adr_i;
assign m3_wb_wr.wbd_sel  = m3_wbd_sel_i;
assign m3_wb_wr.wbd_we   = m3_wbd_we_i;
assign m3_wb_wr.wbd_cyc  = m3_wbd_cyc_i;
assign m3_wb_wr.wbd_stb  = m3_wbd_stb_i;

assign m3_wbd_dat_o      = m3_wb_rd.wbd_dat;
assign m3_wbd_ack_o      = m3_wb_rd.wbd_ack;
assign m3_wbd_lack_o     = m3_wb_rd.wbd_lack;
assign m3_wbd_err_o      = m3_wb_rd.wbd_err;

//--------------------------------------
// Slave-4 Port Mapping
// -------------------------------------
assign  s4_mclk           =  mclk_raw;
assign  s4_wbd_dat_o      =  s4_wb_wr.wbd_dat ;
assign  s4_wbd_adr_o      =  s4_wb_wr.wbd_adr[10:0] ; // Global Reg Need 8 bit
assign  s4_wbd_sel_o      =  s4_wb_wr.wbd_sel ;
assign  s4_wbd_we_o       =  s4_wb_wr.wbd_we  ;
assign  s4_wbd_cyc_o      =  s4_wb_wr.wbd_cyc ;
assign  s4_wbd_stb_o      =  s4_wb_wr.wbd_stb ;

assign  s4_wb_rd.wbd_sid  =  s4_wbd_sid_i ;
assign  s4_wb_rd.wbd_dat  =  s4_wbd_dat_i ;
assign  s4_wb_rd.wbd_ack  =  s4_wbd_ack_i ;
assign  s4_wb_rd.wbd_lack =  s4_wbd_ack_i ;
assign  s4_wb_rd.wbd_err  =  s4_wbd_err_i ; 

//--------------------------------------
// Slave-5 Port Mapping
// -------------------------------------
assign  s5_mclk           =  mclk_raw;
assign  s5_wbd_dat_o      =  s5_wb_wr.wbd_dat ;
assign  s5_wbd_adr_o      =  s5_wb_wr.wbd_adr[10:0] ; // Global Reg Need 8 bit
assign  s5_wbd_sel_o      =  s5_wb_wr.wbd_sel ;
assign  s5_wbd_we_o       =  s5_wb_wr.wbd_we  ;
assign  s5_wbd_cyc_o      =  s5_wb_wr.wbd_cyc ;
assign  s5_wbd_stb_o      =  s5_wb_wr.wbd_stb ;

assign  s5_wb_rd.wbd_sid  =  s5_wbd_sid_i ;
assign  s5_wb_rd.wbd_dat  =  s5_wbd_dat_i ;
assign  s5_wb_rd.wbd_ack  =  s5_wbd_ack_i ;
assign  s5_wb_rd.wbd_lack =  s5_wbd_ack_i ;
assign  s5_wb_rd.wbd_err  =  s5_wbd_err_i ; 

//------------------------------------------
// Command Daisy Chain
//------------------------------------------

// M0 => S0
assign s0p_cmd_data = m0d_cmd_data;
assign s0p_res_ctrl = m0d_res_ctrl;

assign m0d_res_data = s0p_res_data;
assign m0d_cmd_ctrl = s0p_cmd_ctrl;

// S0 => M1
assign m1p_cmd_data = s0d_cmd_data;
assign m1p_res_ctrl = s0d_res_ctrl;

assign s0d_res_data = m1p_res_data;
assign s0d_cmd_ctrl = m1p_cmd_ctrl;

// M1 => S1
assign s1p_cmd_data = m1d_cmd_data;
assign s1p_res_ctrl = m1d_res_ctrl;

assign m1d_res_data = s1p_res_data;
assign m1d_cmd_ctrl = s1p_cmd_ctrl;

// S1 => S2
assign s2p_cmd_data = s1d_cmd_data;
assign s2p_res_ctrl = s1d_res_ctrl;

assign s1d_cmd_ctrl = s2p_cmd_ctrl;
assign s1d_res_data = s2p_res_data;

// S2 => M2
assign m2p_cmd_data = s2d_cmd_data;
assign m2p_res_ctrl = s2d_res_ctrl;

assign s2d_cmd_ctrl = m2p_cmd_ctrl;
assign s2d_res_data = m2p_res_data;

//M2 => S3
assign s3p_cmd_data = m2d_cmd_data;
assign s3p_res_ctrl = m2d_res_ctrl;

assign m2d_cmd_ctrl = s3p_cmd_ctrl;
assign m2d_res_data = s3p_res_data;

//S3 => M3
assign m3p_cmd_data = s3d_cmd_data;
assign m3p_res_ctrl = s3d_res_ctrl;

assign s3d_cmd_ctrl = m3p_cmd_ctrl;
assign s3d_res_data = m3p_res_data;

//M3 => S4
assign s4p_cmd_data = m3d_cmd_data;
assign s4p_res_ctrl = m3d_res_ctrl;

assign m3d_cmd_ctrl = s4p_cmd_ctrl;
assign m3d_res_data = s4p_res_data;

//S4 => S5
assign s5p_cmd_data = s4d_cmd_data;
assign s5p_res_ctrl = s4d_res_ctrl;

assign s4d_cmd_ctrl = s5p_cmd_ctrl;
assign s4d_res_data = s5p_res_data;

// S5 => M0
assign m0p_cmd_data = s5d_cmd_data;
assign m0p_res_ctrl = s5d_res_ctrl;

assign s5d_cmd_ctrl = m0p_cmd_ctrl;
assign s5d_res_data = m0p_res_data;

//----------------------------------------------------------
// M0: WISHBONE HOST MASTER
//----------------------------------------------------------

wbi_master_port_m0 #(
`ifndef SYNTHESIS
     .CDP(2), .RDP(2)
`endif
    ) u_m0 (
`ifdef USE_POWER_PINS
        .vccd1            (vccd1                       ),    // User area 1 1.8V supply
        .vssd1            (vssd1                       ),    // User area 1 digital ground
`endif
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
wbi_slave_port_s0 
     #(
`ifndef SYNTHESIS
       .BENB(1), // BURST ENB
       .SAW (32),// SLAVE ADD WIDTH
       .CDP (2), // CMD FIFO DEPTH
       .RDP (2)  // RESPONSE FIFO DEPTH
`endif

       ) u_s0 (
`ifdef USE_POWER_PINS
       .vccd1             (vccd1                   ),    // User area 1 1.8V supply
       .vssd1             (vssd1                   ),    // User area 1 digital ground
`endif
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

       .wbs_sid_i         ( s0_wb_rd.wbd_sid       ),  // Slave ID
       .wbs_dat_i         ( s0_wb_rd.wbd_dat       ),  // data input
       .wbs_ack_i         ( s0_wb_rd.wbd_ack       ),  // acknowlegement
       .wbs_lack_i        ( s0_wb_rd.wbd_lack      ),  // Last Ack
       .wbs_err_i         ( s0_wb_rd.wbd_err       )   // error

    );

//----------------------------------------------------------
// M1: UART HOST MASTER
//----------------------------------------------------------

wbi_master_port_m1 #(
`ifndef SYNTHESIS
.CDP(2), .RDP(2)
`endif
) u_m1 (
`ifdef USE_POWER_PINS
       .vccd1             (vccd1                   ),    // User area 1 1.8V supply
       .vssd1             (vssd1                   ),    // User area 1 digital ground
`endif
       .reset_n           (rst_n                       ),  // Regular Reset signal
       .mclk              (clk_i                       ),  // System clock
                             
       // Wb I/F - Entry             
       .wbm_cyc_i         (m1_wb_wr.wbd_cyc            ),  // strobe/request
       .wbm_stb_i         (m1_wb_wr.wbd_stb            ),  // strobe/request
       .wbm_adr_i         (m1_wb_wr.wbd_adr            ),  // address
       .wbm_we_i          (m1_wb_wr.wbd_we             ),  // write
       .wbm_dat_i         (m1_wb_wr.wbd_dat            ),  // data output
       .wbm_sel_i         (m1_wb_wr.wbd_sel            ),  // byte enable
       .wbm_tid_i         (m1_wb_wr.wbd_tid            ),
       .wbm_bl_i          (m1_wb_wr.wbd_bl             ),  // Burst Count
       .wbm_bry_i         (m1_wb_wr.wbd_bry            ),  // Burst Ready

       .wbm_dat_o         (m1_wb_rd.wbd_dat            ),  // data input
       .wbm_ack_o         (m1_wb_rd.wbd_ack            ),  // acknowlegement
       .wbm_lack_o        (m1_wb_rd.wbd_lack           ),  // Last Burst access
       .wbm_err_o         (m1_wb_rd.wbd_err            ),  // error
                                          
       // Previous chain - CMD                                  
       .wbp_cmd_wrdy_o    (m1p_cmd_ctrl.wbd_wrdy       ),  // Ready path Ready to accept the data
       .wbp_cmd_wval_i    (m1p_cmd_data.wbd_wval       ),
       .wbp_cmd_adr_i     (m1p_cmd_data.wbd_adr        ),  // address
       .wbp_cmd_we_i      (m1p_cmd_data.wbd_we         ),  // write
       .wbp_cmd_dat_i     (m1p_cmd_data.wbd_dat        ),  // data output
       .wbp_cmd_sel_i     (m1p_cmd_data.wbd_sel        ),  // byte enable
       .wbp_cmd_tid_i     (m1p_cmd_data.wbd_tid        ),
       .wbp_cmd_bl_i      (m1p_cmd_data.wbd_bl         ),  // Burst Count
                                          
       // Previous chain - RES                                  
       .wbp_res_rrdy_i    (m1p_res_ctrl.wbd_rrdy       ),  // Ready path Ready to accept the data
       .wbp_res_rval_o    (m1p_res_data.wbd_rval       ),
       .wbp_res_dat_o     (m1p_res_data.wbd_dat        ),  // data input
       .wbp_res_ack_o     (m1p_res_data.wbd_ack        ),  // acknowlegement
       .wbp_res_lack_o    (m1p_res_data.wbd_lack       ),  // Last Burst access
       .wbp_res_err_o     (m1p_res_data.wbd_err        ),  // error
       .wbp_res_tid_o     (m1p_res_data.wbd_tid        ),
                       
       // Next Daisy chain - CMD                   
       .wbd_cmd_wrdy_i    (m1d_cmd_ctrl.wbd_wrdy        ),  // Ready path Ready to accept the data
       .wbd_cmd_wval_o    (m1d_cmd_data.wbd_wval        ),
       .wbd_cmd_adr_o     (m1d_cmd_data.wbd_adr         ),  // address
       .wbd_cmd_we_o      (m1d_cmd_data.wbd_we          ),  // write
       .wbd_cmd_dat_o     (m1d_cmd_data.wbd_dat         ),  // data output
       .wbd_cmd_sel_o     (m1d_cmd_data.wbd_sel         ),  // byte enable
       .wbd_cmd_tid_o     (m1d_cmd_data.wbd_tid         ),
       .wbd_cmd_bl_o      (m1d_cmd_data.wbd_bl          ),  // Burst Count
                                          
       // Next Daisy chain - RES                   
       .wbd_res_rrdy_o    (m1d_res_ctrl.wbd_rrdy        ),  // Ready path Ready to accept the data
       .wbd_res_rval_i    (m1d_res_data.wbd_rval        ),
       .wbd_res_dat_i     (m1d_res_data.wbd_dat         ),  // data input
       .wbd_res_ack_i     (m1d_res_data.wbd_ack         ),  // acknowlegement
       .wbd_res_lack_i    (m1d_res_data.wbd_lack        ),  // Last Burst access
       .wbd_res_err_i     (m1d_res_data.wbd_err         ),  // error
       .wbd_res_tid_i     (m1d_res_data.wbd_tid         )
    );

//----------------------------------------------------------
// S1: UART
//----------------------------------------------------------

wbi_slave_port_s1 
     #(
`ifndef SYNTHESIS
       .BENB(0), // BURST ENB
       .SAW (11),// SLAVE ADD WIDTH
       .CDP (2), // CMD FIFO DEPTH
       .RDP (2) // RESPONSE FIFO DEPTH
`endif

       ) u_s1 (
`ifdef USE_POWER_PINS
       .vccd1             (vccd1                   ),    // User area 1 1.8V supply
       .vssd1             (vssd1                   ),    // User area 1 digital ground
`endif
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
       .wbs_adr_o         ( s1_wb_wr.wbd_adr[10:0] ),  // address
       .wbs_we_o          ( s1_wb_wr.wbd_we        ),  // write
       .wbs_dat_o         ( s1_wb_wr.wbd_dat       ),  // data output
       .wbs_sel_o         ( s1_wb_wr.wbd_sel       ),  // byte enable
       .wbs_tid_o         ( s1_wb_wr.wbd_tid       ),
       .wbs_bl_o          ( s1_wb_wr.wbd_bl        ),  // Burst Count
       .wbs_bry_o         ( s1_wb_wr.wbd_bry       ),  // Busrt WData Avialble Or Ready To accept Rdata  

       .wbs_sid_i         ( s1_wb_rd.wbd_sid       ),  // Slave ID
       .wbs_dat_i         ( s1_wb_rd.wbd_dat       ),  // data input
       .wbs_ack_i         ( s1_wb_rd.wbd_ack       ),  // acknowlegement
       .wbs_lack_i        ( s1_wb_rd.wbd_lack      ),  // Last Ack
       .wbs_err_i         ( s1_wb_rd.wbd_err       )   // error

    );

//----------------------------------------------------------
// S2: USB
//----------------------------------------------------------

wbi_slave_port_s2 
     #(
`ifndef SYNTHESIS
       .BENB(0), // BURST ENB
       .SAW (11),// SLAVE ADD WIDTH
       .CDP (2), // CMD FIFO DEPTH
       .RDP (2) // RESPONSE FIFO DEPTH
`endif

       ) u_s2 (
`ifdef USE_POWER_PINS
       .vccd1             (vccd1                   ),    // User area 1 1.8V supply
       .vssd1             (vssd1                   ),    // User area 1 digital ground
`endif
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
       .wbs_adr_o         ( s2_wb_wr.wbd_adr[10:0] ),  // address
       .wbs_we_o          ( s2_wb_wr.wbd_we        ),  // write
       .wbs_dat_o         ( s2_wb_wr.wbd_dat       ),  // data output
       .wbs_sel_o         ( s2_wb_wr.wbd_sel       ),  // byte enable
       .wbs_tid_o         ( s2_wb_wr.wbd_tid       ),
       .wbs_bl_o          ( s2_wb_wr.wbd_bl        ),  // Burst Count
       .wbs_bry_o         ( s2_wb_wr.wbd_bry       ),  // Busrt WData Avialble Or Ready To accept Rdata  

       .wbs_sid_i         ( s2_wb_rd.wbd_sid       ),  // Slave ID
       .wbs_dat_i         ( s2_wb_rd.wbd_dat       ),  // data input
       .wbs_ack_i         ( s2_wb_rd.wbd_ack       ),  // acknowlegement
       .wbs_lack_i        ( s2_wb_rd.wbd_lack      ),  // Last Ack
       .wbs_err_i         ( s2_wb_rd.wbd_err       )   // error

    );

//----------------------------------------------------------
// M2: SSPI HOST MASTER
//----------------------------------------------------------

wbi_master_port_m2 #(
`ifndef SYNTHESIS
     .CDP(2), .RDP(2)
`endif

      ) u_m2 (
`ifdef USE_POWER_PINS
       .vccd1             (vccd1                   ),    // User area 1 1.8V supply
       .vssd1             (vssd1                   ),    // User area 1 digital ground
`endif
       .reset_n           (rst_n                       ),  // Regular Reset signal
       .mclk              (clk_i                       ),  // System clock
                             
       // Wb I/F - Entry             
       .wbm_cyc_i         (m2_wb_wr.wbd_cyc            ),  // strobe/request
       .wbm_stb_i         (m2_wb_wr.wbd_stb            ),  // strobe/request
       .wbm_adr_i         (m2_wb_wr.wbd_adr            ),  // address
       .wbm_we_i          (m2_wb_wr.wbd_we             ),  // write
       .wbm_dat_i         (m2_wb_wr.wbd_dat            ),  // data output
       .wbm_sel_i         (m2_wb_wr.wbd_sel            ),  // byte enable
       .wbm_tid_i         (m2_wb_wr.wbd_tid            ),
       .wbm_bl_i          (m2_wb_wr.wbd_bl             ),  // Burst Count
       .wbm_bry_i         (m2_wb_wr.wbd_bry            ),  // Burst Ready

       .wbm_dat_o         (m2_wb_rd.wbd_dat            ),  // data input
       .wbm_ack_o         (m2_wb_rd.wbd_ack            ),  // acknowlegement
       .wbm_lack_o        (m2_wb_rd.wbd_lack           ),  // Last Burst access
       .wbm_err_o         (m2_wb_rd.wbd_err            ),  // error
                                          
       .wbp_cmd_wrdy_o    (m2p_cmd_ctrl.wbd_wrdy       ),  // Ready path Ready to accept the data
       .wbp_cmd_wval_i    (m2p_cmd_data.wbd_wval       ),
       .wbp_cmd_adr_i     (m2p_cmd_data.wbd_adr        ),  // address
       .wbp_cmd_we_i      (m2p_cmd_data.wbd_we         ),  // write
       .wbp_cmd_dat_i     (m2p_cmd_data.wbd_dat        ),  // data output
       .wbp_cmd_sel_i     (m2p_cmd_data.wbd_sel        ),  // byte enable
       .wbp_cmd_tid_i     (m2p_cmd_data.wbd_tid        ),
       .wbp_cmd_bl_i      (m2p_cmd_data.wbd_bl         ),  // Burst Count
                                          
       .wbp_res_rrdy_i    (m2p_res_ctrl.wbd_rrdy       ),  // Ready path Ready to accept the data
       .wbp_res_rval_o    (m2p_res_data.wbd_rval       ),
       .wbp_res_dat_o     (m2p_res_data.wbd_dat        ),  // data input
       .wbp_res_ack_o     (m2p_res_data.wbd_ack        ),  // acknowlegement
       .wbp_res_lack_o    (m2p_res_data.wbd_lack       ),  // Last Burst access
       .wbp_res_err_o     (m2p_res_data.wbd_err        ),  // error
       .wbp_res_tid_o     (m2p_res_data.wbd_tid        ),
                       
       .wbd_cmd_wrdy_i    (m2d_cmd_ctrl.wbd_wrdy       ),  // Ready path Ready to accept the data
       .wbd_cmd_wval_o    (m2d_cmd_data.wbd_wval       ),
       .wbd_cmd_adr_o     (m2d_cmd_data.wbd_adr        ),  // address
       .wbd_cmd_we_o      (m2d_cmd_data.wbd_we         ),  // write
       .wbd_cmd_dat_o     (m2d_cmd_data.wbd_dat        ),  // data output
       .wbd_cmd_sel_o     (m2d_cmd_data.wbd_sel        ),  // byte enable
       .wbd_cmd_tid_o     (m2d_cmd_data.wbd_tid        ),
       .wbd_cmd_bl_o      (m2d_cmd_data.wbd_bl         ),  // Burst Count
                                          
       .wbd_res_rrdy_o    (m2d_res_ctrl.wbd_rrdy       ),  // Ready path Ready to accept the data
       .wbd_res_rval_i    (m2d_res_data.wbd_rval       ),
       .wbd_res_dat_i     (m2d_res_data.wbd_dat        ),  // data input
       .wbd_res_ack_i     (m2d_res_data.wbd_ack        ),  // acknowlegement
       .wbd_res_lack_i    (m2d_res_data.wbd_lack       ),  // Last Burst access
       .wbd_res_err_i     (m2d_res_data.wbd_err        ),  // error
       .wbd_res_tid_i     (m2d_res_data.wbd_tid        )
    );

//----------------------------------------------------------
// S3: SSPI
//----------------------------------------------------------

wbi_slave_port_s3 
     #(
`ifndef SYNTHESIS
       .BENB(0), // BURST ENB
       .SAW (11),// SLAVE ADD WIDTH
       .CDP (2), // CMD FIFO DEPTH
       .RDP (2) // RESPONSE FIFO DEPTH
`endif

       ) u_s3 (
`ifdef USE_POWER_PINS
       .vccd1             (vccd1                   ),    // User area 1 1.8V supply
       .vssd1             (vssd1                   ),    // User area 1 digital ground
`endif
       .reset_n           ( rst_n                  ),  // Regular Reset signal
       .mclk              ( clk_i                  ),  // System clock
                                           
       .wbp_cmd_wrdy_o    ( s3p_cmd_ctrl.wbd_wrdy  ),  // Ready path Ready to accept the data
       .wbp_cmd_wval_i    ( s3p_cmd_data.wbd_wval  ),
       .wbp_cmd_adr_i     ( s3p_cmd_data.wbd_adr   ),  // address
       .wbp_cmd_we_i      ( s3p_cmd_data.wbd_we    ),  // write
       .wbp_cmd_dat_i     ( s3p_cmd_data.wbd_dat   ),  // data output
       .wbp_cmd_sel_i     ( s3p_cmd_data.wbd_sel   ),  // byte enable
       .wbp_cmd_tid_i     ( s3p_cmd_data.wbd_tid   ),
       .wbp_cmd_bl_i      ( s3p_cmd_data.wbd_bl    ),  // Burst Count
                                    
       .wbp_res_rrdy_i    ( s3p_res_ctrl.wbd_rrdy  ),  // Ready path Ready to accept the data
       .wbp_res_rval_o    ( s3p_res_data.wbd_rval  ),
       .wbp_res_dat_o     ( s3p_res_data.wbd_dat   ),  // data input
       .wbp_res_ack_o     ( s3p_res_data.wbd_ack   ),  // acknowlegement
       .wbp_res_lack_o    ( s3p_res_data.wbd_lack  ),  // Last Burst access
       .wbp_res_err_o     ( s3p_res_data.wbd_err   ),  // error
       .wbp_res_tid_o     ( s3p_res_data.wbd_tid   ),
                                         
       .wbd_cmd_wrdy_i    ( s3d_cmd_ctrl.wbd_wrdy  ),  // Ready path Ready to accept the data
       .wbd_cmd_wval_o    ( s3d_cmd_data.wbd_wval  ),
       .wbd_cmd_adr_o     ( s3d_cmd_data.wbd_adr   ),  // address
       .wbd_cmd_we_o      ( s3d_cmd_data.wbd_we    ),  // write
       .wbd_cmd_dat_o     ( s3d_cmd_data.wbd_dat   ),  // data output
       .wbd_cmd_sel_o     ( s3d_cmd_data.wbd_sel   ),  // byte enable
       .wbd_cmd_tid_o     ( s3d_cmd_data.wbd_tid   ),
       .wbd_cmd_bl_o      ( s3d_cmd_data.wbd_bl    ),  // Burst Count
                                      
       .wbd_res_rrdy_o    ( s3d_res_ctrl.wbd_rrdy  ),  // Ready path Ready to accept the data
       .wbd_res_rval_i    ( s3d_res_data.wbd_rval  ),
       .wbd_res_dat_i     ( s3d_res_data.wbd_dat   ),  // data input
       .wbd_res_ack_i     ( s3d_res_data.wbd_ack   ),  // acknowlegement
       .wbd_res_lack_i    ( s3d_res_data.wbd_lack  ),  // Last Burst access
       .wbd_res_err_i     ( s3d_res_data.wbd_err   ),  // error
       .wbd_res_tid_i     ( s3d_res_data.wbd_tid   ),
                                        
       .wbs_cyc_o         ( s3_wb_wr.wbd_cyc       ),  // strobe/request
       .wbs_stb_o         ( s3_wb_wr.wbd_stb       ),  // strobe/request
       .wbs_adr_o         ( s3_wb_wr.wbd_adr[10:0] ),  // address
       .wbs_we_o          ( s3_wb_wr.wbd_we        ),  // write
       .wbs_dat_o         ( s3_wb_wr.wbd_dat       ),  // data output
       .wbs_sel_o         ( s3_wb_wr.wbd_sel       ),  // byte enable
       .wbs_tid_o         ( s3_wb_wr.wbd_tid       ),
       .wbs_bl_o          ( s3_wb_wr.wbd_bl        ),  // Burst Count
       .wbs_bry_o         ( s3_wb_wr.wbd_bry       ),  // Busrt WData Avialble Or Ready To accept Rdata  

       .wbs_sid_i         ( s3_wb_rd.wbd_sid       ),  // Slave ID
       .wbs_dat_i         ( s3_wb_rd.wbd_dat       ),  // data input
       .wbs_ack_i         ( s3_wb_rd.wbd_ack       ),  // acknowlegement
       .wbs_lack_i        ( s3_wb_rd.wbd_lack      ),  // Last Ack
       .wbs_err_i         ( s3_wb_rd.wbd_err       )   // error

    );

//----------------------------------------------------------
// M3: Riscv
//----------------------------------------------------------

wbi_master_port_m3 #(
`ifndef SYNTHESIS
     .CDP(2), .RDP(2)
`endif
    ) u_m3 (
`ifdef USE_POWER_PINS
        .vccd1            (vccd1                       ),    // User area 1 1.8V supply
        .vssd1            (vssd1                       ),    // User area 1 digital ground
`endif
       .reset_n           (rst_n                       ),  // Regular Reset signal
       .mclk              (clk_i                       ),  // System clock
                             
       // Wb I/F - Entry             
       .wbm_cyc_i         (m3_wb_wr.wbd_cyc            ),  // strobe/request
       .wbm_stb_i         (m3_wb_wr.wbd_stb            ),  // strobe/request
       .wbm_adr_i         (m3_wb_wr.wbd_adr            ),  // address
       .wbm_we_i          (m3_wb_wr.wbd_we             ),  // write
       .wbm_dat_i         (m3_wb_wr.wbd_dat            ),  // data output
       .wbm_sel_i         (m3_wb_wr.wbd_sel            ),  // byte enable
       .wbm_tid_i         (m3_wb_wr.wbd_tid            ),
       .wbm_bl_i          (m3_wb_wr.wbd_bl             ),  // Burst Count
       .wbm_bry_i         (m3_wb_wr.wbd_bry            ),  // Burst Ready

       .wbm_dat_o         (m3_wb_rd.wbd_dat            ),  // data input
       .wbm_ack_o         (m3_wb_rd.wbd_ack            ),  // acknowlegement
       .wbm_lack_o        (m3_wb_rd.wbd_lack           ),  // Last Burst access
       .wbm_err_o         (m3_wb_rd.wbd_err            ),  // error
                                          
       // Previous chain - CMD                                  
       .wbp_cmd_wrdy_o    (m3p_cmd_ctrl.wbd_wrdy       ),  // Ready path Ready to accept the data
       .wbp_cmd_wval_i    (m3p_cmd_data.wbd_wval       ),
       .wbp_cmd_adr_i     (m3p_cmd_data.wbd_adr        ),  // address
       .wbp_cmd_we_i      (m3p_cmd_data.wbd_we         ),  // write
       .wbp_cmd_dat_i     (m3p_cmd_data.wbd_dat        ),  // data output
       .wbp_cmd_sel_i     (m3p_cmd_data.wbd_sel        ),  // byte enable
       .wbp_cmd_tid_i     (m3p_cmd_data.wbd_tid        ),
       .wbp_cmd_bl_i      (m3p_cmd_data.wbd_bl         ),  // Burst Count
                                          
       // Previous chain - RES                                  
       .wbp_res_rrdy_i    (m3p_res_ctrl.wbd_rrdy       ),  // Ready path Ready to accept the data
       .wbp_res_rval_o    (m3p_res_data.wbd_rval       ),
       .wbp_res_dat_o     (m3p_res_data.wbd_dat        ),  // data input
       .wbp_res_ack_o     (m3p_res_data.wbd_ack        ),  // acknowlegement
       .wbp_res_lack_o    (m3p_res_data.wbd_lack       ),  // Last Burst access
       .wbp_res_err_o     (m3p_res_data.wbd_err        ),  // error
       .wbp_res_tid_o     (m3p_res_data.wbd_tid        ),
                       
       // Next Daisy chain - CMD                   
       .wbd_cmd_wrdy_i    (m3d_cmd_ctrl.wbd_wrdy        ),  // Ready path Ready to accept the data
       .wbd_cmd_wval_o    (m3d_cmd_data.wbd_wval        ),
       .wbd_cmd_adr_o     (m3d_cmd_data.wbd_adr         ),  // address
       .wbd_cmd_we_o      (m3d_cmd_data.wbd_we          ),  // write
       .wbd_cmd_dat_o     (m3d_cmd_data.wbd_dat         ),  // data output
       .wbd_cmd_sel_o     (m3d_cmd_data.wbd_sel         ),  // byte enable
       .wbd_cmd_tid_o     (m3d_cmd_data.wbd_tid         ),
       .wbd_cmd_bl_o      (m3d_cmd_data.wbd_bl          ),  // Burst Count
                                          
       // Next Daisy chain - RES                   
       .wbd_res_rrdy_o    (m3d_res_ctrl.wbd_rrdy        ),  // Ready path Ready to accept the data
       .wbd_res_rval_i    (m3d_res_data.wbd_rval        ),
       .wbd_res_dat_i     (m3d_res_data.wbd_dat         ),  // data input
       .wbd_res_ack_i     (m3d_res_data.wbd_ack         ),  // acknowlegement
       .wbd_res_lack_i    (m3d_res_data.wbd_lack        ),  // Last Burst access
       .wbd_res_err_i     (m3d_res_data.wbd_err         ),  // error
       .wbd_res_tid_i     (m3d_res_data.wbd_tid         )
    );

//----------------------------------------------------------
// S4: Pinmux
//----------------------------------------------------------

wbi_slave_port_s4 
     #(
`ifndef SYNTHESIS
       .BENB(0), // BURST ENB
       .SAW (11),// SLAVE ADD WIDTH
       .CDP (2), // CMD FIFO DEPTH
       .RDP (2) // RESPONSE FIFO DEPTH
`endif

       ) u_s4 (
`ifdef USE_POWER_PINS
       .vccd1             (vccd1                   ),    // User area 1 1.8V supply
       .vssd1             (vssd1                   ),    // User area 1 digital ground
`endif
       .reset_n           ( rst_n                  ),  // Regular Reset signal
       .mclk              ( clk_i                  ),  // System clock
                                           
       .wbp_cmd_wrdy_o    ( s4p_cmd_ctrl.wbd_wrdy  ),  // Ready path Ready to accept the data
       .wbp_cmd_wval_i    ( s4p_cmd_data.wbd_wval  ),
       .wbp_cmd_adr_i     ( s4p_cmd_data.wbd_adr   ),  // address
       .wbp_cmd_we_i      ( s4p_cmd_data.wbd_we    ),  // write
       .wbp_cmd_dat_i     ( s4p_cmd_data.wbd_dat   ),  // data output
       .wbp_cmd_sel_i     ( s4p_cmd_data.wbd_sel   ),  // byte enable
       .wbp_cmd_tid_i     ( s4p_cmd_data.wbd_tid   ),
       .wbp_cmd_bl_i      ( s4p_cmd_data.wbd_bl    ),  // Burst Count
                                   
       .wbp_res_rrdy_i    ( s4p_res_ctrl.wbd_rrdy  ),  // Ready path Ready to accept the data
       .wbp_res_rval_o    ( s4p_res_data.wbd_rval  ),
       .wbp_res_dat_o     ( s4p_res_data.wbd_dat   ),  // data input
       .wbp_res_ack_o     ( s4p_res_data.wbd_ack   ),  // acknowlegement
       .wbp_res_lack_o    ( s4p_res_data.wbd_lack  ),  // Last Burst access
       .wbp_res_err_o     ( s4p_res_data.wbd_err   ),  // error
       .wbp_res_tid_o     ( s4p_res_data.wbd_tid   ),
                                        
       .wbd_cmd_wrdy_i    ( s4d_cmd_ctrl.wbd_wrdy  ),  // Ready path Ready to accept the data
       .wbd_cmd_wval_o    ( s4d_cmd_data.wbd_wval  ),
       .wbd_cmd_adr_o     ( s4d_cmd_data.wbd_adr   ),  // address
       .wbd_cmd_we_o      ( s4d_cmd_data.wbd_we    ),  // write
       .wbd_cmd_dat_o     ( s4d_cmd_data.wbd_dat   ),  // data output
       .wbd_cmd_sel_o     ( s4d_cmd_data.wbd_sel   ),  // byte enable
       .wbd_cmd_tid_o     ( s4d_cmd_data.wbd_tid   ),
       .wbd_cmd_bl_o      ( s4d_cmd_data.wbd_bl    ),  // Burst Count
                                     
       .wbd_res_rrdy_o    ( s4d_res_ctrl.wbd_rrdy  ),  // Ready path Ready to accept the data
       .wbd_res_rval_i    ( s4d_res_data.wbd_rval  ),
       .wbd_res_dat_i     ( s4d_res_data.wbd_dat   ),  // data input
       .wbd_res_ack_i     ( s4d_res_data.wbd_ack   ),  // acknowlegement
       .wbd_res_lack_i    ( s4d_res_data.wbd_lack  ),  // Last Burst access
       .wbd_res_err_i     ( s4d_res_data.wbd_err   ),  // error
       .wbd_res_tid_i     ( s4d_res_data.wbd_tid   ),
                                       
       .wbs_cyc_o         ( s4_wb_wr.wbd_cyc       ),  // strobe/request
       .wbs_stb_o         ( s4_wb_wr.wbd_stb       ),  // strobe/request
       .wbs_adr_o         ( s4_wb_wr.wbd_adr[10:0] ),  // address
       .wbs_we_o          ( s4_wb_wr.wbd_we        ),  // write
       .wbs_dat_o         ( s4_wb_wr.wbd_dat       ),  // data output
       .wbs_sel_o         ( s4_wb_wr.wbd_sel       ),  // byte enable
       .wbs_tid_o         ( s4_wb_wr.wbd_tid       ),
       .wbs_bl_o          ( s4_wb_wr.wbd_bl        ),  // Burst Count
       .wbs_bry_o         ( s4_wb_wr.wbd_bry       ),  // Busrt WData Avialble Or Ready To accept Rdata  

       .wbs_sid_i         ( s4_wb_rd.wbd_sid       ),  // Slave ID
       .wbs_dat_i         ( s4_wb_rd.wbd_dat       ),  // data input
       .wbs_ack_i         ( s4_wb_rd.wbd_ack       ),  // acknowlegement
       .wbs_lack_i        ( s4_wb_rd.wbd_lack      ),  // Last Ack
       .wbs_err_i         ( s4_wb_rd.wbd_err       )   // error

    );
//----------------------------------------------------------
// S5: Peri-0
//----------------------------------------------------------

wbi_slave_port_s5 
     #(
`ifndef SYNTHESIS
       .BENB(0), // BURST ENB
       .SAW (11),// SLAVE ADD WIDTH
       .CDP (2), // CMD FIFO DEPTH
       .RDP (2) // RESPONSE FIFO DEPTH
`endif

       ) u_s5 (
`ifdef USE_POWER_PINS
       .vccd1             (vccd1                   ),    // User area 1 1.8V supply
       .vssd1             (vssd1                   ),    // User area 1 digital ground
`endif
       .reset_n           ( rst_n                  ),  // Regular Reset signal
       .mclk              ( clk_i                  ),  // System clock
                                           
       .wbp_cmd_wrdy_o    ( s5p_cmd_ctrl.wbd_wrdy  ),  // Ready path Ready to accept the data
       .wbp_cmd_wval_i    ( s5p_cmd_data.wbd_wval  ),
       .wbp_cmd_adr_i     ( s5p_cmd_data.wbd_adr   ),  // address
       .wbp_cmd_we_i      ( s5p_cmd_data.wbd_we    ),  // write
       .wbp_cmd_dat_i     ( s5p_cmd_data.wbd_dat   ),  // data output
       .wbp_cmd_sel_i     ( s5p_cmd_data.wbd_sel   ),  // byte enable
       .wbp_cmd_tid_i     ( s5p_cmd_data.wbd_tid   ),
       .wbp_cmd_bl_i      ( s5p_cmd_data.wbd_bl    ),  // Burst Count
                                  
       .wbp_res_rrdy_i    ( s5p_res_ctrl.wbd_rrdy  ),  // Ready path Ready to accept the data
       .wbp_res_rval_o    ( s5p_res_data.wbd_rval  ),
       .wbp_res_dat_o     ( s5p_res_data.wbd_dat   ),  // data input
       .wbp_res_ack_o     ( s5p_res_data.wbd_ack   ),  // acknowlegement
       .wbp_res_lack_o    ( s5p_res_data.wbd_lack  ),  // Last Burst access
       .wbp_res_err_o     ( s5p_res_data.wbd_err   ),  // error
       .wbp_res_tid_o     ( s5p_res_data.wbd_tid   ),
                                       
       .wbd_cmd_wrdy_i    ( s5d_cmd_ctrl.wbd_wrdy  ),  // Ready path Ready to accept the data
       .wbd_cmd_wval_o    ( s5d_cmd_data.wbd_wval  ),
       .wbd_cmd_adr_o     ( s5d_cmd_data.wbd_adr   ),  // address
       .wbd_cmd_we_o      ( s5d_cmd_data.wbd_we    ),  // write
       .wbd_cmd_dat_o     ( s5d_cmd_data.wbd_dat   ),  // data output
       .wbd_cmd_sel_o     ( s5d_cmd_data.wbd_sel   ),  // byte enable
       .wbd_cmd_tid_o     ( s5d_cmd_data.wbd_tid   ),
       .wbd_cmd_bl_o      ( s5d_cmd_data.wbd_bl    ),  // Burst Count
                                    
       .wbd_res_rrdy_o    ( s5d_res_ctrl.wbd_rrdy  ),  // Ready path Ready to accept the data
       .wbd_res_rval_i    ( s5d_res_data.wbd_rval  ),
       .wbd_res_dat_i     ( s5d_res_data.wbd_dat   ),  // data input
       .wbd_res_ack_i     ( s5d_res_data.wbd_ack   ),  // acknowlegement
       .wbd_res_lack_i    ( s5d_res_data.wbd_lack  ),  // Last Burst access
       .wbd_res_err_i     ( s5d_res_data.wbd_err   ),  // error
       .wbd_res_tid_i     ( s5d_res_data.wbd_tid   ),
                                      
       .wbs_cyc_o         ( s5_wb_wr.wbd_cyc       ),  // strobe/request
       .wbs_stb_o         ( s5_wb_wr.wbd_stb       ),  // strobe/request
       .wbs_adr_o         ( s5_wb_wr.wbd_adr[10:0] ),  // address
       .wbs_we_o          ( s5_wb_wr.wbd_we        ),  // write
       .wbs_dat_o         ( s5_wb_wr.wbd_dat       ),  // data output
       .wbs_sel_o         ( s5_wb_wr.wbd_sel       ),  // byte enable
       .wbs_tid_o         ( s5_wb_wr.wbd_tid       ),
       .wbs_bl_o          ( s5_wb_wr.wbd_bl        ),  // Burst Count
       .wbs_bry_o         ( s5_wb_wr.wbd_bry       ),  // Busrt WData Avialble Or Ready To accept Rdata  

       .wbs_sid_i         ( s5_wb_rd.wbd_sid       ),  // Slave ID
       .wbs_dat_i         ( s5_wb_rd.wbd_dat       ),  // data input
       .wbs_ack_i         ( s5_wb_rd.wbd_ack       ),  // acknowlegement
       .wbs_lack_i        ( s5_wb_rd.wbd_lack      ),  // Last Ack
       .wbs_err_i         ( s5_wb_rd.wbd_err       )   // error

    );


endmodule

