module uart_handshake (
    input  logic        clock,
    input  logic        reset_n,
    input  logic        i_Rx_Serial,
    input  logic        t0,                   // Nueva señal desde el timer
    output logic        o_Tx_Serial,
    output logic        handshake_done,
    output logic        handshake_successful,
    output logic        handshake_fail,       // Nueva señal de falla
    output logic [3:0]  handshake_code
);

    // Señales internas
    logic        tx_start;
    logic [7:0]  tx_data;
    logic        tx_busy;
    logic        tx_done;
    logic [7:0]  rx_data;
    logic        rx_dv;
    logic        handshake_active;

    typedef enum logic [2:0] {
        HS_IDLE,
        HS_INIT,
        HS_WAIT_TX,
        HS_WAIT_RX,
        HS_DONE
    } hs_state_t;

    hs_state_t hs_state;

    // Instancias de UART TX y RX
    uart_tx #(
        .CLKS_PER_BIT(5208)
    ) uart_tx_inst (
        .i_Clock     (clock),
        .i_Enable    (handshake_active),
        .i_Tx_DV     (tx_start),
        .i_Tx_Byte   (tx_data),
        .o_Tx_Active (tx_busy),
        .o_Tx_Serial (o_Tx_Serial),
        .o_Tx_Done   (tx_done)
    );

    uart_rx #(
        .CLKS_PER_BIT(5208)
    ) uart_rx_inst (
        .i_Clock     (clock),
        .i_Enable    (handshake_active),
        .i_Rx_Serial (i_Rx_Serial),
        .o_Rx_DV     (rx_dv),
        .o_Rx_Byte   (rx_data)
    );

    // Máquina de estados para el handshake
    always_ff @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            hs_state            <= HS_IDLE;
            tx_start            <= 1'b0;
            tx_data             <= 8'd0;
            handshake_done      <= 1'b0;
            handshake_successful<= 1'b0;
            handshake_fail      <= 1'b0;
            handshake_active    <= 1'b0;
        end else begin
            if (t0 && !handshake_fail) begin
                // Iniciar nuevo handshake al recibir t0, si no ha fallado previamente
                hs_state            <= HS_INIT;
                handshake_done      <= 1'b0;
                handshake_successful<= 1'b0;
            end

            case (hs_state)
                HS_IDLE: begin
                    handshake_active <= 1'b0;
                    if (t0 && !handshake_fail) begin
                        hs_state <= HS_INIT;
                    end
                end
                HS_INIT: begin
                    handshake_active <= 1'b1;
                    tx_start <= 1'b1;
                    tx_data  <= 8'hFF;  // Enviar 11111111
                    hs_state <= HS_WAIT_TX;
                end
                HS_WAIT_TX: begin
                    tx_start <= 1'b0;
                    if (tx_done) begin
                        handshake_done <= 1'b1; // handshake_done es TRUE después de enviar 0xFF
                        hs_state <= HS_WAIT_RX;
                    end
                end
                HS_WAIT_RX: begin
                    if (rx_dv) begin
                        if (rx_data == 8'hFF) begin
                            handshake_successful <= 1'b1;
                            handshake_fail <= 1'b0;
                        end else begin
                            handshake_successful <= 1'b0;
                            handshake_fail <= 1'b1;  // Indicar falla en el handshake
                        end
                        hs_state <= HS_DONE;
                    end
                end
                HS_DONE: begin
                    handshake_active <= 1'b0;
                    // Permanecer en HS_DONE hasta el próximo t0
                end
                default: hs_state <= HS_IDLE;
            endcase
        end
    end

    // Asignación del código del handshake
    always_comb begin
        if (handshake_fail) begin
            handshake_code = 4'b1111; // 'F' Error en el handshake
        end else if (handshake_successful) begin
            handshake_code = 4'b1110; // 'E'
        end else begin
            handshake_code = 4'b0000; // Sin error, pero no existe conexión
        end
    end

endmodule
