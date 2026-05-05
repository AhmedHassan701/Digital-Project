module ppa_32bit (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire        Cin,
    output wire [32:0] Sum    // Sum[32] = carry out
);

    // ------------------------------------------------
    // Stage 1 — Pre-processing
    // G[i] = A[i] & B[i]
    // P[i] = A[i] ^ B[i]
    // ------------------------------------------------
    wire [31:0] G0, P0;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : pre
            assign G0[i] = A[i] & B[i];
            assign P0[i] = A[i] ^ B[i];
        end
    endgenerate

    // ------------------------------------------------
    // Stage 2 — Kogge-Stone prefix tree
    // 5 levels, each level doubles the stride
    //
    // Cin is seeded into bit 0 of Level 1:
    //   G1[0] = G0[0] | (P0[0] & Cin)
    //   P1[0] = P0[0]
    // This way G5[j] = carry OUT of bit j given Cin
    // ------------------------------------------------
    wire [31:0] G1, P1;
    wire [31:0] G2, P2;
    wire [31:0] G3, P3;
    wire [31:0] G4, P4;
    wire [31:0] G5, P5;

    // ------------------------------------------------
    // Level 1 — stride = 1
    // bit 0: seed Cin here
    // bits 1-31: dot operator with bit j-1
    // ------------------------------------------------

    // Cin seeded into bit 0
    assign G1[0] = G0[0] | (P0[0] & Cin);
    assign P1[0] = P0[0];

    genvar j;
    generate
        for (j = 1; j < 32; j = j + 1) begin : level1
            dot_operator u_l1 (
                .G_hi  (G0[j]),
                .P_hi  (P0[j]),
                .G_lo  (G0[j-1]),
                .P_lo  (P0[j-1]),
                .G_out (G1[j]),
                .P_out (P1[j])
            );
        end
    endgenerate

    // ------------------------------------------------
    // Level 2 — stride = 2
    // bits 0-1: pass-through
    // bits 2-31: dot operator with bit j-2
    // ------------------------------------------------
    assign G2[0] = G1[0];  assign P2[0] = P1[0];
    assign G2[1] = G1[1];  assign P2[1] = P1[1];

    generate
        for (j = 2; j < 32; j = j + 1) begin : level2
            dot_operator u_l2 (
                .G_hi  (G1[j]),
                .P_hi  (P1[j]),
                .G_lo  (G1[j-2]),
                .P_lo  (P1[j-2]),
                .G_out (G2[j]),
                .P_out (P2[j])
            );
        end
    endgenerate

    // ------------------------------------------------
    // Level 3 — stride = 4
    // bits 0-3: pass-through
    // bits 4-31: dot operator with bit j-4
    // ------------------------------------------------
    assign G3[0] = G2[0];  assign P3[0] = P2[0];
    assign G3[1] = G2[1];  assign P3[1] = P2[1];
    assign G3[2] = G2[2];  assign P3[2] = P2[2];
    assign G3[3] = G2[3];  assign P3[3] = P2[3];

    generate
        for (j = 4; j < 32; j = j + 1) begin : level3
            dot_operator u_l3 (
                .G_hi  (G2[j]),
                .P_hi  (P2[j]),
                .G_lo  (G2[j-4]),
                .P_lo  (P2[j-4]),
                .G_out (G3[j]),
                .P_out (P3[j])
            );
        end
    endgenerate

    // ------------------------------------------------
    // Level 4 — stride = 8
    // bits 0-7: pass-through
    // bits 8-31: dot operator with bit j-8
    // ------------------------------------------------
    assign G4[0] = G3[0];  assign P4[0] = P3[0];
    assign G4[1] = G3[1];  assign P4[1] = P3[1];
    assign G4[2] = G3[2];  assign P4[2] = P3[2];
    assign G4[3] = G3[3];  assign P4[3] = P3[3];
    assign G4[4] = G3[4];  assign P4[4] = P3[4];
    assign G4[5] = G3[5];  assign P4[5] = P3[5];
    assign G4[6] = G3[6];  assign P4[6] = P3[6];
    assign G4[7] = G3[7];  assign P4[7] = P3[7];

    generate
        for (j = 8; j < 32; j = j + 1) begin : level4
            dot_operator u_l4 (
                .G_hi  (G3[j]),
                .P_hi  (P3[j]),
                .G_lo  (G3[j-8]),
                .P_lo  (P3[j-8]),
                .G_out (G4[j]),
                .P_out (P4[j])
            );
        end
    endgenerate

    // ------------------------------------------------
    // Level 5 — stride = 16
    // bits 0-15: pass-through
    // bits 16-31: dot operator with bit j-16
    // ------------------------------------------------
    assign G5[0]  = G4[0];   assign P5[0]  = P4[0];
    assign G5[1]  = G4[1];   assign P5[1]  = P4[1];
    assign G5[2]  = G4[2];   assign P5[2]  = P4[2];
    assign G5[3]  = G4[3];   assign P5[3]  = P4[3];
    assign G5[4]  = G4[4];   assign P5[4]  = P4[4];
    assign G5[5]  = G4[5];   assign P5[5]  = P4[5];
    assign G5[6]  = G4[6];   assign P5[6]  = P4[6];
    assign G5[7]  = G4[7];   assign P5[7]  = P4[7];
    assign G5[8]  = G4[8];   assign P5[8]  = P4[8];
    assign G5[9]  = G4[9];   assign P5[9]  = P4[9];
    assign G5[10] = G4[10];  assign P5[10] = P4[10];
    assign G5[11] = G4[11];  assign P5[11] = P4[11];
    assign G5[12] = G4[12];  assign P5[12] = P4[12];
    assign G5[13] = G4[13];  assign P5[13] = P4[13];
    assign G5[14] = G4[14];  assign P5[14] = P4[14];
    assign G5[15] = G4[15];  assign P5[15] = P4[15];

    generate
        for (j = 16; j < 32; j = j + 1) begin : level5
            dot_operator u_l5 (
                .G_hi  (G4[j]),
                .P_hi  (P4[j]),
                .G_lo  (G4[j-16]),
                .P_lo  (P4[j-16]),
                .G_out (G5[j]),
                .P_out (P5[j])
            );
        end
    endgenerate

    // ------------------------------------------------
    // Stage 3 — Post-processing
    //
    // Sum[0]  = P0[0] ^ Cin          carry into bit 0 is Cin
    // Sum[j]  = P0[j] ^ G5[j-1]     carry into bit j = G5[j-1] (includes Cin)
    // Sum[32] = G5[31] | (P5[31] & Cin)   carry out of MSB
    // ------------------------------------------------
    assign Sum[0] = P0[0] ^ Cin;

    generate
        for (j = 1; j < 32; j = j + 1) begin : post
            assign Sum[j] = P0[j] ^ G5[j-1];
        end
    endgenerate

    assign Sum[32] = G5[31] | (P5[31] & Cin);

endmodule