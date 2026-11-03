// alu_decoder.v - logic for ALU decoder

module alu_decoder (
    input            opb5,
    input [2:0]      funct3,
    input            funct7b5,
    input [1:0]      ALUOp,
    output reg [3:0] ALUControl
);

always @(*) begin
    case (ALUOp)
        2'b00: ALUControl = 4'b0000;             
        2'b01: ALUControl = 4'b0001;             
        default:
            case (funct3) 
                3'b000: begin
                    if (funct7b5 & opb5) ALUControl = 4'b0001; 
                    else                 ALUControl = 4'b0000; 
                end
                3'b001:  ALUControl = 4'b0111;   
                3'b010:  ALUControl = 4'b0101;   
                3'b011:  ALUControl = 4'b0110;   
                3'b100:  ALUControl = 4'b0100;   
                3'b101: begin
                    if (funct7b5) ALUControl = 4'b1001; 
                    else          ALUControl = 4'b1000; 
                end
                3'b110:  ALUControl = 4'b0011;   
                3'b111:  ALUControl = 4'b0010;   
                default: ALUControl = 4'b0000;
            endcase
    endcase
end

endmodule