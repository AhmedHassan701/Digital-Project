module adder_top (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire        Cin,
    output wire [32:0] Sum    // Sum[32] = carry out
);

    ppa_32bit u_adder (
        .A   (A),
        .B   (B),
        .Cin (Cin),
        .Sum (Sum)
    );

endmodule