# I2C UVC Components

This document contains a minimal but complete UVM-based I²C UVC, including:

- `i2c_item.sv`: the sequence item
- `i2c_if.sv`: the interface modeling SDA/SCL with pullups
- `i2c_driver.sv`: a driver that sends address and data on the bus

## `i2c_item.sv`

```systemverilog
class i2c_item extends uvm_sequence_item;
 rand bit [6:0] address;
 rand bit       read;      // 0 = write, 1 = read
 rand bit [7:0] data[];
 bit            nack;      // Response from slave
 bit            error;     // e.g. bus conflict

 `uvm_object_utils_begin(i2c_item)
   `uvm_field_int(address, UVM_ALL_ON)
   `uvm_field_int(read,    UVM_ALL_ON)
   `uvm_field_array_int(data, UVM_ALL_ON)
   `uvm_field_int(nack,    UVM_ALL_ON)
   `uvm_field_int(error,   UVM_ALL_ON)
 `uvm_object_utils_end

 function new(string name = "i2c_item");
   super.new(name);
 endfunction
endclass
```

## `i2c_if.sv`

```systemverilog
interface i2c_if (input bit clk);
 wire scl;
 wire sda;

 logic scl_drv;  // '0' to pull low, 'z' to release
 logic sda_drv;

 // Pullups on bus
 pullup(scl);
 pullup(sda);

 // Drivers (open-drain)
 tran (scl, scl_drv);
 tran (sda, sda_drv);

 // Monitor views
 logic scl_mon;
 logic sda_mon;

 assign scl_mon = scl;
 assign sda_mon = sda;
endinterface
```

## `i2c_driver.sv`

```systemverilog
class i2c_driver extends uvm_driver #(i2c_item);
 virtual i2c_if vif;

 `uvm_component_utils(i2c_driver)

 function new(string name = "i2c_driver", uvm_component parent = null);
   super.new(name, parent);
 endfunction

 task run_phase(uvm_phase phase);
   i2c_item tr;

   forever begin
     seq_item_port.get_next_item(tr);
     drive_item(tr);
     seq_item_port.item_done();
   end
 endtask

 task drive_item(i2c_item tr);
   vif.sda_drv = 1'bz;
   vif.scl_drv = 1'bz;

   @(posedge vif.clk);

   // START condition
   vif.sda_drv = 0;
   @(posedge vif.clk);
   vif.scl_drv = 0;

   // Address + R/W
   drive_byte({tr.address, tr.read});

   // Data phase
   foreach (tr.data[i]) begin
     drive_byte(tr.data[i]);
   end

   // STOP condition
   vif.sda_drv = 0;
   vif.scl_drv = 1;
   @(posedge vif.clk);
   vif.sda_drv = 1;
   @(posedge vif.clk);
 endtask

 task drive_byte(bit [7:0] b);
   for (int i = 7; i >= 0; i--) begin
     vif.sda_drv = b[i];
     @(posedge vif.clk);
     vif.scl_drv = 1; @(posedge vif.clk);
     vif.scl_drv = 0;
   end

   // ACK cycle
   vif.sda_drv = 1'bz;
   @(posedge vif.clk);
   vif.scl_drv = 1;
   @(posedge vif.clk);
   vif.scl_drv = 0;
 endtask
endclass
```
 