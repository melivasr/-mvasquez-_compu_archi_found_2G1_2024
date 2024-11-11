// masterUART.ino
// Definición de pines para los botones y UART
const int botonInfo1Pin = 2;       // GPIO2, Bit 1
const int botonInfo0Pin = 3;       // GPIO3, Bit 0
const int botonConfirmPin = 4;     // GPIO4, Confirmación
const int txPin = 7;               // GPIO7 para UART TX
// Pine UART rx predefinidos para Serial1

// Variables para detectar el cambio de estado del botón de confirmación
bool previousConfirmState = HIGH;  // Estado anterior del botón de confirmación (Inicialmente no presionado)
bool currentConfirmState = HIGH;   // Estado actual del botón de confirmación
bool buttonPressed = false;        // Bandera para indicar si el botón ha sido presionado

// Variables para el debounce del botón de confirmación
unsigned long lastDebounceTime = 0;
unsigned long debounceDelay = 50;  // 50 ms de debounce

void setup() {
  // Configurar los pines de los botones como entradas con resistencias pull-up internas
  pinMode(botonInfo1Pin, INPUT_PULLUP);
  pinMode(botonInfo0Pin, INPUT_PULLUP);
  pinMode(botonConfirmPin, INPUT_PULLUP);
  pinMode(txPin, OUTPUT);
  digitalWrite(txPin, HIGH);  // Estado inactivo (alto) en UART TX
  
  // Inicializar la comunicación UART y el monitor serial
  Serial1.begin(9600);  // Inicializa UART1 a 9600 baudios
  Serial.begin(9600);   // Inicializa el monitor serial a 9600 baudios

  Serial.println("Emisor y receptor UART iniciado. Esperando interacción...");
}

void loop() {
  // Leer el estado de los botones de información
  bool info1State = digitalRead(botonInfo1Pin) == LOW;  // Botón presionado es LOW
  bool info0State = digitalRead(botonInfo0Pin) == LOW;
  
  // Leer el estado actual del botón de confirmación
  int reading = digitalRead(botonConfirmPin);
  
  // Verificar si el estado del botón ha cambiado
  if (reading != previousConfirmState) {
    lastDebounceTime = millis();  // Reiniciar el contador de debounce
  }
  
  if ((millis() - lastDebounceTime) > debounceDelay) {
    // Si el estado ha permanecido estable por el tiempo de debounce
    if (reading != currentConfirmState) {
      currentConfirmState = reading;
      // Detectar cuando el botón se presiona
      if (currentConfirmState == LOW && !buttonPressed) {
        buttonPressed = true;
      }
      // Detectar cuando el botón se suelta
      if (currentConfirmState == HIGH && buttonPressed) {
        buttonPressed = false;
        // Construir un byte con los estados de los botones
        byte dataToSend = 0;
        dataToSend |= (info0State << 0);  // Bit 0
        dataToSend |= (info1State << 1);  // Bit 1
        // Enviar los datos a través de UART1 y mostrar detalles
        sendByte(dataToSend);
        enviarByteConDetalles(dataToSend);
      }
    }
  }
  
  // Actualizar el estado previo del botón de confirmación
  previousConfirmState = reading;
  
  // Verificar si hay datos recibidos en UART1
  if (Serial1.available()) {
    byte receivedData = Serial1.read();
    mostrarDetallesRecepcion(receivedData);
    // Reenviar los mismos datos a través de UART1
    sendByte(receivedData);
    enviarByteConDetalles(receivedData);
  }
}

// Función para enviar un byte y mostrar los detalles de la trama UART
void enviarByteConDetalles(unsigned char data) {
  // Construir la trama UART manualmente
  unsigned char trama[10];
  trama[0] = 0; // Start bit

  // Bits de datos (LSB primero)
  for (int i = 0; i < 8; i++) {
    trama[i + 1] = (data >> i) & 0x01;
  }

  trama[9] = 1; // Stop bit

  // Imprimir los bits individuales con etiquetas
  Serial.println("Transmisor: Detalles de la trama UART:");
  Serial.print("Start bit: ");
  Serial.println(trama[0]);
  for (int i = 1; i <= 8; i++) {
    Serial.print("Data bit D");
    Serial.print(i - 1);
    Serial.print(": ");
    Serial.println(trama[i]);
  }
  Serial.print("Stop bit: ");
  Serial.println(trama[9]);
  Serial.println();
  Serial.println();

  // Enviar el byte usando Serial1
  Serial1.write(data);
}

// Función para enviar un byte por UART utilizando software UART (bit-banging)
void sendByte(unsigned char data) {
  const int bitDuration = 104;  // Duración del bit en microsegundos para 9600 baudios
  // Deshabilitar interrupciones para mantener la temporización precisa
  noInterrupts();
  // Enviar start bit (LOW)
  digitalWrite(txPin, LOW);
  delayMicroseconds(bitDuration);
  // Enviar 8 bits de datos (LSB primero)
  for (int i = 0; i < 8; i++) {
    if (data & (1 << i)) {
      digitalWrite(txPin, HIGH);
    } else {
      digitalWrite(txPin, LOW);
    }
    delayMicroseconds(bitDuration);
  }
  // Enviar stop bit (HIGH)
  digitalWrite(txPin, HIGH);
  delayMicroseconds(bitDuration);
  // Habilitar interrupciones nuevamente
  interrupts();
}

// Función para mostrar los detalles de la recepción de un byte
void mostrarDetallesRecepcion(unsigned char data) {
  // Construir la trama UART manualmente (asumiendo que se recibió correctamente)
  unsigned char trama[10];
  trama[0] = 0; // Start bit

  // Bits de datos (LSB primero)
  for (int i = 0; i < 8; i++) {
    trama[i + 1] = (data >> i) & 0x01;
  }

  trama[9] = 1; // Stop bit

  // Imprimir los bits individuales con etiquetas
  Serial.println("Receptor: Detalles de la trama UART recibida:");
  Serial.print("Start bit: ");
  Serial.println(trama[0]);
  for (int i = 1; i <= 8; i++) {
    Serial.print("Data bit D");
    Serial.print(i - 1);
    Serial.print(": ");
    Serial.println(trama[i]);
  }
  Serial.print("Stop bit: ");
  Serial.println(trama[9]);
  Serial.println();
  Serial.println();
}