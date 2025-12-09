module sekelton_ut;
  import svunit_pkg::svunit_testcase;
  import svunit_uvm_mock_pkg::*;
  string name = "skeleton_ut";

  svunit_testcase svunit_ut;

  logic uut_clk;
  logic uut_reset_n;

  some_module uut(
    .pin0 (uut_pin0),
    .pin1 (uut_pin1),
    .pin2 (uut_pin2),
    .clk                       (uut_clk),
    .reset_n                   (uut_reset_n)
  );
  always #(4.62ns) uut_clk = ~uut_clk;

  function void build();
    svunit_ut = new(name);
  endfunction

  task setup();
    svunit_ut.setup();
    uut_clk = 0;
    uut_reset_n = 1;
    
    uut_pin0 = 0;
    uut_pin1 = 0;

    repeat (10) @(posedge uut_clk);
    @(posedge uut_clk) uut_reset_n = 0;
    repeat (20) @(posedge uut_clk);
    @(posedge uut_clk) uut_reset_n = 1;
    @(posedge uut_clk);
    
    svunit_uvm_test_start();
  endtask

  task teardown();
    svunit_ut.teardown();
    svunit_uvm_test_finish();
  endtask

  task automatic run();
    if (svunit_pkg::_filter.is_selected(svunit_ut, "skeleton_first_test")) begin : skeleton_first_test
      string _testName = "skeleton_first_test";
      integer local_error_count = svunit_ut.get_error_count();
      string fileName;
      int lineNumber;

      svunit_pkg::current_tc = svunit_ut;
      svunit_ut.add_junit_test_case(_testName);
      svunit_ut.start();
      setup();

      fork
        fork 
          begin : SKELETON_FIRST_TEST
            @(posedge uut_clk);
              $display("INFO:  [%0t][%0s]: %s", $time, name, $sformatf("HELLO_SVUNIT_WORLD!", _testName));
          end : SKELETON_FIRST_TEST

          begin : WAIT_FOR_ERROR
            if (svunit_ut.get_error_count() == local_error_count) begin
              svunit_ut.wait_for_error();
            end
          end : WAIT_FOR_ERROR
        join_any
      
        #0;
        disable fork;
      end

      join

      svunit_ut.stop();
      teardown();

      if (svunit_ut.get_error_count() == local_error_count)
        $display("INFO:  [%0t][%0s]: %s", $time, name, $sformatf("%s::PASSED", _testName));
      else
        $display("INFO:  [%0t][%0s]: %s", $time, name, $sformatf("%s::FAILED", _testName));
      
      svunit_ut.update_exit_status();
    end
  endtask
endmodule

module __testsuite;
  import svunit_pkg::svunit_testsuite;
  string name = "__ts";

  svunit_testsuite svunit_ts;
  
  skeleton_ut lutm_read_ut();
  
  function void build();
    skeleton_ut.build();
    svunit_ts = new(name);
    svunit_ts.add_testcase(skeleton_ut.svunit_ut);
  endfunction

  task run();
    svunit_ts.run();
    skeleton_ut.run();
    svunit_ts.report();
  endtask

endmodule

import uvm_pkg::*;

module testrunner();
  import svunit_pkg::svunit_testrunner;
  import svunit_uvm_mock_pkg::svunit_uvm_test_inst;
  import svunit_uvm_mock_pkg::uvm_report_mock;

  string name = "testrunner";

  svunit_testrunner svunit_tr;
  __testsuite __ts();

  initial
  begin
    build();
    svunit_uvm_test_inst("svunit_uvm_test");
    run();
    $finish();
  end

  function void build();
    svunit_tr = new(name);
    __ts.build();
    svunit_tr.add_testsuite(__ts.svunit_ts);
  endfunction

  task run();
    __ts.run();
    svunit_tr.report();
  endtask
endmodule
