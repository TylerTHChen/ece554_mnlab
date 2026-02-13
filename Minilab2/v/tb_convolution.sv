module tb_convolution();

logic clk;
logic rst_n;
logic [11:0]data_in;
logic read;
logic [10:0]x;
logic [10:0]y;
logic vertical;
logic [11:0]data_out;
logic valid;

convolution iDUT(.*);

integer row, col;
integer pixel;
always #5clk = ~clk;
initial begin
    clk = 0;
    rst_n =0;
    // init
    read     = 0;
    data_in  = 0;
    x        = 0;
    y        = 0;
    vertical = 1'b1;

    // wait reset release
    @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    pixel = 1;

    for (row = 0; row < 960; row = row + 1) begin
        for (col = 0; col < 1280; col = col + 1) begin

        @(negedge clk);
        data_in = pixel;
        x       = col;
        y       = row;
        read = 1;

        pixel = pixel + 1;

        end
    end

    @(negedge clk);
    read = 0;
    $display("TB finished.");
    $finish;
end

endmodule