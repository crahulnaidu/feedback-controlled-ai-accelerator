`timescale 1ns/1ps

module pc (
    input wire clk,          // Clock signal
    input wire rst,          // Asynchronous reset (reboots PC to 0)
    input wire pc_enable,   //Controls if pc_out is updated
    input wire [31:0] pc_next, //The next pc address
    output reg [31:0] pc_out // 32-bit output holding the current address
);

    // Triggers on the rising edge of the clock or reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= 32'h00000000; // Reset PC to address 0
        end else if(pc_enable) begin
            pc_out <= pc_next;   // Increment by 4 bytes every cycle
        end
    end

endmodule