# Day 10 Study Notes — Instruction Fetch, Sequential Execution, and Verilog Timing


## 1. Learning objective

On Day 9, the instruction decoder was connected to the existing datapath. On Day 10, instruction memory is added and connected to the existing program counter (PC).

The intended architecture is:

```text
Program Counter (PC)
        |
        | current instruction address
        v
Instruction ROM
        |
        | 32-bit instruction
        v
Instruction Decoder
        |
        | control signals
        v
Datapath + Register File
        |
        | result stored at the active clock edge
        v
PC advances to the next sequential instruction
```

The goal is to execute a small program without the testbench manually supplying every instruction.

## 2. Instruction memory

Instruction memory stores machine-code instructions. In this project, a small combinational ROM is implemented with a Verilog `always @(*)` block and a `case` statement.

Example:

```verilog
always @(*) begin
    case (address)
        32'h00000000: instruction = 32'h00400213;
        32'h00000004: instruction = 32'h00A00313;
        // Other instructions...
        default:      instruction = 32'h00000000;
    endcase
end
```

When the address changes, the ROM produces the corresponding instruction without waiting for a clock edge.

### Why instruction addresses advance by four

Each instruction in this initial design is 32 bits wide:

\[
32\text{ bits} \div 8\text{ bits/byte} = 4\text{ bytes}
\]

Therefore, sequential instruction addresses are `0x00`, `0x04`, `0x08`, `0x0C`, and so on.

For this simple sequential design:

\[
PC_{next} = PC_{current} + 4
\]

This assumes fixed-width 32-bit instructions and sequential execution. Branches, jumps, and compressed instructions are not implemented here.

### Instruction ROM versus register file

| Property | Instruction ROM | Register file |
|---|---|---|
| Stores | Machine-code instructions | Operand and result values |
| Address | Instruction address | Register index |
| Example | Address `0x08` returns an instruction | Register `x4` contains 4 |
| Purpose | Supplies instructions | Supplies operands and stores results |

## 3. Program Counter (PC)

The existing `rtl/day04/pc.v` contains:

```verilog
always @(posedge clk or posedge rst) begin
    if (rst)
        pc_out <= 32'h00000000;
    else
        pc_out <= pc_out + 4;
end
```

- **Asynchronous reset:** `posedge rst` resets the PC as soon as reset is asserted, without waiting for a clock edge.
- **Rising clock edge:** When reset is inactive, the PC advances by four bytes on each rising edge.

Example sequence:

| Event | PC before update | PC after update |
|---|---:|---:|
| Reset asserted | Any value | `0x00` |
| Rising edge | `0x00` | `0x04` |
| Rising edge | `0x04` | `0x08` |
| Rising edge | `0x08` | `0x0C` |

The PC identifies the instruction address; it does not decide which ALU operation is performed.

**Current limitation:** This PC always increments by four. It does not yet support branches, jumps, or stopping at the end of a program.

## 4. Combinational logic versus sequential logic

| Type | Behavior | Examples in this design |
|---|---|---|
| Combinational logic | Outputs respond to current inputs; no clock edge is required to update the logical result | Instruction ROM, decoder, ALU, operand selection |
| Sequential logic | Stored state updates in response to a triggering clock event | PC, register file |

The PC and register file use nonblocking assignments (`<=`) in clocked processes. For example:

```verilog
registers[rd] <= write_data;
```

At a rising edge, the assignment schedules the register update. The updated value becomes visible in the simulator's subsequent update phases.

A testbench must distinguish between:

1. An ALU result being calculated.
2. A result being committed to a register.
3. The PC advancing to the next instruction address.

## 5. Clock timing in the testbench

The testbench generates a clock using:

```verilog
always #5 clk = ~clk;
```

and initializes it with:

```verilog
clk = 1'b0;
```

The period is 10 ns:

\[
T = 5\text{ ns} + 5\text{ ns} = 10\text{ ns}
\]

The corresponding simulated frequency is:

\[
f = \frac{1}{T} = \frac{1}{10\text{ ns}} = 100\text{ MHz}
\]

Rising edges occur at 5, 15, 25, 35 ns, and so on. Falling edges occur at 10, 20, 30, 40 ns, and so on.

