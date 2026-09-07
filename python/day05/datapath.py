from day04.datapath_simulator import mux,register_read,alu
from control_unit import control_unit

def execute_instruction(opcode,rs1,rs2,immediate):
    control=control_unit(opcode)

    if control["ALUSrc"]==0:
        alu_input_b=rs2
    else:
        alu_input_b=immediate

    if opcode=="ADD":
        operation="add"
    elif opcode == "SUB":
        operation = "sub"

    elif opcode == "AND":
        operation = "and"

    elif opcode == "OR":
        operation = "or"

    elif opcode == "LD":
        operation = "add"

    elif opcode == "SD":
        operation = "add"

    elif opcode == "BEQ":
        operation = "sub"     

    else:
        raise ValueError("Unknown opcode.")

    return alu(rs1,alu_input_b,operation)

