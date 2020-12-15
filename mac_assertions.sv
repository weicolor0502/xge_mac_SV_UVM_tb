//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : mac_assertions.sv                                    //
//  Author    : Jiale Wei		                            //
//  Course    : Advanced Verification Methodology (EE8350) 	    //
//  Date      : 12.05.2020
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef MAC_ASSERTIONS__SV
`define MAC_ASSERTIONS__SV

//The clk frequency check can be commented
`define ENABLE_CLK_FREQ_CHECK
module mac_assertions #(parameter PERIOD_156 = 6400,
	parameter PERIOD_XGMII_RX = 6400,
	parameter PERIOD_XGMII_TX = 6400)
	(clk_156m25,
	clk_xgmii_rx,
	clk_xgmii_tx,
	wb_clk_i,
	wb_cyc_i,
	wb_rst_i,
	wb_we_i,
	wb_stb_i,
	wb_ack_o);
input clk_156m25, wb_clk_i;
input clk_xgmii_rx, clk_xgmii_tx;
input wb_rst_i, wb_we_i, wb_stb_i, wb_ack_o, wb_cyc_i;


`ifdef ENABLE_CLK_FREQ_CHECK
  //Assertion to check clock frequency clk_freq
    //Incompatible clk freqency will result in packet loss
    property clk_freq;
    //Define local variable and define the trigger event
    time cur_time;
    @(posedge clk_156m25)
        //Compute the time difference and end the property
	(1, cur_time=$time) |=> ((PERIOD_XGMII_RX==$time-cur_time) && (PERIOD_XGMII_TX==$time-cur_time) );
    endproperty:clk_freq

    //Assert clk_freq and write the display logs for pass/fail reporting
    ap_clk_freq: assert property(clk_freq)
    else 
	$display("Fail: Clock frequency assertion fails at %t", $time);
 
`endif

//Assertion to check wb_ack_o is asserted if wb_stb_i rise in wb_cyc_i
  //Define propery for check wb_ack_o assertion
  property wb_ack_check;
     disable iff(wb_rst_i)
     @(posedge wb_clk_i)
       $rose(wb_stb_i && wb_cyc_i) |-> ##[0:1] $rose(wb_ack_o);
  endproperty:wb_ack_check
  //Assert property for wishbone_acknowledge
  ap_wb_ack_check: assert property(wb_ack_check)
	$display("Pass: Wishbone acknowledge when there is a wishbone communication at %t", $time);
  else
	$display("Fail: Wishbone does not acknowledge when there is a wishbone communication at %t", $time);


//Assertion to check the FIFO status
//Define the generic assertion property for FIFO -- Basically check the overflow and underflow
  property fifo_overflow_check(logic rst_n, logic clk, logic wfull, logic wen);
    disable iff(rst_n)
    @(posedge clk) !(wfull && wen);
  endproperty:fifo_overflow_check
  //Assert property for overflow check
  ap_rxdfifo_over_check:assert property(fifo_overflow_check(xge_mac_dut.rx_data_fifo0.reset_xgmii_rx_n, clk_156m25, xge_mac_dut.rx_data_fifo0.rxdfifo_wfull, xge_mac_dut.rx_data_fifo0.rxdfifo_wen))
  else
	$display("Fail: RXD_FIFO OVERFLOW! at %t", $time);

  ap_txdfifo_over_check:assert property(fifo_overflow_check(xge_mac_dut.tx_data_fifo0.reset_xgmii_tx_n, clk_xgmii_tx, xge_mac_dut.tx_data_fifo0.txdfifo_wfull, xge_mac_dut.tx_data_fifo0.txdfifo_wen))
  else
	$display("Fail: TXD_FIFO OVERFLOW! at %t", $time);

  property fifo_underflow_check(logic clk, logic rempty, logic ren);
    @(posedge clk) !(rempty && ren);
  endproperty:fifo_underflow_check

endmodule:mac_assertions
`endif //MAC_ASSERTIONS__SV
