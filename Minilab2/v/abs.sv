module abs( 
    input clk, 
    input rst_n, 
    input [11:0] ab_in,
    output [11:0] ab_out
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ab_out <= 12'd0;
        end else begin
            if (ab_in[11]) begin
                ab_out <= -ab_in;
            end else begin
                ab_out <= ab_in;
            end
        end
    end

endmodule 