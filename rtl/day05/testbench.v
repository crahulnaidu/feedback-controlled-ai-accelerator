module testbench;

reg [63:0] rs1_data;
reg [63:0] rs2_data;
reg [63:0] immediate;
reg ALUSrc;

wire [63:0] alu_input_b;

datapath dut(
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .immediate(immediate),
    .ALUSrc(ALUSrc),
    .alu_input_b(alu_input_b)
);

initial begin

    rs1_data = 64'd10;
    rs2_data = 64'd20;
    immediate = 64'd100;

    // Select rs2
    ALUSrc = 1'b0;

    #10;

    $display("ALUSrc = 0, ALU input B = %d", alu_input_b);

    // Select immediate
    ALUSrc = 1'b1;

    #10;

    $display("ALUSrc = 1, ALU input B = %d", alu_input_b);

    $finish;

end

endmodule