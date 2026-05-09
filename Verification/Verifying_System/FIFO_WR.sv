module FIFO_WR #(
    parameter ADDR_WIDTH = 4
)(
    input   wire                    W_CLK,
    input   wire                    RST_n,
    input   wire                    W_Enable,
    input   wire [ADDR_WIDTH:0]     Wq2_Rptr,
    output  reg  [ADDR_WIDTH-1:0]   WR_addr,
    output  reg  [ADDR_WIDTH:0]     WR_ptr,
    output  wire                    FULL
);

    reg               Flag;
    reg [ADDR_WIDTH:0] WR_ptr_comb;

    // Convert Binary to Gray
    always @(*) begin
        WR_ptr_comb = {Flag, WR_addr} ^ ({1'b0, Flag, WR_addr} >> 1);
    end

    // FULL Logic
    assign FULL = (WR_ptr_comb == {~Wq2_Rptr[ADDR_WIDTH],
                                   ~Wq2_Rptr[ADDR_WIDTH-1],
                                    Wq2_Rptr[ADDR_WIDTH-2:0]});

    // write pointer and address generation
    always @(posedge W_CLK or negedge RST_n) begin
        if (!RST_n) begin
            WR_addr <= 'd0;
            Flag    <= 1'b0;
        end
        else if (W_Enable && !FULL) begin
            if (WR_addr == {ADDR_WIDTH{1'b1}})
                {Flag, WR_addr} <= WR_addr + 1;  // wrap + flip flag
            else
                WR_addr <= WR_addr + 1;
        end
    end

    always @(posedge W_CLK or negedge RST_n) begin
        if (!RST_n)  WR_ptr <= 0;
        else         WR_ptr <= WR_ptr_comb;
    end

endmodule