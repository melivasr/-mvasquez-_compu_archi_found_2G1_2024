class InstructionDecoder:
    def __init__(self):
        # Mapeo de instrucciones usando (opcode, funct3, funct7)
        self.instruction_map = {
            (0b0000011, 0b000, None): 'LW',  # Load Word (I-type)
            (0b0100011, 0b000, None): 'SW',  # Store Word (S-type)
            (0b0010011, 0b000, None): 'ADDI',  # Add Immediate (I-type)
            (0b1100011, 0b000, None): 'BEQ',  # Branch if Equal (B-type)
            (0b1101111, None, None): 'JAL',  # Jump and Link (J-type)
            (0b0110011, 0b000, 0b0000000): 'ADD',  # Add (R-type)
            (0b0110011, 0b000, 0b0100000): 'SUB',  # Subtract (R-type)
            (0b0110011, 0b111, 0b0000000): 'AND',  # And (R-type)
            (0b0110011, 0b110, 0b0000000): 'OR',  # Or (R-type)
            (0b0110011, 0b010, 0b0000000): 'SLT',  # Set Less Than (R-type)
        }

    def decode(self, instruction):
        # Extraer opcode, funct3 y funct7
        opcode = instruction & 0b1111111
        funct3 = (instruction >> 12) & 0b111 if opcode != 0b1101111 else None  # J-type no tiene funct3
        funct7 = (instruction >> 25) & 0b1111111 if opcode == 0b0110011 else None  # R-type usa funct7

        # Mostrar valores extraídos en formato binario para depuración
        funct3_str = f"{funct3:03b}" if funct3 is not None else "None"
        funct7_str = f"{funct7:07b}" if funct7 is not None else "None"
        print(f"Decoding instruction: opcode={opcode:07b}, funct3={funct3_str}, funct7={funct7_str}")

        # Buscar la instrucción en el mapa
        instruction_name = self.instruction_map.get((opcode, funct3, funct7), None)

        # Si no se encontró la instrucción
        if instruction_name is None:
            print(f"Error: Unknown instruction. Opcode: {opcode:07b}, Funct3: {funct3_str}, Funct7: {funct7_str}")
            return {
                'error': f'Unknown instruction format or opcode. Opcode: {opcode:07b}, Funct3: {funct3_str}, Funct7: {funct7_str}'}

        # Decodificar la instrucción según el nombre
        if instruction_name == 'LW':  # Load Word (I-type)
            rs1 = (instruction >> 15) & 0b11111
            rd = (instruction >> 7) & 0b11111
            imm = (instruction >> 20) & 0xFFF
            return {'type': 'I', 'name': 'LW', 'rd': rd, 'rs1': rs1, 'imm': imm}

        elif instruction_name == 'SW':  # Store Word (S-type)
            rs1 = (instruction >> 15) & 0b11111
            rs2 = (instruction >> 20) & 0b11111
            imm11_5 = (instruction >> 25) & 0b1111111
            imm4_0 = (instruction >> 7) & 0b11111
            imm = (imm11_5 << 5) | imm4_0
            return {'type': 'S', 'name': 'SW', 'rs1': rs1, 'rs2': rs2, 'imm': imm}

        elif instruction_name == 'ADDI':  # Add Immediate (I-type)
            rs1 = (instruction >> 15) & 0b11111
            rd = (instruction >> 7) & 0b11111
            imm = (instruction >> 20) & 0xFFF
            return {'type': 'I', 'name': 'ADDI', 'rd': rd, 'rs1': rs1, 'imm': imm}

        elif instruction_name == 'BEQ':  # Branch if Equal (B-type)
            rs1 = (instruction >> 15) & 0b11111
            rs2 = (instruction >> 20) & 0b11111
            imm12 = (instruction >> 31) & 0b1
            imm10_5 = (instruction >> 25) & 0b111111
            imm4_1 = (instruction >> 8) & 0b1111
            imm11 = (instruction >> 7) & 0b1
            imm = (imm12 << 12) | (imm11 << 11) | (imm10_5 << 5) | (imm4_1 << 1)
            return {'type': 'B', 'name': 'BEQ', 'rs1': rs1, 'rs2': rs2, 'imm': imm}

        elif instruction_name == 'JAL':  # Jump and Link (J-type)
            rd = (instruction >> 7) & 0b11111
            imm20 = (instruction >> 31) & 0b1
            imm10_1 = (instruction >> 21) & 0b1111111111
            imm11 = (instruction >> 20) & 0b1
            imm19_12 = (instruction >> 12) & 0xFF
            imm = (imm20 << 20) | (imm19_12 << 12) | (imm11 << 11) | (imm10_1 << 1)
            return {'type': 'J', 'name': 'JAL', 'rd': rd, 'imm': imm}

        elif opcode == 0b0110011:  # R-type instructions (ADD, SUB, AND, OR, SLT)
            rs1 = (instruction >> 15) & 0b11111
            rs2 = (instruction >> 20) & 0b11111
            rd = (instruction >> 7) & 0b11111

            # Handling based on funct3 and funct7
            if funct3 == 0b000:  # ADD / SUB
                if funct7 == 0b0000000:  # ADD
                    return {'type': 'R', 'name': 'ADD', 'rd': rd, 'rs1': rs1, 'rs2': rs2}
                elif funct7 == 0b0100000:  # SUB
                    return {'type': 'R', 'name': 'SUB', 'rd': rd, 'rs1': rs1, 'rs2': rs2}
            elif funct3 == 0b111:  # AND
                return {'type': 'R', 'name': 'AND', 'rd': rd, 'rs1': rs1, 'rs2': rs2}
            elif funct3 == 0b110:  # OR
                return {'type': 'R', 'name': 'OR', 'rd': rd, 'rs1': rs1, 'rs2': rs2}
            elif funct3 == 0b010:  # SLT (Set Less Than)
                return {'type': 'R', 'name': 'SLT', 'rd': rd, 'rs1': rs1, 'rs2': rs2}
            elif funct3 == 0b011:  # SLTU (Set Less Than Unsigned)
                return {'type': 'R', 'name': 'SLTU', 'rd': rd, 'rs1': rs1, 'rs2': rs2}

        return {'error': 'Unknown instruction format or opcode'}
