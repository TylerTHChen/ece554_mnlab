module greyscale (
    input	[10:0]	iX_Cont,
    input	[10:0]	iY_Cont,
    input	[11:0]	iDATA,
    input			iDVAL,
    input			iCLK,
    input			iRST,
    output  [11:0]  oDATA
    output  [10:0]  oX_Cont,
    output  [10:0]  oY_Cont,
    output          valid,
);

logic rden;
logic wren;
logic [11:0] buffer_out;
logic full;
logic empty;

FIFO #(.DEPTH(1280), .DATA_WIDTH(12)) buffer(
    .clk(iCLK),
    .rst_n(iRST),
    .rden(rden),
    .wren(wren),
    .i_data(iData),
    .o_data(buffer_out),
    .full(full),
    .empty(empty)   
);

assign rden = full;
assign wren = iDVAL;





endmodule
