# Day 5 — RISC-V Control Unit & Instruction Execution

## Objective

Understand how the control unit generates control signals that cause the datapath to execute different instructions.

---

## 1. Datapath vs Control Unit

### Datapath

The datapath contains the hardware that stores, transports, and operates on data.

Important components:

- Program Counter (PC)
- Register File
- ALU
- Multiplexers
- Data Memory
- Instruction Memory

### Control Unit

The control unit generates control signals based on the instruction.

The control signals determine:

- Which inputs are selected by MUXes
- What operation the ALU performs
- Whether registers are written
- Whether memory is read
- Whether memory is written
- Whether a branch can change the PC

Conceptually:

Instruction
    ↓
Control Unit
    ↓
Control Signals
    ↓
Datapath

---

## 2. Important Control Signals

### RegWrite

Determines whether the register file should be written.

RegWrite = 1:
    Write a result into rd.

RegWrite = 0:
    Do not write a register.

---

### ALUSrc

Controls the source of the ALU's second input.

ALUSrc = 0:
    Second ALU input comes from rs2.

ALUSrc = 1:
    Second ALU input comes from the immediate.

Conceptually:

             ┌─────┐
rs2 ────────►│     │
             │ MUX │────► ALU
immediate ──►│     │
             └─────┘
                ▲
              ALUSrc

---

### MemRead

Determines whether data memory is read.

Used by load instructions such as ld.

---

### MemWrite

Determines whether data memory is written.

Used by store instructions such as sd.

---

### MemtoReg

Controls whether the value written to the register file comes from:

- ALU
- Data Memory

For an ALU instruction:

ALU → Register File

For a load:

Data Memory → Register File

---

### Branch

Indicates that the instruction may change the normal PC sequence through a branch.

For beq:

The ALU compares the two register values.

If they are equal, the branch target can become the next PC.

---

## 3. RISC-V Instruction Fields

For an R-format instruction:

    add rd, rs1, rs2

rd:
    destination register

rs1:
    first source register

rs2:
    second source register

Example:

    add x5, x6, x7

rd  = x5
rs1 = x6
rs2 = x7

Therefore:

x6 → ALU input A
x7 → ALU input B
ALU result → x5

---

## 4. Control for Different Instructions

| Instruction | ALUSrc | RegWrite | MemRead | MemWrite | Branch |
|-------------|--------|----------|---------|----------|--------|
| add         | 0      | 1        | 0       | 0        | 0      |
| sub         | 0      | 1        | 0       | 0        | 0      |
| and         | 0      | 1        | 0       | 0        | 0      |
| or          | 0      | 1        | 0       | 0        | 0      |
| ld          | 1      | 1        | 1       | 0        | 0      |
| sd          | 1      | 0        | 0       | 1        | 0      |
| beq         | 0      | 0        | 0       | 0        | 1      |

---

## 5. ADD Instruction

Example:

    add x5, x6, x7

Conceptual path:

Instruction
    ↓
Decode
    ↓
Control Unit
    ↓
Register File
    ↓
Read x6 and x7
    ↓
ALU
    ↓
Addition
    ↓
Result
    ↓
Write to x5

---

## 6. ADDI Instruction

Example:

    addi x5, x6, 10

The second ALU input is an immediate rather than rs2.

Therefore:

rs1 → ALU input A

immediate → MUX → ALU input B

ALUSrc = 1

---

## 7. Load Instruction

Example:

    ld x5, 8(x6)

Conceptual operation:

1. Read x6 from register file.
2. Sign-extend immediate 8.
3. Select immediate using ALUSrc.
4. ALU calculates address:

       x6 + 8

5. Read data memory.
6. Select memory result using MemtoReg.
7. Write result into x5.

---

## 8. Store Instruction

Example:

    sd x5, 8(x6)

Conceptual operation:

1. Read x6.
2. Read x5.
3. Sign-extend immediate.
4. ALU calculates address:

       x6 + 8

5. Write the value from x5 to data memory.

No register is written.

---

## 9. Branch Instruction

Example:

    beq x5, x6, label

The processor:

1. Reads x5 and x6.
2. ALU compares them, typically using subtraction.
3. If the result is zero, the values are equal.
4. Branch control and the ALU Zero signal determine whether the branch target is selected.

---

## 10. Single-Cycle Limitation

In a single-cycle processor, every instruction must complete in one clock cycle.

Therefore the clock period must be long enough for the slowest instruction.

For example:

ADD  → short path
AND  → short path
LD   → longer path

The slowest path determines the clock period.

This is inefficient because fast instructions must still wait for the same long clock cycle.

---

## 11. Pipelining Preview

Pipelining allows multiple instructions to overlap in execution.

Instead of:

Instruction 1 → completely finish
Instruction 2 → completely finish
Instruction 3 → completely finish

we can have:

Instruction 1 → Stage 2 → Stage 3
Instruction 2 → Stage 1 → Stage 2 → Stage 3
Instruction 3 → Stage 1 → Stage 2 → Stage 3

This increases throughput.

---

## Day 5 Questions

1. Why does the processor need a control unit if the ALU already knows how to add?

2. Why is ALUSrc required?

3. Determine the control signals for add, ld, sd, and beq.

4. Explain the complete datapath for ld x5, 8(x6).

5. Explain why a single-cycle processor is inefficient.

### Bonus

What signals could an accelerator expose to a RISC-V processor so that the CPU does not need to blindly wait while the accelerator executes?