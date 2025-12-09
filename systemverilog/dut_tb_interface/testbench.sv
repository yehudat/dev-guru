`include "dut_if.sv"

module testbench;
  import common_pkg::*;
  import uvm_pkg::*;
  import test_pkg::*;
  bit SystemCLK=1;
  always #5 SystemCLK++;
  
  DUT_IF if(.Clock(SystemCLK));
  typedef virtual DUT_IF vi_if_t;
  
  DUT dut(.CLK(if.Clock), .CS(if.ChipSelect), .WE(if.WriteEnable));
  
  bind model : dut.sub1 probe_if #(.WIDTH(common_pkg::WordSize1)) m1_1(InternalBus);
  bind model : dut.sub2 probe_if #(.WIDTH(common_pkg::WordSize2)) m1_2(InternalBus);
  bind model : dut.sub1 probe_if #(.WIDTH(1)) m1_3(CS);

  initial begin
    uvm_config_db#(vi_if_t)::set(null,"","DUT_IF",if);
    run_test("my_test");
  end
endmodule : testbench