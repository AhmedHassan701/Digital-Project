`timescale 1ns/1ps

// ============================================================
//  fifo_tb_top
//
//  Clocks
//    W_CLK : 20  MHz → period = 50 ns
//    R_CLK : 100 MHz → period = 10 ns
// ============================================================
module fifo_tb_top ();

  // ----------------------------------------------------------
  // Parameters
  // ----------------------------------------------------------
  localparam DATA_WIDTH = 32;
  localparam DATA_DEPTH = 16;
  localparam ADDR_WIDTH = 4;

  // ----------------------------------------------------------
  // Clock periods (ns)
  // ----------------------------------------------------------
  localparam real CLK_PERIOD_W = 50.0;   // 20 MHz
  localparam real CLK_PERIOD_R = 10.0;   // 100 MHz

  // ----------------------------------------------------------
  // Clock generation
  // ----------------------------------------------------------
  bit W_CLK;
  bit R_CLK;

  initial begin
    W_CLK = 1'b0;
    forever #(CLK_PERIOD_W / 2.0) W_CLK = ~W_CLK;
  end

  initial begin
    R_CLK = 1'b0;
    forever #(CLK_PERIOD_R / 2.0) R_CLK = ~R_CLK;
  end

  // ----------------------------------------------------------
  // Interface
  // ----------------------------------------------------------
  fifo_if #(.DATA_WIDTH(DATA_WIDTH)) fifoif (
    .W_CLK(W_CLK),
    .R_CLK(R_CLK)
  );

  // ----------------------------------------------------------
  // DUT
  // ----------------------------------------------------------
  ASYNC_FIFO #(
    .DATA_WIDTH(DATA_WIDTH),
    .DATA_DEPTH(DATA_DEPTH),
    .ADDR_WIDTH(ADDR_WIDTH)
  ) dut (
    .W_CLK    (fifoif.W_CLK),
    .RST_n    (fifoif.RST_n),
    .W_Enable (fifoif.W_Enable),
    .R_CLK    (fifoif.R_CLK),
    .R_Enable (fifoif.R_Enable),
    .WR_DATA  (fifoif.WR_DATA),
    .RD_DATA  (fifoif.RD_DATA),
    .FULL     (fifoif.FULL),
    .EMPTY    (fifoif.EMPTY)
  );

  // ----------------------------------------------------------
  // Testbench
  // ----------------------------------------------------------
  fifo_tb tb (
    fifoif.TB,
    dut.FULL,
    dut.EMPTY
  );

endmodule
