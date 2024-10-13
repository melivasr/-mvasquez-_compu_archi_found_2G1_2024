// uart_tx_fsm_structural.sv
module uart_tx_fsm
  #(parameter int CLKS_PER_BIT = 5208)
  (
    input  logic                   i_Clock,        // Reloj
    input  logic                   i_Enable,       // Habilitación
    input  logic                   i_Tx_DV,        // Data Valid
    input  uart_tx_pkg::state_t    current_state,  // Estado actual
    input  logic [15:0]            clock_count,    // Contador de reloj
    input  logic [2:0]             bit_index,      // Índice de bit
    output uart_tx_pkg::state_t    next_state      // Próximo estado
  );
  import uart_tx_pkg::*;

  // Señales intermedias para la detección de estados
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

  // Condiciones de transición
  wire t1 = is_IDLE & i_Tx_DV;                                        // s_IDLE -> s_TX_START_BIT
  wire t2 = is_IDLE & ~i_Tx_DV;                                       // s_IDLE -> s_IDLE
  wire t3 = is_TX_START_BIT & (clock_count < CLKS_PER_BIT - 1);       // s_TX_START_BIT -> s_TX_START_BIT
  wire t4 = is_TX_START_BIT & (clock_count >= CLKS_PER_BIT - 1);      // s_TX_START_BIT -> s_TX_DATA_BITS
  wire t5 = is_TX_DATA_BITS & (clock_count < CLKS_PER_BIT - 1);       // s_TX_DATA_BITS -> s_TX_DATA_BITS
  wire t6 = is_TX_DATA_BITS & (clock_count >= CLKS_PER_BIT - 1) & (bit_index < 7); // s_TX_DATA_BITS -> s_TX_DATA_BITS
  wire t7 = is_TX_DATA_BITS & (clock_count >= CLKS_PER_BIT - 1) & (bit_index >= 7); // s_TX_DATA_BITS -> s_TX_STOP_BIT
  wire t8 = is_TX_STOP_BIT & (clock_count < CLKS_PER_BIT - 1);        // s_TX_STOP_BIT -> s_TX_STOP_BIT
  wire t9 = is_TX_STOP_BIT & (clock_count >= CLKS_PER_BIT - 1);       // s_TX_STOP_BIT -> s_CLEANUP
  wire t10 = is_CLEANUP;                                               // s_CLEANUP -> s_IDLE

  // Señales para cada bit de next_state
  wire next_state_bit2_t9 = t9;                                       // s_CLEANUP
  wire next_state_bit1_t4 = t4;
  wire next_state_bit1_t5 = t5;
  wire next_state_bit1_t6 = t6;
  wire next_state_bit1_t7 = t7;
  wire next_state_bit1_t8 = t8;
  wire next_state_bit0_t1 = t1;
  wire next_state_bit0_t3 = t3;
  wire next_state_bit0_t7 = t7;
  wire next_state_bit0_t8 = t8;

  // Asignación estructural de los bits de next_state
  assign next_state[2] = next_state_bit2_t9;

  assign next_state[1] = next_state_bit1_t4 | 
                          next_state_bit1_t5 | 
                          next_state_bit1_t6 | 
                          next_state_bit1_t7 | 
                          next_state_bit1_t8;

  assign next_state[0] = next_state_bit0_t1 | 
                          next_state_bit0_t3 | 
                          next_state_bit0_t7 | 
                          next_state_bit0_t8;

endmodule