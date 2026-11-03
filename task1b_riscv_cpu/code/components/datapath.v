// datapath.v
module datapath (
    input         clk, reset,
    input [1:0]   ResultSrc,
    input         PCSrc, ALUSrc,
    input         RegWrite,
    input [2:0]   ImmSrc,
    input [2:0]   ALUControl,
    output        Zero,
    output [31:0] PC,
    input  [31:0] Instr,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result,
    input  [1:0]  ALUSrcA,
    input         JALR
);

wire [31:0] PCNext, PCNextBase, PCPlus4, PCTarget;
wire [31:0] ImmExt, RD1, SrcA, SrcB, WriteData, ALUResult;

// next PC logic
reset_ff #(32) pcreg(clk, reset, PCNext, PC);
adder          pcadd4(PC, 32'd4, PCPlus4);
adder          pcaddbranch(PC, ImmExt, PCTarget);
mux2 #(32)     pcmux(PCPlus4, PCTarget, PCSrc, PCNextBase);

// JALR: next PC = (rs1 + imm) with bit 0 cleared
assign PCNext = JALR ? {ALUResult[31:1], 1'b0} : PCNextBase;

// register file logic
reg_file       rf (clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, RD1, WriteData);
imm_extend     ext (Instr[31:7], ImmSrc, ImmExt);

// ALU logic
// ALUSrcA: 00 = rs1, 01 = PC (auipc), 10 = zero (lui)
mux3 #(32)     srcamux(RD1, PC, 32'd0, ALUSrcA, SrcA);
mux2 #(32)     srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
alu            alu (SrcA, SrcB, ALUControl, ALUResult, Zero);
mux3 #(32)     resultmux(ALUResult, ReadData, PCPlus4, ResultSrc, Result);

assign Mem_WrData = WriteData;
assign Mem_WrAddr = ALUResult;

endmodule