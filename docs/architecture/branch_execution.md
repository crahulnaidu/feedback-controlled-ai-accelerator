# Branch Execution — RISC-V RTL

## 1. Purpose

This document describes the conditional-branch path added to the educational RISC-V-style processor in the `feedback-controlled-ai-accelerator` project.

The goal is to support the **BEQ (branch if equal)** instruction while preserving the existing ADD, SUB, AND, OR, and ADDI execution paths, the program counter (PC) enable, and program-completion behavior.

This is a small sequential-execution design, not a complete RISC-V processor. Other branch types, jumps, loads, stores, and a full illegal-instruction trap mechanism are outside the current scope.

## 2. Architecture overview

For a supported BEQ instruction, the system:

1. Fetches the instruction from `instruction_rom` using the current PC address.
2. Decodes the instruction and asserts `branch_enable` for the supported BEQ encoding.
3. Reconstructs the B-type branch immediate.
4. Uses the existing ALU to subtract `rs2` from `rs1`.
5. Treats the ALU's `zero_flag` as the equality result for BEQ.
6. Calculates the branch target as `PC + branch_imm`.
7. Selects the branch target when the branch is taken; otherwise selects `PC + 4`.
8. Updates the PC at the next rising clock edge, provided `pc_enable` is asserted.

Conceptual data flow:

```text
                         +------------------+
             PC address->|  Instruction ROM |---- instruction -----+
                  |      +------------------+                       |
                  |                                                 v
                  |                                   +-------------------------+
                  |                                   | Decoder + existing ALU |
                  |                                   | branch_enable, zero    |
                  |                                   +-------------------------+
                  |                                                 |
                  |      +------------------------------+           |
                  +----->| Branch immediate generator  |           |
                         +------------------------------+           |
                                       | branch_imm                 |
                                       v                            v
                              +----------------+        branch_taken =
                              | PC + branch_imm|        branch_enable &
                              +----------------+        instruction_valid &
                                       |                 zero_flag
                                       v                            |
                              +----------------+                    |
 PC + 4 -------------------->| Next-PC select |<-------------------+
                              +----------------+
                                       |
                                  pc_next
                                       |
                              +----------------+
                              | PC (enable)    |
                              +----------------+
```

## 3. Supported BEQ behavior

The branch opcode is `7'b1100011`. Within that opcode, this design supports BEQ when `funct3 == 3'b000`.

For BEQ, the decoder outputs:

| Signal | Value | Meaning |
|---|---:|---|
| `alu_control` | `4'b0110` | Select subtraction in the existing ALU |
| `alu_src` | `1'b0` | Use the second source-register value, not the immediate, as ALU operand B |
| `reg_write` | `1'b0` | Do not write an ALU result to a general-purpose register |
| `instruction_valid` | `1'b1` | This encoding is supported |
| `branch_enable` | `1'b1` | Interpret the ALU zero flag as the BEQ condition |

The branch condition is:

```verilog
assign branch_taken =
    branch_enable & instruction_valid & zero_flag;
```

The `instruction_valid` qualification ensures an unsupported instruction cannot redirect the PC through this branch path. `zero_flag` alone must not be used as the branch-select condition because arithmetic instructions can also produce zero.

## 4. B-type immediate reconstruction

RISC-V B-type immediate bits are distributed across the instruction word:

| Immediate bit(s) | Instruction bit(s) |
|---|---|
| `imm[12]` | `inst[31]` |
| `imm[11]` | `inst[7]` |
| `imm[10:5]` | `inst[30:25]` |
| `imm[4:1]` | `inst[11:8]` |
| `imm[0]` | constant `0` |

The RTL is:

```verilog
assign branch_imm = {
    {19{inst[31]}},
    inst[31],
    inst[7],
    inst[30:25],
    inst[11:8],
    1'b0
};
```

The resulting 32-bit value is a sign-extended byte offset. The least-significant bit is zero because the encoded B-type offset is in two-byte increments.

For a branch at `PC = 0x1C` with offset `+8`:

```text
branch_target = 0x1C + 0x08 = 0x24
```

The offset is added to the address of the branch instruction itself, not to `PC + 4`.

## 5. Next-PC selection and completion

The current next-address logic is:

```verilog
assign sequential_pc = address + 32'd4;
assign branch_target = address + branch_imm;

assign branch_taken =
    branch_enable & instruction_valid & zero_flag;

assign pc_next = branch_taken ? branch_target : sequential_pc;
```

The PC stores `pc_next` only at a rising clock edge and only when `pc_enable` is high:

```verilog
always @(posedge clk or posedge rst) begin
    if (rst)
        pc_out <= 32'h00000000;
    else if (pc_enable)
        pc_out <= pc_next;
end
```

Program completion is controlled separately. In the current demonstration, the program-end address is `0x30`, the first address after the final mapped instruction:

```verilog
program_controller #(
    .END_ADDR(32'h00000030)
) pc_control (...);
```

The controller asserts `program_done` when the current PC is at or beyond the endpoint and deasserts `pc_enable`. The PC then holds. Reset has highest priority inside the PC; otherwise, `pc_enable` determines whether the selected next address is committed.

The current ROM contains a straight-line program with two BEQ instructions. The first redirects execution; the second does not. A general branch-capable processor will need carefully defined arbitration if branches, exceptions, interrupts, stalls, and completion can coincide.

## 6. Demonstration program

The relevant ROM entries are:

