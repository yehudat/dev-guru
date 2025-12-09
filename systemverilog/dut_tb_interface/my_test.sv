class my_test extends uvm_test;
  function new(string name="",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  typedef uvm_component_registry #(my_test,"my_test") type_id;

  my_driver my_drv_h;

  function void build_phase(uvm_phase phase);
    my_drv_h = my_driver::type_id::create("my_drv_h",this);
  endfunction : build_phase
endclass : my_test 