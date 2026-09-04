from day02.logic_gates import AND,OR,NOR

def mux(a, b, select):
    return OR(AND(a,select),AND(b,NOR(select)))
    pass

def register_read(registers, index):
    return registers[index]
    pass

def alu(a, b, operation):
    if operation=="and":
        return AND(a,b)
    elif operation=="or":
        return OR(a,b)
    elif operation=="add":
        return a+b
    elif operation=="sub":
        return a-b
    else:
        return ValueError("Unknown ALU operation")
    pass

def execute_instruction(opcode, rs1, rs2, immediate):
    if opcode=="ADD":
        return alu(rs1,rs2,"add")
    
    elif opcode=="SUB":
        return alu(rs1,rs2,"sub")
    elif opcode == "AND":
        return alu(rs1, rs2, "and")

    elif opcode == "OR":
        return alu(rs1, rs2, "or")

    elif opcode == "ADDI":
        return alu(rs1, immediate, "add")

    else:
        raise ValueError("Unknown instruction")

    pass