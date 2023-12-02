/////////////////////////////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021 , Dinesh Annayya                                                 ////
//                                                                                               ////
// Licensed under the Apache License, Version 2.0 (the "License");                               ////
// you may not use this file except in compliance with the License.                              ////
// You may obtain a copy of the License at                                                       ////
//                                                                                               ////
//      http://www.apache.org/licenses/LICENSE-2.0                                               ////
//                                                                                               ////
// Unless required by applicable law or agreed to in writing, software                           ////
// distributed under the License is distributed on an "AS IS" BASIS,                             ////
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.                      ////
// See the License for the specific language governing permissions and                           ////
// limitations under the License.                                                                ////
// SPDX-License-Identifier: Apache-2.0                                                           ////
// SPDX-FileContributor: Created by Dinesh Annayya <dinesh.annayya@gmail.com>                    ////
//                                                                                               ////
/////////////////////////////////////////////////////////////////////////////////////////////////////
////                                                                                             ////
////  Digital core                                                                               ////
////                                                                                             ////
////  This file is part of the riscduino cores project                                           ////
////                                                                                             ////
////  Description                                                                                ////
////      This is digital core and integrate all the main block                                  ////
////      here.  Following block are integrated here                                             ////
////                                                                                             ////
////  To Do:                                                                                     ////
////    nothing                                                                                  ////
////                                                                                             ////
////  Author(s):                                                                                 ////
////      - Dinesh Annayya, dinesh.annayya@gmail.com                                             ////
////                                                                                             ////
////  Revision :                                                                                 ////
////    0.1 - 18th Nov 2023, Dinesh A                                                            ////
////          Initial integration 
////                                                                                             ////
////                                                                                             ////
/////////////////////////////////////////////////////////////////////////////////////////////////////
////                                                                                             ////
////          Copyright (C) 2000 Authors and OPENCORES.ORG                                       ////
////                                                                                             ////
////          This source file may be used and distributed without                               ////
////          restriction provided that this copyright statement is not                          ////
////          removed from the file and that any derivative work contains                        ////
////          the original copyright notice and the associated disclaimer.                       ////
////                                                                                             ////
////          This source file is free software; you can redistribute it                         ////
////          and/or modify it under the terms of the GNU Lesser General                         ////
////          Public License as published by the Free Software Foundation;                       ////
////          either version 2.1 of the License, or (at your option) any                         ////
////          later version.                                                                     ////
////                                                                                             ////
////          This source is distributed in the hope that it will be                             ////
////          useful, but WITHOUT ANY WARRANTY; without even the implied                         ////
////          warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR                            ////
////          PURPOSE.  See the GNU Lesser General Public License for more                       ////
////          details.                                                                           ////
////                                                                                             ////
////          You should have received a copy of the GNU Lesser General                          ////
////          Public License along with this source; if not, download it                         ////
////          from http://www.opencores.org/lgpl.shtml                                           ////
////                                                                                             ////
/////////////////////////////////////////////////////////////////////////////////////////////////////


`include "user_params.svh"

module user_project_wrapper #(parameter WB_WIDTH = 32) (
`ifdef USE_POWER_PINS
    inout vdd,		// User area 5.0V supply
    inout vss,		// User area ground
