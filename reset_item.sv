//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : reset_item.sv                                       //
//  Author    : Jiale Wei					    //
//  Course    : EE8350 Advanced Verification Methodology	    //
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef RESET_ITEM__SV
`define RESET_ITEM__SV


class reset_item extends uvm_sequence_item;
  //Declare two reset mode
  typedef enum bit { LOW=0, HIGH=1 } rst_mode;
  //When the reset is asserted, the reset is low
  rand rst_mode     reset_n;
  rand int unsigned cycles;

  `uvm_object_utils_begin(reset_item)
    `uvm_field_enum( rst_mode, reset_n  , UVM_DEFAULT )
    `uvm_field_int( cycles              , UVM_DEFAULT )
  `uvm_object_utils_end

  // ======== Constraints ========
  constraint C_cycles {
    cycles  inside {[5:25]};
  }

  function new(string name="reset_item");
    super.new();
  endfunction : new

endclass : reset_item

`endif // RESET_ITEM__SV
