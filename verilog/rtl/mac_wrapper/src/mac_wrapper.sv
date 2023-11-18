module mac_wrapper #(
       parameter SCW = 8   // SCAN CHAIN WIDTH
     )(

                   input logic         app_clk        ,
                   input logic         reset_n        ,

                  // Clock Skew Adjust
                  input logic [3:0]    cfg_cska_mac,
                  input logic          wbd_clk_int,
	              output logic         wbd_clk_skew,

                   //-----------------------------------------------------------------------
                   // Line-Tx Signal
                   //-----------------------------------------------------------------------
                   output logic         phy_tx_en      ,
                   output logic         phy_tx_er      ,
                   output logic [7:0]   phy_txd        ,
                   input  logic	        phy_tx_clk     ,
                   
                   //-----------------------------------------------------------------------
                   // Line-Rx Signal
                   //-----------------------------------------------------------------------
                   input  logic	        phy_rx_clk     ,
                   input  logic	        phy_rx_er      ,
                   input  logic	        phy_rx_dv      ,
                   input  logic [7:0]   phy_rxd        ,
                   input  logic	        phy_crs        ,
                   
                   
                   //-----------------------------------------------------------------------
                   // MDIO Signal
                   //-----------------------------------------------------------------------
                   input  logic	       mdio_clk        ,
                   input  logic        mdio_in         ,
                   output logic        mdio_out_en     ,
                   output logic        mdio_out        ,

                   //--------------------------------------------
                   // GMAC TX WB Master I/F
                   //--------------------------------------------
                   input  logic [31:0] wbm_gtx_dat_i   ,
                   input  logic        wbm_gtx_ack_i   ,
                   output logic [15:0] wbm_gtx_adr_o   ,
                   output logic [3:0]  wbm_gtx_sel_o   ,
                   output logic        wbm_gtx_we_o    ,
                   output logic        wbm_gtx_stb_o   ,
                   output logic        wbm_gtx_cyc_o   ,
                
                //--------------------------------------------
                // GMAC RX WB Master I/F
                //--------------------------------------------
                   input  logic [31:0]  wbm_grx_dat_i  ,
                   input  logic         wbm_grx_ack_i  ,
                   output logic [31:0]  wbm_grx_dat_o  ,
                   output logic [15:0]  wbm_grx_adr_o  ,
                   output logic [3:0]   wbm_grx_sel_o  ,
                   output logic         wbm_grx_we_o   ,
                   output logic         wbm_grx_stb_o  ,
                   output logic         wbm_grx_cyc_o  ,
                
                //--------------------------------------------
                // GMAC REG WB SLAVE I/F
                //--------------------------------------------
                   output  logic [31:0]  wbs_grg_dat_o  ,
                   output  logic         wbs_grg_ack_o  ,
                   input   logic [31:0]  wbs_grg_dat_i  ,
                   input   logic [12:0]  wbs_grg_adr_i  ,
                   input   logic [3:0]   wbs_grg_sel_i  ,
                   input   logic         wbs_grg_we_i   ,
                   input   logic         wbs_grg_stb_i  ,
                   input   logic         wbs_grg_cyc_i  ,
                   
                  // Q Occupancy
                   output logic [9:0]   cfg_tx_qbase_addr,
                   output logic [9:0]   cfg_rx_qbase_addr,

                   input logic           mac_tx_qcnt_inc,
                   input logic           mac_tx_qcnt_dec,
                   input logic           mac_rx_qcnt_inc,  
                   input logic           mac_rx_qcnt_dec       

                );

wire [8:0]               app_txfifo_wrdata_i;
wire [15:0]              app_rxfifo_addr    ;
wire [3:0]               tx_qcnt            ;
wire [3:0]               rx_qcnt            ;

//-----------------------------
// MAC Related wire Decleration
//-----------------------------
wire [8:0]               app_rxfifo_rddata_o;
wire [31:0]              app_rx_desc_data   ;

wire tx_q_empty  = (tx_qcnt == 0);
wire rx_q_empty  = (rx_qcnt == 0);


//  clock skew control
clk_skew_adjust u_skew_mac
       (
`ifdef USE_POWER_PINS
               .vccd1      (vccd1                      ),// User area 1 1.8V supply
               .vssd1      (vssd1                      ),// User area 1 digital ground
`endif
	           .clk_in     (wbd_clk_int                 ), 
	           .sel        (cfg_cska_mac                ), 
	           .clk_out    (wbd_clk_skew                ) 
       );

