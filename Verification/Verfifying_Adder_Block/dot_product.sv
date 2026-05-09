module dot_operator (
    input  wire G_hi,
    input  wire P_hi,
    input  wire G_lo,
    input  wire P_lo,

    output wire G_out,
    output wire P_out
);

    assign G_out = G_hi | (P_hi & G_lo);
    assign P_out = P_hi & P_lo;

endmodule