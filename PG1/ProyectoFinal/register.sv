module register(input logic [2:0] D, input logic clk, reset, output logic [2:0] Q);

	always_ff @(posedge clk, posedge reset) begin
		if (reset) Q<=3'h0;
		else Q<=D;
	end

endmodule 