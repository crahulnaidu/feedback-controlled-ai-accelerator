module tb_d_reg;
    reg clk;
    reg rst;
    reg d;
    wire q;

    // Connect testbench inputs/outputs to the register design
    d_reg uut (
        .clk(clk),
        .rst(rst),
        .d(d),
        .q(q)
    );

    // --- 1. GENERATE THE CLOCK SIGNAL ---
    // Starts at 0. Every 5 time units, it toggles (~clk).
    // This creates a complete clock cycle every 10 units forever.
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // --- 2. APPLY TEST STIMULUS ---
    initial begin
        // Set up waveform dumping for GTKwave
        $dumpfile("reg_wave.vcd");
        $dumpvars(0, tb_d_reg);

        // Monitor changing values in terminal
        $monitor("Time=%0t | rst=%b d=%b | q=%b", $time, rst, d, q);

        // Initialize and Reset the hardware
        rst = 1; d = 0; #12; 
        rst = 0;             // Turn off reset after 12 units
        
        // Test 1: Set data to 1 
        d = 1; #10;          

        // Test 2: Set data to 0
        d = 0; #10;

        // Test 3: Set data to 1 right before a clock edge
        d = 1; #2;
        
        // Test 4: Maintain data to observe stability
        #16;

        $finish; // Stop simulation safely
    end
endmodule
