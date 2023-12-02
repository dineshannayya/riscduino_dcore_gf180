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
////  UARTMS  Top Module                                         ////
////                                                              ////
////  Description                                                 ////
////    1. uart_core                                              ////
////    2. uart_msg_handler                                       ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 12th Sep 2022, Dinesh A                             ////
////          baud config auto detect for unknow system clock case////
////          implemented specific to unknown caravel system clk  ////
////    0.2 - 31 July 2023, Dinesh A                              ////
////          Seperated Stop bit for tx and rx                    ////
////          recomended setting rx = 0, tx = 1                   ////
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

module uartms_top (  
        input wire                  arst_n          , //  sync reset
        input wire                  app_clk         , //  sys clock    

        // Reg Bus Interface Signal
        input logic                 reg_cs,
        input logic                 reg_wr,
        input logic [3:0]           reg_addr,
        input logic [7:0]           reg_wdata,
        input logic                 reg_be,

        // Outputs
        output logic [7:0]          reg_rdata,
        output logic                reg_ack,


    // Master Port
       output   wire                wbm_cyc_o        ,  // strobe/request
       output   wire                wbm_stb_o        ,  // strobe/request
       output   wire [31:0]         wbm_adr_o        ,  // address
       output   wire                wbm_we_o         ,  // write
       output   wire [31:0]         wbm_dat_o        ,  // data output
       output   wire [3:0]          wbm_sel_o        ,  // byte enable
       input    wire [31:0]         wbm_dat_i        ,  // data input
       input    wire                wbm_ack_i        ,  // acknowlegement
       input    wire                wbm_err_i        ,  // error

       // Line Interface
       input    wire              rxd               , // uart rxd
       output   wire              txd                 // uart txd

     );




parameter W  = 8'd8;
parameter DP = 8'd16;


//-------------------------------------
//---------------------------------------
// Control Unit interface
// --------------------------------------

wire  [31:0]       line_reg_addr        ; // Register Address
wire  [31:0]       line_reg_wdata       ; // Register Wdata
wire               line_reg_req         ; // Register Request
wire               line_reg_wr          ; // 1 -> write; 0 -> read
wire   [3:0]       line_reg_be          ; // Byte Enable
wire               line_reg_ack         ; // Register Ack
wire   [31:0]      line_reg_rdata       ;
//--------------------------------------
// TXD Path - UART core
// -------------------------------------
wire              line_tx_data_avail    ; // Indicate valid TXD Data 
wire [7:0]        line_tx_data          ; // TXD Data to be transmited
wire              line_tx_rd            ; // Indicate TXD Data Been Read


//--------------------------------------
// RXD Path - UART core
// -------------------------------------
wire              line_rx_ready         ; // Indicate Ready to accept the Read Data
wire [7:0]        line_rx_data          ; // RXD Data 
wire              line_rx_wr             ; // Valid RXD Data

//--------------------------------------
// TXD Path - Message Handler
// -------------------------------------
wire              line_tx_data_avail_msg    ; // Indicate valid TXD Data 
wire [7:0]        line_tx_data_msg          ; // TXD Data to be transmited
wire              line_tx_rd_msg            ; // Indicate TXD Data Been Read


//--------------------------------------
// RXD Path - Message Handler
// -------------------------------------
wire              line_rx_ready_msg         ; // Indicate Ready to accept the Read Data
wire [7:0]        line_rx_data_msg          ; // RXD Data 
wire              line_rx_wr_msg            ; // Valid RXD Data


wire              line_reset_n         ;
wire              app_reset_n          ;

//--------------------------------------
// Auto Baud Detection Logic
// -------------------------------------

wire [11:0]       auto_baud_16x        ;
wire              auto_tx_enb          ;
wire              auto_rx_enb          ;

//--------------------------------------------
// configuration control
//--------------------------------------------
wire             cfg_auto_det          ; // Auto Baud Config detect mode
wire             cfg_tx_enable         ; // Enable Transmit Path
wire             cfg_rx_enable         ; // Enable Received Path
wire             cfg_tx_stop_bit       ; // Tx Stop Bit; 0 -> 1 Start , 1 -> 2 Stop Bits
wire             cfg_rx_stop_bit       ; // Rx Stop Bit; 0 -> 1 Start , 1 -> 2 Stop Bits
wire [1:0]       cfg_pri_mod           ; // priority mode, 0 -> nop, 1 -> Even, 2 -> Odd
wire [11:0]	     cfg_baud_16x          ; // 16x Baud clock generation


