`include "system_pkt.sv"

// ============================================================
//  system_tb
//
//  Verification environment for the CDC FIFO-based adder.
//
//  Write domain  : 20 MHz  (W_CLK)
//  Read  domain  : 100 MHz (R_CLK)
//
//  Flow per transaction (one A+B pair):
//    Write thread  : generate → drive → golden model
//    Read  thread  : collect  → check
//
//  Synchronisation between threads uses a semaphore so there
//  is exactly one in-flight transaction at any time, which
//  avoids the shared-scalar race conditions discussed during
//  code review.
// ============================================================
module system_tb (
  system_if.TB          systemif,
  input logic [1:0]     current_state,
  input logic [1:0]     next_state
);

  // ----------------------------------------------------------
  // Parameters / encoding
  // ----------------------------------------------------------
  localparam DATA_WIDTH = 32;

  localparam [1:0] IDLE   = 2'b00;
  localparam [1:0] READ_A = 2'b01;
  localparam [1:0] READ_B = 2'b10;

  // Number of transactions per Cin phase
  const int NUM_TRANSACTIONS = 1000;

  logic failed;

  // ----------------------------------------------------------
  // Packet handle and transaction counter
  // ----------------------------------------------------------
  system_pkt pkt;
  shortint   pkt_id;          // incremented once per completed A+B pair

  // ----------------------------------------------------------
  // Synchronisation primitive
  // ----------------------------------------------------------
  semaphore sem_slot;

  // ----------------------------------------------------------
  // Result queues  (write thread pushes, read thread pops)
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
  //    Active-low synchronous reset for two W_CLK cycles.
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
  //    Drive safe defaults then reset the DUT.
  // ==========================================================
  task automatic init();
    systemif.W_Enable = 1'b0;
    systemif.WR_DATA  = '0;
    systemif.Cin      = 1'b0;
    pkt_id            = 0;
    num_passes        = 0;
    num_failures      = 0;
    reset();
  endtask

  // ==========================================================
  //  TASK : generateStimulus
  //    Randomise the packet and sample functional coverage.
  // ==========================================================
  task automatic generateStimulus();
    assert (pkt.randomize()) else $fatal(0, "[TB] Randomisation failed");
    pkt.cg.sample();
  endtask

  // ==========================================================
  //  TASK : goldenModel
  //    Reference model: A + B + Cin (33-bit result).
  //    Cin is passed explicitly so it is decoupled from the
  //    packet object, which may be re-randomised before the
  //    read thread consumes this entry.
  // ==========================================================
  task automatic goldenModel(
    input logic [DATA_WIDTH-1:0] operand_A,
    input logic [DATA_WIDTH-1:0] operand_B,
    input logic                  cin
  );
    logic [DATA_WIDTH:0] expected;
    expected = operand_A + operand_B + cin;   // only in TB model — forbidden in RTL
    expected_queue.push_back(expected);
  endtask

  // ==========================================================
  //  TASK : driveStimulus
  //    Writes exactly one A+B pair into the FIFO.
  // ==========================================================
  task automatic driveStimulus();
    logic [DATA_WIDTH-1:0] operands[2];   // [0]=A, [1]=B
    logic                  latched_Cin;
    int                    written_words;

    // Block until the read thread has checked the previous pair
    sem_slot.get(1);
    @(posedge systemif.W_CLK);

    written_words = 0;

    forever begin
      // Generate new stimulus for this attempt
      generateStimulus();

      // Always drive W_Enable so DUT sees de-assertions
      systemif.W_Enable = pkt.W_Enable;

      if (pkt.W_Enable && !systemif.FULL) begin
        // Latch Cin from the first word; hold it for the pair
        if (written_words == 0)
          latched_Cin = pkt.Cin;

        systemif.WR_DATA  = pkt.WR_DATA;
        systemif.Cin      = latched_Cin;    // stable across both writes

        operands[written_words] = pkt.WR_DATA;
        written_words++;
      end

      // Commit to DUT on the rising W_CLK edge
      @(posedge systemif.W_CLK);

      if (written_words == 2) begin
        // Push expected result BEFORE the semaphore is returned
        goldenModel(operands[0], operands[1], latched_Cin);
        // De-assert W_Enable cleanly after the pair is complete
        systemif.W_Enable = 1'b0;
        break;
      end
    end
    // Note: semaphore put() is done by the read thread after
    // checkOutput(), keeping exactly one pair in-flight.
  endtask

  // ==========================================================
  //  TASK : collectOutput
  //    Waits in the R_CLK domain for the FSM to finish
  //    READ_B and transition back to IDLE, then latches Sum.
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
  //  TASK : checkOutput
  //    Pops one entry from each queue and compares.
  //    Releases the semaphore so the write thread can proceed
  //    with the next pair.
  // ==========================================================
  task automatic checkOutput();
    logic [DATA_WIDTH:0] exp_val;
    logic [DATA_WIDTH:0] act_val;

    pkt_id++;

    // Pop from queues — both were pushed in the same order
    exp_val = expected_queue.pop_front();
    act_val = actual_queue.pop_front();

    if (act_val === exp_val) begin
      $display("[PASSED] Packet #%0d | A+B+Cin = %0d (0x%09h)",
               pkt_id, act_val, act_val);
      failed = 1'b0;
      num_passes++;
    end else begin
      $display("[FAILED] Packet #%0d | expected = %0d (0x%09h)  actual = %0d (0x%09h)",
               pkt_id, exp_val, exp_val, act_val, act_val);
      failed = 1'b1;
      num_failures++;
    end

    // Return the slot so driveStimulus can start the next pair
    sem_slot.put(1);
  endtask

  // ==========================================================
  //  TASK : outputSummary
  // ==========================================================
  task automatic outputSummary();
    $display("----------------------------------------------------");
    $display("  SIMULATION COMPLETE");
    $display("  Total transactions : %0d", num_passes + num_failures);
    $display("  PASSED             : %0d", num_passes);
    $display("  FAILED             : %0d", num_failures);
    $display("----------------------------------------------------");
  endtask

  // ==========================================================
  //  WRITE THREAD
  //    Phase 1: 100 transactions with Cin = 0
  //    Phase 2: 100 transactions with Cin = 1
  // ==========================================================
  initial begin
    pkt      = new();
    sem_slot = new(1);    // one slot — first driveStimulus call passes immediately
    init();

    // --- Phase 1: Cin forced to 0 ---
    pkt.Cin_C_0.constraint_mode(1);
    pkt.Cin_C_1.constraint_mode(0);

    for (int i = 0; i < NUM_TRANSACTIONS; i++)
      driveStimulus();

    repeat (5)
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
  //    Mirrors the write thread's transaction count exactly.
  // ==========================================================
  initial begin
    for (int i = 0; i < (2 * NUM_TRANSACTIONS); i++) begin
      collectOutput();
      checkOutput();
    end

    outputSummary();
    $stop;
  end

endmodule
