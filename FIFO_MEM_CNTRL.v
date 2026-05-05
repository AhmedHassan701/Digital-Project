module FIFO_MEM_CNTRL #(
    parameter DATA_WIDTH = 32,
    parameter DATA_DEPTH = 16,
    parameter ADDR_WIDTH = 4
)(
    input   wire  [DATA_WIDTH - 1:0] WR_DATA,
    input   wire  [ADDR_WIDTH - 1:0] WR_addr,
    input   wire  [ADDR_WIDTH - 1:0] RD_addr,
    input   wire                     W_Enable,
    input   wire                     W_CLK,
    input   wire                     RST_n,
    input   wire                     W_Full,
    output  reg   [DATA_WIDTH - 1:0] RD_DATA        );

    reg [DATA_WIDTH - 1:0] FIFO_MEM [DATA_DEPTH - 1:0];
    integer i;

    wire WR_CLK_en;

    assign WR_CLK_en = W_Enable & !W_Full;

    //Write Operation
    always @(posedge W_CLK or negedge RST_n) 
        begin
            if (!RST_n)
                for (i = 0; i < DATA_DEPTH; i = i + 1) 
                    begin
                        FIFO_MEM[i] <= 'd0;
                    end
            else if (WR_CLK_en) 
                begin
                    FIFO_MEM[WR_addr] <= WR_DATA;
                end
        end 

    // Read Operation
    always @(*) 
        begin
            RD_DATA = FIFO_MEM[RD_addr];
        end

endmodule