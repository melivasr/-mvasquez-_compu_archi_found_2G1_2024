module uart_rx_mux_6 (
  input  logic sel,
  input  logic [2:0] in0,
  input  logic [2:0] in1,
  output logic [2:0] out
);
  // Implementación estructural del multiplexor 2:1
  logic [2:0] sel_extended;
  logic [2:0] not_sel_extended;
  logic [2:0] and_result0;
  logic [2:0] and_result1;

  // Extender sel a 3 bits
  assign sel_extended = {3{sel}};
  
  // Calcular el complemento de sel_extended
  assign not_sel_extended = ~sel_extended;

  // Aplicar AND bit a bit
  assign and_result0 = in0 & not_sel_extended;
  assign and_result1 = in1 & sel_extended;

  // Combinar los resultados con OR bit a bit
  assign out = and_result0 | and_result1;

endmodule