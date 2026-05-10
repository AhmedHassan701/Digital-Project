module DF_SYNC #(
    parameter NUM_STAGES = 2 ,
	parameter DATA_WIDTH = 5 
)(
    input   wire                 CLK,
    input   wire                 RST_n,
    input   wire [DATA_WIDTH-1:0] ASYNC_DATA,
    output  reg  [DATA_WIDTH-1:0] SYNC_DATA             );

    reg   [NUM_STAGES-1:0] sync_reg [DATA_WIDTH-1:0] ;

    integer i;

    always @(posedge CLK or negedge RST_n) 
        begin
            if (!RST_n) 
                begin
                    for (i = 0; i < DATA_WIDTH; i = i + 1) 
                        begin
                            sync_reg[i] <= 0;
                        end
                end
            else 
                begin
                    for (i = 0; i < DATA_WIDTH; i = i + 1) 
                        begin
                            sync_reg[i] <= {sync_reg[i][NUM_STAGES-2:0], ASYNC_DATA[i]};
                        end
                end
        end

    always @(*) 
        begin
            for (i = 0; i < DATA_WIDTH; i = i + 1) 
                begin
                    SYNC_DATA[i] = sync_reg[i][NUM_STAGES-1];
                end
        end

endmodule