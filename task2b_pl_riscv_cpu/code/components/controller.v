// controller.v - decode-only controller for the pipelined RISC-V CPU
module controller (
    input  [6:0] op,
    input  [2:0] funct3,
    input        funct7b5,
    output [1:0] ResultSrc,
    output       MemWrite,
    output       ALUSrc,
    output       RegWrite, Branch, Jump, Jalr,
    output [2:0] ImmSrc,
    output [3:0] ALUControl,
    output [1:0] ALUSrcA
);

wire [1:0] ALUOp;

main_decoder md (
    .op        (op),
    .ResultSrc (ResultSrc),
    .MemWrite  (MemWrite),
    .Branch    (Branch),
    .ALUSrc    (ALUSrc),
    .RegWrite  (RegWrite),
    .Jump      (Jump),
    .ImmSrc    (ImmSrc),
    .ALUOp     (ALUOp),
    .ALUSrcA   (ALUSrcA),
    .JALR      (Jalr)
);

alu_decoder ad (
    .opb5       (op[5]),
    .funct3     (funct3),
    .funct7b5   (funct7b5),
    .ALUOp      (ALUOp),
    .ALUControl (ALUControl)
);

endmodule