module filter_grid
#(
    parameter v_constant = 0, 
    parameter h_constant = 0,
    parameter x_dc = -1,
    parameter y_dc = -1
)(
    input clk,
    input rst_n,
    input [13:0]data_in,
    input vertial,
    output [13:0]data_in_d,
    output [12:0]signed data_out
);
logic x, y;
logic [1:0]filter_val;

assign x = data_in[12];
assign y = data_in[13];

assign filter_val = (x == x_dc) ? '0 : 
                    (vertical)  ? v_constant : h_constant;

always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        data_in_d <= '0;
    end else begin
        data_in_d <= data_in;
    end
end

always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        data_out <= '0;
    end else if(vertical) begin
        data_out <= data_in * filter_val;
    end
end

endmodule