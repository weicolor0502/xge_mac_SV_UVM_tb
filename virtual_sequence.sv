//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : virtual_sequence .sv                                //
//  Author    : Jiale Wei		                            //
//  Course    : Advanced Verification Methodology (EE8350)   	    //
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef VIRTUAL_SEQUENCE__SV
`define VIRTUAL_SEQUENCE__SV


class virtual_sequence extends uvm_sequence;

  `uvm_object_utils(virtual_sequence)
  //Declare the virtual sequencer as p_sequencer
  `uvm_declare_p_sequencer(virtual_sequencer)

  reset_sequence            seq_rst;
  wishbone_init_sequence    seq_init_wshbn;
  wishbone_eot_sequence     seq_eot_wshbn;
  packet_sequence           seq_pkt;

  function new(string name="virtual_sequence");
    super.new(name);
    `uvm_info( get_full_name(), $sformatf("Hierarchy: %m"), UVM_HIGH )
  endfunction : new
  

  virtual task body();
    `uvm_info(get_name(), "Reset Sequence start!", UVM_HIGH)
    `uvm_do_on( seq_rst, p_sequencer.seqr_rst);
    #1000;
    `uvm_info(get_name(), "Wishbone initial Sequence start!", UVM_HIGH)
    `uvm_do_on( seq_init_wshbn, p_sequencer.seqr_wshbn);
    #1000;
    `uvm_info( get_name(), "Packet Sequence start!",UVM_HIGH)
    `uvm_do_on( seq_pkt, p_sequencer.seqr_tx_pkt );
    #1000000;

    `uvm_do_on( seq_eot_wshbn, p_sequencer.seqr_wshbn );
  endtask : body


endclass : virtual_sequence

`endif  // VIRTUAL_SEQUENCE__SV
