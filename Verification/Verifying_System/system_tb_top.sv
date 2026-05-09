`timescale 1ns/1ps

// ============================================================
//  system_tb_top
//
//  Clocks
//    W_CLK : 20 MHz  → period = 50 ns
//    R_CLK : 100 MHz → period = 10 ns
// ============================================================
module system_tb_top ();

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
  system_if #(.DATA_WIDTH(DATA_WIDTH)) systemif (
    .W_CLK(W_CLK),
    .R_CLK(R_CLK)
  );

  // ----------------------------------------------------------
  // DUT
  // ----------------------------------------------------------
  CDC_processing_unit_top #(
    .DATA_WIDTH(DATA_WIDTH),
    .DATA_DEPTH(DATA_DEPTH),
    .ADDR_WIDTH(ADDR_WIDTH)
  ) dut (systemif.DUT);

  // ----------------------------------------------------------
  // Testbench
  // ----------------------------------------------------------
  system_tb tb (
    systemif.TB,
    dut.fsm_u.current_state,
    dut.fsm_u.next_state
  );

endmodule
