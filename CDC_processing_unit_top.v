module CDC_processing_unit_top #(
    parameter DATA_WIDTH = 32,
    parameter DATA_DEPTH = 16,
    parameter ADDR_WIDTH = 4
)(
    input   wire                  W_CLK,
    input   wire                  W_Enable,
    input   wire                  R_CLK,
    input   wire                  rst_n,
    input   wire [DATA_WIDTH-1:0] WR_DATA,
    input                         Cin,
    output  wire                  FULL,
    output wire [32:0] Sum    
    
);

wire  EMPTY; 
wire [DATA_WIDTH-1:0] RD_DATA;
wire RD_VALID;
wire R_Enable;
wire [31:0] A_operand_wire;
wire [31:0] B_operand_wire;


ASYNC_FIFO  #(
    .DATA_WIDTH(DATA_WIDTH),
    .DATA_DEPTH(DATA_DEPTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) ASYNC_FIFO_u(
    .W_CLK(W_CLK),
    .RST_n(rst_n),
    .W_Enable(W_Enable),
    .R_CLK(R_CLK),
    .R_Enable(R_Enable),
    .WR_DATA(WR_DATA),
    .RD_DATA(RD_DATA),
    .RD_VALID(RD_VALID),
    .FULL(FULL),
    .EMPTY(EMPTY)             
    );


fsm fsm_u(
    .i_operands(RD_DATA),
    .i_empty(EMPTY),
    .i_data_valid(RD_VALID),
    .clk(R_CLK),
    .rst_n(rst_n),
    .o_read_enable(R_Enable),
    .A_operand(A_operand_wire),
    .B_operand(B_operand_wire)
);

adder_top adder_top_u(
    .A(A_operand_wire),
    .B(B_operand_wire),
    .Cin(Cin),
    .Sum(Sum)    
);





    
endmodule
