`timescale 1ns/1ps

module program_runner(
    input wire clk,
    input wire rst,
    output wire [31:0] alu_result,
    output wire zero_flag,
    output wire instruction_valid,
    output wire program_done,
    output wire branch_enable,
    output wire branch_taken
);

    wire [31:0] address;
    wire [31:0] instruction;
    wire pc_enable;
    wire [31:0] branch_imm;
    wire [31:0] branch_target;
    wire [31:0] sequential_pc;
    wire [31:0] pc_next;

    // Program Completion: 0x30 is the last address after the 
    //extended 12 instruction program.

    program_controller #(
        .END_ADDR(32'h00000030)
    )
    pc_control(
        .pc_addr(address),
        .pc_enable(pc_enable),
        .program_done(program_done)
    );

    pc pc_inst(
        .clk(clk),
        .rst(rst),
        .pc_out(address),
        .pc_enable(pc_enable),
        .pc_next(pc_next)
    );

    instruction_rom rom_inst(
        .address(address),
        .instruction(instruction)
    );

    branch_immediate_generator branch_inst(
        .inst(instruction),
        .branch_imm(branch_imm)
    );

    datapath_extended d_inst(
        .clk(clk),
        .rst(rst),
        .inst(instruction),
        .alu_result(alu_result),
        .zero_flag(zero_flag),
        .instruction_valid(instruction_valid),
        .branch_enable(branch_enable)
    );

    //Reconstruct the B-type offset.
    assign sequential_pc=address+32'd4;
    assign branch_target=address+branch_imm;

    assign branch_taken=branch_enable & instruction_valid & zero_flag;

    assign pc_next=branch_taken ? branch_target:sequential_pc;

endmodule

