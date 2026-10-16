`timescale 1ns/1ps

module tb_datapath_extended;

    reg clk;
    reg rst;
    reg [31:0] inst;

    wire [31:0] alu_result;
    wire instruction_valid;
    wire zero_flag;

    datapath_extended uut (
        .clk(clk),
        .rst(rst),
        .inst(inst),
        .alu_result(alu_result),
        .instruction_valid(instruction_valid),
        .zero_flag(zero_flag)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    // Apply an instruction and check its result and writeback.
    task automatic run_and_check;
        input [31:0] instruction;
        input [31:0] expected_result;

        reg [4:0] rd_idx;

        begin
            // Change instruction away from the active clock edge.
            @(negedge clk);
            inst = instruction;
            rd_idx = instruction[11:7];

            // Wait for execution and register writeback.
            @(posedge clk);
            #1;

            if (instruction_valid !== 1'b1)
                $fatal(1, "FAIL: Instruction not recognized: %h",
                       instruction);

            if (alu_result !== expected_result)
                $fatal(1,
                       "FAIL: inst=%h expected=%h actual=%h",
                       instruction, expected_result, alu_result);

            // Check the stored destination register.
            if ((rd_idx != 5'd0) &&
                (uut.d_t.rf_inst.registers[rd_idx]
                    !== expected_result))
                $fatal(1,
                       "FAIL: rd=x%0d expected=%h actual=%h",
                       rd_idx, expected_result,
                       uut.d_t.rf_inst.registers[rd_idx]);
        end
    endtask

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        inst = 32'd0;

        // Allow synchronous reset to occur on a rising edge.
        #12;
        rst = 1'b0;

        // ------------------------------------------
        // Test 1: ADDI x4, x0, 4
        // x4 = 4
        // ------------------------------------------
        run_and_check(32'h00400213, 32'd4);

        // Test 2: ADDI x6, x0, 10
        // x6 = 10
        run_and_check(32'h00A00313, 32'd10);

        // ------------------------------------------
        // Test 3: ADD x2, x4, x6
        // 4 + 10 = 14
        // ------------------------------------------
        run_and_check(32'h00620133, 32'd14);

        // ------------------------------------------
        // Test 4: SUB x2, x4, x6
        // 4 - 10 = -6
        // ------------------------------------------
        run_and_check(32'h40620133, 32'hFFFFFFFA);

        // ------------------------------------------
        // Test 5: ADDI x4, x0, 1
        // x4 = 1
        // ------------------------------------------
        run_and_check(32'h00100213, 32'd1);

        // Test 6: ADDI x6, x0, 2
        // x6 = 2
        run_and_check(32'h00200313, 32'd2);

        // ------------------------------------------
        // Test 7: AND x2, x4, x6
        // 1 & 2 = 0
        // ------------------------------------------
        run_and_check(32'h00627133, 32'd0);

        // ------------------------------------------
        // Test 8: OR x2, x4, x6
        // 1 | 2 = 3
        // ------------------------------------------
        run_and_check(32'h00626133, 32'd3);

        // ------------------------------------------
        // Test 9: ADDI x4, x0, 9
        // x4 = 9
        // ------------------------------------------
        run_and_check(32'h00900213, 32'd9);

        // Test 10: ADDI x2, x4, 6
        // 9 + 6 = 15
        // ------------------------------------------
        run_and_check(32'h00620113, 32'd15);

        // ------------------------------------------
        // Test 11: Unsupported ADD/SUB encoding
        // funct7 = 0000001 is unsupported by our decoder.
        // x2 must retain its previous value of 15.
        // ------------------------------------------
        @(negedge clk);
        inst = 32'h02620133;

        @(posedge clk);
        #1;

        if (instruction_valid !== 1'b0)
            $fatal(1, "FAIL: Unsupported instruction accepted");

        if (uut.d_t.rf_inst.registers[2] !== 32'd15)
            $fatal(1, "FAIL: Unsupported instruction changed x2");

        $display("SUCCESS: All datapath decoder tests passed!");

        $finish;
    end

endmodule