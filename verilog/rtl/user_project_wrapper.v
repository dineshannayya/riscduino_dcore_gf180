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
////    0.1 - 16th Feb 2021, Dinesh A                                                            ////
////          Initial integration with Risc-V core +                                             ////
////          Wishbone Cross Bar + SPI  Master                                                   ////
////    0.2 - 17th June 2021, Dinesh A                                                           ////
////        1. In risc core, wishbone and core domain is                                         ////
////           created                                                                           ////
////        2. cpu and rtc clock are generated in glbl reg block                                 ////
////        3. in wishbone interconnect:- Stagging flop are added                                ////
////           at interface to break wishbone timing path                                        ////
////        4. buswidth warning are fixed inside spi_master                                      ////
////        modified rtl files are                                                               ////
////           verilog/rtl/digital_core/src/digital_core.sv                                      ////
////           verilog/rtl/digital_core/src/glbl_cfg.sv                                          ////
////           verilog/rtl/lib/wb_stagging.sv                                                    ////
////           verilog/rtl/syntacore/scr1/src/top/scr1_dmem_wb.sv                                ////
////           verilog/rtl/syntacore/scr1/src/top/scr1_imem_wb.sv                                ////
////           verilog/rtl/syntacore/scr1/src/top/scr1_top_wb.sv                                 ////
////           verilog/rtl/user_project_wrapper.v                                                ////
////           verilog/rtl/wb_interconnect/src/wb_interconnect.sv                                ////
////           verilog/rtl/spi_master/src/spim_clkgen.sv                                         ////
////           verilog/rtl/spi_master/src/spim_ctrl.sv                                           ////
////    0.3 - 20th June 2021, Dinesh A                                                           ////
////           1. uart core is integrated                                                        ////
////           2. 3rd Slave ported added to wishbone interconnect                                ////
////    0.4 - 25th June 2021, Dinesh A                                                           ////
////          Moved the pad logic inside sdram,spi,uart block to                                 ////
////          avoid logic at digital core level                                                  ////
////    0.5 - 25th June 2021, Dinesh A                                                           ////
////          Since carvel gives only 16MB address space for user                                ////
////          space, we have implemented indirect address select                                 ////
////          with 8 bit bank select given inside wb_host                                        ////
////          core Address = {Bank_Sel[7:0], Wb_Address[23:0]                                    ////
////          caravel user address space is                                                      ////
////          0x3000_0000 to 0x30FF_FFFF                                                         ////
////    0.6 - 27th June 2021, Dinesh A                                                           ////
////          Digital core level tie are moved inside IP to avoid                                ////
////          power hook up at core level                                                        ////
////          u_risc_top - test_mode & test_rst_n                                                ////
////          u_intercon - s*_wbd_err_i                                                          ////
////          unused wb_cti_i is removed from u_sdram_ctrl                                       ////
////    0.7 - 28th June 2021, Dinesh A                                                           ////
////          wb_interconnect master port are interchanged for                                   ////
////          better physical placement.                                                         ////
////          m0 - External HOST                                                                 ////
////          m1 - RISC IMEM                                                                     ////
////          m2 - RISC DMEM                                                                     ////
////    0.8 - 6th July 2021, Dinesh A                                                            ////
////          For Better SDRAM Interface timing we have taping                                   ////
////          sdram_clock goint to io_out[29] directly from                                      ////
////          global register block, this help in better SDRAM                                   ////
////          interface timing control                                                           ////
////    0.9 - 7th July 2021, Dinesh A                                                            ////
////          Removed 2 Unused port connection io_in[31:30] to                                   ////
////          spi_master to avoid lvs issue                                                      ////
////    1.0 - 28th July 2021, Dinesh A                                                           ////
////          i2cm integrated part of uart_i2cm module,                                          ////
////          due to number of IO pin limitation,                                                ////
////          Only UART OR I2C selected based on config mode                                     ////
////    1.1 - 1st Aug 2021, Dinesh A                                                             ////
////          usb1.1 host integrated part of uart_i2cm_usb module,                               ////
////          due to number of IO pin limitation,                                                ////
////          Only UART/I2C/USB selected based on config mode                                    ////
////    1.2 - 29th Sept 2021, Dinesh.A                                                           ////
////          1. copied the repo from yifive and renames as                                      ////
////             riscdunino                                                                      ////
////          2. Removed the SDRAM controlled                                                    ////
////          3. Added PinMux                                                                    ////
////          4. Added SAR ADC for 6 channel                                                     ////
////    1.3 - 30th Sept 2021, Dinesh.A                                                           ////
////          2KB SRAM Interface added to RISC Core                                              ////
////    1.4 - 13th Oct 2021, Dinesh A                                                            ////
////          Basic verification and Synthesis cleanup                                           ////
////    1.5 - 6th Nov 2021, Dinesh A                                                             ////
////          Clock Skew block moved inside respective block due                                 ////
////          to top-level power hook-up challenges for small IP                                 ////
////    1.6   Nov 14, 2021, Dinesh A                                                             ////
////          Major bug, clock divider inside the wb_host reset                                  ////
////          connectivity open is fixed                                                         ////
////    1.7   Nov 15, 2021, Dinesh A                                                             ////
////           Bug fix in clk_ctrl High/Low counter width                                        ////
////           Removed sram_clock                                                                ////
////    1.8  Nov 23, 2021, Dinesh A                                                              ////
////          Three Chip Specific Signature added at PinMux Reg                                  ////
////          reg_22,reg_23,reg_24                                                               ////
////    1.9  Dec 11, 2021, Dinesh A                                                              ////
////         2 x 2K SRAM added into Wishbone Interface                                           ////
////         Temporary ADC block removed                                                         ////
////    2.0  Dec 14, 2021, Dinesh A                                                              ////
////         Added two more 2K SRAM added into Wishbone Interface                                ////
////    2.1  Dec 16, 2021, Dinesh A                                                              ////
////      1.4 MBIST controller changed to single one                                             ////
////      2.Added one more SRAM to TCM memory                                                    ////
////      3.WishBone Interconnect chang to take care mbist changes                               ////
////      4.Pinmux change to take care of mbist changes                                          ////
////    2.2  Dec 20, 2021, Dinesh A                                                              ////
////      1. MBIST design issue fix for yosys                                                    ////
////      2. Full chip Timing and Transition clean-up                                            ////                   
////    2.3  Dec 24, 2021, Dinesh A                                                              ////
////      UART Master added with message handler at wb_host                                      ////
////    2.4  Jan 01, 2022, Dinesh A                                                              ////
////       LA[0] is added as soft reset option at wb_port                                        ////
////    2.5  Jan 06, 2022, Dinesh A                                                              ////
////       TCM RAM Bug fix inside syntacore                                                      ////
////    2.6  Jan 08, 2022, Dinesh A                                                              ////
////        Pinmux Interrupt Logic change                                                        ////
////    3.0  Jan 14, 2022, Dinesh A                                                              ////
////        Moving from riscv core from syntacore/scr1 to                                        ////
////        yfive/ycr1 on sankranti 2022 (A Hindu New Year)                                      ////
////    3.1  Jan 15, 2022, Dinesh A                                                              ////
////         Major changes in qspim logic to handle special mode                                 ////
////    3.2  Feb 02, 2022, Dinesh A                                                              ////
////         Bug fix around icache/dcache and wishbone burst                                     ////
////         access clean-up                                                                     ////
////    3.3  Feb 08, 2022, Dinesh A                                                              ////
////         support added spisram support in qspim ip                                           ////
////         There are 4 chip select available in qspim                                          ////
////         CS#0/CS#1 targeted for SPI FLASH                                                    ////
////         CS#2/CS#3 targeted for SPI SRAM                                                     ////
////    3.4  Feb 14, 2022, Dinesh A                                                              ////
////         burst mode supported added in imem buffer inside                                    ////
////         riscv core                                                                          ////
////    We have created seperate repo from this onwards                                          ////
////      SRAM based SOC is spin-out to                                                          ////
////      dineshannayya/riscduino_sram.git                                                       ////
////    This repo will remove mbist + SRAM and RISC SRAM will be                                 ////
////    replaced with DFRAM                                                                      ////
////    3.5  Feb 16, Dinesh A                                                                    ////
////       As SRAM from sky130A is not yet qualified,                                            ////
////       Following changes are done                                                            ////
////       A. riscv core cache and tcm interface changed to dffram                               ////  
////       B. removed the mbist controller + 4 SRAM                                              ////
////       C. mbist controller slave port in wb_intern removed                                   ////
////       D. Pinmux mbist port are removed                                                      ////
////       E. mbist related buffering are removed at wb_inter                                    ////
////    3.6  Feb 19, Dinesh A                                                                    ////
////       A.  Changed Module: wb_host                                                           ////
////       wishbone slave clock generation config increase from                                  ////
////       3 to 4 bit support clock source selection                                             ////
////       B.  Changed Module: qspim                                                             ////
////        1. Bug fix in spi rise and fall pulse relation w.r.t                                 ////
////           spi_clk. Note: Previous version work only with                                    ////
////           spi clock config = 0x2                                                            ////
////        2. spi_oen generation fix for different spi mode                                     ////
////        3. spi_csn de-assertion fix for different spi clk div                                ////
////    3.7  Mar 2 2022, Dinesh A                                                                ////
////       1. qspi cs# port mapping changed from io 28:25 to 25:28                               ////
////       2. sspi, bug fix in reg access and endian support added                               ////
////       3. Wishbone interconnect now support cross-connect                                    ////
////          feature                                                                            ////
////    3.8  Mar 10 2022, Dinesh A                                                               ////
////         1. usb chip select bug inside uart_* wrapper                                        ////
////         2. in wb_host, increased usb clk ctrl to 4 to 8 bit                                 ////
////    3.9  Mar 16 2022, Dinesh A                                                               ////
////         1. 3 Timer added                                                                    ////
////         2. Pinmux Register address movement                                                 ////
////         3. Risc fuse_mhartid is removed and internal tied                                   ////
////            inside risc core                                                                 ////
////         4. caravel wb addressing issue restrict to 0x300FFFFF                               ////
////    4.2  April 6 2022, Dinesh A                                                              ////
////         1. SSPI CS# increased from 1 to 4                                                   ////
////         2. uart port increase to two                                                        ////
////    4.3  May 24 2022, Dinesh A                                                               ////
////         Re targetted the design to mpw-6 tools set and risc                                 ////
////         core logic are timing optimized to 100mhz                                           ////
////    4.4  May 29 2022, Dinesh A                                                               ////
////         1. Digital PLL integrated and clock debug signal add                                ////
////           @digitial io [33] port                                                            ////
////    4.5  June 2 2022, Dinesh A                                                               ////
////         1. DFFRAM Replaced by SRAM                                                          ////
////    4.6  June 13 2022, Dinesh A                                                              ////
////         1. icache and dcache bypass config addded                                           ////
////    4.7  July 08 2022, Dinesh A                                                              ////
////          Pinmux changes to support SPI CS port matching to                                  ////
////          arduino                                                                            ////
////    4.8  July 20 2022, Dinesh A                                                              ////
////         SPI ISP boot option added in wb_host, spi slave uses                                ////
////         same spi master interface, but will be active only                                  ////
////         when internal SPI config disabled + RESET PIN = 0                                   ////
////    4.9  Aug 5 2022, Dinesh A                                                                ////
////         changes in sspim                                                                    ////
////           A. SPI Mode 0 to 3 support added,                                                 ////
////           B. SPI Duplex mode TX-RX Mode added                                               ////
////    5.0  Aug 15 2022, Dinesh A                                                               ////
////          A. 15 Hardware Semahore added                                                      ////
////          B. Pinmux Address Space are Split as                                               ////
////             `define ADDR_SPACE_PINMUX  32'h1002_0000                                        ////
////             `define ADDR_SPACE_GLBL    32'h1002_0000                                        ////
////             `define ADDR_SPACE_GPIO    32'h1002_0040                                        ////
////             `define ADDR_SPACE_PWM     32'h1002_0080                                        ////
////             `define ADDR_SPACE_TIMER   32'h1002_00C0                                        ////
////             `define ADDR_SPACE_SEMA    32'h1002_0100                                        ////
////    5.1  Aug 24 2022, Dinesh A                                                               ////
////          A. GPIO interrupt generation changed from 1 to 32                                  ////
////          B. Total interrupt to Riscv changed from 16 to 32                                  ////
////          C. uart_master disable option added at pinmux                                      ////
////          D. Timer interrupt related clean-up                                                ////
////          E. 4x ws281x driver logic added                                                    ////
////          F. 4x ws281x driver are mux with 16x gpio                                          ////
////          G. gpio type select the normal gpio vs ws281x                                      ////
////    5.2  Aug 26 2022, Dinesh A                                                               ////
////          A. We have copied the user_defines.h from caravel                                  ////
////          and configured all the GPIO from 5 onwards as                                      ////
////          GPIO_MODE_USER_STD_BIDIRECTIONAL                                                   ////
////                                                                                             ////
////          As digitial-io[0-5] reserved at power up.                                          ////
////          B. to keep at least one uart access,                                               ////
////              we have moved UART_RXD[1] from io[3] to io[6]                                  ////
////          C. SPI Slave SSN move from io[0] to [7]                                            ////
////    5.3  Sept 2 2022, Dinesh A                                                               ////
////          A. System Strap implementation                                                     ////
////          B. Arduino pins are moved to take care of caravel                                  ////
////            digital-io[0-4] resevred                                                         ////
////          C. global register space increased from 16 to 32                                   ////
////          D. reset fsm is implementation with soft reboot                                    ////
////             option                                                                          ////
////          E. strap based booting option added for qspi                                       ////
////    5.4  Sept 7 2022, Dinesh A                                                               ////
////          A. PLL configuration are moved from wb_host to                                     ////
////          pinmux to help risc core to do pll config and reboot                               ////
////          B. PLL configuration are kept in p_reset_n to avoid                                ////
////           initialized on soft reboot.                                                       ////
////          C. Master Uart has two strap bit to control the                                    ////
////          boot up config                                                                     ////
////          2'b00 - 50Mhz, 2'b01 - 40Mhz, 2'b10 - 50Mhz,                                       ////
////          2'b11 - LA control                                                                 ////
////    5.5  Sept 14 2022, Dinesh A                                                              ////
////          A. Auto Baud detection added in uart master as                                     ////
////          power on user_clock1 is not decided, strap def                                     ////
////          changed                                                                            ////
////          2'b00 - Auto, 2'b01 - 50Mhz, 2'b10 - 4Mhz,                                         ////
////          2'b11 - LA control                                                                 ////
////          B. digital_pll is re-synth with maual placement                                    ////
////    5.6  Sept 29 2022, Dinesh A                                                              ////
////         A. 4x 8bit DAC Integration                                                          ////
////         B. clock skew control added for core clock                                          ////
////    5.7  Nov 7, 2022, Dinesh A                                                               ////
////         A. AES 128 Bit Encription and Decryption integration                                ////
////         B. FPU Integration                                                                  ////
////    5.8  Nov 20, 2022, Dinesh A                                                              ////
////         A. Pinmux - Double Sync added for usb & i2c inter                                   ////
////    5.9  Nov 25, 2022, Dinesh A                                                              ////
////         cpu_clk will be feed through wb_interconnect for                                    ////
////         buffering purpose                                                                   ////
////    6.0  Nov 27, 2022, Dinesh A                                                              ////
////         MPW-7 Timing clean setup                                                            ////
////    6.1  Nov 28, 2022, Dinesh A                                                              ////
////        Power Hook up connectivity issue for                                                 ////
////        aes,fpu,bus repeater is fixed                                                        ////
////    6.2  Dec 4, 2022, Dinesh A                                                               ////
////         Bus repeater north/south/east/west added for better                                 ////
////         global buffering                                                                    ////
////    6.3  Dec 7, 2022, Dinesh A                                                               ////
////         A. peripheral block integration                                                     ////
////         B. RTC Integration                                                                  ////
////    6.4  Dec 13, 2022, Dinesh A                                                              ////
////         A. Random Generator Integration                                                     ////
////         B. NEC IR Receiver Integration                                                      ////
////         C. NEC IR Transmitter Integration                                                   ////
////      Bug Fix In Pinmux                                                                      ////
////         WS281x IO direction fix                                                             //// 
////    6.5  Dec 24, 2022, Dinesh A                                                              ////
////         A. uart_core async fifo mode set to fast access                                     ////
////         B. CTS buffering enabled in all blocks                                              ////
////    6.6  Jan 6, 2023, Dinesh A                                                               ////
////         A. Move to MPW-9 Openlane Tool Chain                                                ////
////         B. Stepper Motor Integration                                                        ////
////    6.7 Jan 29, 2023, Dinesh A                                                               ////
////        block qspi:                                                                          ////
////          A. As part of MPW-2 Silicon Bug-Fx:-                                               ////
////             SPI Flash Power Up command (0xAB) need 3 us delay before the next command       ////
////          B. FAST SIM connected to PORT for better GateSim control                           ////
////    6.8 Feb 11, 2023, Dinesh A                                                               ////
////         A. Centrialized Source Clock gating logic added at wishbone inter connect           ////
////         B. QSpim Modified to generate Idle indication                                       ////
////         C. Register Space Allocated for Wishbone Interconnect                               ////
////    6.9 April 8, 2023, Dinesh A                                                              ////
////         A. Risc core Tap access enabled                                                     ////
////         B. all the cpu clk are routed from ycr_iconnect                                     ////
////         C. glbl_reg_10 add to support software-wise interrupt set                           ////
////    6.10 May 1, 2023, Dinesh A                                                               ////
////         A. AES and FPU idle generation for clock gating purpose                             ////
////    6.11 June 1, 2023, Dinesh A                                                              ////
////         A. Clock Gating for Riscv Core                                                      ////
////         B. Bug fix inside Riscv Core - Tap Reset connectivity                               ////
////    6.12 June 14, 2023, Dinesh A                                                             ////
////         A. Inferred Clock Gating (At Synthesis) add for SPIQ                                ////
////         b. New 4x8bit DAC added with voltage follower and issolation for digital input      //// 
////    7.0  Dec 8, 2023, Dinesh A                                                               ////
////         A. Ported the GF180nm techonology, design has restructured as each IP area in       ////
////         GF180nm 3x more than Sky130nm, Some of the modules are removed to fit the design    ////
////         in within 8mm2.                                                                     ////
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
wire     wbd_pinmux_clk_skew;


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
wire   [3:0]                   wbm_wbhost_mid_i                        ; // Master ID
wire   [9:0]                   wbm_wbhost_bl_i                         ; // Burst Length
wire                           wbm_wbhost_bry_i                        ; // Burst Ready

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
//    RISCV MASTER WB I/F
//---------------------------------------------------------------------
wire                           riscv_mclk                              ;
wire                           wbm_riscv_cyc_i                         ;  // strobe/request
wire                           wbm_riscv_stb_i                         ;  // strobe/request
wire [31:0]                    wbm_riscv_adr_i                         ;  // address
wire                           wbm_riscv_we_i                          ;  // write
wire [31:0]                    wbm_riscv_dat_i                         ;  // data output
wire [3:0]                     wbm_riscv_sel_i                         ;  // byte enable
wire [3:0]                     wbm_riscv_mid_i                         ;  // master id
wire                           wbm_riscv_bry_i                         ;  // bursy ready
wire [9:0]                     wbm_riscv_bl_i                          ;  // burst length

