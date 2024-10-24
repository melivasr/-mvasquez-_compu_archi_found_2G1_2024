module uart_handshake (
    input  logic        clock,
    input  logic        reset_n,
    input  logic        i_Rx_Serial,
    input  logic        t0,
    output logic        o_Tx_Serial,
    output logic        handshake_done,
    output logic        handshake_successful,
    output logic        handshake_fail,
    output logic [3:0]  handshake_code
);

    // Señales internas (sin cambios)
    logic        tx_start, tx_busy, tx_done, rx_dv, handshake_active;
    logic [7:0]  tx_data, rx_data;
    logic [2:0]  hs_state, next_hs_state;
    logic        next_tx_start, next_handshake_done, next_handshake_successful, next_handshake_fail, next_handshake_active;
    logic [7:0]  next_tx_data;

    // Definición de estados (sin cambios)
    localparam [2:0] HS_IDLE    = 3'b000;
    localparam [2:0] HS_INIT    = 3'b001;
    localparam [2:0] HS_WAIT_TX = 3'b010;
    localparam [2:0] HS_WAIT_RX = 3'b011;
    localparam [2:0] HS_DONE    = 3'b100;

    // Instancias de UART TX y RX (sin cambios)
    uart_tx #(.CLKS_PER_BIT(5208)) uart_tx_inst (
        .i_Clock(clock),
        .i_Enable(handshake_active),
        .i_Tx_DV(tx_start),
        .i_Tx_Byte(tx_data),
        .o_Tx_Active(tx_busy),
        .o_Tx_Serial(o_Tx_Serial),
        .o_Tx_Done(tx_done)
    );

    uart_rx #(.CLKS_PER_BIT(5208)) uart_rx_inst (
        .i_Clock(clock),
        .i_Enable(handshake_active),
        .i_Rx_Serial(i_Rx_Serial),
        .o_Rx_DV(rx_dv),
        .o_Rx_Byte(rx_data)
    );

    // Lógica de próximo estado y salidas
    logic is_idle, is_init, is_wait_tx, is_wait_rx, is_done;
    logic t0_and_not_fail, tx_done_condition, rx_dv_condition;

    // Decodificador de estados (sin cambios)
    Comparator_N_bits #(3) cmp_idle (.a(hs_state), .b(HS_IDLE), .equal(is_idle));
    Comparator_N_bits #(3) cmp_init (.a(hs_state), .b(HS_INIT), .equal(is_init));
    Comparator_N_bits #(3) cmp_wait_tx (.a(hs_state), .b(HS_WAIT_TX), .equal(is_wait_tx));
    Comparator_N_bits #(3) cmp_wait_rx (.a(hs_state), .b(HS_WAIT_RX), .equal(is_wait_rx));
    Comparator_N_bits #(3) cmp_done (.a(hs_state), .b(HS_DONE), .equal(is_done));

    // Condiciones (sin cambios)
    assign t0_and_not_fail = t0 & ~handshake_fail;
    assign tx_done_condition = is_wait_tx & tx_done;
    assign rx_dv_condition = is_wait_rx & rx_dv;

    // Lógica para next_hs_state (corregida)
    logic [2:0] idle_next_state, done_next_state, wait_tx_next_state, wait_rx_next_state;
    
    // Reemplazo de assign con mux estructurales
    uart_handshake_mux_0 mux_idle_next_state (
        .sel(t0_and_not_fail),
        .in0(HS_IDLE),
        .in1(HS_INIT),
        .out(idle_next_state)
    );

    uart_handshake_mux_0 mux_done_next_state (
        .sel(t0_and_not_fail),
        .in0(HS_DONE),
        .in1(HS_INIT),
        .out(done_next_state)
    );

    uart_handshake_mux_0 mux_wait_tx_next_state (
        .sel(tx_done_condition),
        .in0(HS_WAIT_TX),
        .in1(HS_WAIT_RX),
        .out(wait_tx_next_state)
    );

    uart_handshake_mux_0 mux_wait_rx_next_state (
        .sel(rx_dv_condition),
        .in0(HS_WAIT_RX),
        .in1(HS_DONE),
        .out(wait_rx_next_state)
    );

    uart_rx_mux_9 #(3) next_state_mux (
        .sel(hs_state),
        .in0(idle_next_state),
        .in1(HS_WAIT_TX),
        .in2(wait_tx_next_state),
        .in3(wait_rx_next_state),
        .in4(done_next_state),
        .in5(HS_IDLE),
        .in6(HS_IDLE),
        .in7(HS_IDLE),
        .out(next_hs_state)
    );

    // Lógica para next_tx_start (sin cambios)
    assign next_tx_start = is_init | (is_wait_tx & ~tx_start);

    // Lógica para next_tx_data (sin cambios)
    uart_rx_mux_8 #(8) next_tx_data_mux (
        .sel(is_init),
        .in0(tx_data),
        .in1(8'hFF),
        .out(next_tx_data)
    );

    // Lógica para next_handshake_done (sin cambios)
    uart_rx_mux_2 next_handshake_done_mux (
        .sel(tx_done_condition | t0_and_not_fail),
        .in0(handshake_done),
        .in1(tx_done_condition),
        .out(next_handshake_done)
    );

    // Lógica para next_handshake_successful (corregida)
    logic rx_data_equals_ff;
    Comparator_N_bits #(8) rx_data_comp (
        .a(rx_data),
        .b(8'hFF),
        .equal(rx_data_equals_ff)
    );
    logic next_handshake_successful_temp;
    assign next_handshake_successful_temp = rx_dv_condition & rx_data_equals_ff;
    uart_rx_mux_2 next_handshake_successful_mux (
        .sel(rx_dv_condition | t0_and_not_fail),
        .in0(handshake_successful),
        .in1(next_handshake_successful_temp),
        .out(next_handshake_successful)
    );

    // Lógica para next_handshake_fail (corregida)
    logic rx_data_not_equals_ff;
    assign rx_data_not_equals_ff = ~rx_data_equals_ff;
    logic next_handshake_fail_temp;
    assign next_handshake_fail_temp = rx_dv_condition & rx_data_not_equals_ff;
    uart_rx_mux_2 next_handshake_fail_mux (
        .sel(rx_dv_condition | t0_and_not_fail),
        .in0(handshake_fail),
        .in1(next_handshake_fail_temp),
        .out(next_handshake_fail)
    );

    // Lógica para next_handshake_active (sin cambios)
    uart_rx_mux_9 #(1) next_handshake_active_mux (
        .sel(hs_state),
        .in0(t0_and_not_fail),
        .in1(1'b1),
        .in2(1'b1),
        .in3(1'b1),
        .in4(1'b0),
        .in5(1'b0),
        .in6(1'b0),
        .in7(1'b0),
        .out(next_handshake_active)
    );

    // Flip-flops para el estado y las señales de control (sin cambios)
    D_FF_Manual #(3) state_ff (
        .clk(clock),
        .reset(~reset_n),
        .d(next_hs_state),
        .q(hs_state)
    );

    D_FF_Manual #(1) tx_start_ff (
        .clk(clock),
        .reset(~reset_n),
        .d(next_tx_start),
        .q(tx_start)
    );

    D_FF_Manual #(8) tx_data_ff (
        .clk(clock),
        .reset(~reset_n),
        .d(next_tx_data),
        .q(tx_data)
    );

    D_FF_Manual #(1) handshake_done_ff (
        .clk(clock),
        .reset(~reset_n),
        .d(next_handshake_done),
        .q(handshake_done)
    );

    D_FF_Manual #(1) handshake_successful_ff (
        .clk(clock),
        .reset(~reset_n),
        .d(next_handshake_successful),
        .q(handshake_successful)
    );

    D_FF_Manual #(1) handshake_fail_ff (
        .clk(clock),
        .reset(~reset_n),
        .d(next_handshake_fail),
        .q(handshake_fail)
    );

    D_FF_Manual #(1) handshake_active_ff (
        .clk(clock),
        .reset(~reset_n),
        .d(next_handshake_active),
        .q(handshake_active)
    );

    // Lógica combinacional para handshake_code (corregida)
	 logic [3:0] handshake_code_fail, handshake_code_success, handshake_code_temp;
	 assign handshake_code_fail = 4'b1111;
	 assign handshake_code_success = 4'b1110;

	 // Utilizar uart_rx_mux_1 en lugar de uart_rx_mux_2 para manejar 4 bits
	 uart_rx_mux_1 handshake_code_mux1 (
		 .sel(handshake_fail),
		 .data0({4'b0, handshake_code_success}),
		 .data1({4'b0, handshake_code_fail}),
		 .data_out({4'b0, handshake_code_temp})
	 );

	 uart_rx_mux_1 handshake_code_mux2 (
		 .sel(handshake_successful | handshake_fail),
		 .data0({4'b0, 4'b0000}),
		 .data1({4'b0, handshake_code_temp}),
		 .data_out({4'b0, handshake_code})
	 );
endmodule