//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : mac_env.sv                                          //
//  Author    : Jiale Wei		                            //
//  Course    : Advanced Verification Methodology (EE8350)	    //
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef MAC_ENV__SV
`define MAC_ENV__SV

`include "reset_agent.sv"
`include "wishbone_agent.sv"
`include "packet_tx_agent.sv"
`include "packet_rx_agent.sv"
`include "xgmii_tx_agent.sv"
`include "xgmii_rx_agent.sv"
`include "scoreboard.sv"
`include "packet_subscriber.sv"
`include "virtual_sequencer.sv"
`include "virtual_sequence.sv"

class mac_env extends uvm_env;
  `uvm_component_utils(mac_env)
  reset_agent       	rst_agent;
  wishbone_agent    	wshbn_agent;
  packet_tx_agent   	pkt_tx_agent;
  packet_rx_agent   	pkt_rx_agent;
  xgmii_tx_agent	xgmii_tx_agt;
  xgmii_rx_agent	xgmii_rx_agt;
  scoreboard        	scbd;
  packet_subscriber 	sub;
  

  function new(string name, input uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase( uvm_phase phase);

    super.build_phase( phase );
    rst_agent      = reset_agent::type_id::create( "rst_agent", this );
    wshbn_agent    = wishbone_agent::type_id::create( "wshbn_agent", this );
    pkt_tx_agent   = packet_tx_agent::type_id::create( "pkt_tx_agent", this );
    //Set the status of agent is UVM_ACTIVE
    pkt_tx_agent.is_active = UVM_ACTIVE;
    `uvm_info(get_name(), "Set the TX_AGENT as UVM_ACTIVE",UVM_HIGH)
    pkt_rx_agent   = packet_rx_agent::type_id::create( "pkt_rx_agent", this );
    xgmii_tx_agt   = xgmii_tx_agent::type_id::create( "xgmii_tx_agt", this );
    xgmii_rx_agt   = xgmii_rx_agent::type_id::create( "xgmii_rx_agt", this );
    scbd           = scoreboard::type_id::create( "scbd", this );
    sub		   = packet_subscriber::type_id::create("sub", this);
  endfunction : build_phase


  virtual function void connect_phase( uvm_phase phase );

    super.connect_phase( phase );
    //Analysis port from transmitt monitor to scoreboard
    pkt_tx_agent.pkt_tx_mon.tx_Mon2Sb_port.connect( scbd.from_pkt_tx_mon );
    pkt_rx_agent.pkt_rx_mon.rx_Mon2Sb_port.connect( scbd.from_pkt_rx_mon );
    wshbn_agent.wshbn_mon.wshbn_Mon2Sb.connect( scbd.from_wshbn_mon );
    xgmii_tx_agt.xgmii_pkt_tx_mon.ap_xgmii_mon.connect( scbd.from_xgmii_pkt_tx_mon );
    xgmii_rx_agt.xgmii_pkt_rx_mon.ap_xgmii_mon.connect( scbd.from_xgmii_pkt_rx_mon );
    //Analysis port from packet_rx_monitor to subscriber
    pkt_rx_agent.pkt_rx_mon.rx_Mon2Sub_port.connect( sub.sub_port_from_rx );
  endfunction : connect_phase

endclass : mac_env

`endif  //MAC_ENV__SV
