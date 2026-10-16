# Day 6 and 7-RISC V Datapath execution using control signals.

## Objective

Integrate the Multiplexer (MUX), Arithmetic Logic Unit (ALU), Register File, and Sign-Extension module into a unified single-cycle execution datapath.

## 1.Integrated Datapath Components.

The execution datapath connects core hardware units in a closed execution loop.

Important components:

Register File: Provides source operands asynchronously from rs1 and rs2; writes back results synchronously on posedge clk.

Sign Extension Unit: Converts 12-bit instruction immediates (inst[31:20]) into 32-bit two's complement values.

ALU Source MUX (ALUSrc): Selects whether the ALU's second operand comes from a register (ReadData2) or an immediate (Imm32).

ALU: Computes arithmetic and logic operations based on ALUControl.

## 2.Instruction Field Extraction.

Instructions drive the datapath through specific bitfields:
inst[19:15] (rs1): Read register address 1
inst[24:20] (rs2): Read register address 2
inst[11:7] (rd): Write register address
inst[31:20] (imm12): 12-bit immediate field for I-type instructions

## 3.Data and Control Flow.

Executing R-Type Instructions (e.g., add x5, x6, x7)
1. Read x6 (rs1) and x7 (rs2) from Register File.
2. ALUSrc = 0 selects ReadData2 (R_2) for Operand B.
3. ALU performs addition (ALUControl = 4'b0010).
4. RegWrite = 1 writes the ALU result into x5 (rd) on posedge clk.

## 4. Control Signals for Integrated Operations.

Instruction   ALUSrc   RegWrite   ALUControl   Operation

add           0        1          4'b0010      R1+R2
sub           0        1          4'b0010      R1-R2
and           0        1          4'b0000      R1 AND R2
or            0        1          4'b0001      R1 OR R2
addi          1        1          4'b0010      R1 + Imm32

## 5. Critical Path Delay and Throughput.

Propagation Delay (T_critical)

The longest path through combinational logic determines the minimum clock period:T_critical = T_RF_read + T_MUX + T_ALU + T_setup.

Throughput

In a single-cycle execution unit:Throughput=1/(T_critical)
To maximize clock frequency and performance,T_critical must be minimized across all executed instructions.



1. The opcode is -0110011 which means it is a R type instruction,rd-01000,rs1-01010,rs2-10110,funct3-000,funct7-0000000.

The assembly instruction is AND x8,x10,x22.

2. RegWrite-1,ALUSrc-1,ALUControl-0010.
For this the second operand comes from the immediate field so rs2 is not necessary

3. First is the register file reading delay T_critical+=T_read(1.2ns).
Then is sign extending the 12 bit immediate field which takes T_sign_ext(0.2ns),then the mux which selects the immediate field instead of rs2 which is T_mux(0.3ns),then the alu delay which is T_alu(2.1ns) ,then the register write which is T_setup(0.4ns) for a total time of 4.2ns.

4. The exact 32 bit output would be 1111 1111 1111 1111 1111 1000 0000 0000.
This represents -2048.

5. There will be a data hazard as even though the instruction takes a single clock to execute and there is no pipelining,the register x5 takes extra clock cycle to get written or updated.So the sub operation receives the old value of x5.

## Bonus.
The value in the register x0 will be 32'd0 as ,it is reserved for zero output flag and cannot be used for writing or any other computation.








1. The wiring error is probably in the assignment of the second operand based on alu_src.To verify the diagnosis we can check the contents of the destination register or the second operand to see if it contains the immediate field for addi and rs2 for a normal add operation.

2. The register file stores 12 in the next clock cycle as the time taken to write a register must be within the active clock edge.If regwrite is 0 then the register's contents do not change.

3. It's signed decimal value is -8.Its 32 bit sign-extended representation would be 1111 1111 1111 1111 1111 1111 1111 1000.The ADDI instruction would produce the result 2.

4. Only checking alu_result is insufficient because the destination register might have a value different than the result because of some error.The additional checks would be to check the destination register and the second operand to see if it correctly contains the value of the immediate field or rs2 depending on the instruction.

5.  An instruction decoder that automatically extracts those flags based on the opcode and instruction fields.

## Bonus.

No,it does not prove that the synthesized datapath can run at 100 MHz.The actual datapath may have additional propogation delays or some errors because of some defect which would increase the 10ns clock period.