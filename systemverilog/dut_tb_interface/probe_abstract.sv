virtual class probe_abstract #(type T=int) extends uvm_object;
  function new(string name="");
    super.new(name);
  endfunction

  // the API for the internal probe
  pure virtual function T get_probe();
  pure virtual function void set_probe(T Data );
  pure virtual task edge_probe(bit Edge=1);
endclass : probe_abstract
