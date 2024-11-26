class HazardUnit:
    def __init__(self):
        self.stall = False
    def detect_hazards(self, decode_stage, execute_stage, memory_stage, mode):
        """
        Detecta riesgos de datos y saltos (en full_hazard_unit).
        Retorna:
        - stall_needed: Indica si se requiere un stall.
        - forwarding_signals: Señales para aplicar forwarding.
        - branch_prediction: Predicción de saltos (si aplica en modo full_hazard_unit).
        """
        if not decode_stage:
            return False, {}, None
        
        rs1 = decode_stage["decoded"].get("rs1")
        rs2 = decode_stage["decoded"].get("rs2")
        stall_needed = False
        forwarding_signals = {}
        branch_prediction = None


        # Forwarding y Stalls para ambos modos
        if mode in ["hazard_unit", "full_hazard_unit"]:
            # Forwarding desde Execute 
            if execute_stage:
                ex_rd = execute_stage["decoded"].get("rd")
                if execute_stage["control_signals"]["MemRead"]:
                    if ex_rd in [rs1, rs2]:
                        print(f"Hazard detectado: registrando stall. rd={ex_rd}, rs1={rs1}, rs2={rs2}")
                        stall_needed = True

            if memory_stage:
                mem_rd = memory_stage["decoded"].get("rd")
                mem_control = memory_stage["control_signals"]
                if mem_rd == rs1 and mem_rd is not None:
                    forwarding_signals["rs1"] = "memory"
                if mem_rd == rs2 and mem_rd is not None:
                    forwarding_signals["rs2"] = "memory"
                if mem_control['MemRead'] and mem_rd in [rs1, rs2] and mem_rd is not None:
                    print(f"Stalling decode: Dependencia de datos con lw (R{mem_rd})")
                    stall_needed = True
        if mode == "full_hazard_unit":
            branch_prediction = self.handle_branch_prediction(decode_stage)
        return stall_needed, forwarding_signals, branch_prediction
    
    def handle_branch_prediction(self, decode_stage):
         """
        Implementa la predicción de salto estética (Siempre predice que no hay salto)
        """
         instruction_name = decode_stage["decoded"]["instruction"]
         if instruction_name == "BEQ":
                return False
         return None


