//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : virtual_sequence .sv                                //
//  Author    : Jiale Wei		                            //
//  Course    : Advanced Verification Methodology (EE8350) 	    //
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef PACKET_SEQUENCE__SV
`define PACKET_SEQUENCE__SV

`include "packet.sv"


class packet_sequence extends uvm_sequence #(packet);
  
  int num_packets=10;
  //Register in factory
  `uvm_object_utils(packet_sequence)

  function new(string name="packet_sequence");
    super.new(name);
    `uvm_info( get_name(), $sformatf("Hierarchy: %m"), UVM_HIGH )
  endfunction : new


  virtual task body();
	//Sending large number of transactions, reuse the same sequence item.
	req = packet::type_id::create("req");
	//Send up to 100 transactions
	//num_packets = $urandom_range(100);
    repeat (num_packets) begin
	wait_for_grant();
	if(!req.randomize()) begin
		`uvm_error("PACKET", "Sequence Randomize Failed!")
	end
	//Send request to driver
	send_request(req);
	//Wait for packets to be driven
	wait_for_item_done();
    end//repeat_end
  endtask : body


  virtual task pre_start();
    if ( starting_phase != null ) begin
      `uvm_info(get_name(), "Sequence start!",UVM_HIGH)
      starting_phase.raise_objection( this );
    end
    uvm_config_db #(int unsigned)::get(null, get_full_name(), "num_packets", num_packets);
  endtask : pre_start


  virtual task post_start();
    if  ( starting_phase != null )
      starting_phase.drop_objection( this );
  endtask : post_start

endclass : packet_sequence

`endif  // PACKET_SEQUENCE__SV
