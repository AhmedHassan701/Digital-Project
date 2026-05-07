module fsm(
    input  [31:0] i_operands,
    input         i_empty,
    input         clk,
    input         rst_n,
    output reg    o_read_enable,        // combinational -- driven by always @(*)
    output reg [31:0] A_operand,
    output reg [31:0] B_operand
);

localparam [1:0] IDLE   = 2'b00,
                 READ_A = 2'b01,
                 READ_B = 2'b10;

reg [1:0]  current_state, next_state;
reg [31:0] A_operand_reg;

// -----------------------------------------------
// Block 1: state register
// -----------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) current_state <= IDLE;
    else        current_state <= next_state;
end

// -----------------------------------------------
// Block 2: output logic (sequential)
// Latches operands based on next_state to
// compensate for the 1-cycle FIFO read latency
// -----------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        A_operand     <= 0;
        B_operand     <= 0;
        A_operand_reg <= 0;
    end else begin
        case (current_state)           
            READ_A: begin
                A_operand_reg <= i_operands;   // capture A one cycle after read
            end
            READ_B: begin
                if (!i_empty) begin
                    A_operand <= A_operand_reg;  // output A from previous cycle
                    B_operand <= i_operands;    // output B from current cycle
                end
            end
            default: ;
        endcase
    end
end

// -----------------------------------------------
// Block 3: o_read_enable (combinational)
// -----------------------------------------------
always @(*) begin
    case (current_state)
        IDLE:    o_read_enable = 1'b0;
        READ_A:  o_read_enable = !i_empty;
        READ_B:  o_read_enable = !i_empty;
        default: o_read_enable = 1'b0;
    endcase
end

// -----------------------------------------------
// Block 4: next state logic (combinational)
// -----------------------------------------------
always @(*) begin
    case (current_state)
        IDLE:    next_state = !i_empty ? READ_A : IDLE;
        READ_A:  next_state = !i_empty ? READ_B : READ_A;
        READ_B:  next_state = !i_empty ? IDLE : READ_B;
        default: next_state = IDLE;
    endcase
end

endmodule