module tb_mac();
	logic clk, rst_n, En, Clr;
	logic [7:0] Ain, Bin;
	logic [23:0] Cout;

	MAC idut(.clk(clk), .rst_n(rst_n), .En(En), .Clr(Clr), .Ain(Ain), .Bin(Bin), .Cout(Cout));

	initial begin 
	clk = 1;
	rst_n = 0;
	En = 0;
	Clr = 0;
	Ain = 8'b0000_0010;
	Bin = 8'b0000_0010;
	#5;
	rst_n = 1;
	#5;

	if(Cout != 8'b0) begin
		$display("en low should be all zeros");
		$stop();
	end
	
	#5;
	En = 1'b1;
	@(posedge clk)
	#1;
	if(Cout != 8'b0000_0100) begin
		$display("Cout should be 4 here");
		$stop();
	end

	@(posedge clk);
	@(posedge clk);
	#1;
	if(Cout != 8'b0000_1100) begin
		$display("Cout different then expected");
		$stop();
	end

	En = 1'b0;
	@(posedge clk);
	@(posedge clk);
	#1;
	if(Cout != 8'b0000_1100) begin
		$display("Cout changed with en low");
		$stop();
	end

	Clr = 1'b1;

	@(posedge clk);
	@(posedge clk);
	#1;
	if(Cout != 8'b0000_0000) begin
		$display("Cout did not clear with clear");
		$stop();
	end
	
	$display("Tests passed maybe");
	$finish();

	end

	always begin 
		clk = !clk;
		#5;
	end

endmodule