module filter_grid
#(
    parameter v_constant = 0, 
    parameter h_constant = 0
)(
    input logic clk,
    input logic rst_n,
    input logic [33:0]data_in,
    input logic vertical,
    input logic [10:0] x_dc,
    input logic [10:0] y_dc,
    output logic [13:0]data_in_d,
    output logic signed [11:0] data_out
);
logic [10:0]x, y;
logic [1:0]filter_val;

assign x = data_in[22:12];
assign y = data_in[33:23];

assign filter_val = (x == x_dc || y == y_dc) ? '0 : 
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
        data_out <= data_in / 4 * filter_val;
    end
end

endmodule