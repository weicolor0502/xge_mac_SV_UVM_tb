//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : packet_subscriber.sv                                //
//  Author    : Jiale Wei		                            //
//  Course    : Advanced Verification Methodology (EE8350)	    //
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef PACKET_SUBSCRIBER__SV
`define PACKET_SUBSCRIBER__SV

class packet_subscriber extends uvm_subscriber #(packet);
	//register in factory
	`uvm_component_utils(packet_subscriber)
	bit [47:0] 	mac_dst_addr;
	bit [47:0] 	mac_src_addr;
	bit [15:0]	ether_type;
	int 		payload_size;
	
	//define covergroup and coverpoints
	covergroup cover_packet;
		coverpoint mac_dst_addr
		{
			bins low = {[48'h1:48'h3FFFFFFFFFFF]};
			bins mid = {[48'h400000000000:48'hBFFFFFFFFFFF]};
			bins high= {[48'hC00000000000:48'hFFFFFFFFFFFF]};
		}
		coverpoint mac_src_addr
		{
			bins low = {[48'h1:48'h3FFFFFFFFFFF]};
			bins mid = {[48'h400000000000:48'hBFFFFFFFFFFF]};
			bins high= {[48'hC00000000000:48'hFFFFFFFFFFFF]};
		}
		coverpoint ether_type
		{
			bins ipv4 = {16'h0800};
			bins ARP  = {16'h0806};
			bins ipv6 = {16'h88DD};
		}
		
		coverpoint payload_size
		{
			bins pay_low = {[46:100]};
			bins pay_mid = {[101:1000]};
			bins pay_high= {[1001:1500]};
		}
	endgroup
	
	//Declare vritual interface 
	virtual xge_mac_interface sub_vi;
	//Declare analysis port to get transactions from monitor
	uvm_analysis_imp #(packet, packet_subscriber) sub_port_from_rx;
	//`uvm_analysis_imp_decl( _sub_port_from_rx)
	//uvm_analysis_imp_sub_port_from_rx #(packet, packet_subscriber ) sub_port_from_rx;
	
	function new (string name, uvm_component parent);
	begin
		super.new(name, parent);
		//Call new for covergroup
		cover_packet = new();
	end
	endfunction
	
	function void build_phase(uvm_phase phase);
		//Get virtual interface reference from config database
		if(!uvm_config_db#(virtual xge_mac_interface)::get(this, "", "sub_vi", sub_vi))
			`uvm_error("UVM subscriber", "uvm_config_db::get FAILED!")
		//sub_port_from_tx = new("sub_port_from_tx", this);
		sub_port_from_rx = new("sub_port_from_rx", this);
		//sub_port_from_wish = new("sub_port_from_wish", this);
	endfunction
	
	//write function for the analysis port
	function void write (packet t);
		`uvm_info(get_name(), $psprintf("Received pkt_rx packet"), UVM_FULL )
		mac_dst_addr = t.mac_dst_addr;
		mac_src_addr = t.mac_src_addr;
		ether_type   = t.ether_type;
		payload_size = t.payload.size();
		
		cover_packet.sample();
	endfunction
endclass:packet_subscriber

`endif	//subscriber.sv	
