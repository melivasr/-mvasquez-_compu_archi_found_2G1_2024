module uart_fpga_top (
    input  logic        clock,          // Reloj del sistema (ej. 50 MHz)
    input  logic        reset_n,        // Reset activo en bajo
    input  logic        button,         // Botón en la FPGA (activo en bajo)
    input  logic        i_Rx_Serial,    // Línea UART RX (entrada)
    output logic        o_Tx_Serial,    // Línea UART TX (salida)
	 output logic        uart_enable,
    output logic [7:0]  leds,           // LEDs de la FPGA para mostrar datos recibidos
    output logic [6:0]  seg_unidades,   // Display unidades del timer
    output logic [6:0]  seg_decenas,    // Display decenas del timer
    output logic [6:0]  seg_handshake   // Display para mostrar 'E' o 'F'
);

    // Señales internas
    logic        button_sync0, button_sync1;
    logic        button_prev;
    logic        button_released;
    logic [7:0]  rx_data;
    logic        rx_dv;
    logic [7:0]  received_data;

    // Señales para handshake
    logic handshake_done;
    logic handshake_successful;
    logic handshake_fail;
    logic [3:0] handshake_code;
    logic handshake_o_Tx_Serial;
    logic o_Tx_Serial_normal;


    // Señales para el timer
    logic t0;
    logic timer_enable;

    // Señales para lógica estructural
    logic [7:0] received_data_next;
	 
	 
    // Instanciación de los flip-flops para la sincronización del botón
    D_FF_Manual button_sync0_ff (
        .clk(clock),
        .reset(~reset_n),
        .d(button),
        .q(button_sync0)
    );

    D_FF_Manual button_sync1_ff (
        .clk(clock),
        .reset(~reset_n),
        .d(button_sync0),
        .q(button_sync1)
    );

    D_FF_Manual button_prev_ff (
        .clk(clock),
        .reset(~reset_n),
        .d(button_sync1),
        .q(button_prev)
    );

    // Detección del flanco de subida (liberación del botón)
    assign button_released = (button_prev == 1'b0) && (button_sync1 == 1'b1);

    // Habilitación de UART basada en handshake_successful y handshake_fail
    assign uart_enable = handshake_successful && ~handshake_fail;

    // Habilitación del timer
    assign timer_enable = ~handshake_fail;


    // Mux para received_data_next
    uart_fpga_top_mux_4 received_data_mux (
        .sel(uart_enable & rx_dv),
        .in0(received_data),
        .in1(rx_data),
        .out(received_data_next)
    );


    D_FF_Manual #(.N(8)) received_data_ff (
        .clk(clock),
        .reset(~reset_n),
        .d(received_data_next),
        .q(received_data)
    );

    // Instancia del módulo UART Receptor
    uart_rx #(
        .CLKS_PER_BIT(5208)
    ) uart_rx_inst (
        .i_Clock     (clock),
        .i_Enable    (uart_enable),
        .i_Rx_Serial (i_Rx_Serial),
        .o_Rx_DV     (rx_dv),
        .o_Rx_Byte   (rx_data)
    );

    // Instancia del módulo de handshake
    uart_handshake handshake_inst (
        .clock               (clock),
        .reset_n             (reset_n),
        .i_Rx_Serial         (i_Rx_Serial),
        .t0                  (t0),
        .o_Tx_Serial         (handshake_o_Tx_Serial),
        .handshake_done      (handshake_done),
        .handshake_successful(handshake_successful),
        .handshake_fail      (handshake_fail),
        .handshake_code      (handshake_code)
    );

    // Instancia de los multiplexores estructurales para reemplazar las asignaciones con "?"
    uart_fpga_top_mux_0 leds_mux (
        .sel(uart_enable),
        .in0(8'd0),
        .in1(received_data),
        .out(leds)
    );

    assign o_Tx_Serial = handshake_o_Tx_Serial;

    // Instancia del módulo Timer
    Timer timer_inst (
        .clk            (clock),
        .reset          (~reset_n || handshake_fail),  // Reset si hay falla en el handshake
        .enable         (timer_enable),
        .seg_unidades   (seg_unidades),
        .seg_decenas    (seg_decenas),
        .t0             (t0)
    );

    // Instancia del módulo BCD_to_7Segment para mostrar "E" o "F"
    BCD_to_7Segment bcd_to_7seg_inst (
        .bcd(handshake_code),
        .seg(seg_handshake)
    );

endmodule