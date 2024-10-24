module uart_rx_mux_5(
  input  logic [2:0] sel,
  input  logic [15:0] in0,
  input  logic [15:0] in1,
  output logic [15:0] out
);
  logic sel_condition;

  // Comparar sel con 3'b000
  Comparator_N_bits #(3) sel_comparator (
    .a(sel),
    .b(3'b000),
    .equal(sel_condition)
  );

  // Usar un multiplexor 2:1 para seleccionar entre in1 e in0
  uart_rx_mux_8 #(16) output_selector (
    .sel(sel_condition),
    .in0(in0),
    .in1(in1),
    .out(out)
  );

endmodule