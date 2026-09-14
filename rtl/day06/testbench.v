module testbench;

  reg clk;
  reg RegWrite;

  reg [4:0] rs1;
  reg [4:0] rs2;
  reg [4:0] rd;

  reg [63:0] write_data;
  
  wire [63:0] read_data1;
  wire [63:0] read_data2;

  reg [7:0] immediate_in;
  wire [63:0] immediate_out;

  register_file rf(
    .clk(clk),
    .RegWrite(RegWrite),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
  );

  immediate_generator ig(
    .immediate_in(immediate_in),
    .immediate_out(immediate_out)
  );


  always #5 clk=~clk;

  initial begin

    clk = 0;
    RegWrite = 0;

    rs1 = 0;
    rs2 = 0;
    rd = 0;
    write_data = 0;

    immediate_in = 8'b00000101;

    #10;

    $display("Positive immediate = %d", immediate_out);

    immediate_in = 8'b11111011;

    #10;

    $display("Negative immediate = %d", $signed(immediate_out));

    $finish;

end

endmodule
