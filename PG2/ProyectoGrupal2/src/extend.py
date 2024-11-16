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
        imm = (instruction >> 20) & 0xFFF  # Para la mayoría de instrucciones I
        if type_of_instruction == 'I':
            return self.sign_extend(imm)

        elif type_of_instruction == 'S':
            imm11_5 = (instruction >> 25) & 0x7F
            imm4_0 = (instruction >> 7) & 0x1F
            #imm = (imm11_5 << 5) | imm4_0
            return self.sign_extend(imm4_0, bits=12)

        elif type_of_instruction == 'B':
            imm12 = (instruction >> 31) & 0x1
            imm10_5 = (instruction >> 25) & 0x3F
            imm4_1 = (instruction >> 8) & 0xF
            imm11 = (instruction >> 7) & 0x1
            imm = (imm12 << 12) | (imm11 << 11) | (imm10_5 << 5) | (imm4_1 << 1)
            return self.sign_extend(imm, bits=13)

        elif type_of_instruction == 'U':
            imm = (instruction >> 12) & 0xFFFFF
            return imm

        return 0
