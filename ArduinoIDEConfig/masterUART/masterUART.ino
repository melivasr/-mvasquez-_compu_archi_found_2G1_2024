// Definición de pines para los botones y UART
const int botonInfo1Pin = 2;       // GPIO2
const int botonInfo2Pin = 3;       // GPIO3
const int botonConfirmPin = 6;     // GPIO6
const int txPin = 7;               // GPIO7 para UART TX
const int rxPin = 8;               // GPIO8 para UART RX

// Variables para almacenar el estado actual de los botones de información
bool estadoInfo1 = HIGH;           // Inicialmente no presionado (pull-up)
bool estadoInfo2 = HIGH;

// Variables para el botón de confirmación
bool estadoConfirmAnterior = HIGH;
bool esperandoLiberacionConfirm = false;

// Variables para la recepción UART
unsigned char receivedByte = 0;

void setup() {
  // Iniciar la comunicación Serial USB para el monitor serial
  Serial.begin(115200);

  // Esperar a que se inicie el monitor serial (opcional)
  while (!Serial) {
    ; // Esperar a que se conecte el monitor serial
  }

  // Configurar los pines de los botones como entradas con resistencias de pull-up internas
  pinMode(botonInfo1Pin, INPUT_PULLUP);
  pinMode(botonInfo2Pin, INPUT_PULLUP);
  pinMode(botonConfirmPin, INPUT_PULLUP);

  // Configurar los pines de transmisión y recepción UART
  pinMode(txPin, OUTPUT);
  digitalWrite(txPin, HIGH);  // Estado inactivo (alto) en UART TX

  pinMode(rxPin, INPUT);  // Configurar rxPin como entrada

  Serial.println("Emisor y receptor UART iniciado. Esperando interacción...");
}

void loop() {
  // Leer el estado actual de los botones de información
  estadoInfo1 = digitalRead(botonInfo1Pin);
  estadoInfo2 = digitalRead(botonInfo2Pin);

  // Actualizar el registro de 8 bits basado en el estado de los botones de información
  unsigned char registro8Bits = 0x00;  // Resetear a 00000000
  if (estadoInfo1 == LOW) {
    registro8Bits |= (1 << 1);  // Establecer Bit 1
  }
  if (estadoInfo2 == LOW) {
    registro8Bits |= (1 << 0);  // Establecer Bit 0
  }

  // Leer el estado actual del botón de confirmación
  bool estadoConfirmActual = digitalRead(botonConfirmPin);

  // Detectar el flanco de bajada (presión del botón de confirmación)
  if (estadoConfirmAnterior == HIGH && estadoConfirmActual == LOW) {
    esperandoLiberacionConfirm = true;  // Indicar que estamos esperando que se suelte el botón
  }

  // Detectar el flanco de subida (liberación del botón de confirmación)
  if (esperandoLiberacionConfirm && estadoConfirmAnterior == LOW && estadoConfirmActual == HIGH) {
    // Enviar el byte por UART utilizando software UART
    sendByte(registro8Bits);
    esperandoLiberacionConfirm = false;  // Resetear el estado de espera
  }

  // Actualizar el estado anterior del botón de confirmación
  estadoConfirmAnterior = estadoConfirmActual;

  // Verificar si hay datos disponibles en UART
  if (digitalRead(rxPin) == LOW) {  // Detectar start bit
    // Iniciar la lectura del byte
    receivedByte = readByte();
    // (Opcional) Enviar una respuesta de vuelta
    sendByte(receivedByte);
  }
  // Pequeño retraso para estabilidad
  delay(10);
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

// Función para leer un byte por UART utilizando software UART (bit-banging)
unsigned char readByte() {
  const int bitDuration = 104;  // Duración del bit en microsegundos para 9600 baudios
  unsigned char data = 0;
  // Deshabilitar interrupciones para mantener la temporización precisa
  noInterrupts();
  // Ya hemos detectado el inicio del start bit (línea en LOW)
  // Esperar a la mitad del start bit para confirmar
  delayMicroseconds(bitDuration / 2);
  if (digitalRead(rxPin) != LOW) {
    // No es un start bit válido
    interrupts();
    return 0;
  }

  // Ahora, para cada uno de los 8 bits de datos
  for (int i = 0; i < 8; i++) {
    // Esperar un bit completo para llegar al centro del bit
    delayMicroseconds(bitDuration);
    // Leer el bit
    bool bit = digitalRead(rxPin);
    if (bit) {
      data |= (1 << i);
    }
  }

  // Esperar un bit completo para el stop bit
  delayMicroseconds(bitDuration);
  // Verificar el stop bit
  if (digitalRead(rxPin) != HIGH) {
    // Stop bit inválido
    interrupts();
    return 0;
  }

  // Habilitar interrupciones nuevamente
  interrupts();
  return data;
}