wire             cfg_tx_enable_m       ; // Enable Transmit Path - Modified
wire             cfg_rx_enable_m       ; // Enable Received Path - Modified
wire [11:0]	     cfg_baud_16x_m        ; // 16x Baud clock generation - Modified

//---------------------------------------
// Status information
//---------------------------------------
wire        frm_error            ; // framing error
wire       	par_error            ; // par error
wire        frm_error_ss         ; // framing error, double sync app clk
wire       	par_error_ss         ; // par error, double sync app clk
wire       	rx_fifo_full_err_ss  ; // par error, double sync app clk
wire        baud_clk_16x         ; // 16x Baud clock
wire        cfg_auto_det_ss      ; // Auto Baud Config detect mode


//---------------------------------------
// Status information
//---------------------------------------

//-------------------------------------
// TX FIFO - Line Clock Domanin
//------------------------------------
wire [W-1: 0]   line_txfifo_rdata;
wire            line_txfifo_ren;
wire            line_txfifo_empty;


//-------------------------------------
// RX FIFO - Line Clock Domanin
//------------------------------------
wire [W-1: 0]   line_rxfifo_wdata;
wire            line_rxfifo_wen;
wire            line_rxfifo_full;


//-------------------------------------
// TX FIFO - Application Clock Domanin
//------------------------------------
wire [W-1: 0]   app_txfifo_wdata;
wire            app_txfifo_full;
wire [4:0]      app_txfifo_fspace;
wire            app_txfifo_wen;


//-------------------------------------
// RX FIFO - Application Clock Domanin
//------------------------------------
wire [W-1: 0]   app_rxfifo_rdata;
wire            app_rxfifo_empty;
wire            app_rxfifo_ren;
wire [4:0]      app_rxfifo_taval;



assign cfg_tx_enable_m = (cfg_auto_det) ?  auto_tx_enb: cfg_tx_enable;
assign cfg_rx_enable_m = (cfg_auto_det) ?  auto_rx_enb: cfg_rx_enable;
assign cfg_baud_16x_m  = (cfg_auto_det) ?  auto_baud_16x: cfg_baud_16x;

// towards uart core
assign      line_tx_data_avail   = (cfg_auto_det_ss) ? line_tx_data_avail_msg : !line_txfifo_empty;
assign      line_tx_data         = (cfg_auto_det_ss) ? line_tx_data_msg  : line_txfifo_rdata;
assign      line_rx_ready        = (cfg_auto_det_ss) ? line_rx_ready_msg : !line_rxfifo_full;


// towards message handler
assign      line_tx_rd_msg       = (cfg_auto_det_ss) ? line_tx_rd        : 1'b0;
assign      line_rx_wr_msg       = (cfg_auto_det_ss) ? line_rx_wr        : 1'b0;
assign      line_rx_data_msg     = line_rx_data;

// towards line side RxFIO/TXFIFO

assign      line_rxfifo_wen      = (cfg_auto_det) ? 1'b0             : line_rx_wr;
assign      line_rxfifo_wdata    = line_rx_data;
assign      line_txfifo_ren      = (cfg_auto_det) ? 1'b0             : line_tx_rd;




assign wbm_cyc_o  = wbm_stb_o;

