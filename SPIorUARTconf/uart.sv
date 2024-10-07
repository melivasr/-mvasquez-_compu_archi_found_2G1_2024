module uart(
	input logic clock,
	//input logic [7:0]  i_Tx_Byte,
	input  logic       i_Tx_DV,
	input  logic       i_Rx_Serial,
	input  logic       signal,
	output logic       o_Tx_Done,
	output logic [7:0] o_Rx_Byte,
	output logic o_Tx_Serial
	
);
	logic [7:0] i_Tx_Byte;

	uart_rx rx(
		.i_Clock(clock),
		.i_Rx_Serial(i_Rx_Serial),
		.o_Rx_Byte(o_Rx_Byte),
		.o_Rx_DV()
		
	);
	uart_tx tx(
	.i_Clock(clock),
	.i_Tx_DV(i_Tx_DV),
	.i_Tx_Byte(i_Tx_Byte),
	.o_Tx_Active(),
	.o_Tx_Serial(o_Tx_Serial), 
	.o_Tx_Done(o_Tx_Done)
	);
	
	always_comb begin
		if(signal == 0)begin
			i_Tx_Byte = 8'b00000001;
		end
		else begin
			i_Tx_Byte = 8'b01000001;
		end
	end
endmodule	