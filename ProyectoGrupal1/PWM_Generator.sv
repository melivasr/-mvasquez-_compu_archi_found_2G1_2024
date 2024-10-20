module PWM_Generator(input  logic clk, reset,  input  logic [1:0] duty_cycle, output logic pwm_out);


logic [2:0] oldcounter, addresult, newcounter;
logic [1:0]  carry_out;
logic valueconditional;


lessthan lessthan_1(oldcounter,3'h3, valueconditional);

mux2a1 mux2a1_1( 1'h0, addresult[0], valueconditional, newcounter[0]);
mux2a1 mux2a1_2( 1'h0, addresult[1], valueconditional, newcounter[1]);
mux2a1 mux2a1_3( 1'h0, addresult[2], valueconditional, newcounter[2]);


fulladderOP fulladder1(oldcounter[0], 1'h1, 1'h0, addresult[0], carry_out[0]);
fulladderOP fulladder2(oldcounter[1], 1'h0, carry_out[0], addresult[1], carry_out[1]);
fulladderOP fulladder3(oldcounter[2], 1'h0, carry_out[1], addresult[2] );

register register(newcounter, clk, reset, oldcounter);

lessthan lessthan_2(oldcounter, {1'h0,duty_cycle}, pwm_out);

endmodule

