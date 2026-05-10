interface fifo_if #(parameter DATA_WIDTH = 32) (
  input bit W_CLK,
  input bit R_CLK
);

  // Interface Signals
  logic                  RST_n;
  logic                  W_Enable;
  logic                  R_Enable;
  logic [DATA_WIDTH-1:0] WR_DATA;
  logic [DATA_WIDTH-1:0] RD_DATA;
  logic                  FULL;
  logic                  EMPTY;

  modport TB (
    input  RD_DATA,
    input  FULL,
    input  EMPTY,
    input  W_CLK,
    input  R_CLK,
    output RST_n,
    output W_Enable,
    output R_Enable,
    output WR_DATA
  );

  modport DUT (
    input  RST_n,
    input  W_Enable,
    input  R_Enable,
    input  WR_DATA,
    input  W_CLK,
    input  R_CLK,
    output RD_DATA,
    output FULL,
    output EMPTY
  );

endinterface
