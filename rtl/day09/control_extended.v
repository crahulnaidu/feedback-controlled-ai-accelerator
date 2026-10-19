`timescale 1ns/1ps

module control_extended(
    input wire [31:0] inst,

    output reg [3:0] alu_control,
    output reg alu_src,
    output reg reg_write,
    output reg instruction_valid,
    output reg branch_enable
);

    wire [6:0] opcode;
    wire [2:0] funct_3;
    wire [6:0] funct_7;

    assign opcode=inst[6:0];
    assign funct_3=inst[14:12];
    assign funct_7=inst[31:25];

    localparam AND=4'b0000;
    localparam OR=4'b0001;
    localparam ADD=4'b0010;
    localparam SUB=4'b0110;


    always @ (*) begin
        
        //Safe Defaults.
        alu_control=AND;
        alu_src=1'b0;
        reg_write=1'b0;
        instruction_valid=1'b0;
        branch_enable=1'b0;

        case (opcode)
            7'b0110011: begin
                case (funct_3)
                    3'b000: begin
                        case (funct_7)
                            7'b0000000: begin
                                alu_control=ADD;
                                alu_src=1'b0;
                                reg_write=1'b1;
                                instruction_valid=1'b1;
                                branch_enable=1'b0;
                            end

                            7'b0100000: begin
                                alu_control=SUB;
                                alu_src=1'b0;
                                reg_write=1'b1;
                                instruction_valid=1'b1;
                                branch_enable=1'b0;
                            end

                            default: begin

                            end
                        endcase
                    end

                    3'b111:begin
                        case (funct_7)
                            7'b0000000:begin
                                alu_control=AND;
                                alu_src=1'b0;
                                reg_write=1'b1;
                                instruction_valid=1'b1;
                                branch_enable=1'b0;
                            end

                            default:begin
                            end
                        endcase
                    end

                    3'b110:begin
                        case (funct_7)
                            7'b0000000:begin
                                alu_control=OR;
                                alu_src=1'b0;
                                reg_write=1'b1;
                                instruction_valid=1'b1;
                                branch_enable=1'b0;
                            end
                            default:begin
                            end
                        endcase
                    end
                endcase
            end


            7'b0010011:begin
                case (funct_3)
                    3'b000:begin
                        alu_control=ADD;
                        alu_src=1'b1;
                        reg_write=1'b1;
                        instruction_valid=1'b1;
                        branch_enable=1'b0;
                    end

                    default:begin
                    end
                endcase

            end

            7'b1100011:begin
                case (funct_3)
                    3'b000:begin
                        alu_control=SUB;
                        alu_src=1'b0;
                        reg_write=1'b0;
                        instruction_valid=1'b1;
                        branch_enable=1'b1;
                    end
                    default:begin
                    end
                endcase
            end

            default:begin
                // Unsupported Opcode.
            end
        endcase
    end
    endmodule
   
                            
        

                         
