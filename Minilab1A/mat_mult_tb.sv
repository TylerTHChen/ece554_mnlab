module mat_mult_tb();
logic clk, rst_n, Clr;
logic [7:0] a_mat [0:7];
logic [7:0] b_vec;
logic [23:0] sum [0:7];

mat_mult iDUT(.clk(clk), .rst_n(rst_n), .Clr(Clr), 
            .a_mat(a_mat), .b_vec(b_vec), .sum(sum));

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
    
