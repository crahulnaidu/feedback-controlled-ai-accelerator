`timescale 1ns/1ps

module datapath_top(
    input wire clk,
    input wire rst,
    input wire [31:0] inst,
    input wire reg_write,
    input wire [3:0]alu_ctrl,
    input wire alu_src,
    output wire [31:0] alu_result,
    output wire zero_flag
);
    
    wire [4:0] rs1=inst[19:15];
    wire [4:0] rs2=inst[24:20];
    wire [4:0] rd=inst[11:7];

    wire [31:0] rdata1;
    wire [31:0] rdata2;
    wire [31:0] imm32;
    wire [31:0] operand_b;

    assign imm32={{20{inst[31]}},inst[31:20]};

    register_file rf_inst(
        .clk(clk),
        .rst(rst),
        .RegWrite(reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(alu_result),
        .read_data1(rdata1),
        .read_data2(rdata2)
    );

    assign operand_b=(alu_src) ? imm32 : rdata2;

    alu alu_inst(
        .a(rdata1),
        .b(operand_b),
        .alu_control(alu_ctrl),
        .result(alu_result),
        .zero(zero_flag)
    );

    endmodule