reset_sync  u_arst_sync (
	      .scan_mode        (1'b0         ),
          .dclk             (app_clk      ), // Destination clock domain
	      .arst_n           (arst_n       ), // active low async reset
          .srst_n           (app_reset_n  )
          );




//---------------------------------------------
// Application Clock Domain
//---------------------------------------------



uartms_auto_det u_aut_det (
         .mclk                (app_clk             ),
         .reset_n             (app_reset_n         ),
         .cfg_auto_det        (cfg_auto_det        ),
         .rxd                 (rxd                 ),

         .auto_baud_16x       (auto_baud_16x       ),
         .auto_tx_enb         (auto_tx_enb         ),
         .auto_rx_enb         (auto_rx_enb         )

        );


uartms_core u_core (  
          .arst_n             (app_reset_n         ),
          .app_clk            (app_clk             ),

	// configuration control
          .cfg_tx_enable      (cfg_tx_enable_m     ), 
          .cfg_rx_enable      (cfg_rx_enable_m     ), 
          .cfg_tx_stop_bit    (cfg_tx_stop_bit     ), 
          .cfg_rx_stop_bit    (cfg_rx_stop_bit     ), 
          .cfg_pri_mod        (cfg_pri_mod         ), 
	      .cfg_baud_16x       (cfg_baud_16x_m      ),

    // TXD Information w.r.t baud 16x clk
          .tx_data_avail_i    (line_tx_data_avail  ),
          .tx_rd_o            (line_tx_rd          ),
          .tx_data_i          (line_tx_data        ),
         

    // RXD Information w.r.t baud 16x clk
          .rx_ready_i         (line_rx_ready       ),
          .rx_wr_o            (line_rx_wr          ),
          .rx_data_o          (line_rx_data        ),

       // Status information
          .frm_error          (frm_error           ),
	      .par_error          (par_error           ),

	      .baud_clk_16x       (baud_clk_16x        ),
	      .line_reset_n       (line_reset_n        ),

       // Line Interface
          .rxd                (rxd                 ),
          .txd                (txd                 ) 

     );

//-----------------------------------------
// Uart configuration
//----------------------------------------
uartms_cfg u_cfg (

             . mclk                (app_clk),
             . reset_n             (app_reset_n),

        // Reg Bus Interface Signal
             . reg_cs              (reg_cs),
             . reg_wr              (reg_wr),
             . reg_addr            (reg_addr),
             . reg_wdata           (reg_wdata),
             . reg_be              (reg_be),

            // Outputs
            . reg_rdata           (reg_rdata),
            . reg_ack             (reg_ack),


       // configuration
             .cfg_auto_det        (cfg_auto_det)    , 
            . cfg_tx_enable       (cfg_tx_enable),
            . cfg_rx_enable       (cfg_rx_enable),
            . cfg_tx_stop_bit     (cfg_tx_stop_bit),
            . cfg_rx_stop_bit     (cfg_rx_stop_bit),
            . cfg_pri_mod         (cfg_pri_mod),

            . cfg_baud_16x        (cfg_baud_16x),  

            . tx_fifo_full        (app_txfifo_full),
             .tx_fifo_fspace      (app_txfifo_fspace ),
            . tx_fifo_wr_en       (app_txfifo_wen),
            . tx_fifo_data        (app_txfifo_wdata),

            . rx_fifo_empty       (app_rxfifo_empty),
             .rx_fifo_dval        (app_rxfifo_taval),
            . rx_fifo_rd_en       (app_rxfifo_ren),
            . rx_fifo_data        (app_rxfifo_rdata) ,

            . frm_error_o         (frm_error_ss),
            . par_error_o         (par_error_ss),
            . rx_fifo_full_err_o  (rx_fifo_full_err_ss)

        );

//-----------------------------------------------
// Baud 16x clock domain
//-----------------------------------------------


//----------------------------------------
// Uart Message Handler
//----------------------------------------

uartms_msg_handler u_msg (  
          .reset_n            (line_reset_n            ),
          .sys_clk            (baud_clk_16x            ),
          .cfg_uart_enb       (cfg_auto_det_ss         ),


    // UART-TX Information
          .tx_data_avail_o    (line_tx_data_avail_msg  ),
          .tx_rd_i            (line_tx_rd_msg          ),
          .tx_data_o          (line_tx_data_msg        ),
         

    // UART-RX Information
          .rx_ready_o         (line_rx_ready_msg       ),
          .rx_wr_i            (line_rx_wr_msg          ),
          .rx_data_i          (line_rx_data_msg        ),

      // Towards Control Unit
          .reg_addr          (line_reg_addr           ),
          .reg_wr            (line_reg_wr             ),
          .reg_be            (line_reg_be             ),
          .reg_wdata         (line_reg_wdata          ),
          .reg_req           (line_reg_req            ),
          .reg_ack           (line_reg_ack            ),
	      .reg_rdata         (line_reg_rdata          ) 

     );


//---------------------------------------------
// baud 16x and app clock cross over logic
//---------------------------------------------


// UART-RX => APP FIFO
async_fifo_th #(W,DP,1,1) u_rxfifo (                  
          .wr_clk                  (baud_clk_16x           ),
          .wr_reset_n              (line_reset_n           ),
          .wr_en                   (line_rxfifo_wen        ),
          .wr_data                 (line_rxfifo_wdata      ),
          .full                    (line_rxfifo_full       ), // sync'ed to wr_clk
          .wr_total_free_space     (                       ),

          .rd_clk                  (app_clk                ),
          .rd_reset_n              (app_reset_n            ),
          .rd_en                   (app_rxfifo_ren         ),
          .empty                   (app_rxfifo_empty       ),  // sync'ed to rd_clk
          .rd_total_aval           (app_rxfifo_taval       ),
          .rd_data                 (app_rxfifo_rdata       )
                );

