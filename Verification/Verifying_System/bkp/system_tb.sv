`include "system_pkt.sv"

module system_tb (system_if.TB systemif, input logic [1:0]current_state, input logic [1:0]next_state);

  // Packet Handle
  system_pkt pkt;
  shortint pkt_id;

  // Finished Collecting Flag
  bit collect_done;

  // Parameters
  localparam DATA_WIDTH = 32;

  // State Encoding
  localparam [1:0] IDLE   = 2'b00;
  localparam [1:0] READ_A = 2'b01;
  localparam [1:0] READ_B = 2'b10;

  // Constant
  const int num_rands = 100;

  // Queues
  logic [DATA_WIDTH:0]expected_output_queue[$];
  logic [DATA_WIDTH:0]expected_output;
  logic [DATA_WIDTH:0]actual_output;
  logic [DATA_WIDTH:0]actual_output_queue[$];

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
    collect_done      = 1'b1;
    pkt_id            = 'd0;

    reset ();

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
        generateStimulus();
        systemif.W_Enable = pkt.W_Enable;
        if (pkt.W_Enable && (!systemif.FULL))
          begin
            systemif.WR_DATA        = pkt.WR_DATA;
            systemif.Cin            = pkt.Cin;
            operands[written_words] = pkt.WR_DATA;
            written_words++;
          end

        @(posedge systemif.W_CLK);

        if (written_words == 'd2)
          begin
            goldenModel(operands[0], operands[1]);
            collect_done = 1'b0;
            break;
          end
      end

  endtask

  task collectOutput;

    forever
      begin
        @(posedge systemif.R_CLK);
        if ((current_state == READ_B) && (next_state == IDLE))
          begin
            @(posedge systemif.R_CLK);
            actual_output = systemif.Sum;
            actual_output_queue.push_back(actual_output);
            break;
          end
      end

  endtask

  task checkOutput;

    pkt_id++;
    if (actual_output == expected_output)
      begin
        $display("[PASSED] The Packet #%0d has passed!", pkt_id);
      end
    else
      begin
        $display("[FAILED] The Packet #%0d has failed!, expected = %0d, actual = %0d", pkt_id, expected_output, actual_output);
      end

    collect_done = 1'b1;

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

  // Write System
  initial
    begin
      pkt = new();
      init();

      pkt.Cin_C_0.constraint_mode(1);
      pkt.Cin_C_1.constraint_mode(0);

      for (int i = 0; i < num_rands; i++)
        begin
          wait(collect_done);
          driveStimulus();
        end

      pkt.Cin_C_0.constraint_mode(0);
      pkt.Cin_C_1.constraint_mode(1);

      for (int i = 0; i < num_rands; i++)
        begin
          wait(collect_done);
          driveStimulus();
        end

      $display ("%0d", expected_output_queue.size());
    end

  // Read System
  initial
    begin
      for (int i = 0; i < (2 * num_rands); i++)
        begin
          wait(!collect_done);
          collectOutput();
          checkOutput();
        end

      outputSummary();

      $stop;
    end  

endmodule