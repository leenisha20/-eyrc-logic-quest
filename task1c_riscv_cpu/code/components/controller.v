// controller.v - controller for RISC-V CPU

module controller (
    input [6:0]  op,
    input [2:0]  funct3,
    input        funct7b5,
    input        Zero, lt, ltu,
    output       [1:0] ResultSrc,
    output       MemWrite,
    output       PCSrc, ALUSrc,
    output       RegWrite, Jump,
    output [2:0] ImmSrc,
    output [3:0] ALUControl,
    output [1:0] ALUSrcA,
    output       JALR
);

wire [1:0] ALUOp;
wire       Branch;
reg        take;

main_decoder    md (op, ResultSrc, MemWrite, Branch,
                    ALUSrc, RegWrite, Jump, ImmSrc, ALUOp,
                    ALUSrcA, JALR);

alu_decoder     ad (op[5], funct3, funct7b5, ALUOp, ALUControl);

// branch condition from funct3
always @(*) begin
    case (funct3)
        3'b000:  take = Zero;     // beq
        3'b001:  take = ~Zero;    // bne
        3'b100:  take = lt;       // blt
        3'b101:  take = ~lt;      // bge
        3'b110:  take = ltu;      // bltu
        3'b111:  take = ~ltu;     // bgeu
        default: take = 1'b0;
    endcase
end

assign PCSrc = (Branch & take) | Jump;

endmodule