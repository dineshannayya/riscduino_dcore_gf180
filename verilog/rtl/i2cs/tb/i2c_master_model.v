//==============================================================================
// Author      : Dinesh Annayya
//==============================================================================
/////////////////////////////////////
//   I2C BFM LOGIC
// Supports
//  1. 8 addressing
//  2. 10 bit extended addressing
//  3. i2c read task
//  4. i2c write task
/////////////////////////////////////


`include "timescale.v"
module i2c_master_model (
              reset_n,
              i2c_clk,
              i2c_data
            );

parameter CLK_WIDTH = 10000;

input   reset_n;
inout   i2c_clk;
inout   i2c_data;

reg     i2c_mode; // 0 -> slave mode
                  // 1 -> master mode
reg     i2c_data_oen;
reg     i2c_clk_oen;
reg     bus_idle;
reg [6:0] i2c_portaddr;
event       error_detected;
integer     err_cnt;
reg         error_ind;


always @error_detected begin
  error_ind = 1;
  err_cnt = err_cnt + 1;
end

wire    i2c_clk =   (i2c_mode && (i2c_clk_oen ==0)) ?  1'b0 : 1'bz ;
wire    i2c_data =  (i2c_data_oen == 0) ? 1'b0:  1'bz;

initial
begin
   i2c_mode = 0;
   i2c_data_oen = 1;
   i2c_clk_oen = 1;
   i2c_portaddr = 0;
   err_cnt = 0;
end

// Detect bus idle
always @(i2c_clk or i2c_data)
begin
  bus_idle = i2c_clk & i2c_data;
end

// Check the bus is idle
task CheckBusIdle;
begin
  if (!bus_idle) begin
    $display ("**ERROR: Bus is not idle");
    -> error_detected;
    end
end
endtask
task i2c_set_mode;
input mode;
begin
   i2c_mode = mode;
end
endtask

task i2c_set_portaddr;
input [6:0] addr;
begin
   i2c_portaddr = addr;
end
endtask
//-----------------------------------------------------------
// i2c master write address
// task i2c_master_write_port_addr (port_id,extended_mode);
//-----------------------------------------------------------

task send_addr;
input [9:0]  port_id;
input        extended_mode;
input        rd_wr_n; // '0' -> write access; '1' -> read access
reg   [7:0]  temp;
begin
   
   $display("STATUS: I2C write Port Address -> Address : %x ",port_id);

   // keep 2 cycle i2c clock high
   #CLK_WIDTH   i2c_clk_oen  = 1; i2c_data_oen = 1;
   #CLK_WIDTH   i2c_clk_oen  = 1; i2c_data_oen = 1;
   #CLK_WIDTH   i2c_data_oen = 0; // Start Indication
   #CLK_WIDTH   i2c_clk_oen  = 0;

   // transmit  port id
   for(temp=0; temp < 7; temp = temp+1) begin
     #CLK_WIDTH   i2c_data_oen = port_id[6-temp];
     #CLK_WIDTH   i2c_clk_oen = 1;
     #CLK_WIDTH   i2c_clk_oen = 0;
   end


   // send write/read access indication
     #CLK_WIDTH   i2c_data_oen = rd_wr_n;
     #CLK_WIDTH   i2c_clk_oen = 1;
     #CLK_WIDTH   i2c_clk_oen = 0;

   // Wait Ack from Slave device
     #CLK_WIDTH   i2c_clk_oen = 1; i2c_data_oen = 1;

   if(!i2c_data) begin
      $display("STATUS : Write/Read Ack Received");

    #CLK_WIDTH   i2c_clk_oen = 0; 
 
   // transmit extended address
   if(extended_mode) begin
     #CLK_WIDTH   i2c_data_oen = port_id[7];
     #CLK_WIDTH   i2c_clk_oen  = 1;
     #CLK_WIDTH   i2c_clk_oen  = 0;
     #CLK_WIDTH   i2c_data_oen = port_id[8];
     #CLK_WIDTH   i2c_clk_oen  = 1;
     #CLK_WIDTH   i2c_clk_oen  = 0;
     #CLK_WIDTH   i2c_data_oen = port_id[9];
     #CLK_WIDTH   i2c_clk_oen  = 1;
     #CLK_WIDTH   i2c_clk_oen  = 0;
   end
     
   end
   else begin
      #CLK_WIDTH   i2c_clk_oen = 0; 
      $display("ERROR: No I2C write Ack access received");
      -> error_detected;
   end
     #CLK_WIDTH; 
     #CLK_WIDTH; 
end
endtask

//-----------------------------------------------------------
// send byte
// task send_byte (write_data,retry_cnt);
//-----------------------------------------------------------

task send_byte ;
input [7:0]   write_data   ;
input [3:0]   retry_cnt      ;
reg   [7:0]   temp         ;
reg   [7:0]   cnt          ;
begin
   for(cnt=1; cnt <= retry_cnt; cnt = cnt+1) begin
        $display("STATUS: I2C write Data access -> Data : %x",write_data);
        // transmit Data Here
        for(temp=0; temp < 8; temp = temp+1) begin
          #CLK_WIDTH   i2c_data_oen = write_data[7-temp];
          #CLK_WIDTH   i2c_clk_oen = 1;
          #CLK_WIDTH   i2c_clk_oen = 0;
        end

        // Wait Ack from Slave device
          #CLK_WIDTH   i2c_data_oen = 1;
          #CLK_WIDTH   i2c_clk_oen = 1; 

        if(!i2c_data) begin
           $display("STATUS : Write Ack Received");
           cnt = retry_cnt; // break the loop
        end
        else begin
           if(cnt == retry_cnt) begin
              $display("ERROR: No I2C write Data Ack access received");
              -> error_detected;
           end
      end
   end
     #CLK_WIDTH   i2c_clk_oen = 0; 
     #CLK_WIDTH;
     #CLK_WIDTH;
end
endtask

//-----------------------------------------------------------
// rd_byte
// task receive_byte (port_id,extended_mode,address,read_data);
//-----------------------------------------------------------

task rec_byte;
output [7:0] read_data;
reg   [7:0]  temp;
begin

   i2c_data_oen = 1; 
   for(temp=0; temp < 8; temp = temp+1) begin
     #CLK_WIDTH   i2c_clk_oen = 1;
     #CLK_WIDTH   read_data[7-temp] =i2c_data;
     #CLK_WIDTH   i2c_clk_oen = 0;
   end

   // Send Ack To Slave device
     #CLK_WIDTH   i2c_data_oen = 0;
     #CLK_WIDTH   i2c_clk_oen = 1; 
     #CLK_WIDTH   i2c_clk_oen = 0; 
     #CLK_WIDTH   i2c_data_oen = 1;

     #CLK_WIDTH;
     #CLK_WIDTH;
end
endtask

//-----------------------------------------------------------
// rd_byte
// task receive_byte (port_id,extended_mode,address,read_data);
//-----------------------------------------------------------
// Last Read Access will not have any ack
task rec_byte_noack;
output [7:0] read_data;
reg   [7:0]  temp;
begin

   i2c_data_oen = 1; 
   for(temp=0; temp < 8; temp = temp+1) begin
     #CLK_WIDTH   i2c_clk_oen = 1;
     #CLK_WIDTH   read_data[7-temp] =i2c_data;
     #CLK_WIDTH   i2c_clk_oen = 0;
   end

   // No Ack for the last read access - Important

     #CLK_WIDTH;
     #CLK_WIDTH;
end
endtask

task send_stop;
begin
   #CLK_WIDTH   i2c_data_oen = 0; 
   #CLK_WIDTH   i2c_clk_oen = 1;
   #CLK_WIDTH   i2c_clk_oen = 1;
   #CLK_WIDTH   i2c_data_oen = 1; // STOP indication
   #CLK_WIDTH   i2c_data_oen = 1; // STOP indication
end
endtask

task wr_byte;
input [7:0] addr;
input [7:0] data;
begin

  send_addr(i2c_portaddr,0,0);
  $display("STATUS: I2C write Address : %x  WrData: %x",addr,data);
  send_byte (addr[7:0], 4'h1);
  send_byte (data[7:0], 4'h1);
  send_stop;
end
endtask

task wr_word;
input [7:0] addr;
input [15:0] data;
begin

  send_addr(i2c_portaddr,0,0);
  $display("STATUS: I2C write Address : %x  WrData: %x",addr,data);
  send_byte (addr[7:0], 4'h1);
  send_byte (data[15:8], 4'h1);
  send_byte (data[7:0], 4'h1);
  send_stop;
end
endtask

task wr_dword;
input [7:0] addr;
input [31:0] data;
begin

  send_addr(i2c_portaddr,0,0);
  $display("STATUS: I2C write Address : %x  WrData: %x",addr,data);
  send_byte (addr[7:0], 4'h1);
  send_byte (data[31:24], 4'h1);
  send_byte (data[23:16], 4'h1);
  send_byte (data[15:8], 4'h1);
  send_byte (data[7:0], 4'h1);
  send_stop;
end
endtask

task wr_qword;
input [7:0] addr;
input [63:0] data;
begin

  send_addr(i2c_portaddr,0,0);
  $display("STATUS: I2C write Address : %x  WrData: %x",addr,data);
  send_byte (addr[7:0], 4'h1);
  send_byte (data[63:56], 4'h1);
  send_byte (data[55:48], 4'h1);
  send_byte (data[47:40], 4'h1);
  send_byte (data[39:32], 4'h1);
  send_byte (data[31:24], 4'h1);
  send_byte (data[23:16], 4'h1);
  send_byte (data[15:8], 4'h1);
  send_byte (data[7:0], 4'h1);
  send_stop;
end
endtask

task rd_byte;
input  [7:0] addr;
input [7:0]  exp_data;
reg    [7:0] data;
begin

  send_addr(i2c_portaddr,0,0);
  send_byte (addr[7:0], 4'h1);
  send_stop;
  send_addr(i2c_portaddr,0,1);
  rec_byte_noack (data[7:0]);

  if(exp_data !== data) begin
     $display("ERRO: I2C Read Address : %x  Exp Data: %x Rxd Data: %x",addr,exp_data,data);
    -> error_detected;
  end else
    $display("STATUS: I2C Read Address : %x  Data: %x",addr,data);

  send_stop;
end
endtask

task rd_word;
input  [7:0] addr;
input [15:0]  exp_data;
reg    [15:0] data;
begin

  send_addr(i2c_portaddr,0,0);
  send_byte (addr[7:0], 4'h1);
  send_stop;
  send_addr(i2c_portaddr,0,1);
  rec_byte (data[15:8]);
  rec_byte_noack(data[7:0]);

  if(exp_data !== data) begin
     $display("ERRO: I2C Read Address : %x  Exp Data: %x Rxd Data: %x",addr,exp_data,data);
    -> error_detected;
  end else
    $display("STATUS: I2C Read Address : %x  Data: %x",addr,data);

  send_stop;
end
endtask


task rd_dword;
input  [7:0] addr;
input [31:0]  exp_data;
reg    [31:0] data;
begin

  send_addr(i2c_portaddr,0,0);
  send_byte (addr[7:0], 4'h2);
  send_stop;
  send_addr(i2c_portaddr,0,1);
  rec_byte (data[31:24]);
  rec_byte (data[23:16]);
  rec_byte (data[15:8]);
  rec_byte_noack (data[7:0]);

  if(exp_data !== data) begin
     $display("ERRO: I2C Read Address : %x  Exp Data: %x Rxd Data: %x",addr,exp_data,data);
    -> error_detected;
  end else
    $display("STATUS: I2C Read Address : %x  Data: %x",addr,data);

  send_stop;
end
endtask

task rd_qword;
input  [7:0] addr;
input [63:0]  exp_data;
reg    [63:0] data;
begin

  send_addr(i2c_portaddr,0,0);
  send_byte (addr[7:0], 4'h2);
  send_stop;
  send_addr(i2c_portaddr,0,1);
  rec_byte (data[63:56]);
  rec_byte (data[55:48]);
  rec_byte (data[47:40]);
  rec_byte (data[39:32]);
  rec_byte (data[31:24]);
  rec_byte (data[23:16]);
  rec_byte (data[15:8]);
  rec_byte_noack (data[7:0]);

  if(exp_data !== data) begin
     $display("ERRO: I2C Read Address : %x  Exp Data: %x Rxd Data: %x",addr,exp_data,data);
    -> error_detected;
  end else
    $display("STATUS: I2C Read Address : %x  Data: %x",addr,data);

  send_stop;
end
endtask
task rd_byte_nc;
input  [7:0] addr;
output [7:0] data;
reg    [7:0] data;
begin

  send_addr(i2c_portaddr,0,0);
  send_byte (addr[7:0], 4'h1);
  send_stop;
  send_addr(i2c_portaddr,0,1);
  rec_byte_noack (data[7:0]);

  $display("STATUS: I2C Read Address : %x  Data: %x",addr,data);
  send_stop;
end

endtask
task rd_word_nc;
input  [7:0] addr;
output [15:0] data;
reg    [15:0] data;
begin

  send_addr(i2c_portaddr,0,0);
  send_byte (addr[7:0], 4'h1);
  send_stop;
  send_addr(i2c_portaddr,0,1);
  rec_byte (data[15:8]);
  rec_byte_noack (data[7:0]);

  $display("STATUS: I2C Read Address : %x  Data: %x",addr,data);
  send_stop;
end
endtask

task rd_dword_nc;
input  [7:0] addr;
output [31:0] data;
reg    [31:0] data;
begin

  send_addr(i2c_portaddr,0,0);
  send_byte (addr[7:0], 4'h1);
  send_stop;
  send_addr(i2c_portaddr,0,1);
  rec_byte (data[31:24]);
  rec_byte (data[23:16]);
  rec_byte (data[15:8]);
  rec_byte_noack (data[7:0]);

  $display("STATUS: I2C Read Address : %x  Data: %x",addr,data);
  send_stop;
end
endtask

task rd_qword_nc;
input  [7:0] addr;
output [63:0] data;
reg    [63:0] data;
begin

  send_addr(i2c_portaddr,0,0);
  send_byte (addr[7:0], 4'h1);
  send_stop;
  send_addr(i2c_portaddr,0,1);
  rec_byte (data[63:56]);
  rec_byte (data[55:48]);
  rec_byte (data[47:40]);
  rec_byte (data[39:32]);
  rec_byte (data[31:24]);
  rec_byte (data[23:16]);
  rec_byte (data[15:8]);
  rec_byte_noack (data[7:0]);

  $display("STATUS: I2C Read Address : %x  Data: %x",addr,data);
  send_stop;
end
endtask
endmodule
             
