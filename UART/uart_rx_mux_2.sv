module uart_rx_mux_2(
  input  logic sel,
  input  logic in0,
  input  logic in1,
  output logic out
);
  // Structural implementation of 2:1 mux without using '?'
  wire not_sel;
  wire term1;
  wire term2;

  assign not_sel = ~sel;
  assign term1 = not_sel & in0;
  assign term2 = sel & in1;
  assign out = term1 | term2;
endmodule