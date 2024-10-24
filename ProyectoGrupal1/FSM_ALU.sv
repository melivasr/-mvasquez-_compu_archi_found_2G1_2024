module FSM_ALU (
	input clk, reset, handshaking, confirm_op, 
	input logic [1:0] switch_op,
	input logic [1:0] operand_a, operand_b ,
	output logic [1:0] alu_result

);

	logic [1:0] state;
	logic [1:0] next_state;
	logic s1_not, s0_not, c_not;
	logic termn1_ns1, term2_ns1, term1_ns0, term2_ns0;
	logic alu_enable;
	logic [1:0] alu_out, mux_out;
	//Negados
	assign s1_not = ~state[1];
	assign s0_not = ~state[0];
	assign c_not = ~confirm_op;
	// NS1 = (~S1 * S0 * c) + (S1 * ~S0)
	// NS0 = (~S1 * ~S0 * h) + (~S1 * S0 *~c) + S1
	//Términos para NS1 y NS2
	assign termn1_ns1 = s1_not & state[0] & confirm_op;
	assign termn2_ns1 = state[1] & s0_not;
	assign termn1_ns0 = s1_not & s0_not & handshaking;
	assign termn2_ns0 = s1_not & state[0] & c_not;
	//Unión de términos
	assign next_state = termn1_ns1 | termn2_ns1;
	assign state = termn1_ns0 | termn2_ns0 | state[1];
	
	// Flip-Flops de Estado
	dff ff_state0(
		.clk(clk),
		.reset(reset),
		.d(next_state[0]),
		.q(state[0])
	);
	dff ff_state1(
		.clk(clk),
		.reset(reset),
		.d(next_state[1]),
		.q(state[1]),
	);
	
	assign alu_enable = state[1] & s0_not;
	
	ALU alu_inst(
		.a(operand_a),
		.b(operand_b),
		.s(switch_op),
		.y(alu_out),
		.c(),
		.z(),
		.n(),
		.o(),
	);
	//Muxes para seleccionar si el flipflop debe almacenar un nuevo resultado
	mux2a1 mux_bit0(
		.a(alu_result[0]),
		.b(alu_out[0]),
		.s(alu_enable),
		.y(mux_out[0])
	);
	
	mux2a1 mux_bit1(
		.a(alu_result[1]),
		.b(alu_out[1]),
		.s(alu_enable),
		.y(mux_out[1])
	);
	
	dff ff_result0(
		.clk(clk),
		.reset(reset),
		.d(mux_out[0]),
		.q(alu_result[0])
	);
	dff ff_result1(
		.clk(clk),
		.reset(reset),
		.d(mux_out[1]),
		.q(alu_result[1])
	);
	
	
	 

endmodule