/****************************
//---------------------------------------------------------------
// Mapping the MAC Interface Signal to Caravel I/O
//---------------------------------------------------------------
//-----------------------------------------------------------------------
// Line-Tx Signal
//-----------------------------------------------------------------------
logic	      phy_tx_clk     ;
logic         phy_tx_en      ;
logic         phy_tx_er      ;
logic [7:0]   phy_txd        ;

assign io_out[7:0] = phy_txd;
assign io_out[8]   = phy_tx_en;
assign io_out[9]   = phy_tx_er;
assign io_out[10]  = phy_tx_clk;
assign io_out[11]  = 1'b0; // Reserved

assign io_oeb[11:0] = 'h0; // All are Output

                   
//-----------------------------------------------------------------------
// Line-Rx Signal
//-----------------------------------------------------------------------
input  logic	        phy_rx_clk     ,
input  logic	        phy_rx_er      ,
input  logic	        phy_rx_dv      ,
input  logic [7:0]      phy_rxd        ,
input  logic	        phy_crs        ,

assign  phy_rx_dv   = io_in[12];
assign  phy_rx_er   = io_in[13];
assign  phy_crs     = io_in[14];
assign  phy_rx_clk  = io_in[15];
assign  phy_rxd     = io_in[23:16];

assign io_oeb[23:16] = 12'hFFF; // All are Inputs
                   
                   
//-----------------------------------------------------------------------
// MDIO Signal
//-----------------------------------------------------------------------
logic	        mdio_clk        ;
logic           mdio_in         ;
logic           mdio_out_en     ;
logic           mdio_out        ;


assign io_in[24]  = mdio_clk;
assign io_in[25]  = mdio_in;
assign io_out[25] = mdio_out;
assign io_oeb[24] = 1'b1; // mdio clk input
assign io_oeb[25] = mdio_out_en;
*******************/



// QCounter Inc/dec generation
// Ned to move this logic to wishbone interconnect
//wire tx_qcnt_inc = (cfg_tx_buf_qbase_addr == wb_xram_adr[15:6]) && wb_xram_stb && wb_xram_wr  && wb_xram_ack && (wb_xram_be[3] == 1'b1);
//wire tx_qcnt_dec = (cfg_tx_buf_qbase_addr == wb_xram_adr[15:6]) && wb_xram_stb && !wb_xram_wr && wb_xram_ack && (wb_xram_be[3] == 1'b1);
//wire rx_qcnt_inc = (cfg_rx_buf_qbase_addr == wb_xram_adr[15:6]) && wb_xram_stb && wb_xram_wr  && wb_xram_ack && (wb_xram_be[3] == 1'b1);
//wire rx_qcnt_dec = (cfg_rx_buf_qbase_addr == wb_xram_adr[15:6]) && wb_xram_stb && !wb_xram_wr && wb_xram_ack && (wb_xram_be[3] == 1'b1);

//-------------------------------------------
// GMAC core instantiation
//-------------------------------------------

