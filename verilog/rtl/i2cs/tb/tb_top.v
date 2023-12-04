
`include "timescale.v"
module tb_top ();

// Set the REGISTER INTERFACE, BUS WIDTH HERE
parameter RDW     = 32;
parameter RDB     = RDW/8;
parameter RDBC    = (RDB/2 == 0) ? 1 : RDB/2;
//-------------------------------------

parameter P_SYS  = 10;     //    100MHz

// General
reg            RESETN;



// TB signals
integer        i, j, k;
integer        ErrCnt;


// I2C Parameter decleration
parameter PRER_LO = 8'b000;
parameter PRER_HI = 8'b001;
parameter CTR     = 8'b010;
parameter RXR     = 8'b011;
parameter TXR     = 8'b011;
parameter CR      = 8'b100;
parameter SR      = 8'b100;

parameter TXR_R   = 8'b101; // undocumented / reserved output
parameter CR_R    = 8'b110; // undocumented / reserved output

parameter RD      = 1'b1;
parameter WR      = 1'b0;
parameter SADR    = 7'b0010_000;


reg  [RDW-1:0] memory[63:0];




/////////////////////////////////////////////////////////////////////////
// DUT Instantiation
/////////////////////////////////////////////////////////////////////////
//
// wires

reg sys_clk;

//RegBank
wire       WrEn; // 1- Write, 0 - Read
wire [7:0] RdWrAdd;
wire [RDW-1:0] WrData;
wire [RDW-1:0] RdData;


initial sys_clk = 0;

always #(P_SYS/2) sys_clk = !sys_clk;

wire  scl_pad_i,scl_pad_o,scl_padoen_o,sda_pad_i,sda_pad_o,sda_padoen_o;

// create i2c lines
	delay m0_scl (scl_padoen_o ? 1'bz : scl_pad_o, scl),
	      m0_sda (sda_padoen_o ? 1'bz : sda_pad_o, sda);

pullup p1(scl); // pullup scl line
pullup p2(sda); // pullup sda line




i2cs_top   #(.RDW(RDW)) u_core     (
                   .ResetN   (RESETN),
	           .Clk      (sys_clk),

      // I2C Slave
                   .scl_pad_i    (scl), 
                   .scl_pad_o    (scl_pad_o),
                   .scl_padoen_o (scl_padoen_o),
                   .sda_pad_i    (sda),
                   .sda_pad_o    (sda_pad_o),
                   .sda_padoen_o (sda_padoen_o),

                   .A2(1'b0),
                   .A1(1'b0),
                   .A0(1'b0),

                    //RegBank
                    .WrEn(WrEn),
                    .RdWrAdd(RdWrAdd),
                    .WrData(WrData),
                    .RdData(RdData)



    );

	// hookup i2c master model
    i2c_master_model tb_i2c_master (
                .reset_n(RESETN),
		.i2c_clk(scl),
		.i2c_data(sda)
	);

reg [63:0] dpattern; // data pattern
/////////////////////////////////////////////////////////////////////////
// Test Case
/////////////////////////////////////////////////////////////////////////

initial begin //{
  ErrCnt    = 0;

  RESETN    = 1'h1;


  // Applying reset
  RESETN    = 1'h0;
  #100;
  // Releasing reset
  RESETN    = 1'h1;
  #1000;

  tb_i2c_master.i2c_set_mode(1'b1); // Set Master Mode
  tb_i2c_master.i2c_set_portaddr(10'h60);

 if(RDW == 8) begin
     $display("\n\n #####################################");
     $display ("   Testing One byte Write and Read Test ");
     $display("\n\n #####################################");
     dpattern = 0;
     for(i = 0; i < 64; i = i +2) begin
        dpattern = dpattern+8'h11;
        tb_i2c_master.wr_byte (i, dpattern[7:0]);
     end
     dpattern = 0;
     for(i = 0; i < 64; i = i +2) begin
        dpattern = dpattern+8'h11;
        tb_i2c_master.rd_byte (i, dpattern[7:0]);
     end
  end
 if(RDW == 16) begin
     $display("\n\n #####################################");
     $display ("   Testing One word Write and Read Test ");
     $display("\n\n #####################################");
     dpattern = 0;
     for(i = 0; i < 64; i = i +2) begin
        dpattern = dpattern+16'h1122;
        tb_i2c_master.wr_word (i, dpattern[15:0]);
     end
     dpattern = 0;
     for(i = 0; i < 64; i = i +2) begin
        dpattern = dpattern+16'h1122;
        tb_i2c_master.rd_word (i, dpattern[15:0]);
     end
  end
 if(RDW == 32) begin
     $display("\n\n #####################################");
     $display ("   Testing double word Write and Read Test ");
     $display("\n\n #####################################");

     dpattern = 0;
     for(i = 0; i < 64; i = i +4) begin
        dpattern = dpattern+32'h11223344;
        tb_i2c_master.wr_dword (i, dpattern[31:0]);
     end
     dpattern = 0;
     for(i = 0; i < 64; i = i +4) begin
      dpattern = dpattern+32'h11223344;
      tb_i2c_master.rd_dword (i, dpattern[31:0]);
     end
  end

  $display("\n\n #####################################");
  $display ("   Testing quard word Write and Read Test ");
  $display("\n\n #####################################");

  dpattern = 0;
  for(i = 0; i < 64; i = i +8) begin
     dpattern = dpattern+64'h1122334455667788;
     tb_i2c_master.wr_qword (i, dpattern[63:0]  );
  end
  dpattern = 0;
  for(i = 0; i < 64; i = i +8) begin
     dpattern = dpattern+64'h1122334455667788;
     tb_i2c_master.rd_qword (i, dpattern[63:0]);
  end

  if (ErrCnt !== 0  || tb_i2c_master.err_cnt != 0) begin //{
    $display ("\n\n #############################################");
    $display ("            Total Error : %d",ErrCnt+tb_i2c_master.err_cnt);
    $display ("            ERROR : TEST FAILED");
    $display (" #################################################\n\n");
  end //}
  else begin //{
    $display ("\n\n #############################################");
    $display ("            STATUS : TEST PASSED");
    $display (" #################################################\n\n");
  end //}
    
  $finish;
end //}


assign RdData = memory[RdWrAdd[5:RDBC]];


always @(posedge WrEn) begin
  memory[RdWrAdd[5:RDBC]] <= WrData;
end


/////////////////////////////////////////////////////////////////////////
// SPI read/write
/////////////////////////////////////////////////////////////////////////


// VCD DUMP

	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("simx.vcd");
	   	$dumpvars(0, tb_top);
	   end
       `endif



endmodule // tb_top


module delay (in, out);
  input  in;
  output out;

  assign out = in;

  specify
    (in => out) = (600,600);
  endspecify
endmodule

