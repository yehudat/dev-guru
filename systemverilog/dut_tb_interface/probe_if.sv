// This interface will be bound inside the DUT and provides the concrete class definition.
interface probe_if #(
  int WIDTH
) (
  inout wire [WIDTH-1:0] WData
);
  import uvm_pkg::*;
  typedef logic [WIDTH-1:0] T;
  
  T Data_reg = 'z;
  assign WData = Data_reg;
  
  import probe_pkg::*;
  // String used for factory by_name registration
  localparam string PATH = $printf("%m");

  class probe extends probe_abstract #(T);
    function new(string name="");
      super.new(name);
    endfunction : new

    typedef uvm_object_registry #(probe,{"probe_",PATH}) type_id;

    static function type_id get_type();
      return type_id::get();
    endfunction : get_type

    // provide the implementations for the pure methods
    function T get_probe();
      return WData;
    endfunction : get_probe
    
    function void set_probe(T Data );
      Data_reg = Data;
    endfunction : set_probe
    
    task edge_probe(bit Edge=1);
      @(WData iff (WData === Edge));
    endtask : edge_probe
  endclass : probe
endinterface : probe_if