wire [31:0]                    wbm_riscv_dat_o                         ;  // data input
wire                           wbm_riscv_ack_o                         ;  // acknowlegement
wire                           wbm_riscv_lack_o                        ;  // acknowlegement
wire                           wbm_riscv_err_o                         ;  // error

wire [63:0]                    riscv_debug                             ;
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

wire   [3:0]                   wbs_qspim_sid_i                         ; // sid
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
wire   [10:0]                  wbs_uart_adr_o                         ; // address
wire                           wbs_uart_we_o                          ; // write
wire   [31:0]                  wbs_uart_dat_o                         ; // data output
wire   [3:0]                   wbs_uart_sel_o                         ; // byte enable
wire                           wbs_uart_cyc_o                         ;

wire   [3:0]                   wbs_uart_sid_i                         ; // sid
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
wire [3:0]                     wbm_uart_mid_i                         ;  // Master ID
wire                           wbm_uart_bry_i                         ;  // burst ready
wire [9:0]                     wbm_uart_bl_i                          ;  // byte length

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
wire   [10:0]                  wbs_usb_adr_o                         ; // address
wire                           wbs_usb_we_o                          ; // write
wire   [31:0]                  wbs_usb_dat_o                         ; // data output
wire   [3:0]                   wbs_usb_sel_o                         ; // byte enable
wire                           wbs_usb_cyc_o                         ;

