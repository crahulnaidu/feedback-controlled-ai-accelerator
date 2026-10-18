# Program Completion Controller

## Purpose
Stop sequential execution when the PC reaches the first address
after the program.

## Interface
- pc_addr: current PC address
- pc_enable: permits the PC to advance
- program_done: completion status

## Current configuration
- First instruction: 0x00000000
- Last instruction: 0x00000018
- End address: 0x0000001C

## Current limitations
- Sequential execution only
- No branch or jump redirection
- No instruction-fetch stall protocol
- Unsupported ROM addresses produce an invalid instruction




1. Since program_done has a non-blocking assignment it gets asserted on the rising edge at the same time as the register file is written with the value of the old pc instruction execution.Hence the final instruction gets executed without stopping.

2. Clock gating introduces timing problems with the sequential element as it may not synchronize properly with the rest of the circuit.Also it may lead to improper increment of the pc leading to invalid instructions.An ordinary pc_enable approach is preferable here as it makes the pc synchronous with the rest of the ROM and datapath without creating any timing problems.

3. In case the pc overshoots the configured endpoint ,the program controller still disables pc_enable and stops the pc from incrementing.While for the equality operator ,in case the pc somehow overshoots the endpoint without going through it the pc would increment indefinitely leading to invalid instructions and wasted clock cycles.In case of branch instructions ,or interrupts or any other type of instructions that change the flow of the pc ,neither expression would work.

4. The reset is asserted continuously for 2 clock cycles for both the register file and the pc so that the register file doesnt begin writing the value.To make the interface robust the reset for the pc can be made during an active edge i.e making it synchronous.

5. The PC should prioritize the branch instruction and save the previous pc_out value in a register so that it can continue execution after the branch instruction is completed.If the zero_flag of the alu is asserted then the pc is added with the immediate field to calculate the branch target address.The program_done and pc_enable fields are reset if branch_taken is asserted otherwise the normal execution continues.

## Bonus
assign temp=pc_out;
After 1 clock cycle.
assign stable=(temp==pc_out);

The assertion samples the old value of the pc.This is useful for a design-review as it enables the designer to check if the pc value is incrementing or staying stable after the end of the program.