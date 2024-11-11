module uart_rx_mux_7 (
  input  logic [2:0] sel,
  input  logic [2:0] in0,
  input  logic [2:0] in1,
  input  logic [2:0] in2,
  input  logic [2:0] in3,
  input  logic [2:0] in4,
  output logic [2:0] out
);
  // Señales intermedias para los multiplexores
  logic [2:0] mux_out_01, mux_out_23, mux_out_0123;

  // Multiplexor para in0 e in1
  uart_rx_mux_6 mux_01 (
    .sel(sel[0]),
    .in0(in0),
    .in1(in1),
    .out(mux_out_01)
  );

  // Multiplexor para in2 e in3
  uart_rx_mux_6 mux_23 (
    .sel(sel[0]),
    .in0(in2),
    .in1(in3),
    .out(mux_out_23)
  );

  // Multiplexor para los resultados de mux_01 y mux_23
  uart_rx_mux_6 mux_0123 (
    .sel(sel[1]),
    .in0(mux_out_01),
    .in1(mux_out_23),
    .out(mux_out_0123)
  );

  // Multiplexor final para seleccionar entre mux_0123 e in4
  uart_rx_mux_6 mux_final (
    .sel(sel[2]),
    .in0(mux_out_0123),
    .in1(in4),
    .out(out)
  );

endmodule