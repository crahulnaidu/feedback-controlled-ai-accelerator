module immediate_generator(

    input [7:0] immediate_in,
    output [63:0] immediate_out
);

assign immediate_out={{56{immediate_in[7]}},immediate_in};

endmodule