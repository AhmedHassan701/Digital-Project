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

    // Each FIFO entry carries two 16-bit operands packed into 32 bits:
    //   WR_DATA[31:16] = A_operand
    //   WR_DATA[15: 0] = B_operand
    reg [DATA_WIDTH-1:0] Data [DATA_DEPTH-1:0];

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
        RD_Initialization();
        WR_Reset();

        // Push every entry into the FIFO (skip if FULL)
        for (i = 0; i < 16; i = i + 1) begin
            if (!FULL_tb)
                WR_Data(Data[i]);
        end

        // De-assert write enable and let a few W_CLK cycles pass
        W_Enable_tb = 0;
        repeat (10) @(negedge W_CLK_tb);

        $stop();
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


endmodule