`endif
    input   wire                       wb_clk_i        ,  // System clock
    input   wire                       user_clock2     ,  // user Clock
    input   wire                       wb_rst_i        ,  // Regular Reset signal

    input   wire                       wbs_cyc_i       ,  // strobe/request
    input   wire                       wbs_stb_i       ,  // strobe/request
    input   wire [WB_WIDTH-1:0]        wbs_adr_i       ,  // address
    input   wire                       wbs_we_i        ,  // write
    input   wire [WB_WIDTH-1:0]        wbs_dat_i       ,  // data output
    input   wire [3:0]                 wbs_sel_i       ,  // byte enable
    output  wire [WB_WIDTH-1:0]        wbs_dat_o       ,  // data input
    output  wire                       wbs_ack_o       ,  // acknowlegement

 
    // Logic Analyzer Signals
    input  wire [63:0]                la_data_in      ,
    output wire [63:0]                la_data_out     ,
    input  wire [63:0]                la_oenb         ,
 

    // IOs
    input  wire  [37:0]                io_in           ,
    output wire  [37:0]                io_out          ,
    output wire  [37:0]                io_oeb          ,

    output wire  [2:0]                 user_irq             

);

////////////// clock skew ///////////////////
wire     wbd_wh_clk_skew;
wire     wbd_wi_clk_skew;
wire     wbd_usb_clk_skew;
wire     wbd_i2c_clk_skew;
wire     wbd_sspi_clk_skew;


//---------------------------------------------------------------------
// WB HOST Interface
//---------------------------------------------------------------------
wire                           wbhost_mclk                             ;
wire                           wbm_wbhost_cyc_i                        ; // strobe/request
wire                           wbm_wbhost_stb_i                        ; // strobe/request
wire   [WB_WIDTH-1:0]          wbm_wbhost_adr_i                        ; // address
wire                           wbm_wbhost_we_i                         ; // write
wire   [WB_WIDTH-1:0]          wbm_wbhost_dat_i                        ; // data output
wire   [3:0]                   wbm_wbhost_sel_i                        ; // byte enable
wire   [WB_WIDTH-1:0]          wbm_wbhost_dat_o                        ; // data input
wire                           wbm_wbhost_ack_o                        ; // acknowlegement
wire                           wbm_wbhost_err_o                        ; // error

wire                           wbd_mclk                                ;
wire                           cfg_fast_sim                            ;
wire                           cpu_clk                                 ;
wire                           wbd_int_rst_n                           ;
wire                           e_reset_n                               ;  // external reset
wire                           p_reset_n                               ;  // power-on reset
wire                           s_reset_n                               ;  // soft reset
wire                           cfg_strap_pad_ctrl                      ;  // Signal to indicate Strap latching phase
wire [31:0]                    system_strap                            ;
//---------------------------------------------------------------------
//    QSPI Master Wishbone Interface
//---------------------------------------------------------------------
wire                           wbs_qspim_stb_o                         ; // strobe/request
wire   [WB_WIDTH-1:0]          wbs_qspim_adr_o                         ; // address
wire                           wbs_qspim_we_o                          ; // write
wire   [WB_WIDTH-1:0]          wbs_qspim_dat_o                         ; // data output
wire   [3:0]                   wbs_qspim_sel_o                         ; // byte enable
wire   [9:0]                   wbs_qspim_bl_o                          ; // Burst count
wire                           wbs_qspim_bry_o                         ; // Busrt Ready
wire                           wbs_qspim_cyc_o                         ;
wire   [WB_WIDTH-1:0]          wbs_qspim_dat_i                         ; // data input
wire                           wbs_qspim_ack_i                         ; // acknowlegement
wire                           wbs_qspim_lack_i                        ; // Last acknowlegement
wire                           wbs_qspim_err_i                         ; // error
// SFLASH I/F
wire                           sflash_sck                             ;
wire [3:0]                     sflash_ss                              ;
wire [3:0]                     sflash_oen                             ;
wire [3:0]                     sflash_do                              ;
wire [3:0]                     sflash_di                              ;

wire [31:0]                    qspi_debug                             ;
//---------------------------------------------------------------------
//    UART SLAVE WB I/F
//---------------------------------------------------------------------
wire                           uart_mclk                              ;
wire                           wbs_uart_stb_o                         ; // strobe/request
wire   [8:0]                   wbs_uart_adr_o                         ; // address
wire                           wbs_uart_we_o                          ; // write
wire   [31:0]                  wbs_uart_dat_o                         ; // data output
wire   [3:0]                   wbs_uart_sel_o                         ; // byte enable
wire                           wbs_uart_cyc_o                         ;
wire   [31:0]                  wbs_uart_dat_i                         ; // data input
wire                           wbs_uart_ack_i                         ; // acknowlegement
wire                           wbs_uart_err_i                         ;  // error

//---------------------------------------------------------------------
//    UART MASTER WB I/F
//---------------------------------------------------------------------
wire                           wbm_uart_cyc_i                         ;  // strobe/request
wire                           wbm_uart_stb_i                         ;  // strobe/request
wire [31:0]                    wbm_uart_adr_i                         ;  // address
wire                           wbm_uart_we_i                          ;  // write
wire [31:0]                    wbm_uart_dat_i                         ;  // data output
wire [3:0]                     wbm_uart_sel_i                         ;  // byte enable
wire [31:0]                    wbm_uart_dat_o                         ;  // data input
wire                           wbm_uart_ack_o                         ;  // acknowlegement
wire                           wbm_uart_err_o                         ;  // error

//---------------------------------------------------------------------
//    UART IO I/F
//---------------------------------------------------------------------
wire       [2:0]               uart_txd                               ;
wire       [2:0]               uart_rxd                               ;

//---------------------------------------------------------------------
//    USB I/F
//---------------------------------------------------------------------
wire                           usb_mclk                              ;
wire                           wbs_usb_stb_o                         ; // strobe/request
wire   [8:0]                   wbs_usb_adr_o                         ; // address
wire                           wbs_usb_we_o                          ; // write
wire   [31:0]                  wbs_usb_dat_o                         ; // data output
wire   [3:0]                   wbs_usb_sel_o                         ; // byte enable
wire                           wbs_usb_cyc_o                         ;
wire   [31:0]                  wbs_usb_dat_i                         ; // data input
wire                           wbs_usb_ack_i                         ; // acknowlegement
wire                           wbs_usb_err_i                         ;  // error

wire                           usbh_dp_o                             ;
wire                           usbh_dn_o                             ;
wire                           usbh_oen                              ;
wire                           usbh_dp_i                             ;
wire                           usbh_dn_i                             ;
wire                           usbh_intr_o                           ;

wire                           usbd_dp_o                             ;
wire                           usbd_dn_o                             ;
wire                           usbd_oen                              ;
wire                           usbd_dp_i                             ;
wire                           usbd_dn_i                             ;
wire                           usbd_intr_o                           ;
//---------------------------------------------------------------------
//    SSPI MASTER WB I/F
//---------------------------------------------------------------------
wire                           wbm_sspi_cyc_i                         ;  // strobe/request
wire                           wbm_sspi_stb_i                         ;  // strobe/request
wire [31:0]                    wbm_sspi_adr_i                         ;  // address
wire                           wbm_sspi_we_i                          ;  // write
wire [31:0]                    wbm_sspi_dat_i                         ;  // data output
wire [3:0]                     wbm_sspi_sel_i                         ;  // byte enable
wire [31:0]                    wbm_sspi_dat_o                         ;  // data input
wire                           wbm_sspi_ack_o                         ;  // acknowlegement
wire                           wbm_sspi_err_o                         ;  // error

wire                           spim_sck                               ;
wire                 [3:0]     spim_ssn                               ;
wire                           spim_miso                              ;
wire                           spim_mosi                              ;

//---------------------------------------------------------------------
//    SSPI Slave I/F
//---------------------------------------------------------------------
wire                           sspi_mclk                             ;
wire                           wbs_sspi_stb_o                        ; // strobe/request
wire   [8:0]                   wbs_sspi_adr_o                        ; // address
wire                           wbs_sspi_we_o                         ; // write
wire   [31:0]                  wbs_sspi_dat_o                        ; // data output
wire   [3:0]                   wbs_sspi_sel_o                        ; // byte enable
wire                           wbs_sspi_cyc_o                        ;
wire   [31:0]                  wbs_sspi_dat_i                        ; // data input
wire                           wbs_sspi_ack_i                        ; // acknowlegement
wire                           wbs_sspi_err_i                        ;  // error

// SPI SLAVE
wire                           sspis_sck                             ;
wire                           sspis_ssn                             ;
wire                           sspis_so                              ;
wire                           sspis_si                              ;

wire                           sspim_sck                             ;
wire                           sspim_so                              ;
wire                           sspim_si                              ;
wire                    [3:0]  sspim_ssn                             ;
//---------------------------------------------------------------------
//    I2C Slave I/F
//---------------------------------------------------------------------
wire                           wbs_i2c_stb_o                         ; // strobe/request
wire   [8:0]                   wbs_i2c_adr_o                         ; // address
wire                           wbs_i2c_we_o                          ; // write
wire   [31:0]                  wbs_i2c_dat_o                         ; // data output
wire   [3:0]                   wbs_i2c_sel_o                         ; // byte enable
wire                           wbs_i2c_cyc_o                         ;
wire   [31:0]                  wbs_i2c_dat_i                         ; // data input
wire                           wbs_i2c_ack_i                         ; // acknowlegement
wire                           wbs_i2c_err_i                         ;  // error


wire                           i2cm_clk_o                            ;
wire                           i2cm_clk_i                            ;
wire                           i2cm_clk_oen                          ;
wire                           i2cm_data_oen                         ;
wire                           i2cm_data_o                           ;
wire                           i2cm_data_i                           ;
wire                           i2cm_intr_o                           ;

//---------------------------------------------------------------------
//    Pinmux
//---------------------------------------------------------------------
wire                           wbs_pinmux_stb_o                       ; // strobe/request
wire   [10:0]                  wbs_pinmux_adr_o                       ; // address
wire                           wbs_pinmux_we_o                        ; // write
wire   [WB_WIDTH-1:0]          wbs_pinmux_dat_o                       ; // data output
wire   [3:0]                   wbs_pinmux_sel_o                       ; // byte enable
wire                           wbs_pinmux_cyc_o                       ;
wire   [WB_WIDTH-1:0]          wbs_pinmux_dat_i                       ; // data input
wire                           wbs_pinmux_ack_i                       ; // acknowlegement
wire                           wbs_pinmux_err_i                       ; // error


wire                           xtal_clk                               ;
wire                           usb_clk                                ;
wire                           rtc_clk                                ;

wire [31:0]                    pinmux_debug                           ;
wire [31:0]                    strap_sticky                           ;

wire  [3:0]                    cpu_core_rst_n                         ;
wire                           cpu_intf_rst_n                         ;
wire                           qspim_rst_n                            ;
wire [1:0]                     sspi_rst_n                             ;
wire [2:0]                     uart_rst_n                             ;
wire                           i2c_rst_n                              ;
wire [1:0]                     usb_rst_n                              ;
wire [31:0]                    irq_lines                              ;
wire [15:0]                    cfg_riscv_ctrl                         ;
//--------------------------------------------------
// peri1
//--------------------------------------------------
wire                           wbs_peri1_stb_o                       ; // strobe/request
wire   [10:0]                  wbs_peri1_adr_o                       ; // address
wire                           wbs_peri1_we_o                        ; // write
wire   [WB_WIDTH-1:0]          wbs_peri1_dat_o                       ; // data output
wire   [3:0]                   wbs_peri1_sel_o                       ; // byte enable
wire                           wbs_peri1_cyc_o                       ;
wire   [WB_WIDTH-1:0]          wbs_peri1_dat_i                       ; // data input
wire                           wbs_peri1_ack_i                       ; // acknowlegement
wire                           wbs_peri1_err_i                       ; // error

wire [3:0]                     ws_txd                                 ;// ws281x txd port
wire [2:0]                     timer_intr                             ;
wire                           pulse_1ms                              ; // 1 Milli Second Pulse for waveform Generator
wire                           pulse_1us                              ; // 1 Micro Second Pulse for waveform Generator


//---------------------------------------------------------------------
assign io_out[37:0] = {cfg_clk_skew_ctrl1[13:8], cfg_clk_skew_ctrl2[31:0]};
assign io_oeb[35:0] = {wbd_wh_adr_i[31:0],wbd_wh_sel_i[3:0]};

assign la_data_out = qspi_debug[31:0],{pinmux_debug[31:0]};


////////////////////////////////////////////////////////
wire [31:0] cfg_clk_skew_ctrl1;

wire [3:0] cfg_wcska_wi          = cfg_clk_skew_ctrl1[3:0];
wire [3:0] cfg_wcska_wh          = cfg_clk_skew_ctrl1[7:4];
wire [3:0] cfg_wcska_riscv       = cfg_clk_skew_ctrl1[11:8];
wire [3:0] cfg_wcska_qspi        = cfg_clk_skew_ctrl1[15:12];
wire [3:0] cfg_wcska_uart        = cfg_clk_skew_ctrl1[19:16];
wire [3:0] cfg_wcska_pinmux      = cfg_clk_skew_ctrl1[23:20];
wire [3:0] cfg_wcska_qspi_co     = cfg_clk_skew_ctrl1[27:24];
wire [3:0] cfg_wcska_peri        = cfg_clk_skew_ctrl1[31:28];

/////////////////////////////////////////////////////////
// RISCV Clock skew control
/////////////////////////////////////////////////////////
wire [31:0] cfg_clk_skew_ctrl2;

wire [3:0]   cfg_ccska_riscv_intf   = cfg_clk_skew_ctrl2[3:0];
wire [3:0]   cfg_ccska_riscv_icon   = cfg_clk_skew_ctrl2[7:4];
wire [3:0]   cfg_ccska_riscv_core0  = cfg_clk_skew_ctrl2[11:8];
wire [3:0]   cfg_ccska_riscv_core1  = cfg_clk_skew_ctrl2[15:12];
wire [3:0]   cfg_wcska_peri1         = cfg_clk_skew_ctrl2[19:16];
wire [3:0]   cfg_wcska_i2c          = cfg_clk_skew_ctrl2[23:20];
wire [3:0]   cfg_wcska_usb          = cfg_clk_skew_ctrl2[27:24];
wire [3:0]   cfg_wcska_sspi         = cfg_clk_skew_ctrl2[31:28];




//-------------------------------------------
// STRAP Mapping
//--------------------------------------------
wire [1:0]  strap_qspi_flash       = system_strap[`STRAP_QSPI_FLASH];
wire        strap_qspi_sram        = system_strap[`STRAP_QSPI_SRAM];
wire        strap_qspi_pre_sram    = system_strap[`STRAP_QSPI_PRE_SRAM];
wire        strap_qspi_init_bypass = system_strap[`STRAP_QSPI_INIT_BYPASS];

//-----------------------------------------------------
// WB-HOST
//----------------------------------------------------

wb_host u_wb_host(
`ifdef USE_POWER_PINS
          .vccd1                   (vdd                     ),// User area 1 1.8V supply
          .vssd1                   (vss                     ),// User area 1 digital ground
`endif

          .cfg_fast_sim            (cfg_fast_sim            ),
          .user_clock1             (wb_clk_i                ),
          .user_clock2             (user_clock2             ),

          .cpu_clk                 (cpu_clk                 ),
          .wbd_int_rst_n           (wbd_int_rst_n           ),

       // to/from Pinmux
          .xtal_clk                (xtal_clk                ),  
	      .e_reset_n               (e_reset_n               ),  
	      .p_reset_n               (p_reset_n               ),  
          .s_reset_n               (s_reset_n               ),  
          .cfg_strap_pad_ctrl      (cfg_strap_pad_ctrl      ),
	      .system_strap            (system_strap            ),
	      .strap_sticky            (strap_sticky            ),


    // Master Port
          .wbm_rst_i               (wb_rst_i                ),  
          .wbm_clk_i               (wb_clk_i                ),  
          .wbm_cyc_i               (wbs_cyc_i               ),  
          .wbm_stb_i               (wbs_stb_i               ),  
          .wbm_adr_i               (wbs_adr_i               ),  
          .wbm_we_i                (wbs_we_i                ),  
          .wbm_dat_i               (wbs_dat_i               ),  
          .wbm_sel_i               (wbs_sel_i               ),  
          .wbm_dat_o               (wbs_dat_o               ),  
          .wbm_ack_o               (wbs_ack_o               ),  
          .wbm_err_o               (                        ),  

    // Clock Skeq Adjust
          .wbd_clk_int             (wbhost_mclk            ),
          .wbd_clk_wh              (wbd_wh_clk_skew        ),  
          .cfg_cska_wh             (cfg_wcska_wh           ),

    // Slave Port
          .wbs_clk_out             (wbd_mclk               ),


          .wbs_clk_i               (wbd_wh_clk_skew        ), 
 
          .wbs_cyc_o               (wbm_wbhost_cyc_i       ),  
          .wbs_stb_o               (wbm_wbhost_stb_i       ),  
          .wbs_adr_o               (wbm_wbhost_adr_i       ),  
          .wbs_we_o                (wbm_wbhost_we_i        ),  
          .wbs_dat_o               (wbm_wbhost_dat_i       ),  
          .wbs_sel_o               (wbm_wbhost_sel_i       ),  
          .wbs_dat_i               (wbm_wbhost_dat_o       ),  
          .wbs_ack_i               (wbm_wbhost_ack_o       ),  
          .wbs_err_i               (wbm_wbhost_err_o       ),  

          .cfg_clk_skew_ctrl1      (cfg_clk_skew_ctrl1     ),
          .cfg_clk_skew_ctrl2      (cfg_clk_skew_ctrl2     )


    );


//---------------------------------------
// Inter connect
//--------------------------------------- 
wbi_top   u_intercon (
`ifdef USE_POWER_PINS
          .vccd1              (vdd                       ),// User area 1 1.8V supply
          .vssd1              (vss                       ),// User area 1 digital ground
`endif
     // Clock Skew adjust
          .wbd_clk_int        (wbd_mclk                  ),// wb clock without skew 
          .cfg_cska_wi        (cfg_wcska_wi              ), 
          .wbd_clk_wi         (wbd_wi_clk_skew           ),// wb clock with skew

          .mclk_raw           (wbd_mclk                  ), // wb clock without skew
          .clk_i              (wbd_wi_clk_skew           ), // wb clock with skew
          .rst_n              (wbd_int_rst_n             ),

         // Master 0 Interface - wbhost
          .m0_mclk            (wbhost_mclk               )
          .m0_wbd_dat_i       (wbm_wbhost_dat_i          ),
          .m0_wbd_adr_i       (wbm_wbhost_adr_i          ),
          .m0_wbd_sel_i       (wbm_wbhost_sel_i          ),
          .m0_wbd_we_i        (wbm_wbhost_we_i           ),
          .m0_wbd_cyc_i       (wbm_wbhost_cyc_i          ),
          .m0_wbd_stb_i       (wbm_wbhost_stb_i          ),
          .m0_wbd_dat_o       (wbm_wbhost_dat_o          ),
          .m0_wbd_ack_o       (wbm_wbhost_ack_o          ),
          .m0_wbd_err_o       (wbm_wbhost_err_o          ),
         
         
       // Slave 0 Interface - qspi
       // .s0_wbd_err_i       (1'b0                      ), - Moved inside IP
          .s0_mclk            (qspim_mclk                ),
          .s0_idle            (qspim_idle                ),
          .s0_wbd_dat_i       (wbs_qspim_dat_i           ),
          .s0_wbd_ack_i       (wbs_qspim_ack_i           ),
          .s0_wbd_lack_i      (wbs_qspim_lack_i          ),
          .s0_wbd_dat_o       (wbs_qspim_dat_o           ),
          .s0_wbd_adr_o       (wbs_qspim_adr_o           ),
          .s0_wbd_bry_o       (wbs_qspim_bry_o           ),
          .s0_wbd_bl_o        (wbs_qspim_bl_o            ),
          .s0_wbd_sel_o       (wbs_qspim_sel_o           ),
          .s0_wbd_we_o        (wbs_qspim_we_o            ),  
          .s0_wbd_cyc_o       (wbs_qspim_cyc_o           ),
          .s0_wbd_stb_o       (wbs_qspim_stb_o           ),
         
         // Master 1 Interface - uart
          .m1_wbd_dat_i       (wbm_uart_dat_i            ),
          .m1_wbd_adr_i       (wbm_uart_adr_i            ),
          .m1_wbd_sel_i       (wbm_uart_sel_i            ),
          .m1_wbd_we_i        (wbm_uart_we_i             ),
          .m1_wbd_cyc_i       (wbm_uart_cyc_i            ),
          .m1_wbd_stb_i       (wbm_uart_stb_i            ),
          .m1_wbd_dat_o       (wbm_uart_dat_o            ),
          .m1_wbd_ack_o       (wbm_uart_ack_o            ),
          .m1_wbd_err_o       (wbm_uart_err_o            ),

       // Slave 1 Interface - uart
       // .s1_wbd_err_i       (1'b0                      ), - Moved inside IP
          .s1_mclk            (uart_mclk                 ),
          .s1_wbd_dat_i       (wbs_uart_dat_i            ),
          .s1_wbd_ack_i       (wbs_uart_ack_i            ),
          .s1_wbd_dat_o       (wbs_uart_dat_o            ),
          .s1_wbd_adr_o       (wbs_uart_adr_o            ),
          .s1_wbd_sel_o       (wbs_uart_sel_o            ),
          .s1_wbd_we_o        (wbs_uart_we_o             ),  
          .s1_wbd_cyc_o       (wbs_uart_cyc_o            ),
          .s1_wbd_stb_o       (wbs_uart_stb_o            ),

       // Slave 2 Interface - usb
       // .s2_wbd_err_i       (1'b0                      ), - Moved inside IP
          .s2_mclk            (usb_mclk                  ),
          .s2_wbd_dat_i       (wbs_usb_dat_i             ),
          .s2_wbd_ack_i       (wbs_usb_ack_i             ),
          .s2_wbd_dat_o       (wbs_usb_dat_o             ),
          .s2_wbd_adr_o       (wbs_usb_adr_o             ),
          .s2_wbd_sel_o       (wbs_usb_sel_o             ),
          .s2_wbd_we_o        (wbs_usb_we_o              ),  
          .s2_wbd_cyc_o       (wbs_usb_cyc_o             ),
          .s2_wbd_stb_o       (wbs_usb_stb_o             ),
         
         // Master 2 Interface - sspi
          .m2_wbd_dat_i       (wbm_sspi_dat_i            ),
          .m2_wbd_adr_i       (wbm_sspi_adr_i            ),
          .m2_wbd_sel_i       (wbm_sspi_sel_i            ),
          .m2_wbd_we_i        (wbm_sspi_we_i             ),
          .m2_wbd_cyc_i       (wbm_sspi_cyc_i            ),
          .m2_wbd_stb_i       (wbm_sspi_stb_i            ),
          .m2_wbd_dat_o       (wbm_sspi_dat_o            ),
          .m2_wbd_ack_o       (wbm_sspi_ack_o            ),
          .m2_wbd_err_o       (wbm_sspi_err_o            ),

        // Slave 3 Interface - sspi
        //.s2_wbd_err_i       (1'b0                      ), - Moved inside IP
          .s2_mclk            (sspi_mclk                 ),
          .s2_wbd_dat_i       (wbs_sspi_dat_i            ),
          .s2_wbd_ack_i       (wbs_sspi_ack_i            ),
          .s2_wbd_dat_o       (wbs_sspi_dat_o            ),
          .s2_wbd_adr_o       (wbs_sspi_adr_o            ),
          .s2_wbd_sel_o       (wbs_sspi_sel_o            ),
          .s2_wbd_we_o        (wbs_sspi_we_o             ),  
          .s2_wbd_cyc_o       (wbs_sspi_cyc_o            ),
          .s2_wbd_stb_o       (wbs_sspi_stb_o            ),

        // Slave 4 Interface - i2c
        //.s4_wbd_err_i       (1'b0                     ), - Moved inside IP
          .s4_mclk            (i2c_mclk                 ),
          .s4_wbd_dat_i       (wbs_i2c_dat_i            ),
          .s4_wbd_ack_i       (wbs_i2c_ack_i            ),
          .s4_wbd_dat_o       (wbs_i2c_dat_o            ),
          .s4_wbd_adr_o       (wbs_i2c_adr_o            ),
          .s4_wbd_sel_o       (wbs_i2c_sel_o            ),
          .s4_wbd_we_o        (wbs_i2c_we_o             ),  
          .s4_wbd_cyc_o       (wbs_i2c_cyc_o            ),
          .s4_wbd_stb_o       (wbs_i2c_stb_o            ),

        // Slave 5 Interface - pinmux
        //.s5_wbd_err_i       (1'b0                     ), - Moved inside IP
          .s5_mclk            (pinmux_mclk              ),
          .s5_wbd_dat_i       (wbs_pinmux_dat_i         ),
          .s5_wbd_ack_i       (wbs_pinmux_ack_i         ),
          .s5_wbd_dat_o       (wbs_pinmux_dat_o         ),
          .s5_wbd_adr_o       (wbs_pinmux_adr_o         ),
          .s5_wbd_sel_o       (wbs_pinmux_sel_o         ),
          .s5_wbd_we_o        (wbs_pinmux_we_o          ),  
          .s5_wbd_cyc_o       (wbs_pinmux_cyc_o         ),
          .s5_wbd_stb_o       (wbs_pinmux_stb_o         ),

        // Slave 6 Interface - Peri
        //.s6_wbd_err_i       (1'b0                     ), - Moved inside IP
          .s6_mclk            (peri1_mclk               ),
          .s6_wbd_dat_i       (wbs_peri1_dat_i          ),
          .s6_wbd_ack_i       (wbs_peri1_ack_i          ),
          .s6_wbd_dat_o       (wbs_peri1_dat_o          ),
          .s6_wbd_adr_o       (wbs_peri1_adr_o          ),
          .s6_wbd_sel_o       (wbs_peri1_sel_o          ),
          .s6_wbd_we_o        (wbs_peri1_we_o           ),  
          .s6_wbd_cyc_o       (wbs_peri1_cyc_o          ),
          .s6_wbd_stb_o       (wbs_peri1_stb_o          )
	);

//------------------------------------------
// QUAD SPI
//------------------------------------------

qspim_top
#(
`ifndef SYNTHESIS
    .WB_WIDTH  (WB_WIDTH                                    )
`endif
) u_qspi_master
(
`ifdef USE_POWER_PINS
          .vccd1                   (vdd                     ),// User area 1 1.8V supply
          .vssd1                   (vss                     ),// User area 1 digital ground
`endif
          .mclk                    (wbd_clk_spi             ),
          .rst_n                   (qspim_rst_n             ),
          .cfg_fast_sim            (cfg_fast_sim            ),

          .strap_flash             (strap_qspi_flash        ),
          .strap_pre_sram          (strap_qspi_pre_sram     ),
          .strap_sram              (strap_qspi_sram         ),
          .cfg_init_bypass         (strap_qspi_init_bypass  ),

    // Clock Skew Adjust
          .cfg_cska_sp_co          (cfg_wcska_qspi_co       ),
          .cfg_cska_spi            (cfg_wcska_qspi          ),
          .wbd_clk_int             (qspim_mclk              ),
          .wbd_clk_spi             (wbd_clk_spi             ),

          .qspim_idle              (qspim_idle              ),

          .wbd_stb_i               (wbs_qspim_stb_o         ),
          .wbd_adr_i               (wbs_qspim_adr_o         ),
          .wbd_we_i                (wbs_qspim_we_o          ), 
          .wbd_dat_i               (wbs_qspim_dat_o         ),
          .wbd_sel_i               (wbs_qspim_sel_o         ),
          .wbd_bl_i                (wbs_qspim_bl_o          ),
          .wbd_bry_i               (wbs_qspim_bry_o         ),
          .wbd_dat_o               (wbs_qspim_dat_i         ),
          .wbd_ack_o               (wbs_qspim_ack_i         ),
          .wbd_lack_o              (wbs_qspim_lack_i        ),
          .wbd_err_o               (wbs_qspim_err_i         ),

          .spi_debug               (qspi_debug              ),

    // Pad Interface
          .spi_sdi                 (sflash_di               ),
          .spi_clk                 (sflash_sck              ),
          .spi_csn                 (sflash_ss               ),
          .spi_sdo                 (sflash_do               ),
          .spi_oen                 (sflash_oen              )

);

//---------------------------------------------------------
// 3x UART
//---------------------------------------------------------


uart_wrapper   u_uart_wrapper (
`ifdef USE_POWER_PINS
          .vccd1              (vdd                          ),// User area 1 1.8V supply
          .vssd1              (vss                          ),// User area 1 digital ground
`endif
          .wbd_clk_int        (uart_mclk                    ), 
          .cfg_cska_uart      (cfg_wcska_uart               ), 
          .wbd_clk_uart       (wbd_clk_uart_skew            ),

          .uart_rstn          (uart_rst_n                   ), // uart reset
          .app_clk            (wbd_clk_uart_skew            ),

        // Reg Bus Interface Signal
          .reg_cs             (wbs_uart_stb_o               ),
          .reg_wr             (wbs_uart_we_o                ),
          .reg_addr           (wbs_uart_adr_o[8:0]          ),
          .reg_wdata          (wbs_uart_dat_o               ),
          .reg_be             (wbs_uart_sel_o               ),

       // Outputs
          .reg_rdata          (wbs_uart_dat_i               ),
          .reg_ack            (wbs_uart_ack_i               ),

      // Wb Master I/F
          .wbm_uart_cyc_o     (wbm_uart_cyc_i               ),  // strobe/request
          .wbm_uart_stb_o     (wbm_uart_stb_i               ),  // strobe/request
          .wbm_uart_adr_o     (wbm_uart_adr_i               ),  // address
          .wbm_uart_we_o      (wbm_uart_we_i                ),  // write
          .wbm_uart_dat_o     (wbm_uart_dat_i               ),  // data output
          .wbm_uart_sel_o     (wbm_uart_sel_i               ),  // byte enable
          .wbm_uart_dat_i     (wbm_uart_dat_o               ),  // data input
          .wbm_uart_ack_i     (wbm_uart_ack_o               ),  // acknowlegement
          .wbm_uart_err_i     (wbm_uart_err_o               ),  // error


       // Pad interface
          .uart_rxd           (uart_rxd                     ),
          .uart_txd           (uart_txd                     )
     );


//---------------------------------------------------------
// USBH/USBD
//---------------------------------------------------------

usb_wrapper u_usb_wrap (  
`ifdef USE_POWER_PINS
          .vccd1              (vdd                          ),
          .vssd1              (vss                          ),
`endif

          .reset_n            (wbd_int_rst_n                ), // global reset

    // clock skew adjust
          .cfg_cska_usb       (cfg_wcska_usb                ),
          .wbd_clk_int        (usb_mclk                     ),
          .wbd_clk_skew       (wbd_usb_clk_skew             ),

          .usbh_rstn          (usbh_rst_n                   ), // async reset
          .usbd_rstn          (usbd_rst_n                   ), // async reset
          .app_clk            (wbd_usb_clk_skew             ),
          .usb_clk            (usb_clk                      ), // 48Mhz usb clock

   // Reg Bus Interface Signal
          .reg_cs             (wbs_usb_stb_o               ),
          .reg_wr             (wbs_usb_we_o                ),
          .reg_addr           (wbs_usb_adr_o[8:0]          ),
          .reg_wdata          (wbs_usb_dat_o               ),
          .reg_be             (wbs_usb_sel_o               ),

   // Outputs
          .reg_rdata          (wbs_usb_dat_i               ),
          .reg_ack            (wbs_usb_ack_i               ),

   // USB 1.1 HOST I/F
          .usbh_in_dp         (usbh_dp_i                   ),
          .usbh_in_dn         (usbh_dn_i                   ),
                                                
          .usbh_out_dp        (usbh_dp_o                   ),
          .usbh_out_dn        (usbh_dn_o                   ),
          .usbh_out_tx_oen    (usbh_oen                    ),
                                                
          .usbh_intr_o        (usbh_intr_o                 ),

   // USB 1.1 DEVICE I/F
          .usbd_in_dp         (usbd_dp_i                   ),
          .usbd_in_dn         (usbd_dn_i                   ),
                                              
          .usbd_out_dp        (usbd_dp_o                   ),
          .usbd_out_dn        (usbd_dn_o                   ),
          .usbd_out_tx_oen    (usbd_oen                    ),
          .                    
          .usbd_intr_o        (usbd_intr_o                 )


     );

//-----------------------------------------------
// SSPIM/SSPIS
//-----------------------------------------------

sspi_wrapper  u_sspi_wrap
     (  
`ifdef USE_POWER_PINS
          .vccd1              (vdd                          ),// User area 1 1.8V supply
          .vssd1              (vss                          ),// User area 1 digital ground
`endif
          .reset_n            (wbd_int_rst_n                ), // global reset

    // clock skew adjust
          .cfg_cska_usb       (cfg_wcska_sspi               ),
          .wbd_clk_int        (sspi_mclk                    ),
          .wbd_clk_skew       (wbd_sspi_clk_skew            ),

          .sspi_rstn          (sspi_rst_n                   ), 
          .app_clk            (wbd_sspi_clk_skew            ),

   // Reg Bus Interface Signal
          .reg_slv_cs         (wbs_sspi_stb_o               ),
          .reg_slv_wr         (wbs_sspi_we_o                ),
          .reg_slv_addr       (wbs_sspi_adr_o[8:0]          ),
          .reg_slv_wdata      (wbs_sspi_dat_o               ),
          .reg_slv_be         (wbs_sspi_sel_o               ),

   // Outputs
          .reg_slv_rdata      (wbs_sspi_dat_i               ),
          .reg_slv_ack        (wbs_sspi_ack_i               ),


   // SPIM I/F
          .sspim_sck          (sspim_sck                    ), 
          .sspim_so           (sspim_so                     ),  
          .sspim_si           (sspim_si                     ),  
          .sspim_ssn          (sspim_ssn                    ), 


   // Wb Master I/F
          .wbm_sspis_cyc_o    (wbm_sspis_cyc_i              ),
          .wbm_sspis_stb_o    (wbm_sspis_stb_i              ),
          .wbm_sspis_adr_o    (wbm_sspis_adr_i              ),
          .wbm_sspis_we_o     (wbm_sspis_we_i               ),
          .wbm_sspis_dat_o    (wbm_sspis_dat_i              ),
          .wbm_sspis_sel_o    (wbm_sspis_sel_i              ),
          .wbm_sspis_dat_i    (wbm_sspis_dat_o              ),
          .wbm_sspis_ack_i    (wbm_sspis_ack_o              ),
          .wbm_sspis_err_i    (wbm_sspis_err_o              ),

          .sclk               (sspis_sck                    ),
          .ssn                (sspis_ssn                    ),
          .sdin               (sspis_si                     ),
          .sdout              (sspis_so                     ),
          .sdout_oen          (                             )

     );

i2c_wrapper  u_i2c_wrap (  
`ifdef USE_POWER_PINS
          .vccd1              (vdd                        ),// User area 1 1.8V supply
          .vssd1              (vss                        ),// User area 1 digital ground
`endif
          .reset_n            (wbd_int_rst_n              ), // global reset

    // clock skew adjust
          .cfg_cska_i2c       (cfg_wcska_i2c              ),
          .wbd_clk_int        (i2c_mclk                   ),
          .wbd_clk_skew       (wbd_i2c_clk_skew           ),

          .i2c_rstn           (i2c_rst_n                  ), // async reset
          .app_clk            (wbd_i2c_clk_skew           ),

   // Reg Bus Interface Signal
          .reg_slv_cs         (wbs_i2c_stb_o               ),
          .reg_slv_wr         (wbs_i2c_we_o                ),
          .reg_slv_addr       (wbs_i2c_adr_o[8:0]          ),
          .reg_slv_wdata      (wbs_i2c_dat_o               ),
          .reg_slv_be         (wbs_i2c_sel_o               ),

   // Outputs
          .reg_slv_rdata      (wbs_i2c_dat_i               ),
          .reg_slv_ack        (wbs_i2c_ack_i               ),


   /////////////////////////////////////////////////////////
   // i2c interface
   ///////////////////////////////////////////////////////
          .scl_pad_i          (i2cm_clk_i                   ),
          .scl_pad_o          (i2cm_clk_o                   ),
          .scl_pad_oen_o      (i2cm_clk_oen                 ),

          .sda_pad_i          (i2cm_data_i                  ),
          .sda_pad_o          (i2cm_data_o                  ),
          .sda_padoen_o       (i2cm_data_oen                ),
     
          .i2cm_intr_o        (i2cm_intr_o                  )



     );


pinmux_top u_pinmux(
      `ifdef USE_POWER_PINS
          .vccd1              (vdd                        ),// User area 1 1.8V supply
          .vssd1              (vss                        ),// User area 1 digital ground
      `endif
        // clock skew adjust
          .cfg_cska_pinmux    (cfg_wcska_pinmux             ),
          .wbd_clk_int        (pinmux_mclk                  ),
          .wbd_clk_pinmux     (wbd_clk_pinmux               ),

          // System Signals
          // Inputs
          .mclk               (wbd_clk_pinmux_skew          ),
          .e_reset_n          (e_reset_n                    ),
          .p_reset_n          (p_reset_n                    ),
          .s_reset_n          (wbd_int_rst_n                ),

          // to/from Global Reset FSM
          .cfg_strap_pad_ctrl (cfg_strap_pad_ctrl           ),
          .system_strap       (system_strap                 ),
          .strap_sticky       (strap_sticky                 ),

          .user_clock1        (wb_clk_i                     ),
          .user_clock2        (user_clock2                  ),
          .xtal_clk           (xtal_clk                     ),
          .cpu_clk            (cpu_clk                      ),

          .rtc_clk            (rtc_clk                      ),
          .usb_clk            (usb_clk                      ),

	// Reset Control
          .cpu_core_rst_n     (cpu_core_rst_n               ),
          .cpu_intf_rst_n     (cpu_intf_rst_n               ),
          .qspim_rst_n        (qspim_rst_n                  ),
          .sspi_rst_n         (sspi_rst_n                   ),
          .uart_rst_n         (uart_rst_n                   ),
          .i2cm_rst_n         (i2c_rst_n                    ),
          .usbh_rst_n         (usbh_rst_n                   ),
          .usbd_rst_n         (usbd_rst_n                   ),

          .cfg_riscv_ctrl     (cfg_riscv_ctrl               ),

        // Reg Bus Interface Signal
          .reg_cs             (wbd_pinmux_stb_o             ),
          .reg_wr             (wbd_pinmux_we_o              ),
          .reg_addr           (wbd_pinmux_adr_o             ),
          .reg_wdata          (wbd_pinmux_dat_o             ),
          .reg_be             (wbd_pinmux_sel_o             ),

       // Outputs
          .reg_rdata          (wbd_pinmux_dat_i             ),
          .reg_ack            (wbd_pinmux_ack_i             ),

		   // Risc configuration
          .irq_lines          (irq_lines                    ),
          .soft_irq           (soft_irq                     ),
          .user_irq           (user_irq                     ),
          .usbh_intr          (usbh_intr_o                  ),
          .usbd_intr          (usbd_intr_o                  ),
          .i2cm_intr          (i2cm_intr_o                  ),

       // Digital IO
          .digital_io_out     (io_out                       ),
          .digital_io_oen     (io_oeb                       ),
          .digital_io_in      (io_in                        ),

       // SFLASH I/F
          .sflash_sck         (sflash_sck                   ),
          .sflash_ss          (sflash_ss                    ),
          .sflash_oen         (sflash_oen                   ),
          .sflash_do          (sflash_do                    ),
          .sflash_di          (sflash_di                    ),

       // USB Host I/F
          .usbh_dp_o          (usbh_dp_o                   ),
          .usbh_dn_o          (usbh_dn_o                   ),
          .usbh_oen           (usbh_oen                    ),
          .usbh_dp_i          (usbh_dp_i                   ),
          .usbh_dn_i          (usbh_dn_i                   ),

       // USB Device I/F
          .usbd_dp_o          (usbd_dp_o                   ),
          .usbd_dn_o          (usbd_dn_o                   ),
          .usbd_oen           (usbd_oen                    ),
          .usbd_dp_i          (usbd_dp_i                   ),
          .usbd_dn_i          (usbd_dn_i                   ),

       // UART I/F
          .uart_txd           (uart_txd[1:0]                ),
          .uart_rxd           (uart_rxd [1:0]               ),
      // UART MASTER I/F
          .uartm_rxd          (uart_rxd[2]                  ),
          .uartm_txd          (uart_txd[2]                  ),

       // I2CM I/F
          .i2cm_clk_o         (i2cm_clk_o                   ),
          .i2cm_clk_i         (i2cm_clk_i                   ),
          .i2cm_clk_oen       (i2cm_clk_oen                 ),
          .i2cm_data_oen      (i2cm_data_oen                ),
          .i2cm_data_o        (i2cm_data_o                  ),
          .i2cm_data_i        (i2cm_data_i                  ),

       // SPI MASTER
          .spim_sck           (sspim_sck                    ),
          .spim_ssn           (sspim_ssn                    ),
          .spim_miso          (sspim_so                     ),
          .spim_mosi          (sspim_si                     ),
		       
       // SPI SLAVE
          .spis_sck           (sspis_sck                    ),
          .spis_ssn           (sspis_ssn                    ),
          .spis_miso          (sspis_so                     ),
          .spis_mosi          (sspis_si                     ),


          .pinmux_debug       (pinmux_debug                 ),


          //-------------------------------------
          // WS281x TXD
          //--------------------------------------
          .ws_txd             (ws_txd                     ),
          //-------------------------------------
          // Timer
          //--------------------------------------
          .pulse_1us          (pulse_1us                  ),
          .timer_intr         (timer_intr                 )




               
   ); 

peri_wrapper1 u_per_wrap1(
       `ifdef USE_POWER_PINS
          .vccd1              (vdd                        ),// User area 1 1.8V supply
          .vssd1              (vss                        ),// User area 1 digital ground
       `endif

        // clock skew adjust
          .cfg_cska_peri      (cfg_wcska_peri1             ),
          .wbd_clk_int        (peri1_mclk                  ),
          .wbd_clk_skew       (wbd_clk_peri1              ),

        // System Signals
        // Inputs
          .mclk               (wbd_clk_peri1               ),
          .reset_n            (wbd_int_rst_n              ), // global reset


          .ws_txd             (ws_txd                     ),
          .timer_intr         (timer_intr                 ),
          .pulse_1ms          (pulse_1ms                  ),
          .pulse_1us          (pulse_1us                  ),

        // Reg Bus Interface Signal
          .reg_cs             (wbs_peri1_stb_o             ),
          .reg_wr             (wbs_peri1_we_o              ),
          .reg_addr           (wbs_peri1_adr_o             ),
          .reg_wdata          (wbs_peri1_dat_o             ),
          .reg_be             (wbs_peri1_sel_o             ),

       // Outputs
          .reg_rdata          (wbs_peri1_dat_i             ),
          .reg_ack            (wbs_peri1_ack_i             ),
               
   ); 




endmodule : user_project_wrapper
