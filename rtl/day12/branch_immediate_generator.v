`timescale 1ns/1ps

module branch_immediate_generator(
    input wire [31:0] inst,
    output wire [31:0] branch_imm
);
      
      assign branch_imm={{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
endmodule