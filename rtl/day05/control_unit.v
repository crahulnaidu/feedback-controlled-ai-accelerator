module control_unit(
    input [6:0] opcode,
    output reg ALUSrc,
    output reg RegWrite,
    output reg MemWrite,
    output reg MemRead,
    output reg Branch
);

always @(*)begin
    //Default Values
    ALUSrc=0;
    RegWrite=0;
    MemWrite=0;
    MemRead=0;
    Branch=0;

    case (opcode)

        // ADD / SUB / AND / OR
        7'b0110011: begin
            ALUSrc   = 0;
            RegWrite = 1;
        end

        // ADDI
        7'b0010011: begin
            ALUSrc   = 1;
            RegWrite = 1;
        end

        // LD
        7'b0000011: begin
            ALUSrc   = 1;
            RegWrite = 1;
            MemRead  = 1;
        end

        // SD
        7'b0100011: begin
            ALUSrc   = 1;
            MemWrite = 1;
        end

        // BEQ
        7'b1100011: begin
            ALUSrc = 0;
            Branch = 1;
        end

        default: begin
            ALUSrc=0;
            RegWrite=0;
            MemRead=0;
            MemWrite=0;
            Branch=0;
        end
    endcase
end


endmodule






