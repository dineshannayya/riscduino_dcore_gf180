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
/*
**---------------------------------------------------------------------
** Title         : I2C Slave
**---------------------------------------------------------------------
** File          : i2c_slave_if.v
** Author        : Dinesh Annayya
** Created       : 
** Last modified : 
** Upper Modules/file instantiating this module:
**
**---------------------------------------------------------------------
** Description : This module implements serial I2C interface
**
**
** Modification history :
**
**
**
**--------------------------------------------------------------------
*/


module i2cs_top (
                    //General
                    Clk,
                    ResetN,
                    //I2C
                    scl_pad_i,
                    scl_pad_o,
                    scl_padoen_o,
                    sda_pad_i,
                    sda_pad_o, 
                    sda_padoen_o,
                    A2,
                    A1,
                    A0,
                    //

             //Reg Interface
                    WrEn        , // write request
                    RdWrAdd     , // address
                    WrData      , // write data
                    RdData      // read data

            );



parameter I2C_ADDR_MSB = 4'hC;
parameter RAW          = 8;     // REGISTER ADDRESS WIDTH 
parameter RDW          = 16;    // REGISTER DATA WIDTH 

parameter RAB          = RAW/8; // REGISTER ADDR BYTE = RAW/8
parameter RDB          = RDW/8; // REGISTER DATA BYTE = RDW/8

// Shift register width computation, find whether address or data width is more.
parameter SW           = (RAW > RDW) ? RAW : RDW; 

parameter RABC         = (RAB/2 == 0) ? 1 : RAB/2; // REGISTER ADDRESS BYTE COUNT
parameter RDBC         = (RDB/2 == 0) ? 1 : RDB/2; // REGISTER DATA BYTE COUNT
//--------------------------------------------------------------
// Global Varable
// -------------------------------------------------------------
input        Clk             ; // system clock
input        ResetN          ; // system reset

//--------------------------------------------------------------
//  I2C Interface
// -------------------------------------------------------------
input           scl_pad_i       ; // I2C Clock Input
output          scl_padoen_o    ; // I2C Clock Pad DIr Select, Active Low
output          scl_pad_o       ; // I2C Clock Output
input           sda_pad_i       ; // I2C Data Input
output          sda_pad_o       ; // I2C Data Output
output          sda_padoen_o    ; // I2C DATA Pad Dir Select, Active Low
input           A2              ; // I2C Address0
input           A1              ; // I2C Address1
input           A0              ; // I2C Address0

//--------------------------------------------------------------
// Register Master  interface
//--------------------------------------------------------------
output          WrEn            ; // write request
output[RAW-1:0] RdWrAdd          ; // address
output[RDW-1:0] WrData          ; // write data
input [RDW-1:0] RdData          ; // read data


// wire and reg declaration
reg  [RDW-1:0]  WrData             ; // write data
reg  [RAW-1:0]  RdWrAdd                ; // address
reg             WrEn              ; // write request
reg             sda_padoen_o;
reg    [2:0]    CurrentState;
reg    [2:0]    NextState;
reg  [SW-1:0]   ShiftReg;
reg             Invalid;
reg    [3:0]    BitCnt; // Bit Counter
reg  [RABC-1:0] AByteCnt; // Address Byte Counter
reg  [RDBC-1:0] DByteCnt; // Data Byte Counter
reg             RdWr;
reg             Start;
reg             Stop;
reg  [RDW-1:0]  RegRdData; 
reg             SdaReg;
reg             SclReg;
reg             ClearTstBit;
wire            NSdaPulse;
wire            PSdaPulse;
wire            NSclPulse;
wire            PSclPulse;
reg             Sda;
reg             Scl;
reg             D1Scl;
reg             D1Sda;
reg             AddrPhase;
reg             WrPhase  ;
reg             RdPhase  ;
reg             AddrInc  ;
reg             AddrInc_d;
wire   [6:0]    SlaveAdd;

parameter IDLE        = 3'b000;
parameter SLAVEID     = 3'b001;
parameter SENDACK     = 3'b010;
parameter RECVDATA    = 3'b011; 
parameter SENDDATA    = 3'b100;
parameter RECVACK     = 3'b101; 


///////////////////////////////////////////////////////////////////////////////////////////////
//                  SLAVE ADDRESS
///////////////////////////////////////////////////////////////////////////////////////////////

assign SlaveAdd = {I2C_ADDR_MSB,A2,A1,A0};     

