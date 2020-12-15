//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : packet_tx_agent.sv                                  //
//  Author    : Jiale Wei		                                    //
//  Course    : Advanced Verification Methodology (EE8350)			//
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef PACKET_TX_AGENT__SV
`define PACKET_TX_AGENT__SV

`include "packet_tx_monitor.sv"
`include "packet_tx_driver.sv"
typedef uvm_sequencer #(packet) packet_tx_sequencer;

class packet_tx_agent extends uvm_agent;
  `uvm_component_utils( packet_tx_agent )
  //Wrap up the sequencer, driver, monitor
  packet_tx_sequencer           pkt_tx_seqr;
  packet_tx_driver              pkt_tx_drv;
  packet_tx_monitor             pkt_tx_mon;


  function new( string name, uvm_component parent );
    super.new( name, parent );
  endfunction : new


  //virtual function void build_phase( uvm_phase phase );
  virtual function void build_phase(uvm_phase phase);
    super.build_phase( phase );
	if( is_active == UVM_ACTIVE) begin
		pkt_tx_drv  = packet_tx_driver::type_id::create( "pkt_tx_drv", this );
		pkt_tx_seqr = packet_tx_sequencer::type_id::create( "pkt_tx_seqr", this );
	end 
    pkt_tx_mon  = packet_tx_monitor::type_id::create( "pkt_tx_mon", this );

  endfunction : build_phase

  //virtual function void connect_phase( uvm_phase phase );
  virtual function void connect_phase( uvm_phase phase);
    super.connect_phase( phase );
	if( is_active == UVM_ACTIVE )begin
		//Connect pkt_tx_seqr to the pkt_tx_drv
		pkt_tx_drv.seq_item_port.connect( pkt_tx_seqr.seq_item_export );
	end

  endfunction : connect_phase

endclass : packet_tx_agent

`endif  // PACKET_TX_AGENT__SV
