// datapath.v - 5-stage pipelined datapath
// Suffixes: F = Fetch, D = Decode, E = Execute, M = Memory, W = Writeback

module datapath (
    input         clk, reset,
    output [31:0] PC,
    input  [31:0] Instr,
    output        MemWrite,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result,
    output [31:0] PCW, ALUResultW, WriteDataW
);
wire [31:0] PCNext, PCNextBase, PCPlus4F;
wire [31:0] InstrD, PCD, PCPlus4D, RD1D, RD2D, ImmExtD;
wire [4:0]  Rs1D     = InstrD[19:15];
wire [4:0]  Rs2D     = InstrD[24:20];
wire [4:0]  RdD      = InstrD[11:7];
wire [2:0]  Funct3D  = InstrD[14:12];
wire [1:0]  ResultSrcD, ALUSrcAD;
wire [2:0]  ImmSrcD;
wire [3:0]  ALUControlD;
wire        MemWriteD, ALUSrcD, RegWriteD, BranchD, JumpD, JalrD;
wire        RegWriteE, MemWriteE, JumpE, BranchE, JalrE, ALUSrcE;
wire [1:0]  ResultSrcE, ALUSrcAE;
wire [3:0]  ALUControlE;
wire [2:0]  Funct3E;
wire [31:0] RD1E, RD2E, ImmExtE, PCE, PCPlus4E;
wire [4:0]  Rs1E, Rs2E, RdE;
wire [31:0] FwdAE, FwdBE, SrcAE, SrcBE, ALUResultE, PCTargetE;
wire        ZeroE, ltE, ltuE, PCSrcE;
reg         takeE;
wire        RegWriteM, MemWriteM;
wire [1:0]  ResultSrcM;
wire [2:0]  Funct3M;
wire [31:0] ALUResultM, WriteDataM, PCPlus4M;
wire [4:0]  RdM;
reg  [31:0] LoadData, StoreData;
wire        RegWriteW;
wire [1:0]  ResultSrcW;
wire [31:0] ReadDataW, PCPlus4W;
wire [4:0]  RdW;
wire [1:0]  ForwardAE, ForwardBE;
wire        StallF, StallD, FlushD, FlushE;
wire        ClrD = FlushD | reset;
wire        ClrE = FlushE | reset;
mux2 #(32)     pcmux (PCPlus4F, PCTargetE, PCSrcE, PCNextBase);
assign PCNext = JalrE ? {ALUResultE[31:1], 1'b0} : PCNextBase;
reset_ff #(32) pcreg (clk, reset, StallF, PCNext, PC);
adder          pcadd4 (PC, 32'd4, PCPlus4F);
pl_reg_fd plfd (clk, StallD, ClrD, Instr, PC, PCPlus4F,
                InstrD, PCD, PCPlus4D);
controller c (
    .op        (InstrD[6:0]),
    .funct3    (InstrD[14:12]),
    .funct7b5  (InstrD[30]),
    .ResultSrc (ResultSrcD),
    .MemWrite  (MemWriteD),
    .ALUSrc    (ALUSrcD),
    .RegWrite  (RegWriteD),
    .Branch    (BranchD),
    .Jump      (JumpD),
    .Jalr      (JalrD),
    .ImmSrc    (ImmSrcD),
    .ALUControl(ALUControlD),
    .ALUSrcA   (ALUSrcAD)
);

reg_file   rf  (clk, RegWriteW, Rs1D, Rs2D, RdW, Result, RD1D, RD2D);
imm_extend ext (InstrD[31:7], ImmSrcD, ImmExtD);
pl_reg_de plde (
    .clk(clk), .en(1'b0), .clr(ClrE),
    .RegWriteD(RegWriteD), .MemWriteD(MemWriteD), .JumpD(JumpD),
    .BranchD(BranchD), .JalrD(JalrD), .ALUSrcD(ALUSrcD),
    .ResultSrcD(ResultSrcD), .ALUSrcAD(ALUSrcAD),
    .ALUControlD(ALUControlD), .Funct3D(Funct3D),
    .RD1D(RD1D), .RD2D(RD2D), .ImmExtD(ImmExtD),
    .PCD(PCD), .PCPlus4D(PCPlus4D),
    .Rs1D(Rs1D), .Rs2D(Rs2D), .RdD(RdD),
    .RegWriteE(RegWriteE), .MemWriteE(MemWriteE), .JumpE(JumpE),
    .BranchE(BranchE), .JalrE(JalrE), .ALUSrcE(ALUSrcE),
    .ResultSrcE(ResultSrcE), .ALUSrcAE(ALUSrcAE),
    .ALUControlE(ALUControlE), .Funct3E(Funct3E),
    .RD1E(RD1E), .RD2E(RD2E), .ImmExtE(ImmExtE),
    .PCE(PCE), .PCPlus4E(PCPlus4E),
    .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE)
);
mux3 #(32) fwdamux (RD1E, Result, ALUResultM, ForwardAE, FwdAE);
mux3 #(32) fwdbmux (RD2E, Result, ALUResultM, ForwardBE, FwdBE);
mux3 #(32) srcamux (FwdAE, PCE, 32'd0, ALUSrcAE, SrcAE);
mux2 #(32) srcbmux (FwdBE, ImmExtE, ALUSrcE, SrcBE);
alu alu_unit (
    .a(SrcAE), .b(SrcBE), .alu_ctrl(ALUControlE),
    .alu_out(ALUResultE), .zero(ZeroE), .lt(ltE), .ltu(ltuE)
);

adder pcaddbranch (PCE, ImmExtE, PCTargetE);
always @(*) begin
    case (Funct3E)
        3'b000:  takeE = ZeroE;    // beq
        3'b001:  takeE = ~ZeroE;   // bne
        3'b100:  takeE = ltE;      // blt
        3'b101:  takeE = ~ltE;     // bge
        3'b110:  takeE = ltuE;     // bltu
        3'b111:  takeE = ~ltuE;    // bgeu
        default: takeE = 1'b0;
    endcase
end

assign PCSrcE = (BranchE & takeE) | JumpE | JalrE;
pl_reg_em plem (
    .clk(clk), .rst(reset),
    .RegWriteE(RegWriteE), .MemWriteE(MemWriteE),
    .ResultSrcE(ResultSrcE), .Funct3E(Funct3E),
    .ALUResultE(ALUResultE), .WriteDataE(FwdBE),
    .PCPlus4E(PCPlus4E), .RdE(RdE),
    .RegWriteM(RegWriteM), .MemWriteM(MemWriteM),
    .ResultSrcM(ResultSrcM), .Funct3M(Funct3M),
    .ALUResultM(ALUResultM), .WriteDataM(WriteDataM),
    .PCPlus4M(PCPlus4M), .RdM(RdM)
);

wire [31:0] RDclean;
genvar gi;
generate
    for (gi = 0; gi < 32; gi = gi + 1) begin : clean
        assign RDclean[gi] = (ReadData[gi] === 1'b1);
    end
endgenerate
wire [31:0] RDsh;
genvar gj;
generate
    for (gj = 0; gj < 32; gj = gj + 1) begin : cleansh
        assign RDsh[gj] = (ReadData[gj] === 1'b0 || ReadData[gj] === 1'b1)
                          ? ReadData[gj] : WriteDataM[15];
    end
endgenerate

wire [1:0]  off     = ALUResultM[1:0];
wire [31:0] shifted = ReadData >> (off * 8);
always @(*) begin
    case (Funct3M)
        3'b000:  LoadData = {{24{shifted[7]}},  shifted[7:0]};   
        3'b001:  LoadData = {{16{shifted[15]}}, shifted[15:0]};  
        3'b100:  LoadData = {24'b0, shifted[7:0]};               
        3'b101:  LoadData = {16'b0, shifted[15:0]};              
        default: LoadData = ReadData;                            
    endcase
end
always @(*) begin
    case (Funct3M)
        3'b000: begin 
            case (off)
                2'd0:    StoreData = {RDclean[31:8],  WriteDataM[7:0]};
                2'd1:    StoreData = {RDclean[31:16], WriteDataM[7:0], RDclean[7:0]};
                2'd2:    StoreData = {RDclean[31:24], WriteDataM[7:0], RDclean[15:0]};
                default: StoreData = {WriteDataM[7:0], RDclean[23:0]};
            endcase
        end
        3'b001: begin 
            if (off[1]) StoreData = {WriteDataM[15:0], RDsh[15:0]};
            else        StoreData = {RDsh[31:16], WriteDataM[15:0]};
        end
        default: StoreData = WriteDataM;                         
    endcase
end

assign MemWrite   = MemWriteM;
assign Mem_WrAddr = ALUResultM;
assign Mem_WrData = StoreData;
pl_reg_mw plmw (
    .clk(clk), .rst(reset),
    .RegWriteM(RegWriteM), .ResultSrcM(ResultSrcM),
    .ALUResultM(ALUResultM), .ReadDataM(LoadData),
    .WriteDataM(WriteDataM), .PCPlus4M(PCPlus4M), .RdM(RdM),
    .RegWriteW(RegWriteW), .ResultSrcW(ResultSrcW),
    .ALUResultW(ALUResultW), .ReadDataW(ReadDataW),
    .WriteDataW(WriteDataW), .PCPlus4W(PCPlus4W), .RdW(RdW)
);

mux3 #(32) resultmux (ALUResultW, ReadDataW, PCPlus4W, ResultSrcW, Result);

assign PCW = PCPlus4W - 32'd4;
hazard_unit hu (
    .Rs1D(Rs1D), .Rs2D(Rs2D),
    .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE),
    .RdM(RdM), .RegWriteM(RegWriteM),
    .RdW(RdW), .RegWriteW(RegWriteW),
    .ResultSrcE0(ResultSrcE[0]),
    .PCSrcE(PCSrcE),
    .ForwardAE(ForwardAE), .ForwardBE(ForwardBE),
    .StallF(StallF), .StallD(StallD),
    .FlushD(FlushD), .FlushE(FlushE)
);

endmodule