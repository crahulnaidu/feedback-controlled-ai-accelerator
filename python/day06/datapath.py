import sys
from pathlib import Path

# Add the parent folder of the current file to sys.path
sys.path.append(str(Path(__file__).resolve().parent.parent))


from register_file import RegisterFile
from immediate_generator import sign_extend
from day04.datapath_simulator import alu


def execute_add(register_file,rd,rs1,rs2,):
    value1=register_file.read(rs1)
    value2=register_file.read(rs2)

    result=alu(value1,value2,"add")

    register_file.write(rd,result)


def execute_addi(register_file,rd,rs1,immediate):
    value1=register_file.read(rs1)
    immediate=sign_extend(immediate,8)

    result=alu(value1,immediate,"add")

    register_file.write(rd,result)



