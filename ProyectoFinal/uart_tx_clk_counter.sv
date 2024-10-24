// uart_tx_clk_counter_structural.sv
module uart_tx_clk_counter
  #(parameter int CLKS_PER_BIT = 5208)
  (
    input  logic                i_Clock,        // Reloj
    input  logic                i_Enable,       // Habilitación (activo bajo)
    input  uart_tx_pkg::state_t next_state,     // Próximo estado
    output logic [15:0]         clock_count,    // Contador de reloj
    output logic                clk_count_enable // Habilita el contador
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
    .a(next_state),
    .b(s_IDLE),
    .equal(is_IDLE)
  );

  Comparator_N_bits #(.N(3)) cmp_TX_START_BIT (
    .a(next_state),
    .b(s_TX_START_BIT),
    .equal(is_TX_START_BIT)
  );

  Comparator_N_bits #(.N(3)) cmp_TX_DATA_BITS (
    .a(next_state),
    .b(s_TX_DATA_BITS),
    .equal(is_TX_DATA_BITS)
  );

  Comparator_N_bits #(.N(3)) cmp_TX_STOP_BIT (
    .a(next_state),
    .b(s_TX_STOP_BIT),
    .equal(is_TX_STOP_BIT)
  );

  Comparator_N_bits #(.N(3)) cmp_CLEANUP (
    .a(next_state),
    .b(s_CLEANUP),
    .equal(is_CLEANUP)
  );

  // Señal para determinar si el estado es de transmisión
  wire is_TX_STATE = is_TX_START_BIT | is_TX_DATA_BITS | is_TX_STOP_BIT;

  // Comparador para clock_count < CLKS_PER_BIT - 1
  wire [15:0] CLKS_PER_BIT_minus1 = CLKS_PER_BIT - 16'd1;
  wire is_count_less;
  Comparator_N_bits #(.N(16)) cmp_count_less (
    .a(clock_count),
    .b(CLKS_PER_BIT_minus1),
    .equal(is_count_less_eq) // Renombrado para claridad
  );
  assign is_count_less = (clock_count < CLKS_PER_BIT_minus1);

  // Suma clock_count + 1
  wire [15:0] clock_count_plus1;
  wire carry_out_add;
  Adder_N_bits #(.N(16)) adder (
    .a(clock_count),
    .b(16'd1),
    .sum(clock_count_plus1),
    .carry_out(carry_out_add)
  );

  // Mux para clock_count_next: si es TX_STATE y count < CLKS_PER_BIT-1, clock_count +1, else 0
  wire sel_mux_clock_count;
  assign sel_mux_clock_count = is_TX_STATE & is_count_less;

  wire [15:0] clock_count_mux_out;
  uart_tx_mux_4 mux_clock_count (
    .sel(sel_mux_clock_count),
    .a(clock_count_plus1),
    .b(16'd0),
    .y(clock_count_mux_out)
  );

  // Asignación de clk_count_enable
  wire enable_condition;
  assign enable_condition = (is_TX_STATE & ~is_count_less) | is_CLEANUP;

  // Mux para clk_count_enable: si enable_condition, 1, else 0
  wire clk_enable_out;
  uart_tx_mux_5 mux_clk_enable (
    .sel(enable_condition),
    .a(1'b1),
    .b(1'b0),
    .y(clk_enable_out)
  );

  // Flip-flops para clock_count y clk_count_enable
  wire reset = ~i_Enable;

  D_FF_Manual #(.N(16)) dff_clock_count (
    .clk(i_Clock),
    .reset(reset),
    .d(clock_count_mux_out),
    .q(clock_count)
  );

  D_FF_Manual #(.N(1)) dff_clk_enable (
    .clk(i_Clock),
    .reset(reset),
    .d(clk_enable_out),
    .q(clk_count_enable)
  );

endmodule
