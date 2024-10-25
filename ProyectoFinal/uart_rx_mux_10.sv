module uart_rx_mux_10 #(parameter WIDTH = 1) (
  input  logic [1:0] sel,
  input  logic [WIDTH-1:0] in0, in1, in2, in3,
  output logic [WIDTH-1:0] out
);
  logic [WIDTH-1:0] mux_out_1, mux_out_2;

  uart_rx_mux_8 #(WIDTH) mux_low (
    .sel(sel[0]),
    .in0(in0),
    .in1(in1),
    .out(mux_out_1)
  );

  uart_rx_mux_8 #(WIDTH) mux_high (
    .sel(sel[0]),
    .in0(in2),
    .in1(in3),
    .out(mux_out_2)
  );

  uart_rx_mux_8 #(WIDTH) mux_final (
    .sel(sel[1]),
    .in0(mux_out_1),
    .in1(mux_out_2),
    .out(out)
  );
endmodule