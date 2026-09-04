# Day 4 — RISC-V Datapath

## Topics

- Combinational elements
- State elements
- Clocking
- Multiplexers
- Program Counter
- Register File
- ALU
- Instruction Memory
- Data Memory
- Datapath

## Combinational vs Sequential

A combinational circuit produce's the same output for the same input.It only depends on the input.A sequential circuit depends on the input and the current state of the circuit to produce an output.

## What is a Datapath?

A datapath is hardware through which data flows and which controls it to perform operations.

## Role of the PC

It holds the address of the next instruction to be decoded.

## Role of the Register File

It contains the operands for the ALU to operate on.

## Role of the ALU

It performs elementary operations like ADD,SUB,AND,OR.etc.

## Why are MUXes required?

They are required to select from a range of possible inputs depending upon the required conditions.

## Connection to AI Accelerator

The study of datapath and its controller is needed as Accelerator contains many computation units that needs necessary signals to perform the required computation.

## Difficult Concepts
Designing the control unit from the ISA.

## Questions
How the Datapath interfaces with the control unit.