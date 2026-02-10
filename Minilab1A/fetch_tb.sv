module fetch_tb();
logic clk, rst_n, request, done;
logic [7:0] A [0:63];
logic [7:0] B [0:7];

fetch iDUT(.clk(clk), .rst_n(rst_n), .request(request), 
        .A(A), .B(B), .done(done));

always $5 clk = !clk;

initial begin 
    clk = 0;
    rst_n = 0;
    request = 0;

    @(posedge clk);
	@(posedge clk);
	@(posedge clk);

    rst_n = 1;
    @(posedge clk);

    request = 1;
    @(posedge clk);
    @(posedge clk);
    request = 0;

    @(posedge done);


    if(A[0] != 8'b0000_0001) begin 
        $display("A[0] is not correct");
		$stop();
    end

    if(B[0] != 8'b1000_0001) begin
        $display("B[0] is not correct");
		$stop();
    end 

    if(B[7] != 8'b1000_1000) begin 
        $display("B[7] is not correct");
		$stop();
    end
end 
endmodule
     