// APP => UART-TX FIFO
async_fifo_th #(W,DP,1,1) u_txfifo  (
               .wr_clk             (app_clk                   ),
               .wr_reset_n         (app_reset_n               ),
               .wr_en              (app_txfifo_wen            ),
               .wr_data            (app_txfifo_wdata          ),
               .full               (app_txfifo_full           ), // sync'ed to wr_clk
               .wr_total_free_space(app_txfifo_fspace         ),

               .rd_clk             (baud_clk_16x              ),
               .rd_reset_n         (line_reset_n              ),
               .rd_en              (line_txfifo_ren           ),
               .empty              (line_txfifo_empty         ),  // sync'ed to rd_clk
               .rd_total_aval      (                          ),
               .rd_data            (line_txfifo_rdata         )
                   );


// Async App clock to Uart clock handling

async_reg_bus #(.AW(32), .DW(32),.BEW(4))
          u_async_reg_bus (
    // Initiator declartion
          .in_clk                    (baud_clk_16x),
          .in_reset_n                (line_reset_n),
       // Reg Bus Master
          // outputs
          .in_reg_rdata               (line_reg_rdata),
          .in_reg_ack                 (line_reg_ack),
          .in_reg_timeout             (),

          // Inputs
          .in_reg_cs                  (line_reg_req),
          .in_reg_addr                (line_reg_addr),
          .in_reg_wdata               (line_reg_wdata),
          .in_reg_wr                  (line_reg_wr),
          .in_reg_be                  (line_reg_be), 

    // Target Declaration
          .out_clk                    (app_clk),
          .out_reset_n                (app_reset_n),
      // Reg Bus Slave
          // output
          .out_reg_cs                 (wbm_stb_o),
          .out_reg_addr               (wbm_adr_o),
          .out_reg_wdata              (wbm_dat_o),
          .out_reg_wr                 (wbm_we_o),
          .out_reg_be                 (wbm_sel_o),

          // Inputs
          .out_reg_rdata              (wbm_dat_i),
          .out_reg_ack                (wbm_ack_i)
   );


double_sync_low   u_frm_err (
               .in_data           ( frm_error        ),
               .out_clk           ( app_clk          ),
               .out_rst_n         ( app_reset_n      ),
               .out_data          ( frm_error_ss      ) 
          );

double_sync_low   u_par_err (
               .in_data           ( par_error            ),
               .out_clk           ( app_clk              ),
               .out_rst_n         ( app_reset_n          ),
               .out_data          ( par_error_ss         ) 
          );

double_sync_low   u_rxfifo_err (
               .in_data           ( line_rxfifo_full     ),
               .out_clk           ( app_clk              ),
               .out_rst_n         ( app_reset_n          ),
               .out_data          ( rx_fifo_full_err_ss  ) 
          );

double_sync_low   u_auto_enb (
               .in_data           ( cfg_auto_det         ),
               .out_clk           ( line_reset_n         ),
               .out_rst_n         ( app_reset_n          ),
               .out_data          ( cfg_auto_det_ss      ) 
          );

endmodule
