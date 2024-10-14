module uart_rx_mux_3(
  input  logic [1:0] sel,
  input  logic [2:0] in0,
  input  logic [2:0] in1,
  input  logic [2:0] in2,
  output logic [2:0] out
);

  // Intermediate wires for the first level of multiplexing
  wire mux0_out0;
  wire mux0_out1;
  wire mux0_out2;

  // First level mux: Select between in0 and in1 based on sel[0]
  uart_rx_mux_2 mux0_bit0 (
    .sel(sel[0]),
    .in0(in0[0]),
    .in1(in1[0]),
    .out(mux0_out0)
  );

  uart_rx_mux_2 mux0_bit1 (
    .sel(sel[0]),
    .in0(in0[1]),
    .in1(in1[1]),
    .out(mux0_out1)
  );

  uart_rx_mux_2 mux0_bit2 (
    .sel(sel[0]),
    .in0(in0[2]),
    .in1(in1[2]),
    .out(mux0_out2)
  );

  // Second level mux: Select between the first mux output and in2 based on sel[1]
  uart_rx_mux_2 mux1_bit0 (
    .sel(sel[1]),
    .in0(mux0_out0),
    .in1(in2[0]),
    .out(out[0])
  );

  uart_rx_mux_2 mux1_bit1 (
    .sel(sel[1]),
    .in0(mux0_out1),
    .in1(in2[1]),
    .out(out[1])
  );

  uart_rx_mux_2 mux1_bit2 (
    .sel(sel[1]),
    .in0(mux0_out2),
    .in1(in2[2]),
    .out(out[2])
  );

endmodule