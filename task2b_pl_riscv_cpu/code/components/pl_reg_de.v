// pl_reg_de.v - pipeline register: Decode -> Execute
// en high = hold, clr high = clear (clr has priority), same style as pl_reg_fd

module pl_reg_de (
    input             clk, en, clr,
    input             RegWriteD, MemWriteD, JumpD, BranchD, JalrD, ALUSrcD,
    input      [1:0]  ResultSrcD, ALUSrcAD,
    input      [3:0]  ALUControlD,
    input      [2:0]  Funct3D,
    input      [31:0] RD1D, RD2D, ImmExtD, PCD, PCPlus4D,
    input      [4:0]  Rs1D, Rs2D, RdD,
    output reg        RegWriteE, MemWriteE, JumpE, BranchE, JalrE, ALUSrcE,
    output reg [1:0]  ResultSrcE, ALUSrcAE,
    output reg [3:0]  ALUControlE,
    output reg [2:0]  Funct3E,
    output reg [31:0] RD1E, RD2E, ImmExtE, PCE, PCPlus4E,
    output reg [4:0]  Rs1E, Rs2E, RdE
);

initial begin
    RegWriteE = 0; MemWriteE = 0; JumpE = 0; BranchE = 0; JalrE = 0; ALUSrcE = 0;
    ResultSrcE = 0; ALUSrcAE = 0; ALUControlE = 0; Funct3E = 0;
    RD1E = 0; RD2E = 0; ImmExtE = 0; PCE = 0; PCPlus4E = 0;
    Rs1E = 0; Rs2E = 0; RdE = 0;
end

always @(posedge clk) begin
    if (clr) begin
        RegWriteE <= 0; MemWriteE <= 0; JumpE <= 0; BranchE <= 0; JalrE <= 0; ALUSrcE <= 0;
        ResultSrcE <= 0; ALUSrcAE <= 0; ALUControlE <= 0; Funct3E <= 0;
        RD1E <= 0; RD2E <= 0; ImmExtE <= 0; PCE <= 0; PCPlus4E <= 0;
        Rs1E <= 0; Rs2E <= 0; RdE <= 0;
    end else if (!en) begin
        RegWriteE <= RegWriteD; MemWriteE <= MemWriteD; JumpE <= JumpD;
        BranchE <= BranchD; JalrE <= JalrD; ALUSrcE <= ALUSrcD;
        ResultSrcE <= ResultSrcD; ALUSrcAE <= ALUSrcAD;
        ALUControlE <= ALUControlD; Funct3E <= Funct3D;
        RD1E <= RD1D; RD2E <= RD2D; ImmExtE <= ImmExtD;
        PCE <= PCD; PCPlus4E <= PCPlus4D;
        Rs1E <= Rs1D; Rs2E <= Rs2D; RdE <= RdD;
    end
end

endmodule