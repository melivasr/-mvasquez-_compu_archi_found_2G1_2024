import tkinter as tk
from asyncio import wait_for
import time

from interfaz.configuracion_ventana import ConfiguracionVentana



from src.control_unit import ControlUnit
from src.instruction_decoder import InstructionDecoder
from src.register_file import RegisterFile
from src.extend import Extend
from src.alu import ALU
from src.instruction_memory import InstructionMemory
from src.program_counter import ProgramCounter
from src.data_memory import DataMemory
from src.pipeline import Pipeline
from src.data_memory import DataMemory

if __name__ == "__main__":
    # Instancias necesarias
    pc = ProgramCounter()
    instruction_memory = InstructionMemory()
    data_memory = DataMemory()  # Instancia de la memoria de datos
    decoder = InstructionDecoder()
    control_unit = ControlUnit()
    register_file = RegisterFile()
    alu = ALU()
    extend = Extend()

    # Instrucciones de ejemplo
    instructions = [
        0b00000000010000010000000010000011,  # LW R1, 4(R2)
        0b00000000001000001000010000100011,  # SW R2, 8(R1) (Esta instrucción se debe retrasar un ciclo para recibir el valor de R1)
        0b00000000001000001000000110110011,  # ADD R3, R1, R2
        0b01000000001000001000000110110011,  # SUB R3, R1, R2
        0b00000000000100010111000110110011,  # AND R3, R2, R1
        0b00000000000100010110000110110011,  # OR R3, R2, R1
        0b00000000010100010000000010010011,  # ADDI R1, R2, 5
        0b00000000000100010010000110110011,  # SLT R3, R2, R1
        0b11111110001000010000110011100011,  # BEQ R2, R2, -4
        0b00000000000100010001000110110011,  # XOR R3, R2, R1
    ]
    instruction_memory.load_instructions(instructions)

    # Crear el pipeline
    pipeline = Pipeline(pc, instruction_memory, register_file, data_memory, alu, decoder, extend, control_unit)

    # # Configuración inicial
    root = tk.Tk()
    app = ConfiguracionVentana(root, pipeline)
    root.mainloop()


    """ # Simulación del ciclo Fetch y Decode
    print("=== Ciclo de Fetch y Decode ===")
    while True:
        # Fetch: obtener la instrucción usando el valor actual del PC
        instruction = instruction_memory.fetch(pc.value)
        if instruction is None:
            break  # Salir cuando no hay más instrucciones

        # Decode: decodificar la instrucción
        decoded = decoder.decode(instruction)
        print(f"PC={pc.value}: Instrucción={instruction:032b} -> Decodificación={decoded}")

        # Generar señales de control
        control_unit.generate_signals(instruction & 0b1111111, (instruction >> 12) & 0b111,
                                      (instruction >> 25) & 0b1111111)
        print(f"Control signals: {control_unit}")

        # Execute: Ejecución de la ALU
        if decoded['type'] == 'R':  # Para instrucciones tipo R (ADD, SUB, etc.)
            input1 = register_file.read(decoded['rs1'])
            input2 = register_file.read(decoded['rs2'])
            print(f"Executing ALU operation")
            alu_result = alu.operate(input1, input2, control_unit.ALUOp)
            print(f"ALU Result: {alu_result}")
        elif decoded['type'] == 'I':  # Para instrucciones tipo I (ADDI, etc.)
            input1 = register_file.read(decoded['rs1'])
            extended_imm = extend.execute(instruction, decoded['type'])
            print(f"Executing ALU operation: {input1} and immediate {extended_imm}")
            alu_result = alu.operate(input1, extended_imm, control_unit.ALUOp)
            print(f"ALU Result: {alu_result}")
        elif decoded['type'] == 'S':  # Para instrucciones tipo S (Store)
            extended_imm = extend.execute(instruction, decoded['type'])
            alu_result = alu.operate(register_file.read(decoded['rs1']), extended_imm, control_unit.ALUOp)
        elif decoded['type'] == 'B':
            input1 = register_file.read(decoded['rs1'])
            input2 = register_file.read(decoded['rs2'])
            print(f"Executing ALU operation")
            alu_result = alu.operate(input1, input2, control_unit.ALUOp)
            print(f"ALU Result: {alu_result}")
            extended_imm = extend.execute(instruction, decoded['type'])

            if alu_result==0:
                pc.set(extended_imm)
                print(pc.value)



        # Memory: Acceder a la memoria si la instrucción es de tipo LW o SW
        if control_unit.MemRead:  # LW (Load Word)
            memory_data = data_memory.read(alu_result)  # Leemos desde la dirección de la memoria
            print(f"Memory read: {memory_data}")
        if control_unit.MemWrite:  # SW (Store Word)
            data_memory.write(alu_result, register_file.read(decoded['rs2']))  # Escribimos en la memoria
            print(data_memory.display())
            print(f"Memory write: Data stored at {alu_result}")

        # WriteBack: Escribir el resultado de la ALU en el registro correspondiente
        if control_unit.RegWrite:
            if decoded['type'] == 'R' or (decoded['type'] == 'I' and decoded[
                'name'] == 'ADDI'):  # En instrucciones R o I
                print(f"Contenido antes de escritura de rd: {register_file.read(decoded['rd'])}")
                register_file.write(decoded['rd'], alu_result)
                print(f"WriteBack: Written {alu_result} to register {decoded['rd']}")
                print(f"R{decoded['rd']}:", register_file.read(decoded['rd']))


            elif decoded['type'] == 'I' and decoded[
                'name'] == 'LW':  # En instrucciones LW, escribir de memoria a registro
                register_file.write(decoded['rd'], memory_data)
                print(f"WriteBack: Written {memory_data} to register {decoded['rd']}")


        # Incrementar el PC para la siguiente instrucción
        pc.increment()

        time.sleep(3)"""
