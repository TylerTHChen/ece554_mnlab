module shift_register #(
    parameter int WIDTH = 35,
    parameter int DEPTH = 1280
) (
    input  logic               clk,
    input  logic               rst_n,
    input  logic [WIDTH - 1:0] data_in,
    output logic [WIDTH - 1:0] data_out
);
    logic [WIDTH-1:0] MEM [0:DEPTH-1];

    integer i;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < DEPTH; i++) MEM[i] <= '0;
        end else begin
            MEM[0] <= data_in;
            for (i = 1; i < DEPTH; i++) MEM[i] <= MEM[i-1];
        end
    end

    assign data_out = MEM[DEPTH-1];

endmodule