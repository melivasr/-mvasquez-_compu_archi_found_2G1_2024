`timescale 1ns / 1ps

module tb_uart_rx;

  // Clock period in nanoseconds
  parameter CLOCK_PERIOD_NS = 10;
  // UART parameters
  parameter int CLKS_PER_BIT = 5208;
  parameter BIT_PERIOD = CLKS_PER_BIT * CLOCK_PERIOD_NS;  // 52,080 ns per bit

  // Input and output signals
  logic i_Clock;
  logic i_Rx_Serial;
  logic o_Rx_DV;
  logic [7:0] o_Rx_Byte;

  // Instantiate the UART receiver
  uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uut (
    .i_Clock(i_Clock),
    .i_Rx_Serial(i_Rx_Serial),
    .o_Rx_DV(o_Rx_DV),
    .o_Rx_Byte(o_Rx_Byte)
  );

  // Generate a 100 MHz clock (10 ns period)
  always #(CLOCK_PERIOD_NS / 2) i_Clock = ~i_Clock;

  // Process to generate test signals
  initial begin
    // Initialization
    i_Clock = 1'b0;
    i_Rx_Serial = 1'b1;  // Idle line in UART is high

    // Wait before starting the test
    #(100 * BIT_PERIOD);

    // Send byte 0xA5 (10100101) via UART
    send_uart_byte(8'hA5);

    // Wait for the byte to be received
    #(10 * BIT_PERIOD);

    // Send byte 0x3C (00111100) via UART
    send_uart_byte(8'h3C);

    // Wait for the byte to be received
    #(10 * BIT_PERIOD);

    $stop;  // End simulation
  end

  // Task to send a byte via UART
  task send_uart_byte(input [7:0] data);
    integer i;

    // Send start bit (logic 0)
    i_Rx_Serial = 1'b0;
    #(BIT_PERIOD);

    // Send the 8 data bits, LSB first
    for (i = 0; i < 8; i = i + 1) begin
      i_Rx_Serial = data[i];
      #(BIT_PERIOD);
    end

    // Send stop bit (logic 1)
    i_Rx_Serial = 1'b1;
    #(BIT_PERIOD);

    // Wait at least one bit period before continuing
    #(BIT_PERIOD);
  endtask

endmodule
