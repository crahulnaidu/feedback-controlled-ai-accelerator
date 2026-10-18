`timescale 1ns/1ps

module program_controller #(
    parameter [31:0] END_ADDR=32'h0000001C
)(
    input wire [31:0] pc_addr,
    output reg pc_enable,
    output reg program_done
);

   //END Address is the first address after the program.
   assign program_done=(pc_addr>=END_ADDR);
   //STOP Advancing when the program is done.
   assign pc_enable=~program_done;

endmodule