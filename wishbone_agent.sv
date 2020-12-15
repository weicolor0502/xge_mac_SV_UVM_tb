//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : wishbone_agent.sv                                   //
//  Author    : Jiale Wei		 	                    //
//  Course    : EE8350 Advanced Verification Methodology 	    //
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef WISHBONE_AGENT__SV
`define WISHBONE_AGENT__SV
`include "wishbone_driver.sv"
`include "wishbone_monitor.sv"

typedef uvm_sequencer #(wishbone_item) wishbone_sequencer;


class wishbone_agent extends uvm_agent;
  //Wrap up the sequencer, driver and monitor
  wishbone_sequencer                    wshbn_seqr;
  wishbone_driver                       wshbn_drv;
  wishbone_monitor                      wshbn_mon;
  //uvm_analysis_port #(wishbone_item)    ap_agent;
  
  `uvm_component_utils( wishbone_agent )

  function new( string name="wishbone_agent", uvm_component parent );
    super.new( name, parent );
  endfunction : new


  virtual function void build_phase( uvm_phase phase );
    super.build_phase( phase );
    wshbn_seqr  = wishbone_sequencer::type_id::create( "wshbn_seqr", this );
    wshbn_drv   = wishbone_driver::type_id::create( "wshbn_drv", this );
    wshbn_mon   = wishbone_monitor::type_id::create( "wshbn_mon", this );
    ;
  endfunction : build_phase


  virtual function void connect_phase( input uvm_phase phase );
    super.connect_phase( phase );
    //Connect sequence item port between sequencer and driver
    wshbn_drv.seq_item_port.connect( wshbn_seqr.seq_item_export );
  endfunction : connect_phase

endclass : wishbone_agent

`endif  // WISHBONE_AGENT__SV
