module greyscale (
    input	[10:0]	iX_Cont,
    input	[10:0]	iY_Cont,
    input	[11:0]	iDATA,
    input			iDVAL,
    input			iCLK,
    input			iRST,
    output  [11:0]  oDATA,
    output  [10:0]  oX_Cont,
    output  [10:0]  oY_Cont,
    output          valid
);

logic rden;
logic wren;
logic [11:0] buffer_out;
logic full;
logic empty;
logic valid_ff;
logic [10:0] curr_x, curr_y;
logic [11:0] top_row_1, top_row_2, bot_row_1, bot_row_2;
logic [13:0] data_out;


assign oX_Cont = curr_x;
assign oY_Cont = curr_y;
assign oDATA = data_out[13:2];
assign valid = valid_ff;
assign rden = full;
assign wren = iDVAL;

// FIFO #(.DEPTH(1280), .DATA_WIDTH(12)) buffer(
//     .clk(iCLK),
//     .rst_n(iRST),
//     .rden(rden),
//     .wren(wren),
//     .i_data(iDATA),
//     .o_data(buffer_out),
//     .full(full),
//     .empty(empty)   
// );

shift_register #(.WIDTH(12), .DEPTH(1280)) buffer (
    .clk(iCLK),
    .rst_n(iRST),
    .data_in(iDATA),
    .data_out(buffer_out)
);

always @(posedge iCLK, negedge iRST) begin
    if(!iRST)begin
        top_row_1 <= 0;
        top_row_2 <= 0;
        bot_row_1 <= 0;
        bot_row_2 <= 0;
    end
    else begin
        top_row_1 <= buffer_out;
        top_row_2 <= top_row_1;
        bot_row_1 <= iDATA;
        bot_row_2 <= bot_row_1;
    end
end

always @(posedge iCLK, negedge iRST)begin
    if(!iRST)begin
        curr_x <= 0;
        curr_y <= 0;
    end
    else begin
        curr_x <= iX_Cont;
        curr_y <= iY_Cont;
    end
end

always_comb begin
    if(~|curr_y && ~|curr_x) 
        data_out <= bot_row_1;
    else if (~|curr_y) begin 
        data_out <= bot_row_1 + bot_row_2;
    end
    else if (~|curr_x) begin
        data_out <= bot_row_1 + top_row_1;
    end
    else begin
        data_out <= bot_row_1 + bot_row_2 + top_row_1 + top_row_2;
    end
end

always @(posedge iCLK, negedge iRST)begin
    if(!iRST)begin
        valid_ff <= 0;
    end else begin
        valid_ff <= iDVAL;
    end
end


endmodule