g_mac_top u_eth_dut (

          .scan_mode                    ( 1'b0               ), 
          .s_reset_n                    ( reset_n            ), 
          .tx_reset_n                   ( reset_n            ),
          .rx_reset_n                   ( reset_n            ),
          .reset_mdio_clk_n             ( reset_n            ),
          .app_reset_n                  ( reset_n            ),

        // Reg Bus Interface Signal
          .reg_cs                       ( wbs_grg_stb_i         ),
          .reg_wr                       ( wbs_grg_we_i          ),
          .reg_addr                     ( wbs_grg_adr_i[5:2]    ),
          .reg_wdata                    ( wbs_grg_dat_i         ),
          .reg_be                       ( wbs_grg_sel_i         ),

           // Outputs
          .reg_rdata                    ( wbs_grg_dat_o         ),
          .reg_ack                      ( wbs_grg_ack_o         ),


          .app_clk                      ( app_clk               ),

          // Application RX FIFO Interface
          .app_txfifo_wren_i            ( app_txfifo_wren_i     ),
          .app_txfifo_wrdata_i          ( app_txfifo_wrdata_i   ),
          .app_txfifo_full_o            ( app_txfifo_full_o     ),
          .app_txfifo_afull_o           ( app_txfifo_afull_o    ),
          .app_txfifo_space_o           (                      ),

          // Application TX FIFO Interface
          .app_rxfifo_rden_i            ( app_rxfifo_rden_i     ),
          .app_rxfifo_empty_o           ( app_rxfifo_empty_o    ),
          .app_rxfifo_aempty_o          ( app_rxfifo_aempty_o   ),
          .app_rxfifo_cnt_o             (                       ),
          .app_rxfifo_rdata_o           ( app_rxfifo_rddata_o   ),
          .app_rxfifo_addr              ( app_rxfifo_addr       ),

          .app_rx_desc_req              ( app_rx_desc_req       ),
          .app_rx_desc_ack              ( app_rx_desc_ack       ),
          .app_rx_desc_discard          ( app_rx_desc_discard   ),
          .app_rx_desc_data             ( app_rx_desc_data      ),

          // Line Side Interface TX Path
          .phy_tx_en                    ( phy_tx_en             ),
          .phy_tx_er                    ( phy_tx_er             ),
          .phy_txd                      ( phy_txd               ),
          .phy_tx_clk                   ( phy_tx_clk            ),

          // Line Side Interface RX Path
          .phy_rx_clk                   ( phy_rx_clk            ),
          .phy_rx_er                    ( phy_rx_er             ),
          .phy_rx_dv                    ( phy_rx_dv             ),
          .phy_rxd                      ( phy_rxd               ),
          .phy_crs                      ( phy_crs               ),

          //MDIO interface
          .mdio_clk                     ( mdio_clk              ),
          .mdio_in                      ( mdio_in               ),
          .mdio_out_en                  ( mdio_out_en           ),
          .mdio_out                     ( mdio_out              ),

          // QCounter
          .rx_buf_qbase_addr            ( cfg_rx_qbase_addr     ),
          .tx_buf_qbase_addr            ( cfg_tx_qbase_addr     ),

          .tx_qcnt_inc                  ( mac_tx_qcnt_inc       ),
          .tx_qcnt_dec                  ( mac_tx_qcnt_dec       ),
          .rx_qcnt_inc                  ( mac_rx_qcnt_inc       ),
          .rx_qcnt_dec                  ( mac_rx_qcnt_dec       ),
          .tx_qcnt                      ( tx_qcnt               ),
          .rx_qcnt                      ( rx_qcnt               )


       );



//-------------------------------------------------
// GMAX => MEMORY WRITE
//-------------------------------------------------

wb_rd_mem2mem #(.D_WD(32),.BE_WD(4),.ADR_WD(16)) u_wb_gmac_tx (

          .rst_n               ( reset_n            ),
          .clk                 ( app_clk            ),

    // descriptor handshake
          .cfg_desc_baddr      (cfg_tx_qbase_addr    ),
          .desc_q_empty        (tx_q_empty           ),

    // Master Interface Signal
          .mem_full            (app_txfifo_full_o   ),
          .mem_afull           (app_txfifo_afull_o  ),
          .mem_wr              (app_txfifo_wren_i   ), 
          .mem_din             (app_txfifo_wrdata_i ),
 
    // Slave Interface Signal
          .wbo_dout            ( wbm_gtx_dat_i      ),
          .wbo_ack             ( wbm_gtx_ack_i      ),
          .wbo_addr            ( wbm_gtx_adr_o      ),
          .wbo_be              ( wbm_gtx_sel_o      ),
          .wbo_we              ( wbm_gtx_we_o       ),
          .wbo_stb             ( wbm_gtx_stb_o      ), 
          .wbo_cyc             ( wbm_gtx_cyc_o      ), 
          .wbo_err             ( 1'b0               ),
          .wbo_rty             ( 1'b0               )
         );


wb_wr_mem2mem #(.D_WD(32),.BE_WD(4),.ADR_WD(16)) u_wb_gmac_rx(

          .rst_n               ( reset_n      ), 
          .clk                 ( app_clk      ),


    // Master Interface Signal
          .mem_addr            (app_rxfifo_addr       ),
          .mem_empty           (app_rxfifo_empty_o    ),
          .mem_aempty          (app_rxfifo_aempty_o   ),
          .mem_rd              (app_rxfifo_rden_i     ), 
          .mem_dout            (app_rxfifo_rddata_o[7:0]),
          .mem_eop             (app_rxfifo_rddata_o[8]),
 
          .cfg_desc_baddr      (cfg_rx_qbase_addr     ),
          .desc_req            (app_rx_desc_req       ),
          .desc_ack            (app_rx_desc_ack       ),
          .desc_disccard       (app_rx_desc_discard   ),
          .desc_data           (app_rx_desc_data      ),
    // Slave Interface Signal
          .wbo_din             ( wbm_grx_dat_o   ), 
          .wbo_addr            ( wbm_grx_adr_o   ), 
          .wbo_be              ( wbm_grx_sel_o   ), 
          .wbo_we              ( wbm_grx_we_o    ), 
          .wbo_ack             ( wbm_grx_ack_i   ),
          .wbo_stb             ( wbm_grx_stb_o   ), 
          .wbo_cyc             ( wbm_grx_cyc_o   ), 
          .wbo_err             ( 1'b0            ),
          .wbo_rty             ( 1'b0            )
         );


endmodule
