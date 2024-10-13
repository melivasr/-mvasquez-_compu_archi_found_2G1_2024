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

    // Sincronización del botón al dominio de reloj
    always_ff @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            button_sync0 <= 1'b1;
            button_sync1 <= 1'b1;
            button_prev  <= 1'b1;
        end else begin
            button_sync0 <= button;
            button_sync1 <= button_sync0;
            button_prev  <= button_sync1;
        end
    end

    // Detección del flanco de subida (liberación del botón)
    assign button_released = (button_prev == 1'b0) && (button_sync1 == 1'b1);

    // Habilitación de UART basada en handshake_successful y handshake_fail
    assign uart_enable = handshake_successful && !handshake_fail;

    // Habilitación del timer
    assign timer_enable = !handshake_fail;

    // Lógica para iniciar la transmisión UART al liberar el botón
    always_ff @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            tx_start      <= 1'b0;
            tx_data       <= 8'd0;
            received_data <= 8'd0;
        end else begin
            if (uart_enable) begin
                if (button_released && !tx_busy) begin
                    tx_start <= 1'b1;
                    tx_data  <= switches;  // Captura el valor de los switches
                end else begin
                    tx_start <= 1'b0;
                end
                if (rx_dv) begin
                    received_data <= rx_data;
                end
            end else begin
                tx_start      <= 1'b0;
                // Opcionalmente, limpiar received_data
                // received_data <= 8'd0;
            end
        end
    end

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

    // Asignación del dato recibido a los LEDs después del handshake
    assign leds = (uart_enable) ? received_data : 8'd0;

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

    // Multiplexor para o_Tx_Serial
    assign o_Tx_Serial = uart_enable ? o_Tx_Serial_normal : handshake_o_Tx_Serial;

    // Instancia del módulo Timer
    Timer timer_inst (
        .clk            (clock),
        .reset          (!reset_n || handshake_fail),  // Reset si hay falla en el handshake
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