module ASYNC_FIFO #(
    parameter DATA_WIDTH = 32,
    parameter DATA_DEPTH = 16,
    parameter ADDR_WIDTH = 4
)(
    input   wire                  W_CLK,
    input   wire                  RST_n,
    input   wire                  W_Enable,
    input   wire                  R_CLK,
    input   wire                  R_Enable,
    input   wire [DATA_WIDTH-1:0] WR_DATA,
    output  wire [DATA_WIDTH-1:0] RD_DATA,
    output  wire                  FULL,
    output  wire                  EMPTY             );

    wire [ADDR_WIDTH:0] WR_ptr, RD_ptr;
    wire [ADDR_WIDTH:0] Wq2_Rptr, Rq2_Wptr;
    wire [ADDR_WIDTH-1:0] WR_addr, RD_addr;

    FIFO_MEM_CNTRL #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_DEPTH(DATA_DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) FIFO (
        .W_CLK(W_CLK),
        .RST_n(RST_n),
        .W_Enable(W_Enable),
        .WR_DATA(WR_DATA),
        .RD_DATA(RD_DATA),
        .W_Full(FULL),
        .WR_addr(WR_addr),
        .RD_addr(RD_addr)           );


    FIFO_WR #(.ADDR_WIDTH(ADDR_WIDTH)) Write_Control (
        .W_CLK(W_CLK),
        .RST_n(RST_n),
        .W_Enable(W_Enable),
        .FULL(FULL),
        .Wq2_Rptr(Wq2_Rptr),
        .WR_addr(WR_addr),
        .WR_ptr(WR_ptr)             );


    FIFO_RD #(.ADDR_WIDTH(ADDR_WIDTH)) Read_Control (
        .R_CLK(R_CLK),
        .RST_n(RST_n),
        .R_Enable(R_Enable),
        .EMPTY(EMPTY),
        .Rq2_Wptr(Rq2_Wptr),
        .RD_addr(RD_addr),
        .RD_ptr(RD_ptr)             );

    DF_SYNC sync_W2R (
        .CLK(R_CLK),
        .RST_n(RST_n),
        .ASYNC_DATA(WR_ptr),
        .SYNC_DATA(Rq2_Wptr)        );

    DF_SYNC sync_R2W (
        .CLK(W_CLK),
        .RST_n(RST_n),
        .ASYNC_DATA(RD_ptr),
        .SYNC_DATA(Wq2_Rptr)            );

endmodule