// TB TOP
module adder_tb_top ();

  adder_if  adderif ();
  adder_top dut (adderif.DUT);
  adder_tb  adder_tb (adderif.TB);

endmodule