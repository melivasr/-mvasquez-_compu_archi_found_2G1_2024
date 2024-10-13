// uart_tx_mux_2_structural.sv
module uart_tx_mux_2
  (
    input  uart_tx_pkg::state_t current_state, // Estado actual
    output logic                   o_Tx_Done      // Indica si la transmisión está completa
  );
  import uart_tx_pkg::*;

  // Señal intermedia para el resultado del comparador
  wire is_CLEANUP;

  // Instanciación del comparador para verificar si current_state es s_CLEANUP
  Comparator_N_bits #(.N(3)) cmp_CLEANUP (
    .a(current_state),
    .b(s_CLEANUP),
    .equal(is_CLEANUP)
  );

  // Asignación estructural de o_Tx_Done
  assign o_Tx_Done = is_CLEANUP;

endmodule