///////////////////////////////////////////////////////////////////////////////////////////////
//                             FSM
///////////////////////////////////////////////////////////////////////////////////////////////
always @ ( CurrentState or Start or Stop or BitCnt or Invalid or
           NSclPulse or PSclPulse or Sda or RdWr )begin //{ 

  NextState  = CurrentState;
  case (CurrentState) //{
    IDLE : begin//{
      if (Start) 
         NextState = SLAVEID;
      else 
         NextState = IDLE; 
    end //}
    
    SLAVEID : begin//{
      if (Invalid)
         NextState = IDLE; 
      else if ((BitCnt == 4'b1000) & (NSclPulse)) begin
         NextState = SENDACK;
      end 
    end //}
    
    SENDACK :  begin//{
      if(Start)
         NextState = SLAVEID; 
      else if (NSclPulse) begin //{ If ACK Send
         if(RdWr) NextState = SENDDATA;
         else     NextState =  RECVDATA; 
      end//}  
      else NextState = SENDACK;
    end //}

    RECVDATA : begin//{
      if (Stop)
        NextState = IDLE;
      else if(Start)
        NextState = SLAVEID;
      else if((BitCnt == 4'b1000) & (NSclPulse)) 
        NextState = SENDACK;
      else 
        NextState = RECVDATA;
    end //}

    SENDDATA : begin//{
      if(Start)
        NextState = SLAVEID;        
      else if ((BitCnt == 4'b1000) & (NSclPulse))
        NextState = RECVACK;
      else 
        NextState = SENDDATA;
    end //}

    RECVACK : begin//{
     if(Start)
        NextState = SLAVEID; 
     else if (PSclPulse & Sda) // If NACK Recive, the abort the transaction
        NextState = IDLE;
      else if(NSclPulse) 
       NextState = SENDDATA;
      else 
        NextState = RECVACK;
    end //}

  default : NextState = IDLE; 
  endcase//} 

end //}

always @ (negedge ResetN or posedge Clk) begin //{
  if (!ResetN)
    CurrentState <= IDLE;
  else
    CurrentState <= NextState;
end //}

////////////////////////////////////////////////////////////////////////////////////////
//   Syncronising Sda ,Scl with master clock.  On detection of both the edges
//   creat pulse.
///////////////////////////////////////////////////////////////////////////////////////

always @ (negedge ResetN or posedge Clk) begin //{
  if (!ResetN) begin //{
    SdaReg <= 1'b1;  // Start up assuming quiescent state of inputs
    SclReg <= 1'b1;  // Start up assuming quiescent state of inputs     
    Sda <= 1'b1;
    Scl <= 1'b1;
    D1Sda <= 1'b0;
    D1Scl <= 1'b0;
  end//}
  else begin //{
    SdaReg <= sda_pad_i; 
    SclReg <= scl_pad_i;
    
    if ({SdaReg,sda_pad_i} == 2'b11)
      Sda <= 1'b1;
    else if ({SdaReg,sda_pad_i} ==2'b00)
      Sda <= 1'b0;
    if ({SclReg,scl_pad_i} ==2'b11)
      Scl <= 1'b1;
    else if ({SclReg,scl_pad_i} ==2'b00)
      Scl <= 1'b0;
    D1Sda <= Sda; 
    D1Scl <= Scl; 
  end //}
end//}

assign NSdaPulse = (D1Sda & (~Sda)); 
assign PSdaPulse = ((~D1Sda) & Sda);
assign NSclPulse = (D1Scl & (~Scl)); 
assign PSclPulse = ((~D1Scl) & Scl);

/////////////////////////////////////////////////////////////////////////////////////////
//    Detecting Start and Stop Conditions
/////////////////////////////////////////////////////////////////////////////////////////
always @ (negedge ResetN or posedge Clk) begin //{
  if (!ResetN)
    Start <= 1'b0;
  else if (Scl & D1Scl & NSdaPulse)
      Start <= 1'b1;
  else 
      Start <= 1'b0;
end //}

always @ (negedge ResetN or posedge Clk) begin //{
  if (!ResetN)
    Stop <= 1'b0;
  else if (Scl & D1Scl & PSdaPulse)
    Stop <= 1'b1;
  else 
      Stop <= 1'b0;  
end //}


always @ (negedge ResetN or posedge Clk) begin //{
   if (!ResetN) begin // {
      AddrPhase    <= 0;
      WrPhase      <= 0;
      RdPhase      <= 0;
      AddrInc      <= 0;
   end // }
   else if ((CurrentState == IDLE) || Start || Stop) begin // {
        AddrPhase    <= 0;
        WrPhase      <= 0;
        RdPhase      <= 0;
        AddrInc      <= 0;
   end // }
   else begin // {
       if(PSclPulse ) begin // {
	   // Read Phase handling , 
	   if(RdWr) begin // {
              if(CurrentState == SENDACK) begin  // {  Read Phase
                 RdPhase      <= 1;
              end // }
	      else if ((CurrentState == RECVACK) && (DByteCnt == RDB-1) && RdPhase )  begin // {
                 AddrInc      <= 1;
              end  // }
	   end // }
	   else begin // Write Phase {
	      if((!WrPhase) &&  (!AddrPhase) && (CurrentState == SENDACK)) begin  // { End of Slaveid phase
                 AddrPhase <= 1;
              end // }
	      else if ((CurrentState == SENDACK) && (AByteCnt == RAB-1) && AddrPhase )  begin // { End of Address Phase
                 AddrPhase    <= 0;
                 WrPhase      <= 1;
              end // }
	      else if ((CurrentState == SENDACK) && (DByteCnt == RDB-1) && WrPhase )  begin // {
                 AddrInc      <= 1;
              end // }
	   end // }
        end // }
        else begin // {
           AddrInc      <= 0;
        end // }
    end	// }
end // }



always @ (negedge ResetN or posedge Clk) begin //{
  if (!ResetN) 
    AddrInc_d <= 1'b0;
  else 
    AddrInc_d <= AddrInc;
end //}


//////////////////////////////////////////////////////////////////////////////////////
//  Read/Write Access to Reg Arbitor.
/////////////////////////////////////////////////////////////////////////////////////

always @ (negedge ResetN or posedge Clk) begin //{
  if (!ResetN) 
    WrData <= {(RDW){1'b0}};
  else if ((CurrentState == RECVDATA) & (DByteCnt == RDB-1) && (BitCnt == 4'b0111) & (WrPhase) & PSclPulse) 
    WrData <= {ShiftReg[RDW-2:0],Sda};
end //}

always @ (negedge ResetN or posedge Clk) begin //{
  if (!ResetN) 
     WrEn <= 1'b0;
  else if ((CurrentState == RECVDATA) & (DByteCnt == RDB-1) && (BitCnt == 4'b0111) & (WrPhase) & PSclPulse) 
     WrEn <= 1'b1;
  else 
     WrEn <= 1'b0;
end //}


//assign RdWrAdd = ShiftReg ; 
always @ (negedge ResetN or posedge Clk) begin //{
  if (!ResetN) 
    RdWrAdd <= {(RAW) {1'b0}};
  else if ((CurrentState == RECVDATA) && (BitCnt == 4'b0111) && PSclPulse && AddrPhase )  
    RdWrAdd <= {ShiftReg[RAW-2:0],Sda};
  else if (AddrInc)
        RdWrAdd <= RdWrAdd + RDB; 
end //}     

always @ (negedge ResetN or posedge Clk) begin //{
  if (!ResetN)
    ShiftReg <= {(SW) {1'h0}};
  else if (Start | (CurrentState == IDLE))
    ShiftReg <= {(SW) {1'h0}};
  else if (((CurrentState == SLAVEID)|(CurrentState == RECVDATA)) & PSclPulse)
    ShiftReg <= {ShiftReg[SW-1:0],Sda};
end //}


///////////////////////////////////////////////////////////////////////////////////////////
//  Read Access to Reg Abitor
//////////////////////////////////////////////////////////////////////////////////////////

always @ (negedge ResetN or posedge Clk) begin //{
  if (!ResetN)
    RegRdData <= {(RDW){1'h0}};
  else if (((BitCnt == 4'b1000) && NSclPulse && AddrPhase ) || AddrInc_d)
    RegRdData<= RdData;
  else if(((CurrentState == SENDDATA) | ((CurrentState == SENDACK) & RdWr) 
        | (CurrentState == RECVACK)) & NSclPulse & (BitCnt != 4'b1000) & RdPhase) 
    RegRdData <= {RegRdData[RDW-1:0],1'b0};
end //}


///////////////////////////////////////////////////////////////////////////////////////////////////
//   Counter to count Bites 
//////////////////////////////////////////////////////////////////////////////////////////////////
always @ (posedge Clk or negedge ResetN) begin //{
  if (!ResetN) begin
    BitCnt   <= 4'b0000;
  end else begin // {
     // Bit Counter
     if ((((CurrentState == SENDACK) | (CurrentState == RECVACK)) & PSclPulse)|Start|(CurrentState == IDLE))
          BitCnt <= 4'b0000;
     else if ((((CurrentState == SLAVEID)|(CurrentState == RECVDATA)) & PSclPulse)| 
      (((CurrentState == SENDDATA)|(CurrentState == RECVACK)|((CurrentState == SENDACK)& RdWr))& PSclPulse))
          BitCnt  <= BitCnt + 1'b1;
  end // }

end //}  
///////////////////////////////////////////////////////////////////////////////////////////////////
//   Counter to count Address Bytes.
//////////////////////////////////////////////////////////////////////////////////////////////////
always @ (posedge Clk or negedge ResetN) begin //{
  if (!ResetN) begin
    AByteCnt  <= {(RABC) {1'b0}};
  end else begin // {
    // Byte Counter
     if((CurrentState == SLAVEID) && PSclPulse)
          AByteCnt <= {(RABC) {1'b0}};
     else if((CurrentState == SENDACK) && (AddrPhase) && PSclPulse)
          AByteCnt <=  AByteCnt + 1;
  end // }
end //}  

///////////////////////////////////////////////////////////////////////////////////////////////////
//   Counter to count Data Bytes.
//////////////////////////////////////////////////////////////////////////////////////////////////
always @ (posedge Clk or negedge ResetN) begin //{
  if (!ResetN) begin
    DByteCnt  <= {(RDBC) {1'b0}};
  end else begin // {
    // Byte Counter
     if((CurrentState == SLAVEID) && PSclPulse)
          DByteCnt <= {(RDBC) {1'b0}};
     else if((((CurrentState == SENDACK) && (WrPhase)) || 
	     ((CurrentState == RECVACK) && RdPhase)) && PSclPulse)
          DByteCnt <=  DByteCnt + 1;
  end // }
end //}  


//////////////////////////////////////////////////////////////////////////////////////////////////////
//   Check Conditions.... (Slave Address) and  (red or write cycle)
/////////////////////////////////////////////////////////////////////////////////////////////////////

always @ (negedge ResetN or posedge Clk) begin //{
  if (!ResetN)
    Invalid <= 1'b0;
  else if ((CurrentState == SLAVEID) & (BitCnt == 4'b0111) & (ShiftReg[6:0] != SlaveAdd)) 
       Invalid <= 1'b1;
  else
       Invalid <= 1'b0; 
end //}

always @ (negedge ResetN or posedge Clk) begin //{
  if (!ResetN)
    RdWr <= 1'b0;
  else if (Start | Stop)
    RdWr <= 1'b0;
  else if ((CurrentState == SLAVEID) & (BitCnt == 4'b0111) & Sda & PSclPulse) 
    RdWr <= 1'b1;
end //}  

///////////////////////////////////////////////////////////////////////////////////////////
//   Driving Sda line.. Tristate Buffer.
//////////////////////////////////////////////////////////////////////////////////////////

always @ (negedge ResetN or posedge Clk) begin //{
  if (!ResetN) 
      sda_padoen_o  <= 1'b1;
  else if ( Invalid && (CurrentState == SLAVEID) && (BitCnt == 4'b1000) && NSclPulse) // Send NAck on at the end of InValid SlaveId
      sda_padoen_o <= 1'b1; // Send NACK
  else if ( !Invalid && (CurrentState == SLAVEID) && (BitCnt == 4'b1000) && NSclPulse) // Send Ack on at the end of SlaveId
      sda_padoen_o <= 1'b0; // Send ACK
  else if ((CurrentState == RECVDATA) && (BitCnt == 4'b1000) && NSclPulse) // Address/Write Data Phase
      sda_padoen_o <= 1'b0; // Send Ack 
  else if (((CurrentState == SENDDATA) | ((CurrentState == SENDACK& RdWr))
      |(CurrentState == RECVACK)) & (BitCnt != 4'b1000) & NSclPulse & RdPhase) 
      sda_padoen_o  <= RegRdData[RDW-1];
  else if (NSclPulse) 
      sda_padoen_o  <= 1'b1;
end //}

assign sda_pad_o     = 1'b0; 
assign scl_padoen_o     = 1'b1;
assign scl_pad_o     = 1'b0;



endmodule 

