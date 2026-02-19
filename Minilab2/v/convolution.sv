module convolution #(
    parameter int ROW_LENGTH = 1280
) (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [11:0] data_in,
    input  logic        read,
    input  logic        switch,   // 0 = vertical, 1 = horizontal
    output logic [11:0] data_out,
    output logic        valid_out
);

    // typedef enum logic [2:0] {IDLE, BUF, WAIT, START_F1, START_F2, DONE_F1} state_e;
    // state_e state, next_state;
    // logic [1:0] full, empty;
    // logic [33:0] fifo_bot_out, fifo_top_out;

    logic signed [13:0] sobel_mag; 
    logic signed [11:0] data [0:2][0:2];
    logic [11:0] row_1, row_2; 
    logic signed [11:0] filter [0:2][0:2];

    logic signed [11:0] vertical [0:2][0:2] = '{
        '{-12'sd1,  12'sd0,  12'sd1},
        '{-12'sd2,  12'sd0,  12'sd2},
        '{-12'sd1,  12'sd0,  12'sd1}
    };

    logic signed [11:0] horizontal [0:2][0:2] = '{
        '{-12'sd1, -12'sd2, -12'sd1},
        '{ 12'sd0,  12'sd0,  12'sd0},
        '{ 12'sd1,  12'sd2,  12'sd1}
    };

     assign filter =   (switch) ? horizontal : vertical; 

    shift_register #(.WIDTH(12), .DEPTH(ROW_LENGTH)) sr1 (
        .clk(clk),
        .rst_n(rst_n), 
        .data_in(data_in),
        .read(read),
        .data_out(row_1)
    );

    shift_register #(.WIDTH(12), .DEPTH(ROW_LENGTH)) sr2 (
        .clk(clk),
        .rst_n(rst_n), 
        .data_in(row_1),
        .read(read),
        .data_out(row_2)
    );

    always_comb begin
        data[0][2] = row_2;
        data[1][2] = row_1;
        data[2][2] = data_in;
    end

    always_ff @(posedge clk) begin
        data[0][0] <= data[0][1];
        data[0][1] <= data[0][2];
        data[1][0] <= data[1][1];
        data[1][1] <= data[1][2];
        data[2][0] <= data[2][1];
        data[2][1] <= data[2][2];
    end

    //     filter_grid mid_one(
    //     .clk(clk),
    //     .rst_n(rst_n),
    //     .data_in(sft_bot_out),
    //     .vertical(vertical),
    //     .x_dc(11'd0),
    //     .y_dc(11'd2000),
    //     .v_constant(3'sd2),
    //     .h_constant(3'sd0),
    //     .data_in_d(mid12),
    //     .data_out(mid1)
    // );

    // filter_grid mid_two(
    //     .clk(clk),
    //     .rst_n(rst_n),
    //     .data_in(mid12),
    //     .vertical(vertical),
    //     .x_dc(11'd2000),
    //     .y_dc(11'd2000),
    //     .v_constant(3'sd0),
    //     .h_constant(3'sd0),
    //     .data_in_d(mid23),
    //     .data_out(mid2)
    // );

    // filter_grid mid_three(
    //     .clk(clk),
    //     .rst_n(rst_n),
    //     .data_in(mid23),
    //     .vertical(vertical),
    //     .x_dc(11'd1279),
    //     .y_dc(11'd2000),
    //     .v_constant(-3'sd2),
    //     .h_constant(3'sd0),
    //     .data_in_d(),
    //     .data_out(mid3)
    // );

    int i, j;
    always_comb begin
        sobel_mag = '0;

        for (i = 0; i < 3; i++) begin
            for (j = 0; j < 3; j++) begin
                sobel_mag += $signed(data[i][j]) * $signed(filter[i][j]);
            end
        end

        sobel_mag = (sobel_mag < 0) ? -sobel_mag : sobel_mag;
    end

    assign data_out = sobel_mag;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            valid_out <= 1'b0;
        else
            valid_out <= read;
    end

endmodule