wire   [3:0]                   wbs_usb_sid_i                         ; // data input
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
wire [3:0]                     wbm_sspi_mid_i                         ;  // master id
wire                           wbm_sspi_bry_i                         ;  // bursy ready
wire [9:0]                     wbm_sspi_bl_i                          ;  // burst length

wire [31:0]                    wbm_sspi_dat_o                         ;  // data input
wire                           wbm_sspi_ack_o                         ;  // acknowlegement
wire                           wbm_sspi_lack_o                        ;  // acknowlegement
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
wire   [10:0]                  wbs_sspi_adr_o                        ; // address
wire                           wbs_sspi_we_o                         ; // write
wire   [31:0]                  wbs_sspi_dat_o                        ; // data output
wire   [3:0]                   wbs_sspi_sel_o                        ; // byte enable
wire                           wbs_sspi_cyc_o                        ;

wire   [3:0]                   wbs_sspi_sid_i                        ; // data input
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

wire   [3:0]                   wbs_pinmux_sid_i                       ; // data input
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
wire [1:0]                     i2c_rst_n                              ;
wire [1:0]                     usb_rst_n                              ;
wire [31:0]                    irq_lines                              ;
wire [15:0]                    cfg_riscv_ctrl                         ;
//--------------------------------------------------
// peri0
//--------------------------------------------------
wire                           peri0_mclk                            ;
wire                           wbs_peri0_stb_o                       ; // strobe/request
wire   [10:0]                  wbs_peri0_adr_o                       ; // address
wire                           wbs_peri0_we_o                        ; // write
wire   [WB_WIDTH-1:0]          wbs_peri0_dat_o                       ; // data output
wire   [3:0]                   wbs_peri0_sel_o                       ; // byte enable
wire                           wbs_peri0_cyc_o                       ;

