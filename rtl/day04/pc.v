module pc (
    input clk,          // Clock signal
    input rst,          // Asynchronous reset (reboots PC to 0)
    output reg [31:0] pc_out // 32-bit output holding the current address
);

    // Triggers on the rising edge of the clock or reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= 32'h00000000; // Reset PC to address 0
        end else begin
            pc_out <= pc_out + 4;   // Increment by 4 bytes every cycle
        end
    end

endmodule