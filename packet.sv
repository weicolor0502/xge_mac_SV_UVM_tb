//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : packet .sv                                	    //
//  Author    : Jiale Wei		                            //
//  Course    : Advanced Verification Methodology (EE8350)          //
//  Date      : 11.27.2020					    //
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef PACKET__SV
`define PACKET__SV


class packet extends uvm_sequence_item;

  // Signals to be driven into the RTL
  // Follow the IEEE Ethernet Standard
  // MAC address: 00-XX-XX-XX-XX-XX (Hex)
  // Ethernet type: 2 Bytes
  rand bit [47:0]       mac_dst_addr;       // 6 Bytes
  rand bit [47:0]       mac_src_addr;       // 6 Bytes
  rand bit [15:0]       ether_type;         // 2 Bytes
  rand bit [7:0]        payload [];
  //rand bit [31:0]       ipg;                // interpacket gap
  rand bit [39:0]		ipg;					// interpacket gap for 10-Gigabit 5 Bytes
  //rand bit[63:0] crc;
  // Signals unrelated to the RTL
  rand bit              sop_mark;
  rand bit              eop_mark;

  `uvm_object_utils_begin(packet)
    `uvm_field_int( mac_dst_addr    , UVM_DEFAULT )
    `uvm_field_int( mac_src_addr    , UVM_DEFAULT )
    `uvm_field_int( ether_type      , UVM_DEFAULT )
    `uvm_field_array_int( payload   , UVM_DEFAULT )
    `uvm_field_int( ipg             , UVM_DEFAULT )
  `uvm_object_utils_end

  // ======== Constraints ========
  constraint C_proper_sop_eop_marks {
    sop_mark == 1;  // SOP mark should be driven
    eop_mark == 1;  // EOP mark should be driven
  }
  
  constraint C_dst_src_addr {
	mac_dst_addr != mac_src_addr;
  }
  
  constraint C_ether_type {
	ether_type        dist { 16'h0800:=34, 16'h0806:=33, 16'h88DD:=33 };  // IPv4, ARP, IPv6
  }
  constraint C_payload_size { //payload.size range from 46~1500
    payload.size() inside {[46:1500]};
  }

  constraint C_ipg {
    ipg inside {[10:50]};
  }

/*
  function bit[31:0] calc_crc();
	return 32'h0;
  endfunction
 
  function void post_randomize();
	crc = calc_crc();
  endfunction
*/

  function new( string name="packet" );
    super.new();
  endfunction : new

  // Declare a pkt_print function
  function void pkt_print();
	$display("dmac = %0h", mac_dst_addr);
	$display("smac = %0h", mac_src_addr);
	$display("ether_type = %0d", ether_type);
	for(int i=0; i<payload.size();i++) begin
		$display("payload[%0d] = %0h", i, payload[i]);
	end
	$display("inter-packet-gap = %0h", ipg);
  endfunction


endclass : packet

//Set the bring up packet
class packet_bringup extends packet;

  `uvm_object_utils( packet_bringup )

  constraint C_bringup 
    {
      mac_dst_addr      == 48'h7788_9900_ABAB;
      mac_src_addr      == 48'h6565_4343_1122;
      ether_type        dist { 16'h0800:=34, 16'h0806:=33, 16'h88DD:=33 };  // IPv4, ARP, IPv6
      payload.size()    inside {[45:54]};
      //The packet's content is constraint as {1,2,3,4...} for simplicity
      foreach( payload[j] )
        {
          payload[j]  == j+1;
        }
      ipg             == 10;
  }

  function new(string name="packet_bringup");
    super.new(name);
  endfunction : new

endclass : packet_bringup



//Oversized Packet 
class packet_oversized extends packet;

  `uvm_object_utils( packet_oversized )

  constraint C_payload_size
    {
      payload.size() inside {[1501:9000]};
    }

  function new(string name="packet_oversized");
    super.new(name);
  endfunction : new

endclass : packet_oversized



//Undersized Packet 
class packet_undersized extends packet;

  `uvm_object_utils( packet_undersized )

  constraint C_payload_size
    {
      // When payload size is less then 46B, the DUT is supposed
      // to pad the packet to the minimum 64B required for Ethernet.
      payload.size() inside {[1:45]};
    }

  function new(string name="packet_undersized");
    super.new(name);
  endfunction : new

endclass : packet_undersized



class packet_small_large extends packet;

  `uvm_object_utils( packet_small_large )

  constraint C_payload_size
    {
      payload.size() dist { [46:50]:/50, [1456:1500]:/50 };
    }

  function new(string name="packet_small_large");
    super.new(name);
  endfunction : new

endclass : packet_small_large



class packet_small_ipg extends packet;

  `uvm_object_utils( packet_small_ipg )

  constraint C_ipg
    {
      ipg inside {[1:10]};
    }

  function new(string name="packet_small_ipg");
    super.new(name);
  endfunction : new

endclass : packet_small_ipg




class packet_zero_ipg extends packet;

  `uvm_object_utils( packet_zero_ipg )

  constraint C_ipg
    {
      ipg == 0;
    }

  function new(string name="packet_zero_ipg");
    super.new(name);
  endfunction : new

endclass : packet_zero_ipg

`endif // PACKET__SV