wire   [3:0]                   wbs_peri0_sid_i                       ; // data input
wire   [WB_WIDTH-1:0]          wbs_peri0_dat_i                       ; // data input
wire                           wbs_peri0_ack_i                       ; // acknowlegement
wire                           wbs_peri0_err_i                       ; // error

wire [3:0]                     ws_txd                                 ;// ws281x txd port
wire [2:0]                     timer_intr                             ;
wire                           pulse_1ms                              ; // 1 Milli Second Pulse for waveform Generator
wire                           pulse_1us                              ; // 1 Micro Second Pulse for waveform Generator


//---------------------------------------------------------------------

assign la_data_out = {qspi_debug[31:0],pinmux_debug[31:0]};


////////////////////////////////////////////////////////
wire [31:0] cfg_clk_skew_ctrl1;

wire [3:0] cfg_wcska_wi          = cfg_clk_skew_ctrl1[3:0];
wire [3:0] cfg_wcska_wh          = cfg_clk_skew_ctrl1[7:4];
wire [3:0] cfg_wcska_riscv       = cfg_clk_skew_ctrl1[11:8];
wire [3:0] cfg_wcska_qspi        = cfg_clk_skew_ctrl1[15:12];
wire [3:0] cfg_wcska_uart        = cfg_clk_skew_ctrl1[19:16];
wire [3:0] cfg_wcska_pinmux      = cfg_clk_skew_ctrl1[23:20];
wire [3:0] cfg_wcska_qspi_co     = cfg_clk_skew_ctrl1[27:24];

