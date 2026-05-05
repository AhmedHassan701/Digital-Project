module adder_top_tb;

    // -----------------------------------------------
    // Inputs
    // -----------------------------------------------
    reg  [31:0] A;
    reg  [31:0] B;
    reg         Cin;

    // -----------------------------------------------
    // Outputs
    // -----------------------------------------------
    wire [32:0] Sum;    // Sum[32] = carry out

    // -----------------------------------------------
    // Instantiate the adder top
    // -----------------------------------------------
    adder_top u_adder_top (
        .A   (A),
        .B   (B),
        .Cin (Cin),
        .Sum (Sum)
    );

    // -----------------------------------------------
    // Task to apply inputs and check result
    // expected_sum  = lower 32 bits
    // expected_cout = carry out = Sum[32]
    // -----------------------------------------------
    task apply_and_check;
        input [31:0] in_A;
        input [31:0] in_B;
        input        in_Cin;
        input [31:0] expected_sum;
        input        expected_cout;
        begin
            A   = in_A;
            B   = in_B;
            Cin = in_Cin;
            #10;
            if (Sum[31:0] === expected_sum && Sum[32] === expected_cout)
                $display("PASS | A=%0b  B=%0b  Cin=%0b  Sum=%0b  Cout=%0b",
                          in_A, in_B, in_Cin, Sum[31:0], Sum[32]);
            else
                $display("FAIL | A=%0b  B=%0b  Cin=%0b  Expected Sum=%0b Cout=%0b  Got Sum=%0b Cout=%0b",
                          in_A, in_B, in_Cin, expected_sum, expected_cout, Sum[31:0], Sum[32]);
        end
    endtask

    // -----------------------------------------------
    // Test cases
    // -----------------------------------------------
    initial begin
        $display("========================================");
        $display("      Kogge-Stone Adder Testbench       ");
        $display("========================================");

        // --- Basic tests (Cin = 0) ---
        apply_and_check(32'd0,   32'd0,   1'b0, 32'd0,   1'b0); // 0 + 0 + 0 = 0
        apply_and_check(32'd1,   32'd1,   1'b0, 32'd2,   1'b0); // 1 + 1 = 2
        apply_and_check(32'd1,   32'd0,   1'b0, 32'd1,   1'b0); // 1 + 0 = 1
        apply_and_check(32'd100, 32'd100, 1'b0, 32'd200, 1'b0); // 100 + 100 = 200

        // --- Cin = 1 tests ---
        apply_and_check(32'd0,   32'd0,   1'b1, 32'd1,   1'b0); // 0 + 0 + 1 = 1
        apply_and_check(32'd1,   32'd1,   1'b1, 32'd3,   1'b0); // 1 + 1 + 1 = 3
        apply_and_check(32'd100, 32'd100, 1'b1, 32'd201, 1'b0); // 100 + 100 + 1 = 201

        // --- Carry propagation tests ---
        apply_and_check(32'h0000_00FF, 32'h0000_0001, 1'b0, 32'h0000_0100, 1'b0); // carry through 8 bits
        apply_and_check(32'h0000_FFFF, 32'h0000_0001, 1'b0, 32'h0001_0000, 1'b0); // carry through 16 bits
        apply_and_check(32'h7FFF_FFFF, 32'h0000_0001, 1'b0, 32'h8000_0000, 1'b0); // carry through 31 bits

        // --- Cout tests (Sum[32] should be 1) ---
        apply_and_check(32'hFFFF_FFFF, 32'h0000_0001, 1'b0, 32'h0000_0000, 1'b1); // max + 1
        apply_and_check(32'hFFFF_FFFF, 32'hFFFF_FFFF, 1'b0, 32'hFFFF_FFFE, 1'b1); // max + max
        apply_and_check(32'h8000_0000, 32'h8000_0000, 1'b0, 32'h0000_0000, 1'b1); // overflow
        apply_and_check(32'hFFFF_FFFF, 32'h0000_0000, 1'b1, 32'h0000_0000, 1'b1); // max + 0 + Cin=1

        // --- Large values ---
        apply_and_check(32'h1234_5678, 32'h8765_4321, 1'b0, 32'h9999_9999, 1'b0);
        apply_and_check(32'hAAAA_AAAA, 32'h5555_5555, 1'b0, 32'hFFFF_FFFF, 1'b0); // alternating bits
        apply_and_check(32'hFFFF_FFFF, 32'h0000_0000, 1'b0, 32'hFFFF_FFFF, 1'b0);
        apply_and_check(32'h0000_0000, 32'hFFFF_FFFF, 1'b0, 32'hFFFF_FFFF, 1'b0);

        $display("========================================");
        $display("         Testbench Complete             ");
        $display("========================================");
        $finish;
    end

endmodule