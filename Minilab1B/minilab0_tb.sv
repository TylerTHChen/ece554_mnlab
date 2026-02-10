module minilab0_tb();
	logic clk50, clk4_50, clk2_50, clk3_50;
	logic [3:0] rst_n;
	logic [9:0] en;
	logic [6:0] hex0, hex1, hex2, hex3, hex4, hex5;
	logic [9:0] LEDR;
	Minilab0 iDUT(.CLOCK2_50(clk2_50),
				  .CLOCK3_50(clk3_50),
				  .CLOCK4_50(clk4_50),
				  .CLOCK_50(clk50),
				  .KEY(rst_n),
				  .SW(en),
				  .LEDR(LEDR),
				  .HEX0(hex0),
				  .HEX1(hex1),
				  .HEX2(hex2),
				  .HEX3(hex3),
				  .HEX4(hex4),
				  .HEX5(hex5)
				  );

	initial begin
		clk50 = 0;
		forever #10 clk50 = ~clk50;
	end
	initial begin
		clk4_50 = 0;
		forever #5 clk4_50 = ~clk4_50;
	end
	initial begin
		clk2_50 = 0;
		forever #2 clk2_50 = ~clk2_50;
	end
	initial begin
		clk3_50 = 0;
		forever #1 clk3_50 = ~clk3_50;
	end
	initial begin
		rst_n = 4'b0000;
		en = 9'b0;
		@(posedge clk50);
		@(posedge clk50);
		@(posedge clk50);
		@(posedge clk50);
		@(posedge clk50);
		@(posedge clk50);
		@(posedge clk50);
		@(posedge clk50);
		@(posedge clk50);
		@(posedge clk50);
		en = '1;
		rst_n = '1;
	end
endmodule