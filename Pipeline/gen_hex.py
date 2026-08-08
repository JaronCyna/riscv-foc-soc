import random
import numpy as np

REGS = [0, 1, 2, 3, 4, 5]

# Hardcoded stress test
instructions = [
    0x00A00293, #addi x5, x0, 10
    0x00428193, #addi x3, x5, 4  RAW (Read-After-Write) EX-to-EX Forwarding

    0x00A00093, #addi x1, x0, 10
    0x00000013, #addi x0, x0, 0 (NOP)
    0x00508113, #addi x2, x1, 5 RAW MEM-to-EX Forwarding

    0x00002083, #lw x1, 0(x0) 
    0x00408113, #addi x2, x1, 4 Load-Use Hazard
    0x00000013,

    0x00500093, #addi x1, x0, 5
    0x00008463, #beq x1, x1, 8 ID-Stage Branch Forwarding
    0x00000013,
    
    0x00000663, # beq  x0, x0, 12
    0x06300213, #addi x4, x0, 99 Branch Flush (Control Hazard)
    0x00000013,
    0x00000013,

    0x03200013, #addi x0, x0, 50
    0x000000B3  #add x1, x0, 0 Register x0 Hardwire Invariance
]

#CRT generators

x   = np.array([0, 0, 4, 14, 0, 10], dtype=np.int64)
mem = np.zeros(128, dtype=np.int64)
addr = 0
branch = False
jump   = 0

def RType(Version, Rs1, Rs2, Rd):
    if not branch:
        if(Version == 0): 
            funct7 = '0000000'
            res = x[Rs1]+x[Rs2]
        elif(Version == 1): 
            funct7 = '0100000'
            res = x[Rs1]-x[Rs2]
        else:
            raise ValueError("Version must be 0 or 1")

        rs2_b = f"{Rs2:05b}"
        rs1_b = f"{Rs1:05b}"
        funct3 = '000'
        rd_b  = f"{Rd:05b}"
        opcode = '0110011'
        comb = f"{funct7}{rs2_b}{rs1_b}{funct3}{rd_b}{opcode}"

        if Rd != 0:
            x[Rd] = res % (1 << 32)
        x[0] = 0

        return f"0x{int(comb, 2):08x}"
    return '0x00000013'

