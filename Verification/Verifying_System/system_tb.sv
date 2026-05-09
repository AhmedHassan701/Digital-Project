`include "system_pkt.sv"

// ============================================================
//  system_tb
//
//  Verification environment for the CDC FIFO-based adder.
//
//  Write domain  : 20 MHz  (W_CLK)
//  Read  domain  : 100 MHz (R_CLK)
//
//  Flow:
//    Write thread  : freely generates and drives pairs into the
//                    FIFO, pushing expected results into a queue
//                    with no blocking synchronisation.
//    Read  thread  : accumulates all actual results into a queue,
//                    then compares both queues at the end.
// ============================================================
module system_tb (
  system_if.TB          systemif,
  input logic [1:0]     current_state,
  input logic [1:0]     next_state,
  input logic           EMPTY
);

  // ----------------------------------------------------------
  // Parameters / encoding
  // ----------------------------------------------------------
  localparam DATA_WIDTH = 32;

  localparam [1:0] IDLE   = 2'b00;
  localparam [1:0] READ_A = 2'b01;
  localparam [1:0] READ_B = 2'b10;

  // Number of transactions per Cin phase
  const int NUM_TRANSACTIONS = 2;

  // ----------------------------------------------------------
  // Packet handle
  // ----------------------------------------------------------
  system_pkt pkt;

  // ----------------------------------------------------------
  // Result queues
  //   expected_queue : pushed by write thread after each pair
  //   actual_queue   : pushed by read  thread after each output
  // ----------------------------------------------------------
  logic [DATA_WIDTH:0] expected_queue[$];
  logic [DATA_WIDTH:0] actual_queue[$];

  // ----------------------------------------------------------
  // Summary counters
  // ----------------------------------------------------------
  int num_passes;
  int num_failures;

  // ==========================================================
  //  TASK : reset
  // ==========================================================
  task automatic reset();
    systemif.rst_n = 1'b1;
    @(posedge systemif.W_CLK);
    systemif.rst_n = 1'b0;
    @(posedge systemif.W_CLK);
    systemif.rst_n = 1'b1;
    @(posedge systemif.W_CLK);
  endtask

  // ==========================================================
  //  TASK : init
  // ==========================================================
  task automatic init();
    systemif.W_Enable = 1'b0;
    systemif.WR_DATA  = '0;
    systemif.Cin      = 1'b0;
    num_passes        = 0;
    num_failures      = 0;
    reset();
  endtask

  // ==========================================================
  //  TASK : generateStimulus
  // ==========================================================
  task automatic generateStimulus();
    assert (pkt.randomize()) else $fatal(0, "[TB] Randomisation failed");
    pkt.cg.sample();
  endtask

  // ==========================================================
  //  TASK : goldenModel
  //    Cin passed explicitly — decoupled from packet object
  //    which may be re-randomised on the next loop iteration.
  // ==========================================================
  task automatic goldenModel(
    input logic [DATA_WIDTH-1:0] operand_A,
    input logic [DATA_WIDTH-1:0] operand_B,
    input logic                  cin
  );
    logic [DATA_WIDTH:0] expected;
    expected = operand_A + operand_B + cin;
    expected_queue.push_back(expected);
  endtask

  // ==========================================================
  //  TASK : driveStimulus
  //    Writes exactly one A+B pair into the FIFO with no
  //    blocking on any read-side synchronisation.
  //    Cin is latched on the first successful write and held
  //    stable for both words of the pair.
  // ==========================================================
  task automatic driveStimulus();
    logic [DATA_WIDTH-1:0] operands[2];
    logic                  latched_Cin;
    int                    written_words;

    written_words = 0;

    forever begin
      generateStimulus();

      systemif.W_Enable = pkt.W_Enable;

      if (pkt.W_Enable && !systemif.FULL) begin
        if (written_words == 0)
          latched_Cin = pkt.Cin;

        systemif.WR_DATA        = pkt.WR_DATA;
        systemif.Cin            = latched_Cin;
        operands[written_words] = pkt.WR_DATA;
        written_words++;
      end

      @(posedge systemif.W_CLK);

      if (written_words == 2) begin
        goldenModel(operands[0], operands[1], latched_Cin);
        systemif.W_Enable = 1'b0;
        break;
      end
    end
  endtask

  // ==========================================================
  //  TASK : collectOutput
  //    Waits for the FSM READ_B -> IDLE transition on R_CLK,
  //    then pushes the result into the actual queue.
  // ==========================================================
  task automatic collectOutput();
    forever begin
      @(posedge systemif.R_CLK);
      if ((current_state == READ_B) && (next_state == IDLE)) begin
        @(posedge systemif.R_CLK);
        actual_queue.push_back(systemif.Sum);
        break;
      end
    end
  endtask

  // ==========================================================
  //  TASK : outputSummary
  //    Compares both queues entry by entry after all results
  //    have been collected.
  // ==========================================================
  task automatic outputSummary();
    logic [DATA_WIDTH:0] exp_val;
    logic [DATA_WIDTH:0] act_val;
    int                  pkt_id;

    pkt_id = 0;

    if (expected_queue.size() != actual_queue.size())
      $display("[TB] WARNING: queue size mismatch — expected %0d entries, actual %0d entries",
               expected_queue.size(), actual_queue.size());

    while (expected_queue.size() > 0 && actual_queue.size() > 0) begin
      pkt_id++;
      exp_val = expected_queue.pop_front();
      act_val = actual_queue.pop_front();

      if (act_val === exp_val) begin
        $display("[PASSED] Packet #%0d | A+B+Cin = %0d (0x%09h)",
                 pkt_id, act_val, act_val);
        num_passes++;
      end else begin
        $display("[FAILED] Packet #%0d | expected = %0d (0x%09h)  actual = %0d (0x%09h)",
                 pkt_id, exp_val, exp_val, act_val, act_val);
        num_failures++;
      end
    end

    $display("----------------------------------------------------");
    $display("  SIMULATION COMPLETE");
    $display("  Total transactions : %0d", num_passes + num_failures);
    $display("  PASSED             : %0d", num_passes);
    $display("  FAILED             : %0d", num_failures);
    $display("----------------------------------------------------");
  endtask

  // ==========================================================
  //  WRITE THREAD
  //    Runs freely — no blocking on read-side state.
  //    Phase 1: NUM_TRANSACTIONS pairs with Cin = 0
  //    Phase 2: NUM_TRANSACTIONS pairs with Cin = 1
  // ==========================================================
  initial begin
    pkt = new();
    init();

    // --- Phase 1: Cin forced to 0 ---
    pkt.Cin_C_0.constraint_mode(1);
    pkt.Cin_C_1.constraint_mode(0);

    for (int i = 0; i < NUM_TRANSACTIONS; i++)
      driveStimulus();

    repeat(5)
      begin
        @(posedge systemif.W_CLK);
      end

    // --- Phase 2: Cin forced to 1 ---
    pkt.Cin_C_0.constraint_mode(0);
    pkt.Cin_C_1.constraint_mode(1);

    for (int i = 0; i < NUM_TRANSACTIONS; i++)
      driveStimulus();

    $display("[TB] Write thread finished — %0d pairs written.", 2 * NUM_TRANSACTIONS);
  end

  // ==========================================================
  //  READ THREAD
  //    Accumulates all actual results into actual_queue, then
  //    calls outputSummary to compare against expected_queue.
  // ==========================================================
  initial begin
    for (int i = 0; i < (2 * NUM_TRANSACTIONS); i++)
      collectOutput();

    outputSummary();
    $stop;
  end

endmodule