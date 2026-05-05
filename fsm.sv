module fsm(
    input  [31:0] i_operands,
    input         i_empty,
    input         i_data_valid,
    input         clk,
    input         rst_n,
    output reg    o_read_enable,
    output reg [31:0] A_operand,
    output reg [31:0] B_operand
);

localparam [1:0] IDLE    = 2'b00,
                 READ_A  = 2'b01,
                 READ_B  = 2'b10;

reg [1:0] current_state, next_state;
reg [31:0] A_operand_reg; 

// -----------------------------------------------
// Block 1: state register
// -----------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) current_state <= IDLE;
    else       current_state <= next_state;
end

// -----------------------------------------------
// Block 2: output logic (sequential)
// -----------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        o_read_enable <= 0;
        A_operand     <= 0;
        B_operand     <= 0;
        A_operand_reg <= 0;
    end else begin
        o_read_enable <= 0;

        case (current_state)
            IDLE: begin
                if(!i_empty) o_read_enable <= 1;
                else         o_read_enable <= 0;
            end

            READ_A: begin
                if (i_data_valid) A_operand_reg <= i_operands;
                if(!i_empty) o_read_enable <= 1;
                else         o_read_enable <= 0;
            end

            READ_B: begin
                if (i_data_valid) begin
                    B_operand     <= i_operands;  
                    A_operand <=  A_operand_reg;
                end
                o_read_enable <= 0;
            end

            default: begin                      
                o_read_enable <= 0;
            end
        endcase
    end
end

// -----------------------------------------------
// Block 3: next state logic (combinational)
// -----------------------------------------------
always @(*) begin
    next_state = current_state;  

    case (current_state)
        IDLE: begin
            if(!i_empty) next_state = READ_A;  
            else         next_state = IDLE;
        end

        READ_A: begin
            if(i_data_valid) next_state = READ_B;   
            else             next_state = READ_A;
        end

        READ_B: begin
            if(i_data_valid) next_state = IDLE;
            else             next_state = READ_B;
        end


        default: begin                         
            next_state = IDLE;
        end
    endcase
end

endmodule