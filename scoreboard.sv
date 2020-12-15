//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : scoreboard.sv                                       //
//  Author    : Jiale Wei		                            //
//  Course    : Advanced Verification Methodology (EE8350)	    //
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef SCOREBOARD__SV
`define SCOREBOARD__SV

typedef uvm_in_order_comparator #(packet) packet_comparator;
typedef uvm_in_order_comparator #(xgmii_packet) xgmii_packet_comparator;

class scoreboard extends uvm_scoreboard;
  //Declare dynamic array to store the packet, xgmii_packet, or wishbone item
  packet        pkt_tx_mon_q [$];
  packet        pkt_rx_mon_q [$];
  wishbone_item wshbn_read_q [$];
  xgmii_packet	xgmii_pkt_tx_mon_q [$];
  xgmii_packet	xgmii_pkt_rx_mon_q [$];

  int unsigned  m_matches;
  int unsigned  m_mismatches;
  // xgmii packet matches and mismatches
  int unsigned  xgmii_matches;
  int unsigned  xgmii_mismatches;

  int unsigned  m_dut_errors;
  int unsigned  non_empty_queue;
  int unsigned  xgmii_non_empty_queue;

  uvm_event     check_packet_event;
  uvm_event	check_xgmii_packet_event;
  uvm_event     check_wshbn_event;
  //Register in factory
  `uvm_component_utils( scoreboard )
  //Analysis implementation ports to support input from many places
  // Analysis port for packet
  `uvm_analysis_imp_decl( _from_pkt_tx_mon )
  uvm_analysis_imp_from_pkt_tx_mon #( packet, scoreboard )    from_pkt_tx_mon;
  `uvm_analysis_imp_decl( _from_pkt_rx_mon )
  uvm_analysis_imp_from_pkt_rx_mon #( packet, scoreboard )    from_pkt_rx_mon;
  // Analysis port for xgmii_packet
  `uvm_analysis_imp_decl( _from_xgmii_pkt_tx_mon )
  uvm_analysis_imp_from_xgmii_pkt_tx_mon #( xgmii_packet, scoreboard )    from_xgmii_pkt_tx_mon;
  `uvm_analysis_imp_decl( _from_xgmii_pkt_rx_mon )
  uvm_analysis_imp_from_xgmii_pkt_rx_mon #( xgmii_packet, scoreboard )    from_xgmii_pkt_rx_mon;
  `uvm_analysis_imp_decl( _from_wshbn_mon )
  uvm_analysis_imp_from_wshbn_mon #( wishbone_item, scoreboard )  from_wshbn_mon;
 


  function new( string name="scoreboard", uvm_component parent );
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase( uvm_phase phase );
    super.build_phase( phase );
    m_matches       = 0;
    m_mismatches    = 0;
    xgmii_matches   = 0;
    xgmii_mismatches= 0;
    m_dut_errors    = 0;
    non_empty_queue = 0;
    xgmii_non_empty_queue=0;
    //Instantiate the analysis port
    from_pkt_tx_mon   = new ("from_pkt_tx_mon", this);
    from_pkt_rx_mon   = new ("from_pkt_rx_mon", this);
    from_xgmii_pkt_tx_mon= new ("from_xgmii_pkt_tx_mon", this);
    from_xgmii_pkt_rx_mon= new ("from_xgmii_pkt_rx_mon", this);
    from_wshbn_mon    = new ("from_wshbn_mon", this );
    //Instantiate the triggering event
    check_packet_event  = new ( "check_packet_event" );
    check_xgmii_packet_event = new ("check_xgmii_packet_event");
    check_wshbn_event   = new ( "check_wshbn_event" );
  endfunction : build_phase


  virtual function write_from_pkt_tx_mon( packet tx_packet );
    `uvm_info( get_name(), $psprintf( "Received pkt_tx packet" ), UVM_FULL )
    pkt_tx_mon_q.push_back( tx_packet );
  endfunction : write_from_pkt_tx_mon


  virtual function write_from_pkt_rx_mon( packet rx_packet );
    `uvm_info( get_name(), $psprintf( "Received pkt_rx packet" ), UVM_FULL )
    pkt_rx_mon_q.push_back( rx_packet );
    check_packet_event.trigger( );
  endfunction : write_from_pkt_rx_mon

  virtual function write_from_xgmii_pkt_tx_mon (xgmii_packet xgmii_tx_packet);
    `uvm_info( get_name(), $psprintf( "Received xgmii_pkt_tx_packet" ), UVM_FULL)
    xgmii_pkt_tx_mon_q.push_back( xgmii_tx_packet );
  endfunction : write_from_xgmii_pkt_tx_mon

  virtual function write_from_xgmii_pkt_rx_mon( xgmii_packet xgmii_rx_packet );
    `uvm_info( get_name(), $psprintf( "Received xgmii_pkt_rx packet" ), UVM_FULL )
    xgmii_pkt_rx_mon_q.push_back( xgmii_rx_packet );
    check_xgmii_packet_event.trigger( );
  endfunction : write_from_xgmii_pkt_rx_mon

  virtual function write_from_wshbn_mon( wishbone_item wshbn_xtxn );
    `uvm_info( get_name(), $psprintf( "Received wishbone transaction" ), UVM_FULL )
    wshbn_read_q.push_back( wshbn_xtxn );
    check_wshbn_event.trigger( );
  endfunction : write_from_wshbn_mon


  virtual task check_packet( );
    forever begin
      check_packet_event.wait_trigger( );
      check_packet_queues( );
    end
  endtask : check_packet

