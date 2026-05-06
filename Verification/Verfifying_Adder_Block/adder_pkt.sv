class adder_pkt;
  
  // Class Atributes
  rand logic [31:0]A;
  rand logic [31:0]B;
  rand logic Cin;

  shortint pkt_id;

  // CRT
  constraint A_C {
    A dist {'d0:/30, 'hFF_FF_FF_FF:/30, ['d1: 'hFF_FF_FF_FE]:/40};
    //A inside {['d1:'d10]};
  }

  constraint B_C {
    B dist {'d0:/30, 'hFF_FF_FF_FF:/30, ['d1: 'hFF_FF_FF_FE]:/40};
    //B inside {['d1:'d10]};
  }

  constraint Cin_C {
    Cin == 1'b0;
  }

  // Cover Group
  covergroup cg;

    cp_A: coverpoint A {
      bins A_ZERO         = {'d0};
      bins A_ONES         = {'hFF_FF_FF_FF};
      bins A_LOW          = {['d1:'h40_00_00_00]};
      bins A_MED          = {['h40_00_00_01:'h80_00_00_00]};
      bins A_HIGH         = {['h80_00_00_01:'hFF_FF_FF_FE]};
      bins A_ZERO_T_HIGH  = ('d0 => 'hFF_FF_FF_FF);
      bins A_HIGH_T_ZERO  = ('hFF_FF_FF_FF => 'd0);
    }

    cp_B: coverpoint B {
      bins B_ZERO         = {'d0};
      bins B_ONES         = {'hFF_FF_FF_FF};
      bins B_LOW          = {['d1:'h40_00_00_00]};
      bins B_MED          = {['h40_00_00_01:'h80_00_00_00]};
      bins B_HIGH         = {['h80_00_00_01:'hFF_FF_FF_FE]};
      bins B_ZERO_T_HIGH  = ('d0 => 'hFF_FF_FF_FF);
      bins B_HIGH_T_ZERO  = ('hFF_FF_FF_FF => 'd0);
    }

    cp_Cin: coverpoint Cin {
      bins Cin_ZERO       = {1'b0};
      bins Cin_ONE        = {1'b1};
      bins Cin_ZERO_T_ONE = (1'b0 => 1'b1);
      bins Cin_ONE_T_ZERO = (1'b1 => 1'b0);
    }

  endgroup

  // Class Methods
  function new ();
    cg  = new ();
  endfunction

  function void post_randomize ();
    ++pkt_id;
  endfunction

endclass