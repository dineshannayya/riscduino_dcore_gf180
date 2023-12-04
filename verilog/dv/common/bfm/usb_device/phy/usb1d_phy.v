/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB 1.1 PHY                                                ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/usb_phy/   ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: usb_phy.v,v 1.4 2003-10-21 05:58:40 rudi Exp $
//
//  $Date: 2003-10-21 05:58:40 $
//  $Revision: 1.4 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.3  2003/10/19 17:40:13  rudi
//               - Made core more robust against line noise
//               - Added Error Checking and Reporting
//               (See README.txt for more info)
//
//               Revision 1.2  2002/09/16 16:06:37  rudi
//               Changed top level name to be consistent ...
//
//               Revision 1.1.1.1  2002/09/16 14:26:59  rudi
//               Created Directory Structure
//
//
//
//
//
//
//
//


module usb1d_phy(clk, rstn, phy_tx_mode, usb_rst,
	
		// Transciever Interface
		txdp, txdn, txoe,	
		rxd, rxdp, rxdn,

		// UTMI Interface
		DataOut_i, TxValid_i, TxReady_o, RxValid_o,
		RxActive_o, RxError_o, DataIn_o, LineState_o
		);


/***************************************
*  Comman Signal
*  *************************************/
input		clk              ; // 48Mhz clock
input		rstn              ; // Active low async reset

input		phy_tx_mode      ; // Used in Tx Path,
                                   // The PHY supports single ended and differential output to the
                                   // transceiver Depending on which device you are using, you have
                                   // to tie the phy_tx_mode high or low. 
output		usb_rst          ; // usb_rst is asserted whenever the host signals reset on the USB bus.
                                   // The USB core will internally reset itself automatically.
                                   // This output is provided for external logic that needs to be
                                   // reset when the USB bus is reset.

output		txdp, txdn, txoe;
input		rxd, rxdp, rxdn;
input	[7:0]	DataOut_i;
input		TxValid_i;
output		TxReady_o;
output	[7:0]	DataIn_o;
output		RxValid_o;
output		RxActive_o;
output		RxError_o;
output	[1:0]	LineState_o;

///////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//

reg	[4:0]	rst_cnt;
reg		usb_rst;
wire		fs_ce;
wire		rstn;

///////////////////////////////////////////////////////////////////
//
// Misc Logic
//

///////////////////////////////////////////////////////////////////
//
// TX Phy
//

usb1d_tx_phy i_tx_phy(
	.clk(		clk		),
	.rstn(		rstn		),
	.fs_ce(		fs_ce		),
	.phy_mode(	phy_tx_mode	),

	// Transciever Interface
	.txdp(		txdp		),
	.txdn(		txdn		),
	.txoe(		txoe		),

	// UTMI Interface
	.DataOut_i(	DataOut_i	),
	.TxValid_i(	TxValid_i	),
	.TxReady_o(	TxReady_o	)
	);

///////////////////////////////////////////////////////////////////
//
// RX Phy and DPLL
//

usb1d_rx_phy i_rx_phy(
	.clk(		clk		),
	.rstn(		rstn		),
	.fs_ce(		fs_ce		),

	// Transciever Interface
	.rxd(		rxd		),
	.rxdp(		rxdp		),
	.rxdn(		rxdn		),

	// UTMI Interface
	.DataIn_o(	DataIn_o	),
	.RxValid_o(	RxValid_o	),
	.RxActive_o(	RxActive_o	),
	.RxError_o(	RxError_o	),
	.RxEn_i(	txoe		),
	.LineState(	LineState_o	)
	);

///////////////////////////////////////////////////////////////////
//
// Generate an USB Reset is we see SE0 for at least 2.5uS
//

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rstn)
`else
always @(posedge clk)
`endif
	if(!rstn)			rst_cnt <= 5'h0;
	else
	if(LineState_o != 2'h0)		rst_cnt <= 5'h0;
	else	
	if(!usb_rst && fs_ce)		rst_cnt <= rst_cnt + 5'h1;

always @(posedge clk)
	usb_rst <= (rst_cnt == 5'h1f);

endmodule

