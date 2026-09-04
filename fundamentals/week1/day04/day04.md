# Day 4 Laboratory Report

## Objective

Understand the basic RISC-V datapath.

## Theory Completed

- Combinational elements
- State elements
- Clocking
- MUX
- PC
- Register File
- ALU
- Data Memory
- Datapath

## RTL Completed

- 2:1 MUX
- Register
- PC

## Python Completed

- MUX simulation
- ALU simulation
- Simple datapath simulation

## Key Observations

The control unit is designed from the instructions opcode.


## Problems Encountered

Had trouble simulating the verilog code.

## Connection to Final Project

A good understanding of datapath and control unit is necessary to design an accelerator.









1.A datapath is the hardware through which data flows and which performs operations on the data.For ex-ALU. A control unit generates contorl signals for the datapath to execute instructions,for ex-CPU.

2.A MUX is essentially a selector which chooses between different inputs depending on the select lines.IT is needed as it helps choose different inputs for different instructions,without it extra ALU would be required for immediate input ,leading to a waste of space and power.

3.The contents of a register depends upon the present state of the register, the clock pulse (high or low),the input to the register,hence it is called state element.An ALU produces the same output for the same input regardless of when and how it is produced,henc it is a combinational element.
For the register when the input change's its contents changes when it is triggered by a clock pulse,while for a combinational circuit it produce's a different output for a different input at the same time just differing by the propogation delay of the circuit.

4.First the instruction is fetched and the program counter is incremented.
The operands x5 and x6 are read into the register files.
The ALU performs the add operation on the registers.
The final result is written into x7.

5.The register is a state element,so it only responds when it is triggered by an active low or high clock pulse.Storing the configuration value in the register allows for it to be controlled and changed during runtime.Its value can also be persisted and kept for later use allowing for a finer control over configuration parameters.

## Bonus Question.

The RISC-V processor should not wait for 100 clock cycles and should instead fetch and decode other instructions that are not directly connected to the ongoing computation.It should also move the next data to be used into a buffer and store it there until the 100 clock cycles are done.