// pl_reg_em.v - pipeline register: Execute -> Memory

module pl_reg_em (
    input             clk, rst,
    input             RegWriteE, MemWriteE,
    input      [1:0]  ResultSrcE,
    input      [2:0]  Funct3E,
    input      [31:0] ALUResultE, WriteDataE, PCPlus4E,
    input      [4:0]  RdE,
    output reg        RegWriteM, MemWriteM,
    output reg [1:0]  ResultSrcM,
    output reg [2:0]  Funct3M,
    output reg [31:0] ALUResultM, WriteDataM, PCPlus4M,
    output reg [4:0]  RdM
);

initial begin
    RegWriteM = 0; MemWriteM = 0; ResultSrcM = 0; Funct3M = 0;
    ALUResultM = 0; WriteDataM = 0; PCPlus4M = 0; RdM = 0;
end

always @(posedge clk) begin
    if (rst) begin
        RegWriteM <= 0; MemWriteM <= 0; ResultSrcM <= 0; Funct3M <= 0;
        ALUResultM <= 0; WriteDataM <= 0; PCPlus4M <= 0; RdM <= 0;
    end else begin
        RegWriteM <= RegWriteE; MemWriteM <= MemWriteE;
        ResultSrcM <= ResultSrcE; Funct3M <= Funct3E;
        ALUResultM <= ALUResultE; WriteDataM <= WriteDataE;
        PCPlus4M <= PCPlus4E; RdM <= RdE;
    end
end

endmodule