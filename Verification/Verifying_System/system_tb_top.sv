`timescale 1ns/1ps

module system_tb_top ();

  // Local Parameter
  localparam DATA_WIDTH = 32;

  // Clock Generation
  localparam CLK_PERIOD_W = 50;
  localparam CLK_PERIOD_R = 10;

  bit R_CLK;
  bit W_CLK;

  initial
    begin
      W_CLK = 1'b0;
      forever
        begin
          #(CLK_PERIOD_W / 2.0) W_CLK = !W_CLK;
        end
    end

  initial
    begin
      R_CLK = 1'b0;
      forever
        begin
          #(CLK_PERIOD_R / 2.0) R_CLK = !R_CLK;
        end
    end

  // Instantiations
  system_if systemif #(.DATA_WIDTH(DATA_WIDTH)) (.W_CLK(W_CLK), .R_CLK(R_CLK));
  CDC_processing_unit_top dut (systemif.DUT);
  system_tb tb  (systemif.TB);

endmodule