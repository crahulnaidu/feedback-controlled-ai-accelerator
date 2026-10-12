// tb_datapath_top.v - Self-checking testbench
`timescale 1ns/1ps

module tb_datapath_top;
    reg        clk;
    reg        rst;
    reg [31:0] inst;
    reg        reg_write;
    reg        alu_src;
    reg [3:0]  alu_control;
    wire [31:0] alu_result;
    wire        zero_flag;

    datapath_top uut (
        .clk(clk),
        .rst(rst),
        .inst(inst),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .alu_control(alu_control),
        .alu_result(alu_result),
        .zero_flag(zero_flag)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        inst = 0;
        reg_write = 0;
        alu_src = 0;
        alu_control = 4'b0000;

        #12 rst = 0;

        // Step 1: Preload x6 = 16 using ADDI x6, x0, 16
        // inst: imm=16(0x010), rs1=0, funct3=0, rd=6, op=0x13 -> 32'h01000313
        inst = 32'h01000313; reg_write = 1; alu_src = 1; alu_control = 4'b0010;
        #10;

        // Step 2: ADDI x5, x6, -4 -> Expect alu_result = 12 (0x0C)
        // inst: imm=-4(0xFFC), rs1=6, funct3=0, rd=5, op=0x13 -> 32'hFFC30293
        inst = 32'hFFC30293; reg_write = 1; alu_src = 1; alu_control = 4'b0010;
        #10;
        if (alu_result !== 32'h0000000C) $error("FAIL: ADDI expected 12, got %h", alu_result);

        // Step 3: SUB x7, x5, x6 -> Expect 12 - 16 = -4 (0xFFFFFFFC)
        // inst: funct7=0, rs2=6, rs1=5, funct3=0, rd=7, op=0x33 -> 32'h006283B3
        inst = 32'h006283B3; reg_write = 1; alu_src = 0; alu_control = 4'b0110;
        #10;
        if (alu_result !== 32'hFFFFFFFC) $error("FAIL: SUB expected -4, got %h", alu_result);

        $display("SUCCESS: All integration datapath tests passed!");
        $finish;
    end
endmodule