| PC | Instruction | Expected behavior |
|---:|---|---|
| `0x1C` | `BEQ x4, x4, +8` (`32'h00420463`) | Taken; next PC is `0x24` |
| `0x20` | `ADDI x5, x0, 99` (`32'h06300293`) | Skipped; `x5` must retain its earlier value of 12 |
| `0x24` | `ADDI x7, x0, 7` (`32'h00700393`) | Executes; `x7 = 7` |
| `0x28` | `BEQ x4, x6, +8` (`32'h00620463`) | Not taken because `x4 = 4` and `x6 = 10` |
| `0x2C` | `ADDI x8, x0, 8` (`32'h00800413`) | Executes; `x8 = 8` |
| `0x30` | Unmapped address | `program_done` asserted; PC holds |

Earlier instructions initialize and compute:

- `x4 = 4`
- `x6 = 10`
- `x2 = 14` after the final OR instruction
- `x3 = 0xFFFFFFFA` (−6)
- `x5 = 12` before the branch sequence

Expected final register state:

| Register | Expected value |
|---|---:|
| `x2` | `32'd14` |
| `x3` | `32'hFFFFFFFA` |
| `x4` | `32'd4` |
| `x5` | `32'd12` |
| `x6` | `32'd10` |
| `x7` | `32'd7` |
| `x8` | `32'd8` |

Expected completion state: `PC = 32'h00000030`, `program_done = 1`, and the PC remains at `0x30` over a subsequent rising edge.

## 7. Verification expectations

The integration testbench should verify more than final register values. It should check:

1. `branch_enable == 1` at both BEQ addresses.
2. `branch_taken == 1` at `0x1C`.
3. The next PC after the taken branch is `0x24`, skipping `0x20`.
4. `branch_taken == 0` at `0x28`.
5. The next PC after the non-taken branch is `0x2C`.
6. `x5` remains 12, proving the sentinel at `0x20` did not execute.
7. `x7 == 7` and `x8 == 8`.
8. The PC reaches `0x30`, `program_done` asserts, and the PC holds.
9. A watchdog terminates the simulation with an error if completion never occurs.

Use case-inequality (`!==`) for important assertions so `X` values are treated as failures. Run the earlier sequential-only program as a regression where its PC interface and completion settings are configured accordingly.

## 8. Source files involved

Current project paths used by this design:

- `rtl/day04/pc.v` — PC with reset, enable, and selected `pc_next` input
- `rtl/day07/alu.v` — existing ALU; subtraction supplies BEQ equality comparison
- `rtl/day07/datapath_top.v` — existing arithmetic datapath
- `rtl/day09/control_extended.v` — supported arithmetic instructions plus BEQ decoding
- `rtl/day09/datapath_extended.v` — decoder/datapath wrapper exposing `branch_enable`
- `rtl/day10/instruction_rom.v` — sequential program and branch instructions
- `rtl/day10/program_runner.v` — instruction fetch, branch target selection, and PC wiring
- `rtl/day11/program_controller.v` — `program_done` and `pc_enable`
- `rtl/day12/branch_immediate_generator.v` — B-type offset reconstruction
- `rtl/day10/tb_program_runner.v` — integration testbench, updated for branch tests

Compile commands and testbench source lists should include all instantiated dependencies. Check every PC instantiation after changing the PC interface: each must connect both `pc_enable` and `pc_next`.

## 9. Current limitations and future work

Current support is intentionally narrow:

- Only BEQ is supported among branch instructions.
- The design uses a small combinational instruction ROM.
- There is no JAL/JALR implementation.
- Loads and stores are not implemented in the datapath.
- There is no full illegal-instruction exception/trap flow.
- Program completion is based on a fixed configured endpoint.
- Branch behavior is not pipelined; a single-cycle combinational path computes the condition and next address.

Potential future improvements, only after this design is working and measured, include BNE, additional branch conditions, jumps, a more complete control-flow policy, and static timing analysis of the PC-to-PC branch path.




1. The 12 bit immediate field is distributed across the instruction and is not contiguous so we cannot directly sign extend inst[31:20].The bits 31,30-25,11-8,7 form the B-Type immediate.imm[0] is zero because of the 2 byte offset required by RISC-V.For PC=0x1C and immediate of +8.the target branch =PC+sign extended immediate. Here 0x1C+sign extended(+8)=0x20.

2. The instruction should be first a valid instruction and a branch instruction for the PC to take a branch along with zero_flag.Using zero_flag alone is incorrect as it may lead to unexpected branches for invalid instructions or instructions that are not BEQ type.

3. Separating the next address selection from the PC allows easier addition of new type of instructions or branches without a need to update the whole pc architecture and others that use pc as an instance.The priority policy should be -reset,branch,program done.

4. One timing critical combinational path might be the ROM and the control_extenced module which decodes the instruction.Since branch instructions are sometimes located far away from the current pc value ,their decoding might take a few extra clock cycles.

5. One fault could be the incorrect decoding of the branch instruction leading to the branch enable being deasserted.Another could be that the zero flag is not set even though the result is zero.

## Bonus

property p_taken_branch_updates_pc;
    @(posedge clk)
    disable iff (reset)
    (branch_valid && branch_taken && pc_update_en)
        |=> (pc_q == $past(branch_target));
endproperty

assert property (p_taken_branch_updates_pc);

If disabling PC updates has priority over a branch, include pc_update_en in the antecedent, as above. Then the assertion does not incorrectly require a branch redirect when the controller has explicitly disabled the PC.

You can also assert that the PC holds when updates are disabled.

