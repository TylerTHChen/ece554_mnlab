//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:   
// Design Name: 
// Module Name:    spart 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spart(
    input logic clk,
    input logic rst,
    input logic iocs,
    input logic iorw,
    output logic rda,
    output logic tbr,
    input logic [1:0] ioaddr,
    inout logic [7:0] databus,
    output logic txd,
    input logic rxd
);

logic en;
logic [7:0] recieve_buffer, divisor_buffer;

bus_interface bus_int(
    .iocs(iocs),
    .iorw(iorw),
    .rda(rda),
    .tbr(tbr),
    .ioaddr(ioaddr),
    .recieve_buffer(recieve_buffer),
    .databus(databus),
    .divisor_buffer(divisor_buffer)
);

baud_rate_generator BRG(
    .clk(clk),
    .rst_n(rst),
    .ioaddr(ioaddr),
    .DB(divisor_buffer), // todo: tyler -> will: I think we should just ahve a db instead of high and low coming from the interface since there is not clk in interface
    .en(en)
);

transmitter t1(
    .clk(clk),
    .rst_n(rst),        
    .baud_tick(en),
    .data_in(databus),
    .data_valid(), //todo: tyler -> bret: dont think we need this since we have busy
    .tx_out(txd),
    .busy(tbr)
);

receiver r1(
    .clk(clk),
    .rst_n(rst),
    .baud_rate(en), 
    .rx(rxd), 
    .clr_valid(), // todo: tyler -> bret: same as above
    .data_out(recieve_buffer),
    .valid() // todo: tyler -> bret: same as above
);

endmodule
