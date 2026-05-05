module FIFO_RD #(
    parameter ADDR_WIDTH = 4
)(
    input   wire                    R_CLK,
    input   wire                    RST_n,
    input   wire                    R_Enable,
    input   wire [ADDR_WIDTH:0]     Rq2_Wptr,
    output  reg  [ADDR_WIDTH:0]     RD_ptr,
    output  reg  [ADDR_WIDTH-1:0]   RD_addr,
    output  reg                     RD_VALID,
    output  wire                    EMPTY
);

    reg               Flag;
    reg [ADDR_WIDTH:0] RD_ptr_comb;

    // EMPTY Logic
    assign EMPTY = (RD_ptr_comb == Rq2_Wptr) ? 1'b1 : 1'b0;

    // convert Binary to Gray
    always @(*) begin
        RD_ptr_comb = {Flag, RD_addr} ^ ({1'b0, Flag, RD_addr} >> 1);
    end

    // read pointer and address generation
    always @(posedge R_CLK or negedge RST_n) begin
        if (!RST_n) begin
            RD_addr <= 'd0;
            Flag    <= 1'b0;
        end
        else if (R_Enable && !EMPTY) begin
            if (RD_addr == {ADDR_WIDTH{1'b1}})   // wraps at 15
                {Flag, RD_addr} <= RD_addr + 1;
            else
                RD_addr <= RD_addr + 1;
        end
    end

    always @(posedge R_CLK or negedge RST_n) begin
        if (!RST_n)  RD_ptr <= 0;
        else         RD_ptr <= RD_ptr_comb;
    end

    reg rd_accept;

    // Read-valid pulse aligned with RD_DATA
    always @(posedge R_CLK or negedge RST_n) begin
        if (!RST_n) begin
            rd_accept <= 1'b0;
            RD_VALID  <= 1'b0;
        end else begin
            rd_accept <= (R_Enable && !EMPTY);
            RD_VALID  <= rd_accept;
        end
    end

endmodule