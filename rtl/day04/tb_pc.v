module tb_pc;
    reg clk;
    reg rst;
    wire [31:0] pc_out;

    // Connect our testing rig to the Program Counter
    pc uut (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out)
    );

    // 1. Generate a continuous clock (toggles every 5 time units)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 2. Run the test sequence
    initial begin
        // Setup waveform file for GTKwave
        $dumpfile("pc_wave.vcd");
        $dumpvars(0, tb_pc);

        // Monitor the PC value in Hexadecimal formatting (%h)
        $monitor("Time=%0td | rst=%b | PC=0x%h (%0d)", $time, rst, pc_out, pc_out);

        // Start with a Reset
        rst = 1; #12; 
        rst = 0; // Release reset to let the PC start counting
        
        // Let it run for several clock cycles
        #80;

        $finish; // End simulation
    end
endmodule