/////////////////////////////////////////////////////////
// RISCV Clock skew control
/////////////////////////////////////////////////////////
wire [31:0] cfg_clk_skew_ctrl2;

//wire [3:0]   cfg_ccska_riscv_intf   = cfg_clk_skew_ctrl2[3:0];
wire [3:0]   cfg_ccska_riscv_icon     = cfg_clk_skew_ctrl2[7:4];
wire [3:0]   cfg_ccska_riscv_core0    = cfg_clk_skew_ctrl2[11:8];
//wire [3:0]   cfg_ccska_riscv_core1  = cfg_clk_skew_ctrl2[15:12];
wire [3:0]   cfg_wcska_peri0         = cfg_clk_skew_ctrl2[19:16];
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
          .wbs_mid_o               (wbm_wbhost_mid_i       ),  
          .wbs_bry_o               (wbm_wbhost_bry_i       ),  
          .wbs_bl_o                (wbm_wbhost_bl_i        ),  


          .wbs_dat_i               (wbm_wbhost_dat_o       ),  
          .wbs_ack_i               (wbm_wbhost_ack_o       ),  
          .wbs_err_i               (wbm_wbhost_err_o       ),  

          .cfg_clk_skew_ctrl1      (cfg_clk_skew_ctrl1     ),
          .cfg_clk_skew_ctrl2      (cfg_clk_skew_ctrl2     )


    );


//------------------------------------------------------------------------------
// RISC V Core instance
//------------------------------------------------------------------------------
ycr_top_wb u_riscv_top (
`ifdef USE_POWER_PINS
          .vdd                     (vdd                        ),// User area 1 1.8V supply
          .vss                     (vss                        ),// User area 1 digital ground
`endif


    // Reset
          .pwrup_rst_n             (wbd_int_rst_n              ),
          .rst_n                   (wbd_int_rst_n              ),
          .cpu_intf_rst_n          (cpu_intf_rst_n             ),
          .cpu_core_rst_n          (cpu_core_rst_n[0]          ),
          .riscv_debug             (riscv_debug                ),

    // Clock
          .core_clk_int            (cpu_clk                    ),
          .cfg_ccska_riscv_icon    (cfg_ccska_riscv_icon       ),
          .cfg_ccska_riscv_core0   (cfg_ccska_riscv_core0      ),

          .rtc_clk                 (rtc_clk                    ),

    // IRQ
          .irq_lines               (irq_lines                  ), 
          .soft_irq                (soft_irq                   ), 

   
     //---------------------------------------------------------------
     // Wishbone Interface
     //---------------------------------------------------------- 
          .wb_clk                  (riscv_mclk                 ), 
          .cfg_wcska_riscv_intf    (cfg_wcska_riscv            ), 
          .wb_rst_n                (wbd_int_rst_n              ),


    // Data memory interface
          .wbd_mid_o               (wbm_riscv_mid_i            ),
          .wbd_dmem_cyc_o          (wbm_riscv_cyc_i            ),
          .wbd_dmem_stb_o          (wbm_riscv_stb_i            ),
          .wbd_dmem_adr_o          (wbm_riscv_adr_i            ),
          .wbd_dmem_we_o           (wbm_riscv_we_i             ), 
          .wbd_dmem_dat_o          (wbm_riscv_dat_i            ),
          .wbd_dmem_sel_o          (wbm_riscv_sel_i            ),
          .wbd_dmem_bl_o           (wbm_riscv_bl_i             ),
          .wbd_dmem_bry_o          (wbm_riscv_bry_i            ),

          .wbd_dmem_dat_i          (wbm_riscv_dat_o            ),
          .wbd_dmem_ack_i          (wbm_riscv_ack_o            ),
          .wbd_dmem_lack_i         (wbm_riscv_lack_o           ),
          .wbd_dmem_err_i          (wbm_riscv_err_o            )

);


