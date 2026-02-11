module image_processing (



);

// grey scale instantiation
greyscale u_greyscale (
    .iX_Cont(), 
    .iY_Cont(),
    .iDATA(),
    .iDVAL(),
    .iCLK(),
    .iRST(),
    .oDATA(),
    .oX_Cont(),
    .oY_Cont(),
);

// Convolution instantiation
convolution u_convolution (
    .clk    (clk),
    .rst_n  (rst_n),
    .data_in (),
    .start   (),
    .data_out (conv_out),
    .valid   ()
    );

// Abs instantiation
abs u_abs (
    .clk    (clk),
    .rst_n  (rst_n),
    .ab_in  (conv_out),
    .ab_out (abs_out)
);



endmodule