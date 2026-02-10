`timescale 1 ps / 1 ps
module mat_mult_tb();
logic clk, rst_n, Clr;
logic [23:0] sum [0:7];

logic done, done_mac;
logic [71:0] curr_data;


fetch dut_fetch (
    .clk(clk),
    .rst_n(rst_n),
    .done(done),
    .curr_data(curr_data)
);

mat_mult dut_mat_mult (
    .clk(clk),
    .rst_n(rst_n),
    .Clr(Clr),
    .wren(done),
    .a_mat({curr_data[7:0], curr_data[15:8], curr_data[23:16], curr_data[31:24], curr_data[39:32], curr_data[47:40], curr_data[55:48], curr_data[63:56]}),
    .b_vec(curr_data[71:64]),
    .sum(sum),
    .done(done_mac)
);



always #5 clk = !clk;

initial begin
    clk = 0; 
    rst_n = 0;
    Clr = 1;

    @(posedge clk);
	@(posedge clk);
	@(posedge clk);

    rst_n = 1;
    Clr = 0;

    repeat (200) @(posedge clk);

    $stop;
end

    
endmodule

    
