module alu(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] alu_control,
    output reg [31:0] result,
    output wire zero
);

    localparam ALU_AND=4'b0000;
    localparam ALU_OR=4'b0001;
    localparam ALU_ADD=4'b0010;
    localparam ALU_SUB=4'b0110;
    localparam ALU_SLT=4'b0111;
    localparam ALU_NOR=4'b1100;

    always @(*)begin
        case (alu_control)
            ALU_ADD:result=a & b;
            ALU_OR:result=a | b;
            ALU_ADD:result=a+b;
            ALU_SUB:result=a-b;
            ALU_SLT:result=($signed(a)<$signed(b)):32'd1:32'd0;
            ALU_NOR:result=~(a | b);
            default:result=32'd0;
        endcase
    end

    assign zero=(result==32'd0);
endmodule