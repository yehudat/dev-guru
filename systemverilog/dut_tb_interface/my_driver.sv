class my_driver extends uvm_component;
  function new(string name="",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  typedef uvm_component_registry #(my_driver,"my_driver") type_id;

  // Virtual interface for accessing top-level DUT signals
  typedef virtual DUT_IF vi_if_t;
  vi_if_t vi_if_h;
  
  // abstract class variables that will hold handles to concrete classes built by the factory
  // These handle names shouldn't be tied to actual bind instance location - just doing it to help
  // follow the example. You could use config strings to set the factory names.
  probe_abstract #(logic [WordSize1-1:0]) sub1_InternalBus_h;
  probe_abstract #(logic [WordSize2-1:0]) sub2_InternalBus_h;
  probe_abstract #(logic) sub1_ChipSelect_h;
  
  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(vi_if_t)::get(this,"","DUT_IF",vi_if_h)) begin
      uvm_report_fatal("NOVif","No DUT_IF instance set",,`__FILE__,`__LINE__);
    end
    $cast(sub1_InternalBus_h, factory.create_object_by_name("probe_testbench.dut.sub1.m1_1",,"sub1_InternalBus_h"));
    $cast(sub2_InternalBus_h, factory.create_object_by_name("probe_testbench.dut.sub2.m1_2",,"sub2_InternalBus_h"));
    $cast(sub1_ChipSelect_h, factory.create_object_by_name("probe_testbench.dut.sub1.m1_3",,"sub1_ChipSelect_h"));
  endfunction : build_phase
  
  // simple driver routine just for testing probe class
  task run_phase(uvm_phase phase);
    phase.raise_objection( this );

    vi_if_h.WriteEnable <= 1;
    vi_if_h.ChipSelect <= 0;

    fork
      process1: forever begin
        @(posedge vi_if_h.Clock);
        `uvm_info("GET1",$printf("%h",sub1_InternalBus_h.get_probe()));
        `uvm_info("GET2",$printf("%h",sub2_InternalBus_h.get_probe()));
      end
      process2: begin
        sub1_ChipSelect_h.edge_probe();
        `uvm_info("EDGE3","CS had a posedge");
        sub1_ChipSelect_h.edge_probe(0);
        `uvm_info("EDGE3","CS had a negedge");
      end
      process3: begin
        @(posedge vi_if_h.Clock);
        vi_if_h.ChipSelect <= 0;
        sub2_InternalBus_h.set_probe('1);
        @(posedge vi_if_h.Clock);
        vi_if_h.ChipSelect <= 1;
        sub1_InternalBus_h.set_probe('1);
        @(posedge vi_if_h.Clock);
        vi_if_h.ChipSelect <= 0;
        sub2_InternalBus_h.set_probe('0);
        @(posedge vi_if_h.Clock);
        @(posedge vi_if_h.Clock);
      end
    join_any

    phase.drop_objection( this );
  endtask : run_phase
endclass : my_driver