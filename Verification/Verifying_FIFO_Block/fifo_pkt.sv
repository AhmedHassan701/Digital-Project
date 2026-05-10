class fifo_pkt;

  // Parameters
  localparam DATA_WIDTH = 32;

  // Class Attributes
  rand logic                  W_Enable;
  rand logic                  R_Enable;
  rand logic [DATA_WIDTH-1:0] WR_DATA;

  // Constraints
  constraint W_Enable_C {
    W_Enable dist {1'b0:/30, 1'b1:/70};
  }

  constraint R_Enable_C {
    R_Enable dist {1'b0:/30, 1'b1:/70};
  }

  constraint WR_DATA_C {
    WR_DATA dist {
      'h0                        :/ 20,
      'hFF_FF_FF_FF              :/ 20,
      ['d1 : 'hFF_FF_FF_FE]     :/ 60
    };
  }

  // Coverage
  covergroup cg;

    cp_WR_DATA: coverpoint WR_DATA {
      bins WR_DATA_ZERO        = {'d0};
      bins WR_DATA_ONES        = {'hFF_FF_FF_FF};
      bins WR_DATA_LOW         = {['d1           : 'h40_00_00_00]};
      bins WR_DATA_MED         = {['h40_00_00_01 : 'h80_00_00_00]};
      bins WR_DATA_HIGH        = {['h80_00_00_01 : 'hFF_FF_FF_FE]};
      bins WR_DATA_ZERO_T_HIGH = ('d0          => 'hFF_FF_FF_FF);
      bins WR_DATA_HIGH_T_ZERO = ('hFF_FF_FF_FF => 'd0);
    }

    cp_W_Enable: coverpoint W_Enable {
      bins W_Enable_ZERO       = {1'b0};
      bins W_Enable_ONE        = {1'b1};
      bins W_Enable_ZERO_T_ONE = (1'b0 => 1'b1);
      bins W_Enable_ONE_T_ZERO = (1'b1 => 1'b0);
    }

    cp_R_Enable: coverpoint R_Enable {
      bins R_Enable_ZERO       = {1'b0};
      bins R_Enable_ONE        = {1'b1};
      bins R_Enable_ZERO_T_ONE = (1'b0 => 1'b1);
      bins R_Enable_ONE_T_ZERO = (1'b1 => 1'b0);
    }

    // Cross coverage: simultaneous read and write
    cx_W_R_Enable: cross cp_W_Enable, cp_R_Enable;

  endgroup

  // Constructor
  function new();
    cg = new();
  endfunction

endclass
