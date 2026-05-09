module adder_top (adder_if.DUT adderif);

    logic [31:0] A;
    logic [31:0] B;
    logic        Cin;
    logic [32:0] Sum;

    assign A            = adderif.A;
    assign B            = adderif.B;
    assign Cin          = adderif.Cin;
    assign adderif.Sum  = Sum;

    ppa_32bit u_adder (
        .A   (A),
        .B   (B),
        .Cin (Cin),
        .Sum (Sum)
    );

endmodule