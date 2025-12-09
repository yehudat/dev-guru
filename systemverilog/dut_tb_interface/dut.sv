// simple DUT containing two sub models. 
module DUT (input wire CLK,CS,WE);
  import common_pkg::*;

  wire CS_L = !CS;
  model #(WordSize1) sub1 (.CLK, .CS, .WE);
  model #(WordSize2) sub2 (.CLK, .CS(CS_L), .WE);
endmodule

// simple lower level modules internal to the DUT
module model (input wire CLK, CS, WE);
  parameter WordSize = 1;

  reg [WordSize-1:0] Mem;
  wire [WordSize-1:0] InternalBus;

  always @(posedge CLK)
  if (CS && WE) begin
    Mem = InternalBus;
    $display("%m Wrote %h at %t",InternalBus,$time);
  end

  assign InternalBus = (CS && !WE) ? Mem : 'z;
endmodule