This is the simulated clock frequency; it does not prove synthesized hardware can meet 100 MHz timing. That requires synthesis and timing analysis.

### Reset sequence

The testbench uses a reset sequence like:

```verilog
rst = 1'b1;
repeat (2) @(posedge clk);
@(negedge clk);
rst = 1'b0;
```

This holds reset through two rising edges and releases reset on a falling edge. This matters because the PC has an asynchronous reset, while the register file uses a synchronous reset and needs a rising edge with reset asserted to initialize its registers.

## 6. What happens during one instruction cycle?

Consider the first instruction in the ROM:

```asm
ADDI x4, x0, 4
```

Its machine code is `32'h00400213`. Its effect is:

\[
x4 \leftarrow x0 + 4 = 4
\]

The sequence is:

1. The PC contains `0x00`.
2. The ROM outputs the instruction stored at `0x00`.
3. The decoder generates the control signals.
4. The ALU calculates the result, 4.
5. At the rising edge, the register file stores 4 in `x4`.
6. At the same edge, the PC advances from `0x00` to `0x04`.
7. After the edge, the ROM presents the next instruction.

The register file uses the instruction and result established before the edge, while the PC advances at that edge. Because the ROM is combinational, it responds to the updated PC after the edge.

### Seven-instruction program

| Address | Instruction | Expected effect |
|---|---|---|
| `0x00` | `ADDI x4, x0, 4` | `x4 = 4` |
| `0x04` | `ADDI x6, x0, 10` | `x6 = 10` |
| `0x08` | `ADD x2, x4, x6` | `x2 = 14` |
| `0x0C` | `SUB x3, x4, x6` | `x3 = -6` |
| `0x10` | `AND x2, x4, x6` | `x2 = 0` |
| `0x14` | `OR x2, x4, x6` | `x2 = 14` |
| `0x18` | `ADDI x5, x2, -2` | `x5 = 12` |

After the seventh instruction executes, the PC advances to `0x1C`. The ROM has no instruction mapped at that address and returns `32'h00000000`. The current decoder should reject that instruction and prevent register writeback.

## 7. Understanding `@(posedge clk)` and `#1`

A testbench may contain:

```verilog
@(posedge clk);
#1;
```

These statements have different meanings:

- `@(posedge clk)` pauses testbench execution until the next rising edge. It waits for an event, not a fixed duration.
- `#1` waits one nanosecond after that edge before continuing.

Your sequential RTL uses nonblocking assignments. The extra simulation delay lets those scheduled updates and resulting combinational changes settle before the testbench checks values.

**Important:** `#1` is a testbench observation delay. It does not add a cycle or a one-nanosecond delay to synthesized hardware.

## 8. Timeline for the seven instructions

Reset is released at the falling edge at 20 ns. The first instruction executes at the rising edge at 25 ns.

| Time | PC before rising edge | Instruction | Expected state update |
|---:|---:|---|---|
| 20 ns before 25 ns edge | `0x00` | `ADDI x4, x0, 4` | `x4 = 4` |
| 26 ns before 35 ns edge | `0x04` | `ADDI x6, x0, 10` | `x6 = 10` |
| 36 ns before 45 ns edge | `0x08` | `ADD x2, x4, x6` | `x2 = 14` |
| 46 ns before 55 ns edge | `0x0C` | `SUB x3, x4, x6` | `x3 = -6` |
| 56 ns before 65 ns edge | `0x10` | `AND x2, x4, x6` | `x2 = 0` |
| 66 ns before 75 ns edge | `0x14` | `OR x2, x4, x6` | `x2 = 14` |
| 76 ns before 85 ns edge | `0x18` | `ADDI x5, x2, -2` | `x5 = 12` |

The testbench prints the current instruction before waiting for its execution edge. After the edge and a `#1` delay, it resumes and observes the updated state.

At 85 ns, the instruction at `0x18` executes. After the edge, the PC updates to `0x1C`, and the ROM presents the unmapped default instruction. That invalid instruction does not execute until the next rising edge.

## 9. Why verify register contents, not only `alu_result`?

