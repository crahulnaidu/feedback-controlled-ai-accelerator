`timescale 1ns/1ps

module tb_program_runner;

    reg clk;
    reg rst;

    wire [31:0] alu_result;
    wire zero_flag;
    wire instruction_valid;
    wire program_done;
    wire branch_taken;
    wire branch_enable;

    reg [31:0] current_pc;
    reg [31:0] expected_next_pc;

    program_runner uut (
        .clk(clk),
        .rst(rst),
        .alu_result(alu_result),
        .zero_flag(zero_flag),
        .instruction_valid(instruction_valid),
        .program_done(program_done),
        .branch_enable(branch_enable),
        .branch_taken(branch_taken)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    // Watchdog prevents an infinite simulation.
    initial begin
        #1000;
        $fatal(1, "TIMEOUT: Program did not finish");
    end

    initial begin
        clk = 1'b0;
        rst = 1'b1;

        // Keep reset active over two rising edges.
        repeat (2) @(posedge clk);

        // Deassert reset away from the rising edge.
        @(negedge clk);
        rst = 1'b0;

        $display("Starting program execution...");

        // Execute instructions until the PC reaches END_ADDR.
        while (program_done !== 1'b1) begin

            current_pc = uut.pc_inst.pc_out;

            $display(
                "PC=%h Instruction=%h ALU=%h Valid=%b Branch=%b Taken=%b",
                current_pc,
                uut.rom_inst.instruction,
                alu_result,
                instruction_valid,
                branch_enable,
                branch_taken
            );

            if (instruction_valid !== 1'b1)
                $fatal(1,
                    "FAIL: Invalid instruction at PC=%h",
                    current_pc
                );

            // Default behavior: sequential execution.
            expected_next_pc = current_pc + 32'd4;

            // Taken BEQ at 0x1C: jump to 0x24.
            if (current_pc == 32'h0000001C) begin

                if (branch_enable !== 1'b1)
                    $fatal(1, "FAIL: BEQ not decoded at 0x1C");

                if (branch_taken !== 1'b1)
                    $fatal(1, "FAIL: BEQ at 0x1C should be taken");

                expected_next_pc = 32'h00000024;
            end

            // Non-taken BEQ at 0x28: continue to 0x2C.
            else if (current_pc == 32'h00000028) begin

                if (branch_enable !== 1'b1)
                    $fatal(1, "FAIL: BEQ not decoded at 0x28");

                if (branch_taken !== 1'b0)
                    $fatal(1, "FAIL: BEQ at 0x28 should not be taken");

                expected_next_pc = 32'h0000002C;
            end

            else begin
                if (branch_enable !== 1'b0)
                    $fatal(1,
                        "FAIL: Unexpected branch at PC=%h",
                        current_pc
                    );

                if (branch_taken !== 1'b0)
                    $fatal(1,
                        "FAIL: Unexpected branch_taken at PC=%h",
                        current_pc
                    );
            end

            // Execute the current instruction.
            @(posedge clk);
            #1;

            // Check the actual PC update.
            if (uut.pc_inst.pc_out !== expected_next_pc)
                $fatal(1,
                    "FAIL: PC transition from %h; expected %h, got %h",
                    current_pc,
                    expected_next_pc,
                    uut.pc_inst.pc_out
                );
        end

        // Program must finish at 0x30.
        if (program_done !== 1'b1)
            $fatal(1, "FAIL: program_done was not asserted");

        if (uut.pc_inst.pc_out !== 32'h00000030)
            $fatal(1, "FAIL: PC should equal 0x30");

        // The ROM returns an unsupported instruction at 0x30.
        if (instruction_valid !== 1'b0)
            $fatal(1, "FAIL: Unmapped instruction should be invalid");

        $display("Checking final register values...");

        // x4 = 4
        if (uut.d_inst.d_t.rf_inst.registers[4] !== 32'd4)
            $fatal(1, "FAIL: x4 should equal 4");

        // x6 = 10
        if (uut.d_inst.d_t.rf_inst.registers[6] !== 32'd10)
            $fatal(1, "FAIL: x6 should equal 10");

        // x2 = 14 (final result of OR)
        if (uut.d_inst.d_t.rf_inst.registers[2] !== 32'd14)
            $fatal(1, "FAIL: x2 should equal 14");

        // x3 = -6
        if (uut.d_inst.d_t.rf_inst.registers[3] !== 32'hFFFFFFFA)
            $fatal(1, "FAIL: x3 should equal -6");

        // x5 = 12; the sentinel ADDI at 0x20 must be skipped.
        if (uut.d_inst.d_t.rf_inst.registers[5] !== 32'd12)
            $fatal(1, "FAIL: x5 should equal 12");

        // x7 = 7; the instruction at 0x24 executes.
        if (uut.d_inst.d_t.rf_inst.registers[7] !== 32'd7)
            $fatal(1, "FAIL: x7 should equal 7");

        // x8 = 8; the non-taken branch falls through to 0x2C.
        if (uut.d_inst.d_t.rf_inst.registers[8] !== 32'd8)
            $fatal(1, "FAIL: x8 should equal 8");

        // Verify that the PC remains at the end address.
        @(posedge clk);
        #1;

        if (uut.pc_inst.pc_out !== 32'h00000030)
            $fatal(1, "FAIL: PC advanced after program completion");

        if (program_done !== 1'b1)
            $fatal(1, "FAIL: program_done deasserted unexpectedly");

        if (uut.d_inst.d_t.rf_inst.registers[2] !== 32'd14)
            $fatal(1, "FAIL: x2 changed after program completion");

        $display("SUCCESS: All program execution tests passed!");
        $finish;

    end

endmodule