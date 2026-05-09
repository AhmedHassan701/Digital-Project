module CDC_processing_unit_top #(
    parameter DATA_WIDTH = 32,
    parameter DATA_DEPTH = 16,
    parameter ADDR_WIDTH = 4
)(system_if.DUT systemif);

logic W_Enable;
logic rst_n;
logic [DATA_WIDTH - 1:0]WR_DATA;
logic Cin;
logic W_CLK;
logic R_CLK;
logic FULL;
logic [DATA_WIDTH:0]Sum;

assign W_Enable       = systemif.W_Enable;
assign rst_n          = systemif.rst_n;
assign WR_DATA        = systemif.WR_DATA;
assign Cin            = systemif.Cin;
assign W_CLK          = systemif.W_CLK;
assign R_CLK          = systemif.R_CLK;

assign systemif.FULL  = FULL;
assign systemif.Sum   = Sum;

wire  EMPTY; 
wire [DATA_WIDTH-1:0] RD_DATA;
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
    .FULL(FULL),
    .EMPTY(EMPTY)             
    );


fsm fsm_u(
    .i_operands(RD_DATA),
    .i_empty(EMPTY),
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
