interface system_if #(parameter DATA_WIDTH = 32) (
  input bit W_CLK,
  input bit R_CLK
);

  // Interface Signals
  logic                  W_Enable;
  logic                  rst_n;
  logic [DATA_WIDTH-1:0] WR_DATA;
  logic                  Cin;
  logic                  FULL;
  logic [DATA_WIDTH:0]   Sum;

  modport TB (
    input  FULL,
    input  Sum,
    input  W_CLK,
    input  R_CLK,
    output W_Enable,
    output rst_n,
    output WR_DATA,
    output Cin
  );

  modport DUT (
    input  W_Enable,
    input  rst_n,
    input  WR_DATA,
    input  Cin,
    input  W_CLK,
    input  R_CLK,
    output FULL,
    output Sum
  );

endinterface
