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
////  Peripheral Wrapper                                          ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////      Integrate following IP's                                ////
////        1. 6x PWM                                             ////
////        2. 3 X Timer                                          ////
////        4. 4 x ws281x driver                                  ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 19th Nov 2023, Dinesh A                             ////
////          initial version                                     ////
//////////////////////////////////////////////////////////////////////
`include "user_params.svh"

module peri_wrapper1 (
                    `ifdef USE_POWER_PINS
                       input logic             vccd1,// User area 1 1.8V supply
                       input logic             vssd1,// User area 1 digital ground
                    `endif
                        // clock skew adjust
                       input logic [3:0]       cfg_cska_per1,
                       input logic	           wbd_clk_int,
                       output logic	           wbd_clk_per1,
                       // System Signals
                       // Inputs
		               input logic             mclk,
	                   input logic             reset_n              ,  // power-on reset


                       output logic [3:0]      ws_txd               ,// ws281x txd port
                       output logic [2:0]      timer_intr           ,
                       output logic            pulse_1ms            , // 1 Milli Second Pulse for waveform Generator
                       output logic            pulse_1us            , // 1 Micro Second Pulse for waveform Generator

		       // Reg Bus Interface Signal
                       input logic             reg_cs,
                       input logic             reg_wr,
                       input logic [10:0]      reg_addr,
                       input logic [31:0]      reg_wdata,
                       input logic [3:0]       reg_be,

                       // Outputs
                       output logic [31:0]     reg_rdata,
                       output logic            reg_ack

               
   ); 



logic         reset_ssn               ;  // Sync Reset

//----------------------------------------
//  Register Response Path Mux
//  --------------------------------------

logic [31:0]  reg_timer_rdata;
logic         reg_timer_ack;

logic [31:0]  reg_ws_rdata;
logic         reg_ws_ack;


logic         reg_timer_cs;
logic         reg_ws_cs   ;



// skew control
clk_skew_adjust u_skew_pinmux
       (
`ifdef USE_POWER_PINS
               .vccd1      (vccd1                 ),// User area 1 1.8V supply
               .vssd1      (vssd1                 ),// User area 1 digital ground
`endif
	       .clk_in     (wbd_clk_int               ), 
	       .sel        (cfg_cska_per1             ), 
	       .clk_out    (wbd_clk_per1              ) 
       );

reset_sync  u_rst_sync (
	      .scan_mode  (1'b0           ),
          .dclk       (mclk           ), // Destination clock domain
	      .arst_n     (reset_n      ), // active low async reset
          .srst_n     (reset_ssn    )
          );


//-----------------------------------------------------------------------
// Timer Top
//-----------------------------------------------------------------------
timer_top  u_timer(
              // System Signals
              // Inputs
		      .mclk                     (mclk                       ),
              .h_reset_n                (reset_ssn                  ),

		      // Reg Bus Interface Signal
              .reg_cs                   (reg_timer_cs               ),
              .reg_wr                   (reg_wr                     ),
              .reg_addr                 (reg_addr[3:2]              ),
              .reg_wdata                (reg_wdata                  ),
              .reg_be                   (reg_be                     ),

              // Outputs
              .reg_rdata                (reg_timer_rdata            ),
              .reg_ack                  (reg_timer_ack              ),

              .pulse_1us                (pulse_1us                  ), 
              .pulse_1ms                (pulse_1ms                  ), 
              .timer_intr               (timer_intr                 ) 
           );

//-----------------------------------------------------------------------
// 4 Port ws281x driver 
//----------------------------------------------------------------------

ws281x_top  u_ws281x(
		                .mclk           (mclk             ),
                        .h_reset_n      (reset_ssn        ),
                                                          
                        .reg_cs         (reg_ws_cs        ),
                        .reg_wr         (reg_wr           ),
                        .reg_addr       (reg_addr[5:2]    ),
                        .reg_wdata      (reg_wdata        ),
                        .reg_be         (reg_be           ),

                        .reg_rdata      (reg_ws_rdata     ),
                        .reg_ack        (reg_ws_ack       ),

                        .txd            (ws_txd           )

                ); 




//-------------------------------------------------
// Register Block Selection Logic
//-------------------------------------------------
reg [3:0] reg_blk_sel;

always @(posedge mclk or negedge reset_ssn)
begin
   if(reset_ssn == 1'b0) begin
     reg_blk_sel <= 'h0;
   end
   else begin
      if(reg_cs) reg_blk_sel <= reg_addr[10:7];
   end
end

assign reg_rdata = (reg_blk_sel    == `SEL_TIMER) ? reg_timer_rdata  : 
	               (reg_blk_sel    == `SEL_WS)    ? reg_ws_rdata     :  'h0;

assign reg_ack   = (reg_blk_sel    == `SEL_TIMER) ? reg_timer_ack  : 
	               (reg_blk_sel    == `SEL_WS)    ? reg_ws_ack     : 1'b0;

assign reg_timer_cs = (reg_addr[10:7] == `SEL_TIMER)? reg_cs : 1'b0;
assign reg_ws_cs    = (reg_addr[10:7] == `SEL_WS)   ? reg_cs : 1'b0;

endmodule 


