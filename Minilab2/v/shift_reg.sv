module shift_register #(
    parameter int WIDTH = 1,
    parameter int DEPTH = 1
)(
    input  logic               clk,
    input  logic               rst_n,
    input  logic [WIDTH-1:0]   data_in,
    input  logic               read,
    output logic [WIDTH-1:0]   data_out
);

    // Storage array for shift stages
    logic [WIDTH-1:0] shift_mem [0:DEPTH-1];

    // First stage
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            shift_mem[0] <= '0;
        else if (read)
            shift_mem[0] <= data_in;
    end

    // Remaining stages
    genvar i;
    generate
        for (i = 1; i < DEPTH; i++) begin : shift_stages
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n)
                    shift_mem[i] <= '0;
                else if (read)
                    shift_mem[i] <= shift_mem[i-1];
            end
        end
    endgenerate

    assign data_out = shift_mem[DEPTH-1];

endmodule
