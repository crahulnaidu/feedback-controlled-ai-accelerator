`timescale 1ns/1ps

module tb_program_runner;

      reg clk;
      reg rst;
      wire [31:0] alu_result;
      wire zero_flag;
      wire instruction_valid;

      program_runner uut(
        .clk(clk),
        .rst(rst),
        .alu_result(alu_result),
        .zero_flag(zero_flag),
        .instruction_valid(instruction_valid)
      );

      always #5 clk=~clk;

      integer i;

      initial begin
        clk=1'b0;
        rst=1'b1;

        //Keep reset active for two clock cycles.
        repeat (2) @(posedge(clk));

        //Deactivate reset away from the rising edge.
        @(negedge(clk));
        rst=1'b0;

        $display("Starting program execution...");

        //Allow the seven ROM instructions to execute.

        for (i=0;i<7;i=i+1) begin

            //Observe the instruction before its execution.
            $display(
                "PC=%h Instruction=%h ALU=%h Valid=%b",
                uut.pc_inst.pc_out,
                uut.rom_inst.instruction,
                alu_result,
                instruction_valid
            );

            if(instruction_valid!==1'b1)
               $fatal(1,"FAIL:Invalid instruction at PC=%h",uut.pc_inst.pc_out);

            //Execute instruction at next clock cycle.
            @(posedge(clk));
            #1;
        end

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

        // x5 = 12
        if (uut.d_inst.d_t.rf_inst.registers[5] !== 32'd12)
            $fatal(1, "FAIL: x5 should equal 12");

        // After seven instructions, PC should be 0x1C
        if (uut.pc_inst.pc_out !== 32'h0000001C)
            $fatal(1, "FAIL: PC should equal 0x1C");

        // The ROM returns 0 at this unmapped address.
        if (instruction_valid !== 1'b0)
            $fatal(1, "FAIL: Unmapped instruction should be invalid");

        // Execute one unsupported instruction and ensure
        // it does not overwrite x2.
        @(posedge clk);
        #1;

        if (uut.d_inst.d_t.rf_inst.registers[2] !== 32'd14)
            $fatal(1, "FAIL: Unsupported instruction modified x2");

        $display("SUCCESS: All program execution tests passed!");
        $finish;
    end

endmodule   