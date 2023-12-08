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

`include "user_reg_map.v"
module wbi_slave_port_s1 
     #(parameter BENB= 1,
       parameter AW  = 32,
       parameter SAW = 32, // Slave Address Width
       parameter BW  = 4,
       parameter BL  = 10,
       parameter DW  = 32,
       parameter CDP = 4, // CMD FIFO DEPTH
       parameter RDP = 2  // RESPONSE FIFO DEPTH

       )
       (
       input   logic               reset_n         ,  // Regular Reset signal
       input   logic               mclk            ,  // System clock

    // Master Command Port
       output  logic               wbp_cmd_wrdy_o  ,  // Ready path Ready to accept the data
       input   logic               wbp_cmd_wval_i  ,
       input   logic [AW-1:0]      wbp_cmd_adr_i   ,  // address
       input   logic               wbp_cmd_we_i    ,  // write
       input   logic [DW-1:0]      wbp_cmd_dat_i   ,  // data output
       input   logic [BW-1:0]      wbp_cmd_sel_i   ,  // byte enable
       input   logic [3:0]         wbp_cmd_tid_i   ,
       input   logic [BL-1:0]      wbp_cmd_bl_i    ,  // Burst Count

    // Master Response Port
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
       input   logic [3:0]         wbd_res_tid_i   ,

    // Slave Port
       input   logic [3:0]         wbs_sid_i      ,  // slave id
       output  logic               wbs_cyc_o      ,  // strobe/request
       output  logic               wbs_stb_o      ,  // strobe/request
       output  logic [SAW-1:0]     wbs_adr_o      ,  // address
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

assign slv_cmd_wval_i   = (get_slave_id(wbp_cmd_wval_i,wbp_cmd_adr_i) == wbs_sid_i);
assign stg_cmd_wval_i  = wbp_cmd_wval_i && !slv_cmd_wval_i;
assign wbp_cmd_wrdy_o  = slv_cmd_wval_i ?  slv_cmd_wrdy_o: stg_cmd_wrdy_o;

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


assign slv_res_rrdy_i = (wbi_grnt == 1'b0) ?  wbp_res_rrdy_i : 1'b0;
assign stg_res_rrdy_i = (wbi_grnt == 1'b1) ?  wbp_res_rrdy_i : 1'b0;
assign wbp_res_rval_o = (wbi_grnt == 1'b0) ?  slv_res_rval_o : stg_res_rval_o ;
assign wbp_res_dat_o  = (wbi_grnt == 1'b0) ?  slv_res_dat_o  : stg_res_dat_o  ; 
assign wbp_res_ack_o  = (wbi_grnt == 1'b0) ?  slv_res_ack_o  : stg_res_ack_o  ; 
assign wbp_res_lack_o = (wbi_grnt == 1'b0) ?  slv_res_lack_o : stg_res_lack_o ; 
assign wbp_res_err_o  = (wbi_grnt == 1'b0) ?  slv_res_err_o  : stg_res_err_o  ; 
assign wbp_res_tid_o  = (wbi_grnt == 1'b0) ?  slv_res_tid_o  : stg_res_tid_o  ; 



// Stagging FF to break write and read timing path
// Assumption, CMD and Response are independent path
wbi_slave_node #(.BENB(BENB),.CDP(CDP), .RDP(RDP), .SAW(SAW)) u_node(
         .clk_i                (mclk                ), 
         .rst_n                (reset_n             ),
         // WishBone Input master I/P
         .wbm_cmd_wrdy_o       (slv_cmd_wrdy_o      ),
         .wbm_cmd_val_i        (slv_cmd_wval_i      ),
         .wbm_cmd_adr_i        (wbp_cmd_adr_i       ),
         .wbm_cmd_sel_i        (wbp_cmd_sel_i       ),
         .wbm_cmd_we_i         (wbp_cmd_we_i        ),
         .wbm_cmd_dat_i        (wbp_cmd_dat_i       ),
         .wbm_cmd_bl_i         (wbp_cmd_bl_i        ),
         .wbm_cmd_tid_i        (wbp_cmd_tid_i       ),

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
         .wbs_tid_o            (wbs_tid_o           )

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
       .wbp_cmd_adr_i         (wbp_cmd_adr_i       ),  // address
       .wbp_cmd_we_i          (wbp_cmd_we_i        ),  // write
       .wbp_cmd_dat_i         (wbp_cmd_dat_i       ),  // data output
       .wbp_cmd_sel_i         (wbp_cmd_sel_i       ),  // byte enable
       .wbp_cmd_tid_i         (wbp_cmd_tid_i       ),
       .wbp_cmd_bl_i          (wbp_cmd_bl_i        ),  // Burst Count

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




//---------------------------------------------------------------------
// Check the Slave Address Matches with incomming command
//---------------------------------------------------------------------
function logic [3:0]  get_slave_id;
input        stb;
input [31:0] mem_addr;
begin
   get_slave_id    = `WBI_SID_NULL;
   if      (stb && ((mem_addr & `USER_ADDR0_MASK_QSPI)    == `USER_ADDR0_QSPI))      get_slave_id    = `WBI_SID_QSPI;
   else if (stb && ((mem_addr & `USER_ADDR1_MASK_QSPI)    == `USER_ADDR1_QSPI))      get_slave_id    = `WBI_SID_QSPI;
   else if (stb && ((mem_addr & `USER_ADDR0_MASK_UART)    == `USER_ADDR0_UART))      get_slave_id    = `WBI_SID_UART;
   else if (stb && ((mem_addr & `USER_ADDR1_MASK_UART)    == `USER_ADDR1_UART))      get_slave_id    = `WBI_SID_UART;
   else if (stb && ((mem_addr & `USER_ADDR0_MASK_I2C)     == `USER_ADDR0_I2C))       get_slave_id    = `WBI_SID_SSPI_I2C;
   else if (stb && ((mem_addr & `USER_ADDR0_MASK_USB)     == `USER_ADDR0_USB))       get_slave_id    = `WBI_SID_USB;
   else if (stb && ((mem_addr & `USER_ADDR0_MASK_SSPI)    == `USER_ADDR0_SSPI))      get_slave_id    = `WBI_SID_SSPI_I2C;
   else if (stb && ((mem_addr & `USER_ADDR0_MASK_PINMUX)  == `USER_ADDR0_PINMUX))    get_slave_id    = `WBI_SID_PINMUX;
   else if (stb && ((mem_addr & `USER_ADDR0_MASK_PERI)    == `USER_ADDR0_PERI))      get_slave_id    = `WBI_SID_PERI0;
   else if (stb && ((mem_addr & `USER_ADDR1_MASK_PERI)    == `USER_ADDR1_PERI))      get_slave_id    = `WBI_SID_PERI1;
   else if (stb && ((mem_addr & `USER_ADDR0_MASK_WBI)     == `USER_ADDR0_WBI))       get_slave_id    = `WBI_SID_WBI;
   else if (stb && ((mem_addr & `USER_ADDR0_MASK_WBHOST)  == `USER_ADDR0_WBHOST))    get_slave_id    = `WBI_SID_WBHOST;
   else if (stb && ((mem_addr & `USER_ADDR1_MASK_PERI)    == `USER_ADDR0_RISCV))     get_slave_id    = `WBI_SID_RISCV;
end
endfunction
endmodule

