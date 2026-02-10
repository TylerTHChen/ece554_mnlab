// module MAC #
// (
// parameter DATA_WIDTH = 8
// )
// (
// input clk,
// input rst_n,
// input En,
// input Clr,
// input [DATA_WIDTH-1:0] Ain,
// input [DATA_WIDTH-1:0] Bin,
// output logic [DATA_WIDTH-1:0] Bout,
// output logic [DATA_WIDTH*3-1:0] Cout
// );


// always_ff @(posedge clk, negedge rst_n) begin
// 	if(~rst_n)
// 		Cout <= '0;
// 	else if(En)
// 		Cout <= (Ain * Bin) + Cout;
// 	else if(Clr)
// 		Cout <= '0;
// 	else 
// 		Cout <= Cout;
// end

// always_ff @(posedge clk, negedge rst_n) begin
// 	if(~rst_n)
// 		Bout <= '0;
// 	else if (En)
// 		Bout <= Bin;
// 	else 
// 		Bout <= Bout;
// end

// endmodule

module MAC #(
  parameter DATA_WIDTH = 8
)(
  input  logic clk,
  input  logic rst_n,
  input  logic En,
  input  logic Clr,
  input  logic [DATA_WIDTH-1:0] Ain,
  input  logic [DATA_WIDTH-1:0] Bin,
  output logic [DATA_WIDTH-1:0] Bout,
  output logic [DATA_WIDTH*3-1:0] Cout
);

  logic [DATA_WIDTH*2-1:0] prod_reg;   // 16-bit for 8x8
  logic                   en_d;        // delayed enable

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      prod_reg <= '0;
      en_d     <= 1'b0;
      Bout     <= '0;
    end else if(Clr) begin
      prod_reg <= '0;
      en_d     <= 1'b0;
      Bout     <= '0;
    end else begin
      en_d <= En;
      if (En) begin
        prod_reg <= Ain * Bin;   // stage 1
        Bout     <= Bin;         // keep Bout aligned with En
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      Cout <= '0;
    end else if(Clr) begin
      Cout <= '0;
    end else if(en_d) begin
      Cout <= Cout + prod_reg;   // stage 2
    end
  end

endmodule