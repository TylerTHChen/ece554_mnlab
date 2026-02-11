module convolution(
    input logic clk,
    input logic rst_n,
    input logic [11:0]data_in,
    input logic start,
    output logic [11:0]data_out,
    output logic valid
);

logic [1:0] full_logic;
logic [11:0] fifo_bot_out, fifo_top_out;


always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin

end

FIFO #(.DEPTH(1280), .DATA_WIDTH(12)) fifo_top(
    .clk(clk),
    .rst_n(rst_n),
    .rden(),
    .wren(),
    .i_data(fifo_bot_out),
    .o_data(fifo_top_out),
    .full(full[1]),
    .empty()
);

FIFO #(.DEPTH(1280), .DATA_WIDTH(12)) fifo_bot(
    .clk(clk),
    .rst_n(rst_n),
    .rden(),
    .wren(),
    .i_data(data_in),
    .o_data(fifo_bot_out),
    .full(full[0]),
    .empty()
);


endmodule