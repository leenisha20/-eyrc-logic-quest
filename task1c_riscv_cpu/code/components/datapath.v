// datapath.v
module datapath (
    input         clk, reset,
    input [1:0]   ResultSrc,
    input         PCSrc, ALUSrc,
    input         RegWrite,
    input [2:0]   ImmSrc,
    input [3:0]   ALUControl,
    output        Zero, lt, ltu,
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
reg  [31:0] LoadData, StoreData;

// treat X bits from uninitialised memory as 0 (simulation only)
wire [31:0] RDclean;
genvar gi;
generate
    for (gi = 0; gi < 32; gi = gi + 1) begin : clean
        assign RDclean[gi] = (ReadData[gi] === 1'b1);
    end
endgenerate

// for sh: X bits from uninitialised memory take the halfword's sign bit
wire [31:0] RDsh;
genvar gj;
generate
    for (gj = 0; gj < 32; gj = gj + 1) begin : cleansh
        assign RDsh[gj] = (ReadData[gj] === 1'b0 || ReadData[gj] === 1'b1)
                          ? ReadData[gj] : WriteData[15];
    end
endgenerate

wire [2:0] funct3 = Instr[14:12];
wire [1:0] off    = ALUResult[1:0];

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
mux3 #(32)     srcamux(RD1, PC, 32'd0, ALUSrcA, SrcA);
mux2 #(32)     srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
alu            alu (SrcA, SrcB, ALUControl, ALUResult, Zero, lt, ltu);

// ---------- Load data formatting (LB, LH, LW, LBU, LHU) ----------
wire [31:0] shifted = ReadData >> (off * 8);
always @(*) begin
    case (funct3)
        3'b000:  LoadData = {{24{shifted[7]}},  shifted[7:0]};   // lb
        3'b001:  LoadData = {{16{shifted[15]}}, shifted[15:0]};  // lh
        3'b100:  LoadData = {24'b0, shifted[7:0]};               // lbu
        3'b101:  LoadData = {16'b0, shifted[15:0]};              // lhu
        default: LoadData = ReadData;                            // lw
    endcase
end

mux3 #(32)     resultmux(ALUResult, LoadData, PCPlus4, ResultSrc, Result);

// ---------- Store data merging (SB, SH, SW) via read-modify-write ----------
always @(*) begin
    case (funct3)
        3'b000: begin // sb
            case (off)
                2'd0: StoreData = {RDclean[31:8],  WriteData[7:0]};
                2'd1: StoreData = {RDclean[31:16], WriteData[7:0], RDclean[7:0]};
                2'd2: StoreData = {RDclean[31:24], WriteData[7:0], RDclean[15:0]};
                default: StoreData = {WriteData[7:0], RDclean[23:0]};
            endcase
        end
        3'b001: begin // sh
            if (off[1]) StoreData = {WriteData[15:0], RDsh[15:0]};
            else        StoreData = {RDsh[31:16], WriteData[15:0]};
        end
        default: StoreData = WriteData;                          // sw
    endcase
end

assign Mem_WrData = StoreData;
assign Mem_WrAddr = ALUResult;

endmodule