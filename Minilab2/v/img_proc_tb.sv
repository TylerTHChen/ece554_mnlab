`timescale 1ns/1ps
module img_proc_tb;

  localparam int W    = 64;
  localparam int H    = 48;
  localparam int NPIX = W*H;

  logic clk, rst_n, switch;
  logic [10:0] iX_Cont, iY_Cont;
  logic [11:0] iData;
  logic        iDVAL;

  logic [11:0] output_data;
  logic        valid;

  logic [11:0] in_mem  [0:NPIX-1];
  logic [11:0] out_mem [0:NPIX-1];

  int idx;
  int out_idx;

  image_processing dut (
    .iCLK(clk),
    .iRST(rst_n),          // active-low reset (same behavior as rst_n)
    .iX_Cont(iX_Cont),
    .iY_Cont(iY_Cont),
    .iData(iData),
    .iDVAL(iDVAL),
    .switch(switch),
    .output_data(output_data),
    .valid(valid)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    rst_n  = 1'b0;         // assert reset (active-low)
    switch = 1'b0;

    iX_Cont = '0;
    iY_Cont = '0;
    iData   = '0;
    iDVAL   = 1'b0;

    for (int k = 0; k < NPIX; k++) out_mem[k] = 12'h000;

    $readmemh("input.hex", in_mem); // expects 12-bit hex values (000..FFF)

    #20;
    rst_n = 1'b1;          // deassert reset
    #10;

    idx = 0;
    for (int y = 0; y < H; y++) begin
      for (int x = 0; x < W; x++) begin
        @(posedge clk);
        iDVAL   <= 1'b1;
        iX_Cont <= x[10:0];
        iY_Cont <= y[10:0];
        iData   <= in_mem[idx];
        idx++;
      end
    end

    @(posedge clk);
    iDVAL <= 1'b0;
    iData <= '0;

    // wait until we've captured all expected output pixels
    while (out_idx < NPIX) @(posedge clk);

    $writememh("dut_out.hex", out_mem);
    $display("WROTE dut_out.hex (captured %0d pixels)", out_idx);
    $finish;
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      out_idx <= 0;
    end else begin
      if (valid) begin
        if (out_idx < NPIX) begin
          out_mem[out_idx] <= output_data;
          out_idx <= out_idx + 1;
        end
      end
    end
  end

endmodule
