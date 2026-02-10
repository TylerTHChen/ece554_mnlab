module fifo_tb();
logic clk, rst_n, rden, wren, full, empty;
logic  [7:0] i_data, o_data;
FIFO iDUT(.clk(clk), 
		  .rst_n(rst_n), 
		  .rden(rden), 
		  .wren(wren), 
		  .full(full), 
		  .empty(empty),
		  .i_data(i_data),		  
		  .o_data(o_data));
		  
always #5 clk = !clk;

initial begin
	clk = 0;
	rst_n = 0;
	rden = 0;
	wren = 0;
	
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	
	rst_n = 1;
	
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	
	i_data = 8'b0001_1110;
	wren = 1;
	
	@(posedge clk);
	wren = 0;
	@(posedge clk);
	rden = 1;
	@(posedge clk);
	if(o_data != 8'b0001_1110)begin
		$display("o_data should be x1E but x%h", o_data);
		$stop();
	end
	
	@(posedge clk);
	rden = 0;
	@(posedge clk);
	
	i_data = 8'b0000_0001;
	wren = 1;
	
	@(posedge clk);
	wren = 0;
	@(posedge clk);
	rden = 1;
	@(posedge clk);
	@(negedge clk);
	if(o_data != 8'b0000_0001)begin
		$display("o_data should be x01 but x%h", o_data);
		$stop();
	end
	@(posedge clk);
	rden = 0;
	
	@(posedge clk);
	i_data = 8'b0001_1110;
	wren = 1;
	@(posedge clk);
	wren = 0;
	@(posedge clk);
	i_data = 8'b1111_1111;
	wren = 1;
	@(posedge clk);
	wren = 0;
	@(posedge clk);
	rden = 1;
	@(posedge clk);
	@(negedge clk);
	if(o_data != 8'b0001_1110)begin
		$display("o_data should be x1E but x%h", o_data);
		$stop();
	end
	@(posedge clk);
	rden = 0;
	
	@(posedge clk);
	rden = 1;
	@(posedge clk);
	@(negedge clk);
	if(o_data != 8'b1111_1111)begin
		$display("o_data should be xFF but x%h", o_data);
		$stop();
	end
	@(posedge clk);
	rden = 0;
	
	@(posedge clk);
	@(posedge clk);
	for(int i = 0; i < 8; i++) begin
		@(posedge clk);
		i_data = 8'b0001_0000+ i;
		wren = 1;
		@(posedge clk);
		wren = 0;
		@(posedge clk);
	end
	
	
	
	$display("ALL TEST PASSED");
	$finish();
end
endmodule	
	
	