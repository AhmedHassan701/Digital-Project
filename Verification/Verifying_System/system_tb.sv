`include "system_pkt.sv"

module system_tb (system_if.TB systemif);

  // Packet Handle
  system_pkt pkt;

  // Parameters
  localparam DATA_WIDTH = 32;

  // Constant
  const int num_rands = 100;

  // Queues
  logic [DATA_WIDTH:0]expected_output_queue[$];
  logic [DATA_WIDTH:0]expected_output;
  logic [DATA_WIDTH:0]actual_output;
  logic [DATA_WIDTH:0]actual_output_queue[$];

  logic [DATA_WIDTH:0]previous_output;

  // Tasks
  task reset;

    systemif.rst_n = 1'b1;
    @(posedge systemif.W_CLK);
    systemif.rst_n = 1'b0;
    @(posedge systemif.W_CLK);
    systemif.rst_n = 1'b1;
    @(posedge systemif.W_CLK);

  endtask

  task init;

    systemif.W_Enable = 1'b0;
    systemif.WR_DATA  = 'd0;
    systemif.Cin      = 1'b0;

    reset ();

    previous_output   = systemif.Sum;

  endtask

  task generateStimulus;

    assert (pkt.randomize ()) else $fatal ("Randomization Error");
    pkt.cg.sample ();

  endtask

  task goldenModel (input logic [DATA_WIDTH - 1:0]operand_A, input logic [DATA_WIDTH - 1:0]operand_B);

    expected_output = operand_A + operand_B + pkt.Cin;
    expected_output_queue.push_back(expected_output);

  endtask

  task driveStimulus;

    logic [DATA_WIDTH - 1:0]operands[1:0];

    int written_words;

    written_words = 'd0;

    forever
      begin
        if (pkt.W_Enable && (!systemif.FULL))
          begin
            systemif.WR_DATA        = pkt.WR_DATA;
            operands[written_words] = pkt.WR_DATA;
            written_words++;
          end

        @(posedge systemif.W_CLK);

        if (written_words == 'd2)
          begin
            goldenModel(operands[0], operands[1]);
            break;
          end
      end

  endtask

  task collectOutput;

    actual_output = systemif.Sum;
    wait(actual_output != previous_output);

  endtask

  task checkOutput;

    if (actual_output == expected_output)
      begin
        $display("[PASSED] The Packet #%0d has passed!", pkt.pkt_id);
      end
    else
      begin
        $display("[FAILED] The Packet #%0d has failed!, expected = %0d, actual = %0d, A = %0d, B = %0d, Cin = %1b", pkt.pkt_id, expected_output, actual_output, pkt.A, pkt.B, pkt.Cin);
      end

  endtask

  task outputSummary;

    int num_passes;
    int num_failures;

    num_passes    = 'd0;
    num_failures  = 'd0;

    foreach(expected_output_queue[i])
      begin
        if (actual_output_queue[i] == expected_output_queue[i])
          begin
            num_passes++;
          end
        else
          begin
            num_failures++;
          end
      end

    $display ("Number of PASSES = %0d", num_passes);
    $display ("Number of FAILURES = %0d", num_failures);

  endtask

  

endmodule