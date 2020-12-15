//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : xgmii_tx_agent.sv                                   //
//  Author    : Jiale Wei	                                    //
//  Course    : Advanced Verification Methodology	            //
//  Date      : 12/02/2020		                            //
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef XGMII_TX_AGENT__SV
`define XGMII_TX_AGENT__SV

`include "xgmii_tx_monitor.sv"
class xgmii_tx_agent extends uvm_agent;

  xgmii_tx_monitor                  xgmii_pkt_tx_mon;

  `uvm_component_utils( xgmii_tx_agent )

  function new( string name="xgmii_tx_agent", uvm_component parent );
    super.new( name, parent );
  endfunction : new


  virtual function void build_phase( uvm_phase phase );
    super.build_phase( phase );
    xgmii_pkt_tx_mon= xgmii_tx_monitor::type_id::create( "xgmii_pkt_tx_mon", this );
  endfunction : build_phase

endclass : xgmii_tx_agent

`endif  // XGMII_TX_AGENT__SV
