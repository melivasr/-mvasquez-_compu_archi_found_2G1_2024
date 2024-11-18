class Extend:
    def __init__(self):
        pass

    def sign_extend(self, immediate, bits=12):
        """
        Extiende el valor inmediato con signo dependiendo del tipo de instrucción.
        """
        if immediate & (1 << (bits - 1)):  # Si el bit más significativo es 1, es negativo
            return immediate | ~((1 << bits) - 1)  # Extiende con signo
        else:
            return immediate

    def execute(self, instruction, type_of_instruction):
        """
        Dependiendo del tipo de instrucción, se extiende el valor inmediato.
        """
        if type_of_instruction == 'I':
            # Para instrucciones tipo I: Imm[11:0]
            imm = instruction >> 20
            return self.sign_extend(imm, bits=12)

        elif type_of_instruction == 'S':
            # Para instrucciones tipo S: Imm[11:5|4:0]
            imm11_5 = (instruction >> 25) & 0x7F
            imm4_0 = (instruction >> 7) & 0x1F
            imm = (imm11_5 << 5) | imm4_0
            return self.sign_extend(imm, bits=12)

        elif type_of_instruction == 'B':
            # Para instrucciones tipo B: Imm[12|10:5|4:1|11]
            imm12 = (instruction >> 31) & 0x1
            imm10_5 = (instruction >> 25) & 0x3F
            imm4_1 = (instruction >> 8) & 0xF
            imm11 = (instruction >> 7) & 0x1
            imm = (imm12 << 12) | (imm11 << 11) | (imm10_5 << 5) | (imm4_1 << 1)
            return self.sign_extend(imm, bits=13)

        elif type_of_instruction == 'U':
            # Para instrucciones tipo U: Imm[31:12]
            imm = instruction & 0xFFFFF000
            return imm

        elif type_of_instruction == 'J':
            # Para instrucciones tipo J: Imm[20|10:1|11|19:12]
            imm20 = (instruction >> 31) & 0x1
            imm10_1 = (instruction >> 21) & 0x3FF
            imm11 = (instruction >> 20) & 0x1
            imm19_12 = (instruction >> 12) & 0xFF
            imm = (imm20 << 20) | (imm19_12 << 12) | (imm11 << 11) | (imm10_1 << 1)
            return self.sign_extend(imm, bits=21)

        return 0