//---------------------------------------
// Inter connect
//--------------------------------------- 
wbi_top   u_intercon (
`ifdef USE_POWER_PINS
          .vccd1              (vdd                       ),// User area 1 1.8V supply
          .vssd1              (vss                       ),// User area 1 digital ground
`endif

          .mclk_raw           (wbd_mclk                  ), // wb clock without skew
          .clk_i              (wbd_mclk                  ), // wb clock with skew
          .rst_n              (wbd_int_rst_n             ),

         // Master 0 Interface - wbhost
          .m0_mclk            (wbhost_mclk               ),
          .m0_wbd_dat_i       (wbm_wbhost_dat_i          ),
          .m0_wbd_adr_i       (wbm_wbhost_adr_i          ),
          .m0_wbd_sel_i       (wbm_wbhost_sel_i          ),
          .m0_wbd_we_i        (wbm_wbhost_we_i           ),
          .m0_wbd_cyc_i       (wbm_wbhost_cyc_i          ),
          .m0_wbd_stb_i       (wbm_wbhost_stb_i          ),
          .m0_wbd_mid_i       (wbm_wbhost_mid_i          ),
          .m0_wbd_bry_i       (wbm_wbhost_bry_i          ),
          .m0_wbd_bl_i        (wbm_wbhost_bl_i           ),

          .m0_wbd_dat_o       (wbm_wbhost_dat_o          ),
          .m0_wbd_ack_o       (wbm_wbhost_ack_o          ),
          .m0_wbd_err_o       (wbm_wbhost_err_o          ),
         
         
       // Slave 0 Interface - qspi
          .s0_mclk            (qspim_mclk                ),
          .s0_idle            (qspim_idle                ),
          .s0_wbd_sid_i       (wbs_qspim_sid_i           ),
          .s0_wbd_dat_i       (wbs_qspim_dat_i           ),
          .s0_wbd_ack_i       (wbs_qspim_ack_i           ),
          .s0_wbd_lack_i      (wbs_qspim_lack_i          ),
          .s0_wbd_err_i       (wbs_qspim_err_i           ), 
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
          .m1_wbd_mid_i       (wbm_uart_mid_i            ),
          .m1_wbd_bry_i       (wbm_uart_bry_i            ),
          .m1_wbd_bl_i        (wbm_uart_bl_i             ),

          .m1_wbd_dat_o       (wbm_uart_dat_o            ),
          .m1_wbd_ack_o       (wbm_uart_ack_o            ),
          .m1_wbd_err_o       (wbm_uart_err_o            ),

       // Slave 1 Interface - uart
          .s1_mclk            (uart_mclk                 ),
          .s1_wbd_sid_i       (wbs_uart_sid_i            ),
          .s1_wbd_dat_i       (wbs_uart_dat_i            ),
          .s1_wbd_ack_i       (wbs_uart_ack_i            ),
          .s1_wbd_err_i       (wbs_uart_err_i            ),
          .s1_wbd_dat_o       (wbs_uart_dat_o            ),
          .s1_wbd_adr_o       (wbs_uart_adr_o            ),
          .s1_wbd_sel_o       (wbs_uart_sel_o            ),
          .s1_wbd_we_o        (wbs_uart_we_o             ),  
          .s1_wbd_cyc_o       (wbs_uart_cyc_o            ),
          .s1_wbd_stb_o       (wbs_uart_stb_o            ),

       // Slave 2 Interface - usb
          .s2_mclk            (usb_mclk                  ),
          .s2_wbd_sid_i       (wbs_usb_sid_i             ),
          .s2_wbd_dat_i       (wbs_usb_dat_i             ),
          .s2_wbd_ack_i       (wbs_usb_ack_i             ),
          .s2_wbd_err_i       (wbs_usb_err_i            ),
          .s2_wbd_dat_o       (wbs_usb_dat_o             ),
          .s2_wbd_adr_o       (wbs_usb_adr_o             ),
          .s2_wbd_sel_o       (wbs_usb_sel_o             ),
          .s2_wbd_we_o        (wbs_usb_we_o              ),  
          .s2_wbd_cyc_o       (wbs_usb_cyc_o             ),
          .s2_wbd_stb_o       (wbs_usb_stb_o             ),
         
         // Master 2 Interface - sspi-i2c
          .m2_wbd_dat_i       (wbm_sspi_dat_i            ),
          .m2_wbd_adr_i       (wbm_sspi_adr_i            ),
          .m2_wbd_sel_i       (wbm_sspi_sel_i            ),
          .m2_wbd_we_i        (wbm_sspi_we_i             ),
          .m2_wbd_cyc_i       (wbm_sspi_cyc_i            ),
          .m2_wbd_stb_i       (wbm_sspi_stb_i            ),
          .m2_wbd_mid_i       (wbm_sspi_mid_i            ),
          .m2_wbd_bry_i       (wbm_sspi_bry_i            ),
          .m2_wbd_bl_i        (wbm_sspi_bl_i             ),

          .m2_wbd_dat_o       (wbm_sspi_dat_o            ),
          .m2_wbd_ack_o       (wbm_sspi_ack_o            ),
          .m2_wbd_err_o       (wbm_sspi_err_o            ),

        // Slave 3 Interface - sspi-i2c
          .s3_mclk            (sspi_mclk                 ),
          .s3_wbd_sid_i       (wbs_sspi_sid_i            ),
          .s3_wbd_dat_i       (wbs_sspi_dat_i            ),
          .s3_wbd_ack_i       (wbs_sspi_ack_i            ),
          .s3_wbd_err_i       (wbs_sspi_err_i            ),
          .s3_wbd_dat_o       (wbs_sspi_dat_o            ),
          .s3_wbd_adr_o       (wbs_sspi_adr_o            ),
          .s3_wbd_sel_o       (wbs_sspi_sel_o            ),
          .s3_wbd_we_o        (wbs_sspi_we_o             ),  
          .s3_wbd_cyc_o       (wbs_sspi_cyc_o            ),
          .s3_wbd_stb_o       (wbs_sspi_stb_o            ),

        // Master-4 Interface - Riscv
          .m3_mclk            (riscv_mclk                ),
          .m3_wbd_dat_i       (wbm_riscv_dat_i           ),
          .m3_wbd_adr_i       (wbm_riscv_adr_i           ),
          .m3_wbd_sel_i       (wbm_riscv_sel_i           ),
          .m3_wbd_we_i        (wbm_riscv_we_i            ),
          .m3_wbd_cyc_i       (wbm_riscv_cyc_i           ),
          .m3_wbd_stb_i       (wbm_riscv_stb_i           ),
          .m3_wbd_mid_i       (wbm_riscv_mid_i           ),
          .m3_wbd_bry_i       (wbm_riscv_bry_i           ),
          .m3_wbd_bl_i        (wbm_riscv_bl_i            ),

          .m3_wbd_dat_o       (wbm_riscv_dat_o           ),
          .m3_wbd_ack_o       (wbm_riscv_ack_o           ),
          .m3_wbd_lack_o      (wbm_riscv_lack_o          ),
          .m3_wbd_err_o       (wbm_riscv_err_o           ),

        // Slave 5 Interface - pinmux
          .s4_mclk            (pinmux_mclk              ),
          .s4_wbd_sid_i       (wbs_pinmux_sid_i         ),
          .s4_wbd_dat_i       (wbs_pinmux_dat_i         ),
          .s4_wbd_ack_i       (wbs_pinmux_ack_i         ),
          .s4_wbd_err_i       (wbs_pinmux_err_i         ),
          .s4_wbd_dat_o       (wbs_pinmux_dat_o         ),
          .s4_wbd_adr_o       (wbs_pinmux_adr_o         ),
          .s4_wbd_sel_o       (wbs_pinmux_sel_o         ),
          .s4_wbd_we_o        (wbs_pinmux_we_o          ),  
          .s4_wbd_cyc_o       (wbs_pinmux_cyc_o         ),
          .s4_wbd_stb_o       (wbs_pinmux_stb_o         ),

        // Slave 6 Interface - Peri
          .s5_mclk            (peri0_mclk               ),
          .s5_wbd_sid_i       (wbs_peri0_sid_i          ),
          .s5_wbd_dat_i       (wbs_peri0_dat_i          ),
          .s5_wbd_ack_i       (wbs_peri0_ack_i          ),
          .s5_wbd_err_i       (wbs_peri0_err_i          ),
          .s5_wbd_dat_o       (wbs_peri0_dat_o          ),
          .s5_wbd_adr_o       (wbs_peri0_adr_o          ),
          .s5_wbd_sel_o       (wbs_peri0_sel_o          ),
          .s5_wbd_we_o        (wbs_peri0_we_o           ),  
          .s5_wbd_cyc_o       (wbs_peri0_cyc_o          ),
          .s5_wbd_stb_o       (wbs_peri0_stb_o          )
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

          .wbd_sid_o               (wbs_qspim_sid_i         ),
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
          .reg_addr           (wbs_uart_adr_o               ),
          .reg_wdata          (wbs_uart_dat_o               ),
          .reg_be             (wbs_uart_sel_o               ),

       // Outputs
          .reg_sid            (wbs_uart_sid_i               ),
          .reg_rdata          (wbs_uart_dat_i               ),
          .reg_ack            (wbs_uart_ack_i               ),
          .reg_err            (wbs_uart_err_i               ),

      // Wb Master I/F
          .wbm_uart_cyc_o     (wbm_uart_cyc_i               ),  // strobe/request
          .wbm_uart_stb_o     (wbm_uart_stb_i               ),  // strobe/request
          .wbm_uart_adr_o     (wbm_uart_adr_i               ),  // address
          .wbm_uart_we_o      (wbm_uart_we_i                ),  // write
          .wbm_uart_dat_o     (wbm_uart_dat_i               ),  // data output
          .wbm_uart_sel_o     (wbm_uart_sel_i               ),  // byte enable
          .wbm_uart_mid_o     (wbm_uart_mid_i               ),  // byte enable
          .wbm_uart_bry_o     (wbm_uart_bry_i               ),  // byte enable
          .wbm_uart_bl_o      (wbm_uart_bl_i                ),  // byte enable


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

          .usbh_rstn          (usb_rst_n[0]                 ), // async reset
          .usbd_rstn          (usb_rst_n[1]                 ), // async reset
          .app_clk            (wbd_usb_clk_skew             ),
          .usb_clk            (usb_clk                      ), // 48Mhz usb clock

   // Reg Bus Interface Signal
          .reg_cs             (wbs_usb_stb_o               ),
          .reg_wr             (wbs_usb_we_o                ),
          .reg_addr           (wbs_usb_adr_o               ),
          .reg_wdata          (wbs_usb_dat_o               ),
          .reg_be             (wbs_usb_sel_o               ),

   // Outputs
          .reg_sid            (wbs_usb_sid_i               ),
          .reg_rdata          (wbs_usb_dat_i               ),
          .reg_ack            (wbs_usb_ack_i               ),
          .reg_err            (wbs_usb_err_i               ),

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
                              
          .usbd_intr_o        (usbd_intr_o                 )


     );

