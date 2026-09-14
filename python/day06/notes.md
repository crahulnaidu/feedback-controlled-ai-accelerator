# Day 6 — Python Notes

## RISC-V instruction fields

For an R-type instruction:

    add rd, rs1, rs2

rd  = destination
rs1 = source 1
rs2 = source 2

Example:

    add x5, x6, x7

x6 → ALU input A
x7 → ALU input B
result → x5


## Register File

The basic datapath register file has:

- Two read ports
- One write port

Read:

    rs1 → ReadData1
    rs2 → ReadData2

Write:

    rd ← WriteData


## Immediate

An immediate is encoded inside the instruction.

For instructions such as ADDI, the immediate is used as an ALU input instead of rs2.


## Sign Extension

Sign extension preserves the signed value when increasing the number of bits.

Positive:

    00000101 → 00000000...00000101

Negative:

    11111011 → 11111111...11111011


## x0

x0 always contains zero.

Attempting to write to x0 should not change its value.


## Questions I still have

How are the timing constraints satisfied in the hardware?






1. Any data operation in RISC-V usually involves 2 operands and a destination operand to store the result. In add x5,x6,x7 the 2 operands x6 and x7 are read into the register files and they are send to the alu to perform the add operation.The alu then writes the result back into x5 using write control. As any operation involves atmost 2 reads and a write the register files have 2 read ports and 1 write port.

2. add x5,x6,x7-rs1=x6,rs2=x7,rd=x5
sub x10,x11,x12-rs1=x11,rs2=x12,rd=x10
addi x8,x9,15-rs1=x9,rd=x8,rs2=default value or all zeros.

ADDi doesn't need rs2 because the second operand can be directly fed to the alu by the MUX.

3. 1-it represents -5
   2-1111111111111011
   3-Because the immediate value may be encoded in a lower binary width compared to the alu input size,so it needs sign extension to match the alu input bit width.

4. First the instruction is fetched and the program counter is incremented.
Then x6 is read into the register file. The immediate value is sign extended and then the MUX selects it as the second operand of the alu.The alu performs the addition and the result is written back into x5 using the write control signal RegWrite.

5. Yes the processer could still execute the instruction but there would have to be  extra cycles for reading both the inputs as there is only a single read port.The ALU would have to wait for both the inputs to be ready leading to wastage of clock cycles.

# Bonus.

Firstly the instruction has to contain the register addresses for the configuration addresses ,along with their contents.So there has to be a decoder unit and a mux unit to decode and select the necessary subset of configuration registers and update their values.Also a control unit has to be there to generate the control signals to write to the registers.