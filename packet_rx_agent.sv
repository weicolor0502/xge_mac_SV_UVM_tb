//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : packet_rx_agent.sv                                  //
//  Author    : Jiale Wei					    //
//  Course    : EE8350						    //
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef PACKET_RX_AGENT__SV
`define PACKET_RX_AGENT__SV

`include "packet_rx_monitor.sv"


class packet_rx_agent extends uvm_agent;
  `uvm_component_utils( packet_rx_agent )
  packet_rx_monitor             pkt_rx_mon;

  

  function new( string name="packet_rx_agent", uvm_component parent );
    super.new( name, parent );
  endfunction : new


  virtual function void build_phase( uvm_phase phase );
    super.build_phase( phase );
    pkt_rx_mon  = packet_rx_monitor::type_id::create( "pkt_rx_mon", this );    
  endfunction : build_phase


  virtual function void connect_phase( uvm_phase phase );
    super.connect_phase( phase );

  endfunction : connect_phase

endclass : packet_rx_agent

`endif  // PACKET_RX_AGENT__SV
