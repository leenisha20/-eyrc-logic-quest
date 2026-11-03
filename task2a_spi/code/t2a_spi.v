/*
eYRC26-27: Logic Quest
Task 2A: SPI Master Module
Description : Parameterizable SPI master controller supporting all 4 SPI
              modes (via CPOL/CPHA), configurable bit order (MSB/LSB
              first), and configurable word length. Derives SCLK by
              dividing down the 50MHz input clock (HALF_PERIOD sets the
              divide ratio). On `start`, shifts tx_data out on MOSI while
              simultaneously shifting MISO into rx_data; `busy` is high
              for the duration and `cs_out` is driven low for the transfer.
Parameters:
  CPOL             - Clock polarity (0: idle low, 1: idle high)        [default: 0]
  CPHA             - Clock phase (0: sample leading edge,
                      1: sample trailing edge)                        [default: 0]
  LSB_FIRST        - Bit order (0: MSB first, 1: LSB first)           [default: 0]
  SPI_WORD_LENGTH  - Number of bits per transfer                      [default: 8]
  HALF_PERIOD      - clk_50MHz cycles per SCLK half-period.
                      SCLK freq = 50MHz / (2 x HALF_PERIOD)           [default: 25 -> 1MHz]
Ports:
  clk_50MHz    (in )  1 bit               - System clock (50MHz)
  rst_n        (in )  1 bit               - Active-low async reset
  start        (in )  1 bit               - Pulse high (sampled in IDLE) to begin transfer
  tx_data      (in )  SPI_WORD_LENGTH     - Data word to transmit on MOSI
  miso_input   (in )  1 bit               - Serial data in from SPI slave
  sclk_out     (out)  1 bit               - SPI serial clock, idles at CPOL
  cs_out       (out)  1 bit               - Chip select, active-low during transfer
  mosi_output  (out)  1 bit               - Serial data out to SPI slave
  rx_data      (out)  SPI_WORD_LENGTH     - Data received from MISO (valid once busy=0)
  busy         (out)  1 bit               - High for the duration of an active transfer
*/

module t2a_spi
#(
    parameter CPOL             = 1'b0,
    parameter CPHA             = 1'b0,
    parameter LSB_FIRST        = 1'b0,
    parameter SPI_WORD_LENGTH  = 8,
    parameter HALF_PERIOD      = 25   // clk_50MHz cycles per half sclk period
)
(
    input wire clk_50MHz,
    input wire rst_n,

    input wire start,
    input wire [SPI_WORD_LENGTH-1:0] tx_data,
    input wire miso_input,

    output reg sclk_out,
    output reg cs_out,
    output reg mosi_output,

    output reg [SPI_WORD_LENGTH-1:0] rx_data,
    output reg busy
);

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

localparam IDLE     = 1'b0;
localparam TRANSFER = 1'b1;
localparam TOTAL_EDGES = 2 * SPI_WORD_LENGTH;
function integer clog2;
    input integer value;
    integer i;
    begin
        value = value - 1;
        for (i = 0; value > 0; i = i + 1)
            value = value >> 1;
        clog2 = i;
    end
endfunction
localparam CYC_W  = clog2(HALF_PERIOD + 1);
localparam EDGE_W = clog2(TOTAL_EDGES + 1);
reg                       state;
reg [CYC_W-1:0]           cyc_cnt;    
reg [EDGE_W-1:0]          edge_cnt;   
reg [SPI_WORD_LENGTH-1:0] tx_shift;   
reg [SPI_WORD_LENGTH-1:0] rx_shift;   
wire half_done = (cyc_cnt == HALF_PERIOD);          
wire last_edge = (edge_cnt == TOTAL_EDGES - 1);     
always @(posedge clk_50MHz or negedge rst_n) begin
    if (!rst_n) begin
        state       <= IDLE;
        cyc_cnt     <= 0;
        edge_cnt    <= 0;
        sclk_out    <= 1'b0;
        cs_out      <= 1'b1;
        busy        <= 1'b0;
        tx_shift    <= 0;
        mosi_output <= 1'b0;
        rx_shift    <= 0;
        rx_data     <= 0;
    end else begin
        case (state)
            IDLE: begin
                if (start) begin
                    state       <= TRANSFER;
                    cs_out      <= 1'b0;
                    busy        <= 1'b1;
                    cyc_cnt     <= 0;
                    edge_cnt    <= 0;
                    tx_shift    <= tx_data;
                    mosi_output <= tx_data[SPI_WORD_LENGTH-1];
                    rx_shift    <= 0;
                end
            end

            TRANSFER: begin
                if (half_done) begin
                    cyc_cnt  <= 1;
                    sclk_out <= ~sclk_out;
                    edge_cnt <= edge_cnt + 1'b1;
                    if (!sclk_out) begin                        
                        rx_shift <= {rx_shift[SPI_WORD_LENGTH-2:0], miso_input};
                    end
                    if (last_edge) begin
                        state   <= IDLE;
                        cs_out  <= 1'b1;
                        busy    <= 1'b0;
                        rx_data <= rx_shift;
                    end else if (sclk_out) begin                        
                        mosi_output <= tx_shift[SPI_WORD_LENGTH-2];
                        tx_shift    <= tx_shift << 1;
                    end
                end else begin
                    cyc_cnt <= cyc_cnt + 1'b1;
                end
            end
        endcase
    end
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule