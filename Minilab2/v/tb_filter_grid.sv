`timescale 1ns/1ps

module tb_filter_grid();
    logic clk, rst_n, vertical;
    logic[33:0] data_in;
    logic [10:0] x_dc;
    logic [10:0] y_dc;
    logic signed [2:0] v_constant;
    logic signed [2:0] h_constant;
    logic [13:0]data_in_d;
    logic signed [11:0] data_out;
    logic [10:0] x_val, y_val;
    logic [11:0] din;
    assign data_in = {y_val, x_val, din};

    filter_grid iDUT(   .clk(clk),
                        .rst_n(rst_n),
                        .data_in(data_in),
                        .vertical(vertical),
                        .x_dc(x_dc),
                        .y_dc(y_dc),
                        .v_constant(v_constant),
                        .h_constant(h_constant),
                        .data_in_d(data_in_d),
                        .data_out(data_out));

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        v_constant = 3'sd2;
        h_constant = -3'sd2;
        vertical = 1;
        x_dc = 11'd0;
        y_dc = 11'd959;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        din = 11'd100;
        x_val = 11'b0;
        y_val = 11'b0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        din = 11'd200;
        x_val = 11'b1;
        y_val = 11'b0;
        @(posedge clk);
        din = 11'd300;
        x_val = 11'd2;
        y_val = 11'b0;
        @(posedge clk);
        din = 11'd400;
        x_val = 11'd3;
        y_val = 11'b0;
        @(posedge clk);
        din = 11'd500;
        x_val = 11'd4;
        y_val = 11'b0;
        @(posedge clk);
        din = 11'd100;
        x_val = 11'b0;
        y_val = 11'b0;
        @(posedge clk);
        @(posedge clk);
        vertical = 0;
        @(posedge clk);
        @(posedge clk);
        din = 11'd200;
        x_val = 11'b1;
        y_val = 11'd959;
        @(posedge clk);
        din = 11'd300;
        x_val = 11'd2;
        y_val = 11'b0;
        @(posedge clk);
        din = 11'd400;
        x_val = 11'd3;
        y_val = 11'b0;
        @(posedge clk);
        din = 11'd500;
        x_val = 11'd4;
        y_val = 11'b0;
        @(posedge clk);
        din = 11'd600;
        x_val = 11'd5;
        y_val = 11'b0;
        @(posedge clk);
        din = 11'd700;
        x_val = 11'd6;
        y_val = 11'b0;
        @(posedge clk);
        din = 11'd800;
        x_val = 11'd7;
        y_val = 11'b0;
        $display("TB finished.");
        $finish;
    end
endmodule
