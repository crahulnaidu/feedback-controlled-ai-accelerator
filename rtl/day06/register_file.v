module register_file(
    input clk,
    input RegWrite,

    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,

    input [63:0] write_data,

    output [63:0] read_data1,
    output [63:0] read_data2
);

reg [63:0] registers [31:0];

assign read_data1=registers[rs1];
assign read_data1=registers[rs2];

always @ (posedge clk)begin
    
    if (RegWrite && rd!=5'd0)
    registers[rd]<=write_data;
end
endmodule
