
`timescale 1ns/1ps

module tb_datapath_top;

    reg clk;
    reg rst;
    reg [31:0] inst;
    reg reg_write;
    reg alu_src;
    reg [3:0] alu_control;

    wire [31:0] alu_result;
    wire zero_flag;

    datapath_top uut (
        .clk(clk),
        .rst(rst),
        .inst(inst),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .alu_ctrl(alu_control),
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
        alu_control = 4'b0010;

        // Reset register file.
        #12;
        rst = 0;

        // Test 1: ADDI x6, x0, 16
        inst = 32'h01000313;
        reg_write = 1;
        alu_src = 1;
        alu_control = 4'b0010;

        #10;
        if (uut.rf_inst.registers[6] !== 32'd16)
            $fatal(1, "FAIL: x6 should equal 16");

        // Test 2: ADDI x5, x6, -4
        inst = 32'hFFC30293;
        alu_src = 1;
        alu_control = 4'b0010;

        #10;
        if (alu_result !== 32'd12)
            $fatal(1, "FAIL: ADDI result should be 12");
        if (uut.rf_inst.registers[5] !== 32'd12)
            $fatal(1, "FAIL: x5 should equal 12");

        // Test 3: SUB x7, x5, x6
        inst = 32'h406283B3;
        alu_src = 0;
        alu_control = 4'b0110;

        #10;
        if (alu_result !== 32'hFFFFFFFC)
            $fatal(1, "FAIL: SUB result should equal -4");
        if (uut.rf_inst.registers[7] !== 32'hFFFFFFFC)
            $fatal(1, "FAIL: x7 should equal -4");

        // Test 4: x0 must remain zero.
        inst = 32'h01000013; // ADDI x0, x0, 16
        alu_src = 1;
        alu_control = 4'b0010;

        #10;
        if (uut.rf_inst.registers[0] !== 32'd0)
            $fatal(1, "FAIL: x0 was modified");

        $display("SUCCESS: All datapath integration tests passed!");
        $finish;
    end

endmodule
