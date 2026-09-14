from register_file import RegisterFile
from datapath import execute_add,execute_addi

rf=RegisterFile()

rf.write(6,10)
rf.write(7,20)

print("x6 =",rf.read(6))
print("x7 =",rf.read(7))

execute_add(rf,5,6,7)

print("x5 after ADD",rf.read(5))

execute_addi(rf, 4, 5, 5)

print("x4 after ADDI =", rf.read(4))


rf.write(0, 100)

print("x0 =", rf.read(0))