virtual task check_xgmii_packet( );
    forever begin
      check_xgmii_packet_event.wait_trigger( );
      check_xgmii_packet_queues( );
    end
  endtask : check_xgmii_packet


  virtual task check_wishbone_trans( );
    forever begin
      check_wshbn_event.wait_trigger( );
      check_wshbn_queue( );
    end
  endtask : check_wishbone_trans


  virtual function void check_packet_queues() ;
    packet          tx_pkt;
    packet          rx_pkt;
    int unsigned    error;
    int unsigned    mismatch;

    while ( pkt_tx_mon_q.size() && pkt_rx_mon_q.size() ) begin
      error = 0;
      tx_pkt = pkt_tx_mon_q.pop_front( );
      rx_pkt = pkt_rx_mon_q.pop_front( );
	  //Check the packet item one-by-one
      if ( tx_pkt.mac_dst_addr != rx_pkt.mac_dst_addr ) begin
        `uvm_error( get_name(), $psprintf( "MAC_DST_ADDR MISMATCH!, Exp=0x%0x, Act=0x%0x",
                    tx_pkt.mac_dst_addr, rx_pkt.mac_dst_addr ) )
        error++;
      end
      if ( tx_pkt.mac_src_addr != rx_pkt.mac_src_addr ) begin
        `uvm_error( get_name(), $psprintf( "MAC_SRC_ADDR MISMATCH!, Exp=0x%0x, Act=0x%0x",
                    tx_pkt.mac_src_addr, rx_pkt.mac_src_addr ) )
        error++;
      end
      if ( tx_pkt.ether_type != rx_pkt.ether_type ) begin
        `uvm_error( get_name(), $psprintf( "ETHER_TYPE MISMATCH!, Exp=0x%0x, Act=0x%0x",
                    tx_pkt.ether_type, rx_pkt.ether_type ) )
        error++;
      end
      if ( tx_pkt.payload.size() > rx_pkt.payload.size() ) begin
	if( (tx_pkt.payload.size()>1500) && (rx_pkt.payload.size()>1500) )begin
	  `uvm_error( get_name(), $psprintf( "PYLD SIZE Oversized and the DUT don't cut down the size. " ))
	  error++;
	end
        else begin
	  `uvm_error( get_name(), $psprintf( "PYLD SIZE MISMATCH!, Exp=%0d, Act=%0d - BYTES DROPPED!",
                    tx_pkt.payload.size(), rx_pkt.payload.size() ) )
        error++;
        compare_payload_bytes( tx_pkt.payload, rx_pkt.payload, rx_pkt.payload.size(), mismatch );
	end
        if ( mismatch )
          error++;
      end
      else if ( tx_pkt.payload.size() < rx_pkt.payload.size() ) begin
        if ( tx_pkt.payload.size() >= 46 ) begin
          `uvm_error( get_name(), $psprintf( "PYLD SIZE MISMATCH!, Exp=%0d, Act=%0d - BYTES ADDED!",
                    tx_pkt.payload.size(), rx_pkt.payload.size() ) )
          error++;
          compare_payload_bytes( tx_pkt.payload, rx_pkt.payload, tx_pkt.payload.size(), mismatch );
          if ( mismatch )
            error++;
        end
        else begin
          // When payload size is less then 46B, the DUT will pad with zeroes
          compare_payload_bytes( tx_pkt.payload, rx_pkt.payload, tx_pkt.payload.size(), mismatch );
          if ( mismatch )
            error++;
	  //Check whether the padding values are 0x0
          for ( int i=tx_pkt.payload.size(); i<rx_pkt.payload.size(); i++ ) begin
            if ( rx_pkt.payload[i] != 8'h0 ) begin
              `uvm_error( get_name(), $psprintf( "PYLD[%0d] PADDING MISMATCH!, Exp=0x%0x, Act=0x%0x",
                            i, 8'h0, rx_pkt.payload[i] ) )
              error++;
            end
          end
        end
      end
      else begin
	if( (tx_pkt.payload.size()>1500) && (rx_pkt.payload.size()>1500) )begin
	  `uvm_error( get_name(), $psprintf( "PYLD SIZE Oversized and the DUT don't cut down the size. " ))
	  error++;
	end
        compare_payload_bytes( tx_pkt.payload, rx_pkt.payload, tx_pkt.payload.size(), mismatch );
        if ( mismatch )
          error++;
      end

      if ( error )
        m_mismatches++;
      else begin
        m_matches++;
        `uvm_info( get_name(), $psprintf( "PACKET MATCH" ), UVM_HIGH )
      end
    end//while_end
  endfunction : check_packet_queues

  virtual function void check_xgmii_packet_queues();
    xgmii_packet          xgmii_tx_pkt;
    xgmii_packet          xgmii_rx_pkt;
    int unsigned    xgmii_error;

    while ( xgmii_pkt_tx_mon_q.size() && xgmii_pkt_rx_mon_q.size() ) begin
      xgmii_error = 0;
	  //Pop out the front element to compare 
      xgmii_tx_pkt = xgmii_pkt_tx_mon_q.pop_front( );
      xgmii_rx_pkt = xgmii_pkt_rx_mon_q.pop_front( );
	  //Check the packet item one-by-one
      if ( xgmii_tx_pkt.control != xgmii_rx_pkt.control ) begin
        `uvm_error( get_name(), $psprintf( "Control Signal in XGMII Port Mismatch!, Exp=%0h, Act=%0h",
                    xgmii_tx_pkt.control, xgmii_rx_pkt.control ) )
        xgmii_error++;
      end
      if ( xgmii_tx_pkt.data != xgmii_rx_pkt.data ) begin
        //`uvm_error( get_name(), $psprintf( "Data Signal in XGMII Port Mismatch!, Exp=%0h, Act=%0h",
                    //xgmii_tx_pkt.data, xgmii_rx_pkt.data ) )
        xgmii_error++;
      end

      if ( xgmii_error )
        xgmii_mismatches++;
      else begin
        xgmii_matches++;
        //`uvm_info( get_name(), $psprintf( "PACKET MATCH" ), UVM_HIGH )
      end
    end//while_end
  endfunction : check_xgmii_packet_queues


  function compare_payload_bytes( bit[7:0] exp_bytes[], bit[7:0] act_bytes[], 
                                  int unsigned length, ref int unsigned mismatch );
    //Each time compare the payload, clear the mismatch counting
    mismatch = 0;
    //Foreach palyoud byte, if not matched, report unmatched value
    for ( int i=0; i<length; i++ ) begin
      if ( exp_bytes[i] != act_bytes[i] ) begin
        `uvm_error( get_name(), $psprintf( "PYLD[%0d] MISMATCH!, Exp=0x%0x, Act=0x%0x",
                    i, exp_bytes[i], act_bytes[i] ) )
        mismatch++;
      end
	  /*
      else begin
        `uvm_info( get_name(), $psprintf( "PYLD[%0d] MATCH!, Exp=0x%0x, Act=0x%0x",
                    i, exp_bytes[i], act_bytes[i] ), UVM_FULL )
      end
	  */
    end
  endfunction : compare_payload_bytes


  virtual function void check_wshbn_queue( );
    wishbone_item   xtxn;
    int unsigned    error;
    while ( wshbn_read_q.size() ) begin
      error = 0;
      xtxn = wshbn_read_q.pop_front( );
      if ( xtxn.xtxn_n==wishbone_item::WRITE ) begin
        `uvm_info( get_name(), $psprintf( "WISHBONE WR XTXN - No checking done" ), UVM_HIGH )
      end
      else if ( xtxn.xtxn_n==wishbone_item::READ ) begin
        if ( (xtxn.xtxn_addr!=8'h08 && xtxn.xtxn_addr!=8'h0C) ) begin
          `uvm_info( get_name(), $psprintf( "WISHBONE RD XTXN - No checking done" ), UVM_HIGH )
        end
        else begin
          // Make sure there are no interrupts --> DUT function correctly
	  assert(xtxn.xtxn_data == 32'h0)
            `uvm_info(get_name(), $psprintf("RD_ADDR=0x%0x, Exp RD_DATA=0x%0x, Act RD_DATA=0x%0x",xtxn.xtxn_addr, 32'h0, xtxn.xtxn_data ), UVM_HIGH )
	  else begin
            `uvm_error(get_name(), $psprintf("WISHBONE RD XTXN - Error" ) )
            `uvm_error(get_name(), $psprintf("RD_ADDR=0x%0x, Exp RD_DATA=0x%0x, Act RD_DATA=0x%0x",
                                    xtxn.xtxn_addr, 32'h0, xtxn.xtxn_data ) )
            error++;
          end
        end
      end
      if ( error )  m_dut_errors++;
    end
  endfunction : check_wshbn_queue


  task run_phase ( uvm_phase phase );
    `uvm_info( get_name(), $sformatf("HIERARCHY: %m"), UVM_HIGH);
    fork
      check_packet();
      check_wishbone_trans( );
	  check_xgmii_packet();
    join_none
  endtask : run_phase


  virtual function void check_phase ( uvm_phase phase );
    // Check the scoreboard queues and make sure they are empty
    if ( pkt_tx_mon_q.size() ) begin
      `uvm_error( get_name(), $psprintf("pkt_tx_mon_q not empty at end ot test") )
      `uvm_error( get_name(), $psprintf("pkt_tx_mon_q size = %0d", pkt_tx_mon_q.size() ) )
      non_empty_queue++;
    end

    if ( pkt_rx_mon_q.size() ) begin
      `uvm_error( get_name(), $psprintf("pkt_rx_mon_q not empty at end ot test") )
      `uvm_error( get_name(), $psprintf("pkt_rx_mon_q size = %0d", pkt_rx_mon_q.size() ) )
      non_empty_queue++;
    end
	
	if ( xgmii_pkt_tx_mon_q.size() ) begin
      `uvm_error( get_name(), $psprintf("xgmii_pkt_tx_mon_q not empty at end ot test") )
      `uvm_error( get_name(), $psprintf("xgmii_pkt_tx_mon_q size = %0d", xgmii_pkt_tx_mon_q.size() ) )
      non_empty_queue++;
    end

    if ( xgmii_pkt_rx_mon_q.size() ) begin
      `uvm_error( get_name(), $psprintf("xgmii_pkt_rx_mon_q not empty at end ot test") )
      `uvm_error( get_name(), $psprintf("xgmii_pkt_rx_mon_q size = %0d", xgmii_pkt_rx_mon_q.size() ) )
      non_empty_queue++;
    end

    if ( wshbn_read_q.size() ) begin
      `uvm_error( get_name(), $psprintf("wshbn_read_q not empty at end ot test") )
      `uvm_error( get_name(), $psprintf("wshbn_read_q size = %0d", wshbn_read_q.size() ) )
      non_empty_queue++;
    end

  endfunction : check_phase


  virtual function void final_phase ( input uvm_phase phase );
    super.final_phase( phase );
    `uvm_info( get_name( ), $sformatf( "FINAL: Packet/Data Matches   =%0d", m_matches ), UVM_LOW )
    `uvm_info( get_name( ), $sformatf( "FINAL: Packet/Data Mismatches=%0d", m_mismatches), UVM_LOW )
    `uvm_info( get_name( ), $sformatf( "FINAL: Wishbone Errors  =%0d", m_dut_errors), UVM_LOW )
    if ( m_mismatches || m_dut_errors || non_empty_queue )
      `uvm_error( get_name(), "********** TEST FAILED **********" )
    else
      `uvm_info ( get_name(), "********** TEST PASSED **********", UVM_NONE )
  endfunction : final_phase

endclass : scoreboard

`endif  //SCOREBOARD__SV
