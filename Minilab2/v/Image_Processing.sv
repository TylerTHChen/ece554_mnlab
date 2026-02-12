module image_processing (
    input [10:0] iX_Cont,
    input [10:0] iY_Cont,
    input [11:0] iDATA,
    input iDVAL,
    input iCLK,
    input iRST,
    input switch, // 0 for vertical, 1 for horizontal
    output [11:0] output_data, 
    output valid
);

logic [11:0] grey_out;
logic grey_valid;
logic [10:0] x_cont, y_cont;
logic conv_valid;
logic signed [14:0] conv_out;
// grey scale instantiation
greyscale u_greyscale (
    .iX_Cont(iX_Cont), 
    .iY_Cont(iY_Cont),
    .iDATA(iDATA),
    .iDVAL(iDAVAL),
    .iCLK(iCLK),
    .iRST(iRST),
    .oDATA(grey_out),
    .oX_Cont(x_cont),
    .oY_Cont(y_cont),
    .valid(grey_valid)
);

// Convolution instantiation
convolution u_convolution (
    .clk    (iCLK),
    .rst_n  (iRST),
    .data_in (grey_out),
    .read   (grey_valid),
    .x      (x_cont),
    .y      (y_cont),
    .vertical (switch),
    .data_out (conv_out),
    .valid   (valid)
    );

// Abs instantiation
// abs u_abs (
//     .clk    (clk),
//     .rst_n  (rst_n),
//     .ab_in  (conv_out),
//     .ab_out (output_data)
// );



endmodule