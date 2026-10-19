`timescale 1ns/1ps

module datapath_extended(
    input wire clk,
    input wire rst,
    input [31:0] inst,
    
    output wire [31:0] alu_result,
    output wire zero_flag,
    output wire instruction_valid,
    output wire branch_enable
);
    wire decoded_alu_src;
    wire [3:0] decoded_alu_control;
    wire reg_write;
    wire safe_reg_write;

    control_extended c_t(
        .inst(inst),
        .alu_control(decoded_alu_control),
        .alu_src(decoded_alu_src),
        .reg_write(reg_write),
        .instruction_valid(instruction_valid),
        .branch_enable(branch_enable)
    );

    assign safe_reg_write=(reg_write & instruction_valid);

    datapath_top d_t(
        .clk(clk),
        .rst(rst),
        .inst(inst),
        .alu_src(decoded_alu_src),
        .alu_ctrl(decoded_alu_control),
        .reg_write(safe_reg_write),
        .alu_result(alu_result),
        .zero_flag(zero_flag)
    );

endmodule

    