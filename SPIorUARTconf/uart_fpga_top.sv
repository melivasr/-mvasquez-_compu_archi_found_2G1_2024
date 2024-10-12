module uart_fpga_top (
    input  logic        clock,          // Reloj del sistema (ej. 50 MHz)
    input  logic        reset_n,        // Reset activo en bajo
    input  logic        button,         // Botón en la FPGA (activo en bajo)
    input  logic [7:0]  switches,       // Switches de la FPGA para ingresar datos
    input  logic        i_Rx_Serial,    // Línea UART RX (entrada)
    output logic        o_Tx_Serial,    // Línea UART TX (salida)
    output logic [7:0]  leds            // LEDs de la FPGA para mostrar datos recibidos
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

    // Lógica para iniciar la transmisión UART al liberar el botón
    always_ff @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            tx_start <= 1'b0;
            tx_data  <= 8'd0;
				received_data <= 8'd0;
        end else begin
            if (button_released && !tx_busy) begin
                tx_start <= 1'b1;
                tx_data  <= switches;  // Captura el valor de los switches
            end else begin
                tx_start <= 1'b0;
            end if (rx_dv) begin
                received_data <= rx_data;
            end
        end
    end

    // Instancia del módulo UART Transmisor
    uart_tx #(
        .CLKS_PER_BIT(5208)  // Calculado para 9600 baudios con un reloj de 50 MHz
    ) uart_tx_inst (
        .i_Clock    (clock),
        .i_Tx_DV    (tx_start),
        .i_Tx_Byte  (tx_data),
        .o_Tx_Active(tx_busy),
        .o_Tx_Serial(o_Tx_Serial),
        .o_Tx_Done  (tx_done)
    );

    // Instancia del módulo UART Receptor
    uart_rx #(
        .CLKS_PER_BIT(5208)
    ) uart_rx_inst (
        .i_Clock   (clock),
        .i_Rx_Serial(i_Rx_Serial),
        .o_Rx_DV   (rx_dv),
        .o_Rx_Byte (rx_data)
    );

    // Asignación del dato recibido a los LEDs
    assign leds = received_data;

endmodule