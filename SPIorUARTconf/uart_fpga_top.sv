module uart_fpga_top (
    input  logic        clock,          // Reloj del sistema (ej. 50 MHz)
    input  logic        reset_n,        // Reset activo en bajo
    input  logic        button,         // Botón en la FPGA (activo en bajo)
    input  logic [7:0]  switches,       // Switches de la FPGA para ingresar datos
    input  logic        i_Rx_Serial,    // Línea UART RX (entrada)
    output logic        o_Tx_Serial,    // Línea UART TX (salida)
    output logic [7:0]  leds,           // LEDs de la FPGA para mostrar datos recibidos
    output logic [6:0]  seg_unidades,   // Display unidades del timer
    output logic [6:0]  seg_decenas,    // Display decenas del timer
    output logic [6:0]  seg_handshake   // Display para mostrar 'E' o 'F'
);

    // Señales internas
    logic        button_sync0, button_sync1;
    logic        button_prev;
    logic        button_released;
    logic        tx_start;
    logic [7:0]  tx_data;
    logic        tx_busy;
    logic        tx_done;
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
    logic uart_enable;

    // Señales para el timer
    logic t0;
    logic timer_enable;

    // Señales para lógica estructural
    logic tx_start_next;
    logic [7:0] tx_data_next;
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

    // Generación de señales para los multiplexores
    // Mux para tx_start_next
    uart_fpga_top_mux_2 tx_start_mux (
        .sel(uart_enable & button_released & ~tx_busy),
        .in0(1'b0),
        .in1(1'b1),
        .out(tx_start_next)
    );

    // Mux para tx_data_next
    uart_fpga_top_mux_3 tx_data_mux (
        .sel(uart_enable & button_released & ~tx_busy),
        .in0(tx_data),
        .in1(switches),
        .out(tx_data_next)
    );

    // Mux para received_data_next
    uart_fpga_top_mux_4 received_data_mux (
        .sel(uart_enable & rx_dv),
        .in0(received_data),
        .in1(rx_data),
        .out(received_data_next)
    );

    // Instanciación de los flip-flops para tx_start, tx_data y received_data
    D_FF_Manual #(.N(1)) tx_start_ff (
        .clk(clock),
        .reset(~reset_n),
        .d(tx_start_next),
        .q(tx_start)
    );

    D_FF_Manual #(.N(8)) tx_data_ff (
        .clk(clock),
        .reset(~reset_n),
        .d(tx_data_next),
        .q(tx_data)
    );

    D_FF_Manual #(.N(8)) received_data_ff (
        .clk(clock),
        .reset(~reset_n),
        .d(received_data_next),
        .q(received_data)
    );

    // Instancia del módulo UART Transmisor
    uart_tx #(
        .CLKS_PER_BIT(5208)  // Calculado para 9600 baudios con un reloj de 50 MHz
    ) uart_tx_inst (
        .i_Clock     (clock),
        .i_Enable    (uart_enable),
        .i_Tx_DV     (tx_start),
        .i_Tx_Byte   (tx_data),
        .o_Tx_Active (tx_busy),
        .o_Tx_Serial (o_Tx_Serial_normal),
        .o_Tx_Done   (tx_done)
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

    uart_fpga_top_mux_1 tx_serial_mux (
        .sel(uart_enable),
        .in0(handshake_o_Tx_Serial),
        .in1(o_Tx_Serial_normal),
        .out(o_Tx_Serial)
    );

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