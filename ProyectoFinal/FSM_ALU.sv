module FSM_ALU (
    input logic clk,
    input logic reset,
    input logic handshaking,
    input logic confirm_op,
    input logic [1:0] switch_op,
    input logic [1:0] operand_a,
    input logic [1:0] operand_b,
    output logic [1:0] alu_result
);
    logic [1:0] state;
    logic [1:0] next_state;
    logic alu_enable;
    logic [1:0] alu_out;
    logic [1:0] mux_out;

    // Decodificar estados actuales
    logic is_state_idle, is_state_wait_confirm, is_state_execute;
    assign is_state_idle         = ~state[1] & ~state[0];
    assign is_state_wait_confirm = ~state[1] &  state[0];
    assign is_state_execute      =  state[1] & ~state[0];

    // Calcular next_state combinando todas las condiciones en una sola asignación
    always_comb begin
        if (is_state_execute) begin
            next_state = 2'b00; // Volver a IDLE desde EXECUTE
        end else if (is_state_wait_confirm && confirm_op) begin
            next_state = 2'b10; // Cambiar a EXECUTE
        end else if (is_state_idle && handshaking) begin
            next_state = 2'b01; // Cambiar a WAIT_CONFIRM
        end else if (is_state_wait_confirm && ~confirm_op) begin
            next_state = 2'b01; // Permanecer en WAIT_CONFIRM si confirm_op es 0
        end else begin
            next_state = state; // Mantener el estado actual
        end
    end

    // Flip-Flops de Estado
    D_FF_Cell ff_state0 (
        .clk(clk),
        .reset(reset),
        .d(next_state[0]),
        .q(state[0])
    );
    D_FF_Cell ff_state1 (
        .clk(clk),
        .reset(reset),
        .d(next_state[1]),
        .q(state[1])
    );

    // Señal para habilitar la ALU
    assign alu_enable = is_state_execute;

    // Instancia de la ALU
    ALU alu_inst (
        .a(operand_a),
        .b(operand_b),
        .s(switch_op),
        .y(alu_out)
    );

    // Muxes para actualizar el resultado
    mux2a1 mux_bit0 (
        .a(alu_result[0]),  // Valor actual
        .b(alu_out[0]),     // Salida de la ALU
        .s(alu_enable),     // Habilitación
        .y(mux_out[0])      // Entrada al flip-flop
    );

    mux2a1 mux_bit1 (
        .a(alu_result[1]),
        .b(alu_out[1]),
        .s(alu_enable),
        .y(mux_out[1])
    );

    // Flip-Flops para almacenar el resultado
    D_FF_Cell ff_result0 (
        .clk(clk),
        .reset(reset),
        .d(mux_out[0]),
        .q(alu_result[0])
    );
    D_FF_Cell ff_result1 (
        .clk(clk),
        .reset(reset),
        .d(mux_out[1]),
        .q(alu_result[1])
    );

endmodule
