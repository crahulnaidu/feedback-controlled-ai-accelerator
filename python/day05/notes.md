# Day 5 Python Notes

## Main idea

The control unit decides what the datapath should do.

The datapath performs the actual operations.

---

## Control Unit

Input:

- opcode

Output:

- RegWrite
- ALUSrc
- MemRead
- MemWrite
- Branch
- ALU operation

---

## Instruction examples

### ADD

add x5, x6, x7

rs1 = x6
rs2 = x7
rd = x5

ALU input A = x6
ALU input B = x7
ALU operation = ADD
Write result to x5

---

### ADDI

addi x5, x6, 10

rs1 = x6
immediate = 10
rd = x5

ALU input A = x6
ALU input B = immediate
ALU operation = ADD

---

## Important distinction

rd  = destination
rs1 = source 1
rs2 = source 2

Example:

add x5, x6, x7

x6 → input
x7 → input
x5 ← result

---

## Questions / things I don't understand yet

How the instruction set architecture is designed for a particlar processor and why it is designed the way it is.



1. Even through the ALU knows how to perform addition ,the operands on which it acts on depend upon the type of instruction being executed.For ex-for R type instruction ,the ALUSrc is set to 0 which loads the second operand from the register file.But for load or store type instruction the second operand is an immediate field which is sign extended by the immediate generation unit.Since differnet instruction classes activate different control signals,the processor needs a control unit.

2. For constant inputs storing them in the register file would be a waste of register space,as they do not change during the computation.Also ALUSrc and the mux are needed to select between the immediate and second register operand.

3.                  RegWrite   MemRead   MemWrite   Branch
add                  1          0          0         0
ld                   1          1          0         0
sd                   0          0          1         0
beq                  0          0          0         1

add is a R type instruction ,so the alu result is written back into the register.It does no memory read or write.
ld and sd are memory transfer operations and hence use memread and memwrite,with ld using regwrite to write the result from the memory.For beq the branch is 1 as it is branch instruction.

4. The instruction is fetched and the program counter is incremented.
The value of register x6 is read ,the mux selects the immediate value 8 into the alu.
The alu adds the offset 8 to the contents of x6 to calculate the memory address for loading.
The memory is read and the data is written into x5.

5. The clock period must account for the longest running instruction,in this case it is ld so it is 8ns.Since ADD and AND finish in just 2ns,the extra 6ns are wasted doing nothing,leading to inefficiency.Pipelining could improve the throughput by fetching and executing the next instruction while the current instruction is running.This leads to an efficient use of each stage leading to an increase in throughput.

# Bonus question.

The accelerator can use signals like 'continue' to signal to the CPU that it can perform or focus on other instructions without needing to wait for 100 cycles.The other possible signals could be 'load_next',which loads the next data in the computation into the buffer for the accelerator.Other signals like letting the accelerator use more bandwidth or moving the finished computation into a result buffer or displaying it can be done.