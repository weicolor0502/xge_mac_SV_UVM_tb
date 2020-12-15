//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : testcase .sv                                	    //
//  Author    : Jiale Wei		                            //
//  Course    : Advanced Verification Methodology (EE8350)          //
//  Date      : 11.28.2020					    //
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef TESTCASE__SV
`define TESTCASE__SV

//`include "mac_testbench_pkg.sv"
program testcase();

  import uvm_pkg::*;
  //import mac_testbench_pkg::*;
  `include "mac_test.sv"

  initial begin
    uvm_top.run_test();
  end
endprogram:testcase

`endif