`alu_result` is combinational and can change when instruction bits or operands change. The register file stores persistent state and updates only when a write is enabled at the active clock edge.

A correct ALU result therefore does not, by itself, prove that instruction execution succeeded.

Expected final register values:

| Register | Expected decimal | Expected hexadecimal |
|---|---:|---|
| `x4` | 4 | `0x00000004` |
| `x6` | 10 | `0x0000000A` |
| `x2` | 14 | `0x0000000E` |
| `x3` | -6 | `0xFFFFFFFA` |
| `x5` | 12 | `0x0000000C` |

These checks verify the resulting architectural state after the sequence of instructions. This testbench uses hierarchical references to inspect internal register storage, which is convenient for learning but couples the testbench to the module hierarchy.

## 10. Unsupported instructions and program completion

The ROM returns `32'h00000000` for unmapped addresses. The decoder marks this instruction unsupported, and the wrapper prevents register writes using logic like:

```verilog
assign safe_reg_write = reg_write & instruction_valid;
```

This avoids accidental register writes for unsupported encodings.

However, **an invalid instruction is not the same as a program halt**. The PC continues incrementing by four after the program finishes. A future extension could add an explicit `program_done` or halt mechanism. For Day 10, the testbench can stop after checking the seven instruction results.

An `instruction_valid` flag verifies whether the decoder recognizes an instruction; it does not implement a complete RISC-V exception or trap mechanism.

## 11. Key takeaways

1. The PC selects the address of the current instruction.
2. The combinational ROM supplies the instruction at that address.
3. The decoder and ALU calculate control signals and results before the rising edge.
4. The register file writes results at the rising edge when register writeback is enabled.
5. The PC advances on the same edge, and the ROM then presents the next instruction.
6. `@(posedge clk)` waits for a clock event; `#1` delays testbench observation by one nanosecond.
7. Final register checks are stronger evidence of instruction execution than checking only the ALU output.
8. The current design supports sequential execution of the implemented instructions but does not yet support branches, loads/stores, or a halt mechanism.

## 12. Day 10 completion checklist

- [ ] Created `rtl/day10/instruction_rom.v`.
- [ ] Reused the existing PC module.
- [ ] Connected PC, ROM, decoder, and datapath in `program_runner.v`.
- [ ] Ran the seven-instruction program without manually supplying each instruction.
- [ ] Verified final values of `x2`, `x3`, `x4`, `x5`, and `x6`.
- [ ] Confirmed unmapped instructions do not cause unintended register writes.
- [ ] Reviewed changes with `git status` and `git diff`.

## Suggested review questions

1. Why does the PC advance by four bytes in this design?
2. Why can the ROM and ALU be combinational while the PC and register file are sequential?
3. Why does the register file use the instruction at the old PC at the rising edge?
4. What does `@(posedge clk); #1;` achieve in the testbench?
5. Why is an unsupported instruction not equivalent to a halt instruction?



1. Register file stores operands and base addresses for the alu to execute.Rom stores instructions which are accessed by the address generated by the program counter.The register file is accessed via the instructions generated by the pc.

2. Each instruction is 32 bits ,which is 4 bytes in size.Hence after each instruction is fetched and decoded the pc increments the address by 4 bytes.This assumes each  instruction is 4 bytes and there is no spacing between each instruction.

3. Because the register file writes the registers on an active clock edge.If the combinational data is not stable then the data available for write in the active clock edge would not be consistent with the instruction being executed.

4. When the PC reaches an unsupported instruction,the flow still continues but no register writes or alu computation takes place.Invalid instruction and safe write logic is useful because it prevents any unwanted writes or memory accesses.

5. A combinational logic that left shits the immediate field by 1 and sign extends the immediate field to add to the branch instruction is needed along with a mux which selects between incrementing the pc by 4 bytes or selecting the branch target address.

## Bonus.

Initially the PC contains the starting address 32'h00000000.After each active clock edge it increments the address by 4 bytes.After each change in address the ROM unit decodes the address and outputs the corresponding instruction to the datapath unit.The datapath then decodes the instruction and performs the necessary operations and then writes the result back into the register file in the next active clock edge.When the PC reaches an unsupported address ,the ROM simply outputs the default instruction.