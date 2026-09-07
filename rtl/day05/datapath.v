module datapath(
input [63:0] rs1_data,
input [63:0] rs2_data,
input [63:0] immediate,
input ALUSrc,

output [63:0] alu_input_b

);

assign alu_input_b=(ALUSrc==1'b0)?rs2_data:immediate;

endmodule

