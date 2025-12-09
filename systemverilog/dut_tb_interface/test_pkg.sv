// This package defines the UVM test environment
`include “uvm_macros.svh”

package test_pkg;
  import uvm_pkg::*;
  import common_pkg::*;
  import probe_pkg::*;

  `include "my_driver.sv"
  `include "my_test.sv"
endpackage : test_pkg