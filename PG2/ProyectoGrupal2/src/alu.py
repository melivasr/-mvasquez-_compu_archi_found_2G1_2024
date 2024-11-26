class ALU:
    def __init__(self):
        pass

    def operate(self, input1, input2, ALUOp):
        if ALUOp == 0b00:  # ADDI (Add Immediate) or ADD (R-type)
            return input1 + input2
        elif ALUOp == 0b01:  # SUB (Subtract)
            return input1 - input2
        elif ALUOp == 0b10:  # AND
            return input1 & input2  # AND
        elif ALUOp == 0b11:  # OR
            return input1 | input2  # OR
        elif ALUOp == 0b100:  # Set Less Than (SLT)
            return 1 if input1 < input2 else 0
        elif ALUOp == 0b101:  # XOR
            return input1 ^ input2
        else:
            return 0  # Default
