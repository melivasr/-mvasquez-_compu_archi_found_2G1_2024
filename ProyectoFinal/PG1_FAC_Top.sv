module PG1_FAC_Top (
    input  logic        clock,
    input  logic        reset_n,
    input  logic        button,
    input  logic        i_Rx_Serial,
    input  logic [3:0]  entrada_dedos,
    input  logic [1:0]  operation,
    input  logic        confirm_btn,
    output logic        o_Tx_Serial,
    output logic [6:0]  seg_unidades,
    output logic [6:0]  seg_decenas,
    output logic [6:0]  seg_handshake,
    output logic [6:0]  seg_decodificador_dedos,
    output logic [6:0]  seg_resultado,
    output logic        motor_in1, 
    output logic        prueba
);

    // Señales internas
    logic [3:0] salida_decodificadaDedos_4bits;
    logic [7:0] r_data;
    logic handshaking;
    logic [1:0] salida_decodificada;
    logic [1:0] resultado_ALU;
    logic [1:0] acumulado;       // Registro para el acumulado
    logic [3:0] resultado_ALU_4bits;
    logic pwm_signal;
    logic [1:0] operands;        // Señal para operands

    // Sincronización y detección de confirm_btn
    logic confirm_btn_sync0, confirm_btn_sync1;
    logic confirm_btn_pulse;

    // Sincronización y detección de confirm_btn
    always_ff @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            confirm_btn_sync0 <= 1'b0;
            confirm_btn_sync1 <= 1'b0;
        end else begin
            confirm_btn_sync0 <= confirm_btn;
            confirm_btn_sync1 <= confirm_btn_sync0;
        end
    end

    assign confirm_btn_pulse = confirm_btn_sync0 && ~confirm_btn_sync1;

    // Asignar operands de r_data
    always_ff @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            operands <= 2'b00;
        end else begin
            operands <= r_data[1:0];
        end
    end

    // Detección de cambios en operands
    logic [1:0] operands_prev;
    logic operands_changed_pulse;

    always_ff @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            operands_prev <= 2'b00;
            operands_changed_pulse <= 1'b0;
        end else begin
            if (operands_prev != operands) begin
                operands_changed_pulse <= 1'b1;
                operands_prev <= operands;
            end else begin
                operands_changed_pulse <= 1'b0;
            end
        end
    end

    // Actualizar acumulado con prioridad a confirm_btn_pulse
    always_ff @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            acumulado <= 2'b00; // Resetear acumulado
        end else if (confirm_btn_pulse) begin
            acumulado <= resultado_ALU; // Actualizar con el resultado de la ALU
        end else if (operands_changed_pulse) begin
            acumulado <= operands; // Actualizar acumulado con operands cuando cambia
        end
    end

    // Decodificación de la entrada_dedos
    Decodificador_Dedos decodificador (
        .entrada(entrada_dedos),
        .salida(salida_decodificada)
    );

    // Conversión de salida decodificada a 4 bits
    assign salida_decodificadaDedos_4bits = {2'b00, salida_decodificada};

    // Conversión de acumulado a 4 bits para visualización
    assign resultado_ALU_4bits = {2'b00, acumulado};

    // Instancia del módulo BCD_to_7Segment para salida decodificada
    BCD_to_7Segment bcd_to_7seg (
        .bcd(salida_decodificadaDedos_4bits),
        .seg(seg_decodificador_dedos)
    );

    // Instancia del módulo BCD_to_7Segment para el acumulado
    BCD_to_7Segment bcd_to_7seg_result (
        .bcd(resultado_ALU_4bits),
        .seg(seg_resultado)
    );

    // Instancia única del módulo uart_fpga_top
    uart_fpga_top uart_instance (
        .clock(clock),
        .reset_n(reset_n),
        .button(button),
        .i_Rx_Serial(i_Rx_Serial),
        .o_Tx_Serial(o_Tx_Serial),
        .uart_enable(handshaking),
        .leds(r_data),
        .seg_unidades(seg_unidades),
        .seg_decenas(seg_decenas),
        .seg_handshake(seg_handshake)
    );

    // Instancia del FSM_ALU
    FSM_ALU fsm_instance (
        .clk(clock),
        .reset(~reset_n),
        .handshaking(handshaking),
        .confirm_op(confirm_btn_pulse),
        .switch_op(operation),
        .operand_a(acumulado),           // 'operand_a' es el acumulado
        .operand_b(salida_decodificada), // 'operand_b' es la salida decodificada
        .alu_result(resultado_ALU)
    );

    // Instancia del generador de PWM
    PWM_Generator pwm_instance (
        .clk(clock),
        .reset(~reset_n), 
        .duty_cycle(acumulado),
        .pwm_out(pwm_signal)
    );

    // Asignaciones de control del motor
    assign motor_in1 = pwm_signal;
    assign prueba = motor_in1;

endmodule
