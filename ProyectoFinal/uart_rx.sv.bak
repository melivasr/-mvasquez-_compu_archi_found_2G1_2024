module uart_rx 
  #(parameter int CLKS_PER_BIT = 5208)
  (
   input  logic       i_Clock,
   input  logic       i_Rx_Serial,
   output logic       o_Rx_DV,     
   output logic [7:0] o_Rx_Byte
   );
    
  typedef enum logic [2:0] {
    s_IDLE = 3'b000, 
    s_RX_START_BIT = 3'b001, 
    s_RX_DATA_BITS = 3'b010, 
    s_RX_STOP_BIT  = 3'b011, 
    s_CLEANUP      = 3'b100
  } state_t;
  
  state_t r_SM_Main = s_IDLE;  // Estado inicial
   
  logic           r_Rx_Data_R = 1'b1;
  logic           r_Rx_Data   = 1'b1;
   
  logic [15:0]    r_Clock_Count = 16'd0;  // Aumentado para contar hasta CLKS_PER_BIT
  logic [2:0]     r_Bit_Index   = 3'd0;   // Índice para los 8 bits de datos
  logic [7:0]     r_Rx_Byte     = 8'd0;
  logic           r_Rx_DV       = 1'b0;   // Initialize to 0

  // Sincronizar la señal i_Rx_Serial para evitar problemas de metastabilidad
  always_ff @(posedge i_Clock) begin
    r_Rx_Data_R <= i_Rx_Serial;
    r_Rx_Data   <= r_Rx_Data_R;
  end
   
  // Máquina de estados para el receptor UART
  always_ff @(posedge i_Clock) begin
    case (r_SM_Main)
      // Estado IDLE: Espera el start bit
      s_IDLE: begin
        r_Rx_DV       <= 1'b0;  // Restablecer r_Rx_DV
        r_Clock_Count <= 16'd0;
        r_Bit_Index   <= 3'd0;
        r_Rx_Byte     <= 8'd0;   // Limpia el byte recibido
             
        if (r_Rx_Data == 1'b0)  // Start bit detectado
          r_SM_Main <= s_RX_START_BIT;
        else
          r_SM_Main <= s_IDLE;
      end
         
      // Estado START_BIT: Verifica si el start bit sigue en 0 a la mitad del ciclo
      s_RX_START_BIT: begin
        if (r_Clock_Count == (CLKS_PER_BIT-1)/2) begin
          if (r_Rx_Data == 1'b0) begin  // Verifica si el start bit es válido
            r_Clock_Count <= 16'd0;
            r_SM_Main     <= s_RX_DATA_BITS;  // Pasar al estado de recepción de datos
          end else begin
            r_SM_Main <= s_IDLE;  // Start bit inválido, regresar a IDLE
          end
        end else begin
          r_Clock_Count <= r_Clock_Count + 16'd1;
        end
      end
         
      // Estado DATA_BITS: Captura los 8 bits de datos, LSB primero
      s_RX_DATA_BITS: begin
        if (r_Clock_Count < CLKS_PER_BIT-1) begin
          r_Clock_Count <= r_Clock_Count + 16'd1;
        end else begin
          r_Clock_Count <= 16'd0;
          
          // Capturar el bit en la posición correcta
          r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;  
           
          if (r_Bit_Index < 3'd7) begin
            r_Bit_Index <= r_Bit_Index + 3'd1;
          end else begin
            r_Bit_Index <= 3'd0;
            r_SM_Main   <= s_RX_STOP_BIT;  // Todos los bits recibidos
          end
        end
      end
     
      // Estado STOP_BIT: Verifica el bit de parada
      s_RX_STOP_BIT: begin
        if (r_Clock_Count < CLKS_PER_BIT-1) begin
          r_Clock_Count <= r_Clock_Count + 16'd1;
        end else begin
          r_Rx_DV       <= 1'b1;  // Indica que el dato es válido
          r_Clock_Count <= 16'd0;
          r_SM_Main     <= s_CLEANUP;
        end
      end
     
      // Estado CLEANUP: Limpia las señales y vuelve a IDLE
      s_CLEANUP: begin
        r_SM_Main <= s_IDLE;
        r_Rx_DV   <= 1'b0;  // Restablece r_Rx_DV aquí
      end
     
      default: begin
        r_SM_Main <= s_IDLE;
      end
    endcase
  end   
   
  assign o_Rx_DV   = r_Rx_DV;
  assign o_Rx_Byte = r_Rx_Byte;
   
endmodule // uart_rx
