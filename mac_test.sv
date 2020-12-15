//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : mac_test.sv                                         //
//  Author    : Jiale Wei		                            //
//  Course    : Advanced Verification Methodology (EE8350)          //
//  Date      : 11.27.2020				            //
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef MAC_TEST__SV
`define MAC_TEST__SV

`include "reset_sequence.sv"
`include "wishbone_sequence.sv"
`include "packet_sequence.sv"
`include "packet.sv"
`include "xgmii_packet.sv"
`include "mac_env.sv"
`include "virtual_sequencer.sv"
`include "virtual_sequence.sv"

class mac_test extends uvm_test;

  //Register in factory
  `uvm_component_utils(mac_test)
  mac_env 	env;
  
  function new( string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new


  virtual function void build_phase( uvm_phase phase );
    //virtual function void build_phase(input uvm_phase phase);
    super.build_phase(phase);
    //Instantiate the environment
    env = mac_env::type_id::create("env", this);
    
    //Assign virtual interface 
    uvm_config_db #(virtual xge_mac_interface)::set(this, "env.rst_agent.rst_drv", "drv_vi", xge_test_top.xge_mac_if);
    uvm_config_db #(virtual xge_mac_interface)::set(this, "env.wshbn_agent.wshbn_mon", "mon_vi", xge_test_top.xge_mac_if);
    uvm_config_db #(virtual xge_mac_interface)::set(this, "env.wshbn_agent.wshbn_drv", "drv_vi", xge_test_top.xge_mac_if);
    uvm_config_db #(virtual xge_mac_interface)::set(this, "env.pkt_tx_agent.pkt_tx_drv", "drv_vi", xge_test_top.xge_mac_if);
    uvm_config_db #(virtual xge_mac_interface)::set(this, "env.pkt_tx_agent.pkt_tx_mon", "mon_vi", xge_test_top.xge_mac_if);
    uvm_config_db #(virtual xge_mac_interface)::set(this, "env.pkt_rx_agent.pkt_rx_mon", "mon_vi", xge_test_top.xge_mac_if);
    uvm_config_db #(virtual xge_mac_interface)::set(this, "env.xgmii_tx_agt.xgmii_pkt_tx_mon", "mon_vi", xge_test_top.xge_mac_if);
    uvm_config_db #(virtual xge_mac_interface)::set(this, "env.xgmii_rx_agt.xgmii_pkt_rx_mon", "mon_vi", xge_test_top.xge_mac_if);   
    uvm_config_db #(virtual xge_mac_interface)::set(this, "env.sub", "sub_vi", xge_test_top.xge_mac_if);
 
    //Run the sequence on the default sequencer using config_db
    //Run the reset sequence in the reset phase
    uvm_config_db #(uvm_object_wrapper)::set(this, "env.rst_agent.rst_seqr.main_phase", "default_sequence", reset_sequence::get_type());
    //Run the wishbone init sequence in the configuration phase
    uvm_config_db #(uvm_object_wrapper)::set(this, "env.wshbn_agent.wshbn_seqr.main_phase", "default_sequence", wishbone_init_sequence::get_type());
    uvm_config_db #(uvm_object_wrapper)::set(this, "env.pkt_tx_agent.pkt_tx_seqr.main_phase", "default_sequence", packet_sequence::get_type());
    //Set the number of packets in each test sequence
    uvm_config_db #(int unsigned)::set(this, "env.pkt_tx_agent.pkt_tx_seqr.packet_sequence", "num_packets", 10);

  endfunction : build_phase


  virtual function void end_of_elaboration_phase( uvm_phase phase );
    super.end_of_elaboration_phase(phase);
    //Print the UVM hierarchy
    `uvm_info(get_name(), "Printing Topology from end_of_elaboration phase", UVM_MEDIUM)
    if ( uvm_report_enabled(UVM_MEDIUM) ) begin
      uvm_top.print_topology();
    end
  endfunction : end_of_elaboration_phase


  virtual function void start_of_simulation_phase( uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info(get_name(), "Printing factory from start_of_simulation phase", UVM_MEDIUM)
  endfunction  : start_of_simulation_phase


  virtual task run_phase( uvm_phase phase);
    `uvm_info(get_name(), $sformatf("%m"), UVM_HIGH)

  endtask : run_phase


  virtual task main_phase( uvm_phase phase);
    uvm_objection   objection;
    super.main_phase(phase);
    objection = phase.get_objection();
    //Stop the simulation when reaches the time
    objection.set_drain_time(this, 10us);
  endtask : main_phase

endclass : mac_test

class virtual_sequence_base_test extends mac_test;
  //Declare the virtual sequencer
  virtual_sequencer v_seqr;
  virtual_sequence m_vseq;
  //Register in factory
  `uvm_component_utils(virtual_sequence_base_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //instantiate the virtual sequencer
    v_seqr = virtual_sequencer::type_id::create("v_seqr", this);

    //reset and configuration sequences remain the same as previous
    uvm_config_db #(uvm_object_wrapper)::set(this, "env.rst_agent.rst_seqr.main_phase", "default_sequence", reset_sequence::get_type());
    uvm_config_db #(uvm_object_wrapper)::set(this, "env.wshbn_agent.wshbn_seqr.main_phase", "default_sequence", wishbone_init_sequence::get_type());
    uvm_config_db #(uvm_object_wrapper)::set(this, "env.pkt_tx_agent.pkt_tx_seqr.main_phase", "default_sequence", null);
    // set the virtual sequence 
    uvm_config_db #(uvm_object_wrapper)::set(this, "v_seqr.main_phase", "default_sequence", virtual_sequence::get_type() );

  endfunction : build_phase


  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //Let the handle of sequencer point to each sequencer: reset, wishbone, packet
    v_seqr.seqr_rst = env.rst_agent.rst_seqr;
    v_seqr.seqr_wshbn = env.wshbn_agent.wshbn_seqr;
    v_seqr.seqr_tx_pkt = env.pkt_tx_agent.pkt_tx_seqr;

  endfunction:connect_phase

  virtual task run_phase( uvm_phase phase);
    super.run_phase(phase);
    m_vseq = virtual_sequence::type_id::create("m_vseq");
    phase.raise_objection(this);
    m_vseq.start(v_seqr);
    phase.drop_objection(this);

  endtask : run_phase
endclass:virtual_sequence_base_test

//define a testcase when the packets are normal
class bringup_packet_test extends virtual_sequence_base_test;
  //Register in factory
  `uvm_component_utils(bringup_packet_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction:new
  
  virtual function void build_phase(uvm_phase phase);
    //get handle to the singleton factory instance
    uvm_factory factory = uvm_factory::get();
    super.build_phase(phase);
    `uvm_info(get_full_name(), $sformatf("Hierarchy: %m"), UVM_NONE)
    //Type override by type
    factory.set_type_override_by_type(packet::get_type(), packet_bringup::get_type());
  endfunction:build_phase
endclass: bringup_packet_test


//define a testcase when the packets are oversized
class oversized_packet_test extends virtual_sequence_base_test;
  `uvm_component_utils(oversized_packet_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction:new
  
  virtual function void build_phase(uvm_phase phase);
    //get handle to the singleton factory instance
    uvm_factory factory = uvm_factory::get();
    super.build_phase(phase);
    `uvm_info(get_full_name(), $sformatf("Hierarchy: %m"), UVM_NONE)
    //Type override by type
    factory.set_type_override_by_type(packet::get_type(), packet_oversized::get_type());
  endfunction:build_phase
endclass: oversized_packet_test

//define a testcase when the packets are undersized
class undersized_packet_test extends virtual_sequence_base_test;
  `uvm_component_utils(undersized_packet_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction:new
  
  virtual function void build_phase(uvm_phase phase);
    //get handle to the singleton factory instance
    uvm_factory factory = uvm_factory::get();
    super.build_phase(phase);
    `uvm_info(get_full_name(), $sformatf("Hierarchy: %m"), UVM_NONE)
    // Type override by type
    factory.set_type_override_by_type(packet::get_type(), packet_undersized::get_type());
  endfunction:build_phase
endclass : undersized_packet_test

`endif  // MAC_TEST__SV
