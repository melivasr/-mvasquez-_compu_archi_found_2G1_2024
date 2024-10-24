module register(input logic [3:0] D, input logic clk, reset, output logic [3:0] Q);

	always_ff @(posedge clk, posedge reset) begin
		if (reset) Q<=4'h0;
		else Q<=D;
	end

endmodule