// hazard_unit.v - combinational hazard unit
// Handles data hazards (forwarding), load-use hazards (stall)
// and control hazards (flush after a taken branch/jump).

module hazard_unit (
    input      [4:0] Rs1D, Rs2D,
    input      [4:0] Rs1E, Rs2E, RdE,
    input      [4:0] RdM, RdW,
    input            RegWriteM, RegWriteW,
    input            ResultSrcE0,      
    input            PCSrcE,           
    output reg [1:0] ForwardAE, ForwardBE,   
    output           StallF, StallD,
    output           FlushD, FlushE
);

wire lwStall = ResultSrcE0 & (RdE != 5'd0) & ((RdE == Rs1D) | (RdE == Rs2D));
assign StallF = lwStall;
assign StallD = lwStall;
assign FlushD = PCSrcE;
assign FlushE = lwStall | PCSrcE;

always @(*) begin
    if      (RegWriteM && (RdM != 5'd0) && (RdM == Rs1E)) ForwardAE = 2'b10;
    else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs1E)) ForwardAE = 2'b01;
    else                                                  ForwardAE = 2'b00;

    if      (RegWriteM && (RdM != 5'd0) && (RdM == Rs2E)) ForwardBE = 2'b10;
    else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs2E)) ForwardBE = 2'b01;
    else                                                  ForwardBE = 2'b00;
end

endmodule