module FSM_ALU (
    input logic clk,
    input logic reset,
    input logic handshaking,
    input logic confirm_op,
    input logic [1:0] switch_op,
    input logic [1:0] operand_a,
    input logic [1:0] operand_b,
    output logic [1:0] alu_result,
    output logic       z,
    output logic       n,
    output logic       o,
    output logic       c
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

    // Calcular next_state utilizando asignaciones combinacionales
    assign next_state[1] = (~state[1] & state[0] & confirm_op);
    assign next_state[0] = (~state[1] & ~state[0] & handshaking) | 
                           (~state[1] & state[0] & ~confirm_op);

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
        .y(alu_out),
        .c(c),
        .z(z),
        .n(n),
        .o(o)
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
