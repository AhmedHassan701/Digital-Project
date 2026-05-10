`timescale 1ns/1ps
`include "fifo_pkt.sv"

// ============================================================
//  fifo_tb
//
//  Verification environment for the Asynchronous FIFO.
//
//  Write domain : 20  MHz (W_CLK)
//  Read  domain : 100 MHz (R_CLK)
//
//  Flow:
//    Write thread : drives WR_DATA into the FIFO, pushes
//                   written data into expected_queue, checks
//                   FULL flag, then triggers write_done.
//    Read  thread : waits for write_done + CDC settling, drains
//                   FIFO into actual_queue, checks EMPTY flag,
//                   then compares both queues via outputSummary.
// ============================================================
module fifo_tb (
  fifo_if.TB        fifoif,
  input logic       FULL_mon,
  input logic       EMPTY_mon
);

  // ----------------------------------------------------------
  // Parameters
  // ----------------------------------------------------------
  localparam DATA_WIDTH = 32;
  localparam DATA_DEPTH = 16;

  // Number of write transactions in Phase 1
  const int NUM_TRANSACTIONS = 8;

  // ----------------------------------------------------------
  // Packet handle
  // ----------------------------------------------------------
  fifo_pkt pkt;

  // ----------------------------------------------------------
  // Result queues
  // ----------------------------------------------------------
  logic [DATA_WIDTH-1:0] expected_queue[$];
  logic [DATA_WIDTH-1:0] actual_queue[$];

  // ----------------------------------------------------------
  // Summary counters
  // ----------------------------------------------------------
  int num_passes;
  int num_failures;
  int flag_passes;
  int flag_failures;

  // ----------------------------------------------------------
  // Shared event: write thread signals read thread when done
  // ----------------------------------------------------------
  event write_done;

  // ==========================================================
  //  TASK : reset
  // ==========================================================
  task automatic reset();
    fifoif.RST_n = 1'b1;
    @(posedge fifoif.W_CLK);
    fifoif.RST_n = 1'b0;
    repeat(2) @(posedge fifoif.W_CLK);
    fifoif.RST_n = 1'b1;
    @(posedge fifoif.W_CLK);
  endtask

  // ==========================================================
  //  TASK : init
  // ==========================================================
  task automatic init();
    fifoif.W_Enable = 1'b0;
    fifoif.R_Enable = 1'b0;
    fifoif.WR_DATA  = '0;
    num_passes      = 0;
    num_failures    = 0;
    flag_passes     = 0;
    flag_failures   = 0;
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
  // ==========================================================
  task automatic goldenModel(input logic [DATA_WIDTH-1:0] wr_data);
    expected_queue.push_back(wr_data);
  endtask

  // ==========================================================
  //  TASK : checkFlag
  //    Generic flag checker — used for both FULL and EMPTY.
  //    Prints PASSED / FAILED and updates flag counters.
  // ==========================================================
  task automatic checkFlag(
    input string flag_name,
    input logic  actual,
    input logic  expected
  );
    if (actual === expected) begin
      $display("[FLAG PASSED] %s = %0b (correct)", flag_name, actual);
      flag_passes++;
    end else begin
      $display("[FLAG FAILED] %s : expected %0b  actual %0b",
               flag_name, expected, actual);
      flag_failures++;
    end
  endtask

  // ==========================================================
  //  TASK : driveWrite
  //    Snapshots FULL before the rising edge — same view as DUT.
  //    Commits to goldenModel only when the write truly lands.
  // ==========================================================
  task automatic driveWrite();
    logic will_write;
    forever begin
      generateStimulus();

      fifoif.W_Enable = pkt.W_Enable;
      fifoif.WR_DATA  = pkt.WR_DATA;

      will_write = pkt.W_Enable && !fifoif.FULL;

      @(posedge fifoif.W_CLK);
      #1;

      if (will_write) begin
        goldenModel(pkt.WR_DATA);
        fifoif.W_Enable = 1'b0;
        break;
      end

      fifoif.W_Enable = 1'b0;
    end
  endtask

  // ==========================================================
  //  TASK : collectOutput
  //    RD_DATA is combinatorial on RD_addr.
  //    Capture RD_DATA first (already valid), then pulse
  //    R_Enable to advance the read pointer.
  // ==========================================================
  task automatic collectOutput();
    forever begin
      @(posedge fifoif.R_CLK);
      #1;

      if (!fifoif.EMPTY) begin
        actual_queue.push_back(fifoif.RD_DATA);
        fifoif.R_Enable = 1'b1;
        @(posedge fifoif.R_CLK);
        #1;
        fifoif.R_Enable = 1'b0;
        break;
      end else begin
        fifoif.R_Enable = 1'b0;
      end
    end
  endtask

  // ==========================================================
  //  TASK : outputSummary
  // ==========================================================
  task automatic outputSummary();
    logic [DATA_WIDTH-1:0] exp_val;
    logic [DATA_WIDTH-1:0] act_val;
    int                    pkt_id;

    pkt_id = 0;

    if (expected_queue.size() != actual_queue.size())
      $display("[TB] WARNING: queue size mismatch — expected %0d, actual %0d",
               expected_queue.size(), actual_queue.size());

    while (expected_queue.size() > 0 && actual_queue.size() > 0) begin
      pkt_id++;
      exp_val = expected_queue.pop_front();
      act_val = actual_queue.pop_front();

      if (act_val === exp_val) begin
        $display("[PASSED] Packet #%0d | RD_DATA = 0x%08h (%0d)",
                 pkt_id, act_val, act_val);
        num_passes++;
      end else begin
        $display("[FAILED] Packet #%0d | expected = 0x%08h (%0d)  actual = 0x%08h (%0d)",
                 pkt_id, exp_val, exp_val, act_val, act_val);
        num_failures++;
      end
    end

    $display("====================================================");
    $display("  DATA INTEGRITY SUMMARY");
    $display("  Total packets      : %0d", num_passes + num_failures);
    $display("  PASSED             : %0d", num_passes);
    $display("  FAILED             : %0d", num_failures);
    $display("====================================================");
    $display("  FLAG CHECK SUMMARY");
    $display("  Total flag checks  : %0d", flag_passes + flag_failures);
    $display("  PASSED             : %0d", flag_passes);
    $display("  FAILED             : %0d", flag_failures);
    $display("====================================================");
  endtask

  // ==========================================================
  //  WRITE THREAD
  //
  //  Phase 1 : NUM_TRANSACTIONS random writes
  //              → FULL must stay 0 (FIFO not yet full)
  //  Phase 2 : fill FIFO until FULL asserts
  //              → after last write FULL must be 1
  //  Phase 3 : attempt write while FULL
  //              → FULL must stay 1, no new data pushed
  // ==========================================================
  initial begin
    pkt = new();
    init();

    // ---------------------------------------------------------
    // Phase 1: random writes
    // ---------------------------------------------------------
    $display("[TB] Phase 1 — random write transactions");
    for (int i = 0; i < NUM_TRANSACTIONS; i++) begin
      driveWrite();
      // After each write FULL must be 0 (depth=16, wrote <= 8)
      checkFlag("FULL", fifoif.FULL, 1'b0);
    end

    repeat(5) @(posedge fifoif.W_CLK);

    // ---------------------------------------------------------
    // Phase 2: fill FIFO to FULL
    //   Drive W_Enable=1 every cycle; goldenModel on pre-edge
    //   snapshot to match exactly what DUT registers.
    // ---------------------------------------------------------
    $display("[TB] Phase 2 — filling FIFO to FULL");
    begin : fill_loop
      logic pre_full;
      while (!fifoif.FULL) begin
        assert (pkt.randomize()) else $fatal(0, "[TB] Randomisation failed");
        fifoif.W_Enable = 1'b1;
        fifoif.WR_DATA  = pkt.WR_DATA;
        pre_full = fifoif.FULL;           // snapshot before edge
        @(posedge fifoif.W_CLK);
        #1;
        if (!pre_full)                    // write landed only if not full pre-edge
          goldenModel(pkt.WR_DATA);
      end
      fifoif.W_Enable = 1'b0;
    end

    // FULL must now be asserted
    checkFlag("FULL after fill", fifoif.FULL, 1'b1);

    // ---------------------------------------------------------
    // Phase 3: write attempt while FULL — DUT must block it
    // ---------------------------------------------------------
    $display("[TB] Phase 3 — write attempt while FULL (expect no push)");
    fifoif.W_Enable = 1'b1;
    fifoif.WR_DATA  = 32'hDEAD_BEEF;
    @(posedge fifoif.W_CLK);
    #1;
    fifoif.W_Enable = 1'b0;

    // FULL must still be asserted (no read happened)
    checkFlag("FULL still after blocked write", fifoif.FULL, 1'b1);

    $display("[TB] Write thread finished — %0d entries in expected queue.",
             expected_queue.size());

    -> write_done;
  end

  // ==========================================================
  //  READ THREAD
  //
  //  Waits for write_done + CDC settling, then drains FIFO.
  //
  //  Flag checks:
  //    - EMPTY must be 0 before first read (FIFO is full)
  //    - EMPTY must be 1 after last read   (FIFO drained)
  // ==========================================================
  initial begin
    @(write_done);

    // CDC settling: WR_ptr crosses 2-stage R_CLK synchroniser
    repeat(20) @(posedge fifoif.R_CLK);

    // EMPTY must be 0 — FIFO was just filled
    checkFlag("EMPTY before drain", fifoif.EMPTY, 1'b0);

    // Drain all written entries
    begin : drain_loop
      int total;
      total = expected_queue.size();
      for (int i = 0; i < total; i++)
        collectOutput();
    end

    // Allow RD_ptr CDC to propagate back to write domain
    // and EMPTY to assert (2 R_CLK synchroniser stages)
    repeat(20) @(posedge fifoif.R_CLK);

    // EMPTY must be 1 — all entries have been read
    checkFlag("EMPTY after drain", fifoif.EMPTY, 1'b1);

    outputSummary();
    $stop;
  end

endmodule