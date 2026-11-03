// alu.v - ALU module

module alu #(parameter WIDTH = 32) (
    input       [WIDTH-1:0] a, b,       // operands
    input       [3:0] alu_ctrl,         // ALU control (4 bits)
    output reg  [WIDTH-1:0] alu_out,    // ALU output
    output      zero,                   // result == 0
    output      lt,                     // signed   a < b
    output      ltu                     // unsigned a < b
);

always @(*) begin
    case (alu_ctrl)
        4'b0000: alu_out = a + b;                              // ADD
        4'b0001: alu_out = a - b;                              // SUB
        4'b0010: alu_out = a & b;                              // AND
        4'b0011: alu_out = a | b;                              // OR
        4'b0100: alu_out = a ^ b;                              // XOR
        4'b0101: alu_out = ($signed(a) < $signed(b)) ? 1 : 0;  // SLT
        4'b0110: alu_out = (a < b) ? 1 : 0;                    // SLTU
        4'b0111: alu_out = a << b[4:0];                        // SLL
        4'b1000: alu_out = a >> b[4:0];                        // SRL
        4'b1001: alu_out = $signed(a) >>> b[4:0];              // SRA
        default: alu_out = 0;
    endcase
end

assign zero = (alu_out == 0) ? 1'b1 : 1'b0;

assign lt  = ($signed(a) < $signed(b));
assign ltu = (a < b);

endmodule