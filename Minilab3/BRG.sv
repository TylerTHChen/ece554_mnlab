module BRG (
    input logic clk,
    input logic rst_n,
    input logic wr_dbl,
    input logic wr_dbh,
    input logic [7:0] data_in, 
    output logic en_16x
);

    logic [15:0] divisor_buf;
    localparam logic [15:0] DIV_RESET = 16'h0145;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            divisor_buf <= DIV_RESET;
        end else begin
            if (wr_dbl) divisor_buf[7:0]  <= data_in;
            if (wr_dbh) divisor_buf[15:8] <= data_in;
        end
    end

    logic [15:0] down_cnt;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            down_cnt <= DIV_RESET;
            en_16x   <= 1'b0;
        end else begin
            en_16x <= 1'b0;  // default low each cycle

            if (down_cnt == 16'd0) begin
                down_cnt <= divisor_buf; // reload from buffer
                en_16x   <= 1'b1;        // pulse on reload
            end else begin
                down_cnt <= down_cnt - 16'd1;
            end
        end
    end

endmodule