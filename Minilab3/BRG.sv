module baud_rate_generator ()(
    logic clk,
    logic rst_n,
    logic [1:0] ioaddr,
    logic [7:0] DBhigh,
    logic [7:0] DBlow,
    logic en
);

logic [15:0] divisor;

always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        divisor <= 16'd325 //this is the divisor for a 50MHz clk rate and a 9600 baud rate
    end else begin
        
    end
end






endmodule