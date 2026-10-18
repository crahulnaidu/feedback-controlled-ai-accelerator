`timescale 1ns/1ps

module program_runner(
    input wire clk,
    input wire rst,
    output wire [31:0] alu_result,
    output wire zero_flag,
    output wire instruction_valid,
    output wire program_done
);

    wire [31:0] address;
    wire [31:0] instruction;
    wire pc_enable;

    program_controller pc_control(
        .pc_addr(address),
        .pc_enable(pc_enable),
        .program_done(program_done)
    );

    pc pc_inst(
        .clk(clk),
        .rst(rst),
        .pc_out(address),
        .pc_enable(pc_enable)
    );

    instruction_rom rom_inst(
        .address(address),
        .instruction(instruction)
    );

    datapath_extended d_inst(
        .clk(clk),
        .rst(rst),
        .inst(instruction),
        .alu_result(alu_result),
        .zero_flag(zero_flag),
        .instruction_valid(instruction_valid)
    );

endmodule