def IType(Version, Rs1, Val, Rd):
    if not branch:
        imm_val = Val & 0xFFF
        imm = f"{imm_val:012b}"
        rs1_b  = f"{Rs1:05b}"
    
        if(Version == 0): # ADDI
            funct3 = '000'
            res = Val + x[Rs1]
            if Rd != 0:
                x[Rd] = res % (1 << 32)
        elif(Version == 1): #LW
            funct3 = '010'
            addr = int(((x[Rs1] + Val) & 0x1FF) // 4)
            if Rd != 0:
                x[Rd] = mem[addr] % (1 << 32)

        else:
            raise ValueError("Version must be 0 or 1")

        rd_b  = f"{Rd:05b}"
        
        if(Version == 0): opcode = '0010011'
        elif(Version == 1): opcode = '0000011'

        comb = f"{imm}{rs1_b}{funct3}{rd_b}{opcode}"
        x[0] = 0
        return f"0x{int(comb, 2):08x}"
    return '0x00000013'


def SType(Val, Rs1, Rs2):
    if not branch:
        imm_val = Val & 0xFFF
        imm = f"{imm_val:012b}"

        rs2_b = f"{Rs2:05b}"
        rs1_b = f"{Rs1:05b}"
        funct3 = '010'

        opcode = '0100011'

        addr = int(((x[Rs1] + Val) & 0x1FF) // 4)

        mem[addr] = x[Rs2]

        comb = f"{imm[:7]}{rs2_b}{rs1_b}{funct3}{imm[7:]}{opcode}"
        x[0] = 0
        return f"0x{int(comb, 2):08x}"
    return '0x00000013'

def BType(Val, Rs1, Rs2):
    if not branch:
        byte_offset = (Val % 32 + 1) * 4 
        imm_val = byte_offset & 0x1FFF
        imm = f"{imm_val:013b}"

        rs2_b = f"{Rs2:05b}"
        rs1_b = f"{Rs1:05b}"
        funct3 = '000'

        opcode = '1100011'

        branch_taken = (x[Rs1] == x[Rs2])
        inst_jump = byte_offset // 4

        comb = f"{imm[0]}{imm[2:8]}{rs2_b}{rs1_b}{funct3}{imm[8:12]}{imm[1]}{opcode}"
        x[0] = 0
        return f"0x{int(comb, 2):08x}", branch_taken, inst_jump
    return '0x00000013', False, 0


def RandomizeType(Regs):

    global branch, jump

    AvailRegs = len(Regs)
    INST = random.randint(1,4)

    branch_taken = False
    new_jump = 0

    version = random.randint(0,1)
    val     = random.randint(0, 100)
    rs1     = random.randint(0,AvailRegs-1)
    rs2     = random.randint(0,AvailRegs-1)
    rd      = random.randint(0,AvailRegs-1)

    if(INST == 1): instr = RType(version, rs1, rs2, rd)
    if(INST == 2): instr = IType(version, rs1, val, rd)
    if(INST == 3): instr = SType(val, rs1, rs2)
    if(INST == 4): 
        instr, branch_taken, new_jump = BType(val, rs1, rs2)

    if branch:
        jump -= 1
        if jump <= 0:
            branch = False
    elif branch_taken:
        branch = True
        jump = new_jump

    return instr

for num in range(2000):
    Inst = RandomizeType(REGS)
    instructions.append(int(Inst, 16))
    print(f"\n instruction number {num+1} is {Inst}")
    print("=== EXPECTED REGISTER VALUES FOR VERIFICATION", num+18)
    for i in range(6):
        print(f"  x{i} = {x[i]}")


with open("Pipeline/program.hex", "w", encoding="utf-8") as f:
    for inst in instructions:
        f.write(f"{inst:08x}\n")

print("Generated program.hex successfully!")
print("\n=== EXPECTED REGISTER VALUES FOR VERIFICATION ===")
for i in range(6):
    print(f"  x{i} = {x[i]}")






with open("Pipeline/5_Stage_tb.sv", "r", encoding="utf-8") as f:
    tb = f.read()
# Update the assertion check in the testbench
import re
new_if = f"""if (CPU.regfile.mainReg[0] == {x[0]}  &&
            CPU.regfile.mainReg[1] == {x[1]}  && 
            CPU.regfile.mainReg[2] == {x[2]}  && 
            CPU.regfile.mainReg[3] == {x[3]}  && 
            CPU.regfile.mainReg[4] == {x[4]}  && 
            CPU.regfile.mainReg[5] == {x[5]}) begin"""
tb = re.sub(r'if \(CPU\.regfile\.mainReg\[0\].*?begin', new_if, tb, flags=re.DOTALL)
with open("Pipeline/5_Stage_tb.sv", "w", encoding="utf-8") as f:
    f.write(tb)


from capstone import *

md = Cs(CS_ARCH_RISCV, CS_MODE_RISCV32)

with open("Pipeline/program.s", "w", encoding="utf-8") as out_f:
    out_f.write(".text\n.globl main\nmain:\n")
    
    pc = 0
    disassembled = []
    
    for hex_line in instructions:
        raw_bytes = hex_line.to_bytes(4, byteorder='little')
        for insn in md.disasm(raw_bytes, pc):
            disassembled.append((pc, insn.mnemonic, insn.op_str))
        pc += 4
        
    for addr, op, args in disassembled:
        # Check if instruction is a branch and convert numeric target to label L_<target>
        if op.startswith('b'):
            parts = [p.strip() for p in args.rsplit(',', 1)]
            if len(parts) == 2 and (parts[1].startswith('0x') or parts[1].isdigit()):
                target_pc = int(parts[1], 0) if parts[1].startswith('0x') else int(parts[1])
                args = f"{parts[0]}, L_{target_pc}"
                
        out_f.write(f"L_{addr}: {op} {args}\n")

print("Generated Venus-compatible Pipeline/program.s successfully!")
