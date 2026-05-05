`timescale 1ns/1ps
module CDC_processing_unit_top_TB ();

    // ----------------------------------------------------------------
    // Parameters
    // ----------------------------------------------------------------
    parameter DATA_WIDTH = 32;
    parameter DATA_DEPTH = 16;
    parameter ADDR_WIDTH = 4;

    // ----------------------------------------------------------------
    // DUT Inputs
    // ----------------------------------------------------------------
    reg                   W_CLK_tb;
    reg                   W_Enable_tb;
    reg                   R_CLK_tb;
    reg                   rst_n_tb;
    reg  [DATA_WIDTH-1:0] WR_DATA_tb;
    reg                   Cin_tb;

    // ----------------------------------------------------------------
    // DUT Outputs
    // ----------------------------------------------------------------
    wire                  FULL_tb;
    wire [32:0]           Sum_tb;

    // ----------------------------------------------------------------
    // Loop Variables & Storage
    // ----------------------------------------------------------------
    integer i;
    integer j;

    // Each FIFO entry carries one 32-bit operand; pairs are consecutive entries
    reg [DATA_WIDTH-1:0] Data [DATA_DEPTH-1:0];

    localparam integer NUM_OPS = 4;

    // ----------------------------------------------------------------
    // DUT Instantiation
    // ----------------------------------------------------------------
    CDC_processing_unit_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(DATA_DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) DUT (
        .W_CLK   (W_CLK_tb),
        .W_Enable(W_Enable_tb),
        .R_CLK   (R_CLK_tb),
        .rst_n   (rst_n_tb),
        .WR_DATA (WR_DATA_tb),
        .Cin     (Cin_tb),
        .FULL    (FULL_tb),
        .Sum     (Sum_tb)
    );

    // ----------------------------------------------------------------
    // Clock Generation
    //   W_CLK  – slow writer clock  (period = 50 ns  → 20 MHz)
    //   R_CLK  – fast reader clock  (period = 10 ns  → 100 MHz)
    // ----------------------------------------------------------------
    always #(25) W_CLK_tb = ~W_CLK_tb;   // Write CLK
    always #(5)  R_CLK_tb = ~R_CLK_tb;   // Read  CLK

    // ----------------------------------------------------------------
    // Write Initial Block
    // ----------------------------------------------------------------
    initial begin
        // Load test vectors (pairs of operands packed as 32-bit words)
        $readmemh("Data.txt", Data);

        // Initialise & reset on the write domain
        WR_Initialization();
        WR_Reset();

        // Push every entry into the FIFO (skip if FULL)
        for (i = 0; i < (2*NUM_OPS); i = i + 1) begin
            if (!FULL_tb)
                WR_Data(Data[i]);
        end

        // De-assert write enable and let a few W_CLK cycles pass
        W_Enable_tb = 0;
        repeat (20) @(negedge W_CLK_tb);

        $stop();
    end

    // ----------------------------------------------------------------
    // Read / Checker Initial Block
    // ----------------------------------------------------------------
    initial begin
        // Initialise the read-domain signals
        RD_Initialization();

        // Wait for reset de-assertion (driven by write initial block)
        @(posedge rst_n_tb);

        repeat (20) @(negedge R_CLK_tb); // Ensure we're past the reset phase
        // The FSM controls R_Enable internally; we just wait for the
        // adder to produce valid results and check them.
        for (j = 0; j < NUM_OPS; j = j + 1) begin
            // Wait until the FIFO has data and the adder output settles
            @(negedge R_CLK_tb);
            Check_Sum(Data[2*j], Data[2*j+1]);
        end
    end

    // ================================================================
    // Tasks
    // ================================================================

    // --- Write-side initialisation -----------------------------------
    task WR_Initialization;
        begin
            W_CLK_tb    = 0;
            W_Enable_tb = 0;
            WR_DATA_tb  = {DATA_WIDTH{1'b0}};
            Cin_tb      = 1'b0;
        end
    endtask

    // --- Read-side initialisation ------------------------------------
    task RD_Initialization;
        begin
            R_CLK_tb = 0;
        end
    endtask

    // --- Synchronous active-low reset (shared rst_n) -----------------
    task WR_Reset;
        begin
            rst_n_tb = 1'b0;            // Assert reset
            @(negedge W_CLK_tb);        // Hold for one W_CLK cycle
            @(negedge R_CLK_tb);        // Also cover at least one R_CLK
            rst_n_tb = 1'b1;            // De-assert reset
        end
    endtask

    // --- Write one data word into the FIFO ---------------------------
    task WR_Data(
        input reg [DATA_WIDTH-1:0] WR_DATA
    );
        begin
            W_Enable_tb = 1'b1;
            WR_DATA_tb  = WR_DATA;
            @(negedge W_CLK_tb);        // Latch on falling W_CLK edge
        end
    endtask

    // --- Check adder output against expected value -------------------
    task Check_Sum(
        input reg [DATA_WIDTH-1:0] A_in,
        input reg [DATA_WIDTH-1:0] B_in
    );
        reg [31:0] A_exp;
        reg [31:0] B_exp;
        reg [32:0] Sum_exp;
        begin
            A_exp   = A_in;
            B_exp   = B_in;
            Sum_exp = A_exp + B_exp + Cin_tb;

            @(negedge R_CLK_tb);   // Wait for the output to settle

            if (Sum_tb === Sum_exp) begin
                $display("[PASS] Time=%0t | A=0x%08h  B=0x%08h  Cin=%b | Sum=0x%09h",
                          $time, A_exp, B_exp, Cin_tb, Sum_tb);
            end else begin
                $display("[FAIL] Time=%0t | A=0x%08h  B=0x%08h  Cin=%b | Expected=0x%09h  Got=0x%09h",
                          $time, A_exp, B_exp, Cin_tb, Sum_exp, Sum_tb);
            end
        end
    endtask

endmodule