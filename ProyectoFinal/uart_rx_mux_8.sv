module uart_rx_mux_8 #(parameter WIDTH = 1) (
  input  logic sel,
  input  logic [WIDTH-1:0] in0,
  input  logic [WIDTH-1:0] in1,
  output logic [WIDTH-1:0] out
);
  logic [WIDTH-1:0] sel_extended;
  logic [WIDTH-1:0] sel_in0;
  logic [WIDTH-1:0] sel_in1;

  // Extender sel a WIDTH bits
  assign sel_extended = {WIDTH{sel}};

  // Seleccionar in0 cuando sel es 0
  assign sel_in0 = in0 & ~sel_extended;

  // Seleccionar in1 cuando sel es 1
  assign sel_in1 = in1 & sel_extended;

  // Combinar las selecciones
  assign out = sel_in0 | sel_in1;

endmodule