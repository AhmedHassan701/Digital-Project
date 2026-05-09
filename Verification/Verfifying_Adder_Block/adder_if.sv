interface adder_if;

  logic [31:0]A;
  logic [31:0]B;
  logic Cin;
  logic [32:0]Sum;

  modport TB (
    input   Sum,
    output  A,
    output  B,
    output  Cin
  );

  modport DUT (
    input   A,
    input   B,
    input   Cin,
    output  Sum
  );

endinterface