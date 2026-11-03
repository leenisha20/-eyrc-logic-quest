// pl_reg_mw.v - pipeline register: Memory -> Writeback

module pl_reg_mw (
    input             clk, rst,
    input             RegWriteM,
    input      [1:0]  ResultSrcM,
    input      [31:0] ALUResultM, ReadDataM, WriteDataM, PCPlus4M,
    input      [4:0]  RdM,
    output reg        RegWriteW,
    output reg [1:0]  ResultSrcW,
    output reg [31:0] ALUResultW, ReadDataW, WriteDataW, PCPlus4W,
    output reg [4:0]  RdW
);

initial begin
    RegWriteW = 0; ResultSrcW = 0;
    ALUResultW = 0; ReadDataW = 0; WriteDataW = 0; PCPlus4W = 0; RdW = 0;
end

always @(posedge clk) begin
    if (rst) begin
        RegWriteW <= 0; ResultSrcW <= 0;
        ALUResultW <= 0; ReadDataW <= 0; WriteDataW <= 0; PCPlus4W <= 0; RdW <= 0;
    end else begin
        RegWriteW <= RegWriteM; ResultSrcW <= ResultSrcM;
        ALUResultW <= ALUResultM; ReadDataW <= ReadDataM;
        WriteDataW <= WriteDataM; PCPlus4W <= PCPlus4M; RdW <= RdM;
    end
end

endmodule