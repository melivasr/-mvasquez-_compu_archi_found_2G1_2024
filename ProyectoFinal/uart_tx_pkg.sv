// uart_tx_pkg.sv
package uart_tx_pkg;
  typedef enum logic [2:0] {
    s_IDLE         = 3'b000, 
    s_TX_START_BIT = 3'b001, 
    s_TX_DATA_BITS = 3'b010, 
    s_TX_STOP_BIT  = 3'b011, 
    s_CLEANUP      = 3'b100
  } state_t;
endpackage
