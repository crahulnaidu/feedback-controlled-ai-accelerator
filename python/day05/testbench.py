from day05.datapath import execute_instruction
from day05.control_unit import control_unit


print("=== CONTROL UNIT TESTS ===")

print("ADD:")
print(control_unit("ADD"))

print("LD:")
print(control_unit("LD"))

print("SD:")
print(control_unit("SD"))

print("BEQ:")
print(control_unit("BEQ"))


print("\n=== DATAPATH TESTS ===")

print("ADD 10 + 20 =", execute_instruction("ADD", 10, 20, 0))

print("SUB 20 - 10 =", execute_instruction("SUB", 20, 10, 0))

print("AND 10 & 12 =", execute_instruction("AND", 10, 12, 0))

print("OR 10 | 12 =", execute_instruction("OR", 10, 12, 0))

print("LD address calculation =", execute_instruction("LD", 100, 0, 8))

print("SD address calculation =", execute_instruction("SD", 100, 0, 8))

print("BEQ comparison =", execute_instruction("BEQ", 20, 20, 0))