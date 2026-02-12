module convolution(
    input logic clk,
    input logic rst_n,
    input logic [11:0]data_in,
    input logic read,
    input logic [10:0]x,
    input logic [10:0]y,
    input logic vertical,
    output logic [11:0]data_out,
    output logic valid
);

typedef enum logic [2:0] {IDLE, BUF, WAIT, START_F1, START_F2, DONE_F1} state_e;
state_e state, next_state;

logic [1:0] full, empty;
logic [13:0] fifo_bot_out, fifo_top_out;
logic fifo2_wr, fifo2_rd;
logic [13:0] top12, top23, mid12, mid23, bot12, bot23;
logic signed [11:0] top1, top2, top3, mid1, mid2, mid3, bot1, bot2, bot3;
logic signed [12:0] sum;

assign sum = top1 + top2 + top3 + mid1 + mid2 + mid3 + bot1 + bot2 + bot3;
assign data_out = valid ? sum[11:0] : data_out;

always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always_comb begin
    next_state = state;
    valid = 0;
    fifo2_wr = 0;
    fifo2_rd = 0;
    case(state)
        default: begin
            if(read)
                next_state = BUF;
        end
        BUF: begin
            if(full[0])
                next_state = WAIT;
        end
        WAIT: begin
            fifo2_wr = 1;
            next_state = START_F1;
        end
        START_F1: begin
            valid = 1;
            fifo2_wr = 1;
            if(&full)
                next_state = START_F2;
        end
        START_F2: begin
            valid = 1;
            fifo2_wr = 1;
            fifo2_rd = 1;
            if(empty[0])
                next_state = DONE_F1;
        end
        DONE_F1: begin
            valid = 1;
            fifo2_rd = 1;
            if(|empty)
                next_state = IDLE;
        end
    endcase
end

FIFO #(.DEPTH(1280), .DATA_WIDTH(34)) fifo_top(
    .clk(clk),
    .rst_n(rst_n),
    .rden(fifo2_rd),
    .wren(fifo2_wr && !empty[0]),
    .i_data(fifo_bot_out),
    .o_data(fifo_top_out),
    .full(full[1]),
    .empty(empty[1])
);

FIFO #(.DEPTH(1280), .DATA_WIDTH(34)) fifo_bot(
    .clk(clk),
    .rst_n(rst_n),
    .rden(fifo2_wr),
    .wren(read),
    .i_data({y,x,data_in}),
    .o_data(fifo_bot_out),
    .full(full[0]),
    .empty(empty[0])
);

filter_grid #(
    .v_constant(1),
    .h_constant(-1)
) top_one(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(fifo_top_out),
    .vertical(vertical),
    .x_dc(11'b0),
    .y_dc(11'd959),
    .data_in_d(top12),
    .data_out(top1)
);
//959//1279
filter_grid #(
    .v_constant(0),
    .h_constant(-2)
) top_two(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(top12),
    .vertical(vertical),
    .x_dc(11'd2048),
    .y_dc(11'd959),
    .data_in_d(top23),
    .data_out(top2)
);

filter_grid #(
    .v_constant(-1),
    .h_constant(-1)
) top_three(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(top23),
    .vertical(vertical),
    .x_dc(11'd1279),
    .y_dc(11'd959),
    .data_in_d(),
    .data_out(top3)
);

filter_grid #(
    .v_constant(2),
    .h_constant(0)
) mid_one(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(fifo_bot_out),
    .vertical(vertical),
    .x_dc(11'd0),
    .y_dc(11'd2048),
    .data_in_d(mid12),
    .data_out(mid1)
);

filter_grid #(
    .v_constant(0),
    .h_constant(0)
) mid_two(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(mid12),
    .vertical(vertical),
    .x_dc(11'd2048),
    .y_dc(11'd2048),
    .data_in_d(mid23),
    .data_out(mid2)
);

filter_grid #(
    .v_constant(-2),
    .h_constant(0)
) mid_three(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(mid23),
    .vertical(vertical),
    .x_dc(11'd1279),
    .y_dc(11'd2048),
    .data_in_d(),
    .data_out(mid3)
);

filter_grid #(
    .v_constant(1),
    .h_constant(1)
) bot_one(
    .clk(clk),
    .rst_n(rst_n),
    .data_in({y,x,data_in}),
    .vertical(vertical),
    .x_dc(11'd0),
    .y_dc(11'd0),
    .data_in_d(bot12),
    .data_out(bot1)
);

filter_grid #(
    .v_constant(0),
    .h_constant(2)
) bot_two(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(bot12),
    .vertical(vertical),
    .x_dc(11'd2048),
    .y_dc(11'd0),
    .data_in_d(bot23),
    .data_out(bot2)
);

filter_grid #(
    .v_constant(-1),
    .h_constant(1)
) bot_three(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(bot23),
    .vertical(vertical),
    .x_dc(11'd1279),
    .y_dc(11'd0),
    .data_in_d(),
    .data_out(bot3)
);


endmodule