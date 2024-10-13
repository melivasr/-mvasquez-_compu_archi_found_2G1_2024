// uart_tx_mux_1_structural.sv
module uart_tx_mux_1
  (
    input  uart_tx_pkg::state_t current_state,
    input  logic [7:0]             i_Tx_Byte,
    input  logic [2:0]             bit_index,
    output logic                   o_Tx_Serial
  );
  import uart_tx_pkg::*;

  // Declaración de señales intermedias para la detección de estados
  wire is_IDLE;
  wire is_TX_START_BIT;
  wire is_TX_DATA_BITS;
  wire is_TX_STOP_BIT;
  wire is_CLEANUP;

  // Instanciación de comparadores para cada estado
  Comparator_N_bits #(.N(3)) cmp_IDLE (
    .a(current_state),
    .b(s_IDLE),
    .equal(is_IDLE)
  );

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

  Comparator_N_bits #(.N(3)) cmp_CLEANUP (
    .a(current_state),
    .b(s_CLEANUP),
    .equal(is_CLEANUP)
  );

  // Asignación estructural de o_Tx_Serial
  assign o_Tx_Serial = (is_IDLE) |
                       (is_TX_STOP_BIT) |
                       (is_CLEANUP) |
                       (is_TX_DATA_BITS & i_Tx_Byte[bit_index]);

endmodule
