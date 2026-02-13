module filter_grid(
    input logic clk,
    input logic rst_n,
    input logic [33:0]data_in,
    input logic vertical,
    input logic [10:0] x_dc,
    input logic [10:0] y_dc,
    input logic signed [2:0] v_constant,
    input logic signed [2:0] h_constant,
    output logic [13:0]data_in_d,
    output logic signed [11:0] data_out
);
logic [10:0]x, y;
logic signed [2:0]filter_val;
logic signed [12:0] din;
assign x = data_in[22:12];
assign y = data_in[33:23];
assign din = $signed({1'b0, data_in[11:0]});

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
    end else begin
        data_out <= din / 4 * filter_val;
    end
end

endmodule