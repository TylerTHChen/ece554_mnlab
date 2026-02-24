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
    inout wire [7:0] databus,
    output logic txd,
    input logic rxd
);

logic rst_n;
    assign rst_n = ~rst;

    // Internal interconnect wires
    logic        en_16x;

    logic        wr_tx;
    logic [7:0]  wr_data;
    logic        wr_dbl;
    logic        wr_dbh;
    logic        rd_rx;

    logic [7:0]  rx_data_int;
    logic        rda_int;
    logic        tbr_int;

    assign rda = rda_int;
    assign tbr = tbr_int;

    // Bus Interface 
    bus_interface u_bus_if (
        .databus (databus),
        .ioaddr  (ioaddr),
        .iocs    (iocs),
        .iorw    (iorw),

        .rda     (rda_int),
        .tbr     (tbr_int),

        .rx_data (rx_data_int),

        .wr_tx   (wr_tx),
        .wr_data (wr_data),
        .wr_dbl  (wr_dbl),
        .wr_dbh  (wr_dbh),
        .rd_rx   (rd_rx)
    );

    // Baud Rate Generator
    BRG u_brg (
        .clk     (clk),
        .rst_n   (rst_n),
        .wr_dbl  (wr_dbl),
        .wr_dbh  (wr_dbh),
        .data_in (wr_data),
        .en_16x  (en_16x)
    );

    // Transmitter
    transmitter u_tx (
        .clk     (clk),
        .rst_n   (rst_n),
        .en_16x  (en_16x),
        .wr_tx   (wr_tx),
        .wr_data (wr_data),
        .txd     (txd),
        .tbr     (tbr_int)
    );

    // Receiver
    receiver u_rx (
        .clk     (clk),
        .rst_n   (rst_n),
        .en_16x  (en_16x),
        .rxd     (rxd),
        .rd_rx   (rd_rx),
        .rx_data (rx_data_int),
        .rda     (rda_int)
    );

endmodule