//-----------------------------------------------
// SSPIM/SSPIS
//-----------------------------------------------

sspi_i2c_wrapper  u_sspi_wrap
     (  
`ifdef USE_POWER_PINS
          .vccd1              (vdd                          ),// User area 1 1.8V supply
          .vssd1              (vss                          ),// User area 1 digital ground
`endif
          .reset_n            (wbd_int_rst_n                ), // global reset

    // clock skew adjust
          .cfg_cska_sspi       (cfg_wcska_sspi               ),
          .wbd_clk_int        (sspi_mclk                    ),
          .wbd_clk_skew       (wbd_sspi_clk_skew            ),

          .sspi_rstn          (sspi_rst_n                   ), 
          .i2c_rstn           (i2c_rst_n                    ), // async reset
          .app_clk            (wbd_sspi_clk_skew            ),

   // Reg Bus Interface Signal
          .reg_slv_cs         (wbs_sspi_stb_o               ),
          .reg_slv_wr         (wbs_sspi_we_o                ),
          .reg_slv_addr       (wbs_sspi_adr_o               ),
          .reg_slv_wdata      (wbs_sspi_dat_o               ),
          .reg_slv_be         (wbs_sspi_sel_o               ),

   // Outputs
          .reg_slv_sid        (wbs_sspi_sid_i               ),
          .reg_slv_rdata      (wbs_sspi_dat_i               ),
          .reg_slv_ack        (wbs_sspi_ack_i               ),
          .reg_slv_err        (wbs_sspi_err_i               ),


   // SPIM I/F
          .sspim_sck          (sspim_sck                    ), 
          .sspim_so           (sspim_so                     ),  
          .sspim_si           (sspim_si                     ),  
          .sspim_ssn          (sspim_ssn                    ), 


   // Wb Master I/F
          .wbm_sspis_cyc_o    (wbm_sspi_cyc_i               ),
          .wbm_sspis_stb_o    (wbm_sspi_stb_i               ),
          .wbm_sspis_adr_o    (wbm_sspi_adr_i               ),
          .wbm_sspis_we_o     (wbm_sspi_we_i                ),
          .wbm_sspis_dat_o    (wbm_sspi_dat_i               ),
          .wbm_sspis_sel_o    (wbm_sspi_sel_i               ),
          .wbm_sspis_mid_o    (wbm_sspi_mid_i               ),
          .wbm_sspis_bry_o    (wbm_sspi_bry_i               ),
          .wbm_sspis_bl_o     (wbm_sspi_bl_i                ),

          .wbm_sspis_dat_i    (wbm_sspi_dat_o               ),
          .wbm_sspis_ack_i    (wbm_sspi_ack_o               ),
          .wbm_sspis_err_i    (wbm_sspi_err_o               ),

          .sspis_sck          (sspis_sck                    ),
          .sspis_ssn          (sspis_ssn                    ),
          .sspis_si           (sspis_si                     ),
          .sspis_so           (sspis_so                     ),
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
          .vccd1              (vdd                          ),// User area 1 1.8V supply
          .vssd1              (vss                          ),// User area 1 digital ground
      `endif
        // clock skew adjust
          .cfg_cska_pinmux    (cfg_wcska_pinmux             ),
          .wbd_clk_int        (pinmux_mclk                  ),
          .wbd_clk_skew       (wbd_pinmux_clk_skew          ),

          // System Signals
          // Inputs
          .mclk               (wbd_pinmux_clk_skew          ),
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
          .i2c_rst_n          (i2c_rst_n                    ),
          .usb_rst_n          (usb_rst_n                    ),

          .cfg_riscv_ctrl     (cfg_riscv_ctrl               ),

        // Reg Bus Interface Signal
          .reg_cs             (wbs_pinmux_stb_o             ),
          .reg_wr             (wbs_pinmux_we_o              ),
          .reg_addr           (wbs_pinmux_adr_o             ),
          .reg_wdata          (wbs_pinmux_dat_o             ),
          .reg_be             (wbs_pinmux_sel_o             ),

       // Outputs
          .reg_sid            (wbs_pinmux_sid_i             ),
          .reg_rdata          (wbs_pinmux_dat_i             ),
          .reg_ack            (wbs_pinmux_ack_i             ),
          .reg_err            (wbs_pinmux_err_i             ),

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



peri_wrapper0 u_per_wrap0(
       `ifdef USE_POWER_PINS
          .vccd1              (vdd                         ),// User area 1 1.8V supply
          .vssd1              (vss                         ),// User area 1 digital ground
       `endif

        // clock skew adjust
          .cfg_cska_peri      (cfg_wcska_peri0             ),
          .wbd_clk_int        (peri0_mclk                  ),
          .wbd_clk_skew       (wbd_clk_peri0               ),

        // System Signals
        // Inputs
          .mclk               (wbd_clk_peri0               ),
          .reset_n            (wbd_int_rst_n               ), // global reset


          .ws_txd             (ws_txd                      ),
          .timer_intr         (timer_intr                  ),
          .pulse_1ms          (pulse_1ms                   ),
          .pulse_1us          (pulse_1us                   ),

        // Reg Bus Interface Signal
          .reg_cs             (wbs_peri0_stb_o             ),
          .reg_wr             (wbs_peri0_we_o              ),
          .reg_addr           (wbs_peri0_adr_o             ),
          .reg_wdata          (wbs_peri0_dat_o             ),
          .reg_be             (wbs_peri0_sel_o             ),

       // Outputs
          .reg_sid            (wbs_peri0_sid_i             ),
          .reg_rdata          (wbs_peri0_dat_i             ),
          .reg_ack            (wbs_peri0_ack_i             ),
          .reg_err            (wbs_peri0_err_i             )
               
   ); 




endmodule : user_project_wrapper
