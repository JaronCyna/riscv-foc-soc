import sys

# Standalone 32-bit RISC-V (RV32I) Golden Interpreter
def run_riscv_hex(filename):
    with open(filename, "r") as f:
        hex_lines = [line.strip() for line in f if line.strip()]

    # Load 32-bit instructions into memory
    imem = [int(h, 16) for h in hex_lines]

    # Initialize 32 registers and 2048-word data memory
    regs = [0] * 32
    dmem = [0] * 2048

    pc = 0
    max_steps = 200000
    steps = 0

    while (pc // 4) < len(imem) and steps < max_steps:
        
        inst = imem[pc // 4]
        steps += 1

        opcode = inst & 0x7F
        rd     = (inst >> 7) & 0x1F
        funct3 = (inst >> 12) & 0x07
        rs1    = (inst >> 15) & 0x1F
        rs2    = (inst >> 20) & 0x1F
        funct7 = (inst >> 25) & 0x7F

        next_pc = pc + 4

        # OP (R-type)
        if opcode == 0x33:
            val1 = regs[rs1]
            val2 = regs[rs2]
            if funct3 == 0x0: # ADD/SUB
                res = (val1 - val2) if (funct7 == 0x20) else (val1 + val2)
            elif funct3 == 0x1: res = (val1 << (val2 & 31)) # SLL
            elif funct3 == 0x2: res = 1 if (int(val1) < int(val2)) else 0 # SLT
            elif funct3 == 0x3: res = 1 if ((val1 & 0xFFFFFFFF) < (val2 & 0xFFFFFFFF)) else 0 # SLTU
            elif funct3 == 0x4: res = val1 ^ val2 # XOR
            elif funct3 == 0x5: # SRL/SRA
                res = (val1 >> (val2 & 31)) if (funct7 == 0x00) else ((val1 if val1 < 0x80000000 else val1 - 0x100000000) >> (val2 & 31))
            elif funct3 == 0x6: res = val1 | val2 # OR
            elif funct3 == 0x7: res = val1 & val2 # AND
            if rd != 0: regs[rd] = res & 0xFFFFFFFF

        # OP-IMM (I-type)
        elif opcode == 0x13:
            imm_i = inst >> 20
            if imm_i & 0x800: imm_i -= 0x1000 # Sign extend 12 bits
            val1 = regs[rs1]
            if funct3 == 0x0: res = val1 + imm_i # ADDI
            elif funct3 == 0x4: res = val1 ^ imm_i # XORI
            elif funct3 == 0x6: res = val1 | imm_i # ORI
            elif funct3 == 0x7: res = val1 & imm_i # ANDI
            elif funct3 == 0x1: res = val1 << (imm_i & 31) # SLLI
            elif funct3 == 0x5: # SRLI/SRAI
                shamt = imm_i & 31
                res = (val1 >> shamt) if ((inst >> 30) == 0) else ((val1 if val1 < 0x80000000 else val1 - 0x100000000) >> shamt)
            if rd != 0: regs[rd] = res & 0xFFFFFFFF

        # LOAD (I-type)
        elif opcode == 0x03:
            imm_i = inst >> 20
            if imm_i & 0x800: imm_i -= 0x1000
            addr = (regs[rs1] + imm_i) & 0x1FF
            word_idx = (addr // 4) % len(dmem)
            if funct3 == 0x2: # LW
                if rd != 0: regs[rd] = dmem[word_idx] & 0xFFFFFFFF

        # STORE (S-type)
        elif opcode == 0x23:
            imm_s = ((inst >> 25) << 5) | ((inst >> 7) & 0x1F)
            if imm_s & 0x800: imm_s -= 0x1000
            addr = (regs[rs1] + imm_s) & 0x1FF
            word_idx = (addr // 4) % len(dmem)
            if funct3 == 0x2: # SW
                dmem[word_idx] = regs[rs2] & 0xFFFFFFFF

        # BRANCH (B-type)
        elif opcode == 0x63:
            imm_b = (((inst >> 31) & 1) << 12) | (((inst >> 7) & 1) << 11) | (((inst >> 25) & 0x3F) << 5) | (((inst >> 8) & 0x0F) << 1)
            if imm_b & 0x1000: imm_b -= 0x2000 # Sign extend 13 bits
            val1 = regs[rs1]
            val2 = regs[rs2]
            taken = False
            if funct3 == 0x0: taken = (val1 == val2) # BEQ
            elif funct3 == 0x1: taken = (val1 != val2) # BNE
            elif funct3 == 0x4: taken = (int(val1) < int(val2)) # BLT
            elif funct3 == 0x5: taken = (int(val1) >= int(val2)) # BGE
            if taken:
                next_pc = pc + imm_b

        # LUI / AUIPC (U-type)
        elif opcode == 0x37: # LUI
            if rd != 0: regs[rd] = (inst & 0xFFFFF000) & 0xFFFFFFFF
        elif opcode == 0x17: # AUIPC
            if rd != 0: regs[rd] = (pc + (inst & 0xFFFFF000)) & 0xFFFFFFFF

        # JAL (J-type)
        elif opcode == 0x6F:
            imm_j = (((inst >> 31) & 1) << 20) | (((inst >> 12) & 0xFF) << 12) | (((inst >> 20) & 1) << 11) | (((inst >> 21) & 0x3FF) << 1)
            if imm_j & 0x100000: imm_j -= 0x200000
            if rd != 0: regs[rd] = (pc + 4) & 0xFFFFFFFF
            next_pc = pc + imm_j

        regs[0] = 0 # x0 is hardwired to 0
        pc = next_pc
        print("=== STANDALONE GOLDEN RISC-V SIMULATOR OUTPUT ===")
        for i in range(6):
            print(f"  x{i} = {regs[i]}")

    print("=== STANDALONE GOLDEN RISC-V SIMULATOR OUTPUT ===")
    for i in range(6):
        print(f"  x{i} = {regs[i]}")

if __name__ == "__main__":
    filepath = sys.argv[1] if len(sys.argv) > 1 else "Pipeline/program.hex"
    run_riscv_hex(filepath)
