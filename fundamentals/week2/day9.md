# Day 9-Instruction Decoder for R-type instruction's.

## Objective

Understand how control signals are generated from the instruction bits for R-type and how all of the functional units connect together.

## 1.R-type Instructions.

These are the arithmetic instructions that provide the operands for the alu to operate on.The 4 basic arithmetic instructions supported by the RISC-V instruction set are: 1.ADD
                     2.SUB
                     3.AND
                     4.OR

## 2.Decoding the R-type instruction bits.

The 32-bit R-type instructions reserves 15 bits for 2 source registers and a destination register.7 bits are for the opcode which decides the instruction class like-R,I,S.etc.The rest 10 bits are reserved for funct_7 and funct_3 fields which determine the type of arithmetic operation within the R-type instruction.In case of a ADDI instruction the last 12 bits are reserved for the immediate field which is the value to be added with the source register.

eg:-for the assembly instruction add x2,x4,x6,the corresponding 32 bit instruction is -0x00620133.
The bit layout is given below-

Field	Value
funct7	0000000
rs2	x6 = 00110
rs1	x4 = 00100
funct3	000
rd	x2 = 00010
opcode	0110011 = 0x33

The decoder must first detect the type of instruction from the opcode and if it an R-type instruction then the funct_7 and funct_3 fields are used to decode the correct arithmetic operation.


1. funct_7 field is used to distinguish between ADD and SUB.For ADD it is 0000000,for SUB it is 0100000.

2. the funct_7 bits from the immediate field may not be a valid sequence,leading to errors.

3. So that the instruction doesn't accidentally rewrite the registers with a differnet value or perform some other operation's leading to unknown operations in the datapath.

4. So that it generates appropriate signals for different instruction classes and handles exceptions and unsupported instructions well.

5. The current decoder doesn't support the load type instruction,as it would assert the instruction_valid flag to high.

## Bonus

In manual execution ,the control signals alu_ctrl,alu_src are generated manually and tested on the datapath,while for the other the testbench generates the whole 32-bit instruction as input which passes through the decoder and then the datapath.The latter is a stronger evidence of instruction execution as it can test different type of instructions even unsupported ones and exceptions to check if the decoder correctly decodes them and the datapath doesnt give some garbage value.
