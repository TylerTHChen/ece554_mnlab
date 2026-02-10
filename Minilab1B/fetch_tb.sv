
`timescale 1 ps / 1 ps
module fetch_tb;

  logic clk;
  logic rst_n;
  logic done;
  logic [71:0] curr_data;

  // DUT
  fetch dut (
    .clk(clk),
    .rst_n(rst_n),
    .done(done),
    .curr_data(curr_data)
  );

  // clock: 10 ns period
  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    rst_n   = 1'b0;

    repeat (3) @(posedge clk);
    rst_n = 1'b1;

    repeat (2) @(posedge clk);

    // FIRST REQUEST
    @(posedge clk);
    @(posedge clk);

    @(posedge done);
    @(posedge clk);

    @(negedge done);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);

    // check first streamed beat (index = 63)
    $stop();
  end

endmodule
