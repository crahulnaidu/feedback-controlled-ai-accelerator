module tb_mux_2to1;
    reg a;
    reg b;
    reg sel;
    wire y;

    // Instantiate the Unit Under Test (UUT)
    mux_2to1 uut (
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    initial begin
        // Monitor changes to inputs and output
        $monitor("Time=%0t | sel=%b a=%b b=%b | y=%b", $time, sel, a, b, y);

        // Test all 8 combinations of inputs (sel, a, b)
        sel = 0; a = 0; b = 0; #10;
        sel = 0; a = 0; b = 1; #10;
        sel = 0; a = 1; b = 0; #10;
        sel = 0; a = 1; b = 1; #10;
        sel = 1; a = 0; b = 0; #10;
        sel = 1; a = 0; b = 1; #10;
        sel = 1; a = 1; b = 0; #10;
        sel = 1; a = 1; b = 1; #10;

        $finish;
    end
endmodule