`timescale 1ns/1ps

module instruction_rom(
    input wire [31:0] address,
    output reg [31:0] instruction
);

     always @(*) begin
        case (address)
            //Initialize x4=4
            32'h00000000:begin
                instruction=32'h00400213;
            end
            //Initialize x6-10
            32'h00000004:begin
                instruction=32'h00A00313;
            end

            // x2 = x4 + x6 = 14
            32'h00000008:begin
                instruction = 32'h00620133;
            end

            // x3 = x4 - x6 = -6
            32'h0000000C:begin
                instruction = 32'h406201B3;
            end

            // x2 = x4 & x6 = 0
            32'h00000010:begin
                instruction = 32'h00627133;
            end

            // x2 = x4 | x6 = 14
            32'h00000014:begin
                instruction = 32'h00626133;
            end

            // x5 = x2 - 2 = 12
            32'h00000018:begin
                instruction = 32'hFFE10293;
            end

            default:begin
            instruction=32'h00000000;
            end

        endcase
            
     end
endmodule