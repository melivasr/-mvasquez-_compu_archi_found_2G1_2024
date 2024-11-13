import tkinter as tk
from interfaz.configuracion_ventana import ConfiguracionVentana

# # Configuración inicial
# root = tk.Tk()
# app = ConfiguracionVentana(root)
# root.mainloop()

from src.instruction_memory import InstructionMemory
from src.instruction_decoder import InstructionDecoder
from src.program_counter import ProgramCounter

if __name__ == "__main__":
    # Inicializar el Program Counter (PC)
    pc = ProgramCounter()

    # Crear la memoria de instrucciones y cargar las instrucciones en binario
    instructions = [
        0b00000000010000001000000010000011,  # LW R1, 4(R2)
        0b01000000010100010000001000100011,  # SW R2, 8(R1)
        0b00000000001000010000000110110011,  # ADD R3, R2, R1
        0b01000000001000010000000110110011,  # SUB R3, R2, R1
        0b00000000001000010111100110110011,  # AND R3, R2, R1
        0b00000000001000010110000110110011,  # OR R3, R2, R1
        0b00000000010100010000001000010011,  # ADDI R1, R2, 5
        0b00000000001000010010000110110011,  # SLT R3, R2, R1
        0b00000000001000001000001001100011,  # BEQ R1, R2, 4
        0b00000000000000000000001011101111,  # JAL R1, 10
    ]

    # Instancia de la memoria de instrucciones y cargar las instrucciones
    instruction_memory = InstructionMemory()
    instruction_memory.load_instructions(instructions)

    # Crear el decodificador de instrucciones
    decoder = InstructionDecoder()

    # Simular el ciclo de Fetch y Decode
    print("=== Ciclo de Fetch y Decode ===")
    while True:
        # Fetch: obtener la instrucción usando el valor actual del PC
        instruction = instruction_memory.fetch(pc.value)
        if instruction is None:
            break  # Salir cuando no hay más instrucciones

        # Decode: decodificar la instrucción
        decoded = decoder.decode(instruction)
        print(f"PC={pc.value}: Instrucción={instruction:032b} -> Decodificación={decoded}")

        # Incrementar el PC para la siguiente instrucción
        pc.increment()
