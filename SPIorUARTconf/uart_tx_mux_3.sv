// uart_tx_mux_3_structural.sv
module uart_tx_mux_3
  (
    input  uart_tx_pkg::state_t current_state, // Estado actual
    output logic                   o_Tx_Active      // Indica si la transmisión está activa
  );
  import uart_tx_pkg::*;

  // Señales intermedias para los resultados de los comparadores
  wire is_TX_START_BIT;
  wire is_TX_DATA_BITS;
  wire is_TX_STOP_BIT;

  // Instanciación de comparadores para cada estado que activa la transmisión
  Comparator_N_bits #(.N(3)) cmp_TX_START_BIT (
    .a(current_state),
    .b(s_TX_START_BIT),
    .equal(is_TX_START_BIT)
  );

  Comparator_N_bits #(.N(3)) cmp_TX_DATA_BITS (
    .a(current_state),
    .b(s_TX_DATA_BITS),
    .equal(is_TX_DATA_BITS)
  );

  Comparator_N_bits #(.N(3)) cmp_TX_STOP_BIT (
    .a(current_state),
    .b(s_TX_STOP_BIT),
    .equal(is_TX_STOP_BIT)
  );

  // Asignación estructural de o_Tx_Active utilizando operaciones lógicas
  assign o_Tx_Active = is_TX_START_BIT | is_TX_DATA_BITS | is_TX_STOP_BIT;

endmodule