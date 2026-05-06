`include "adder_pkt.sv"

module adder_tb (adder_if.TB adderif);

  // Packet Handle
  adder_pkt pkt;

  // Parameters
  localparam DATA_WIDTH = 32;
  localparam DELAY      = 1;

  // Constant
  const int num_rands = 100;

  // Queues
  logic [DATA_WIDTH:0]expected_output_queue[$];
  logic [DATA_WIDTH:0]expected_output;
  logic [DATA_WIDTH:0]actual_output;
  logic [DATA_WIDTH:0]actual_output_queue[$];

  // Tasks
  task init;

    adderif.A   = 'd0;
    adderif.B   = 'd0;
    adderif.Cin = 1'b0;

  endtask

  task generateStimulus;

    assert (pkt.randomize ()) else $fatal ("Randomization Error");
    pkt.cg.sample ();

  endtask

  task goldenModel;

    logic [DATA_WIDTH:0]expected_sum;
    expected_sum  = pkt.A + pkt.B + pkt.Cin;
    expected_output_queue.push_back(expected_sum);
    expected_output = expected_sum;

  endtask

  task driveStimulus;

    adderif.A   = pkt.A;
    adderif.B   = pkt.B;
    adderif.Cin = pkt.Cin;

    #(DELAY);

  endtask

  task collectOutput;

    actual_output_queue.push_back(adderif.Sum);
    actual_output = adderif.Sum;

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

  initial
    begin
      pkt = new ();
      init();

      for (int i = 0; i < num_rands; i++)
        begin
          generateStimulus();
          goldenModel();
          driveStimulus();
          collectOutput();
          checkOutput();
        end

      outputSummary();

      $stop;
    end

endmodule