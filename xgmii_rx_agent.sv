//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : xgmii_rx_agent.sv                                   //
//  Author    : Jiale Wei	                                    //
//  Course    : Advanced Verification Methodology	            //
//  Date      : 12/02/2020		                            //
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef XGMII_RX_AGENT__SV
`define XGMII_RX_AGENT__SV

`include "xgmii_rx_monitor.sv"


class xgmii_rx_agent extends uvm_agent;

  xgmii_rx_monitor                  xgmii_pkt_rx_mon;

  `uvm_component_utils( xgmii_rx_agent )

  function new(  string name="xgmii_rx_agent",  uvm_component parent );
    super.new( name, parent );
  endfunction : new


  virtual function void build_phase(  uvm_phase phase );
    super.build_phase( phase );
    xgmii_pkt_rx_mon= xgmii_rx_monitor::type_id::create( "xgmii_pkt_rx_mon", this );
  endfunction : build_phase


endclass : xgmii_rx_agent

`endif  // XGMII_RX_AGENT__SV
