module mat_mult #(
    parameter DATA_WIDTH = 8, 
    parameter DEPTH = 8
)

(
    input logic clk, 
    input logic rst_n, 
    input logic Clr,

    input logic wren,

    input logic [DATA_WIDTH-1:0] a_mat [0:DEPTH-1],
    input logic [DATA_WIDTH-1:0] b_vec,
    
    output logic [DATA_WIDTH*3-1:0] sum [0:7],
    output logic done
);

logic [7:0] rden;
logic [7:0] En;

logic all_full;
logic [8:0] full;
logic [8:0] empty;
assign all_full = &full;

logic [7:0] En_d;

always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n) En_d <= '0;
  else       En_d <= En;
end

assign done = (|Bout[7]) && !En_d[7];


////////////////ENABLE LOGIC//////////////////////////
always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        rden <= '0;
    end
    else if(Clr)begin
        rden <= '0;
    end
    else if(all_full)begin
        rden <= {rden[6:0], 1'b1};
    end
    else if(rden[7])begin
        rden <= {rden[6:0],1'b0};
    end
    else begin
        rden <= {rden[6:0], rden[0]};
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        En <= '0;
    else 
        En <= rden;
end


///////////////     MAC     ///////////////////////

logic [DATA_WIDTH*3-1:0] Cout [0:DEPTH-1];
logic [DATA_WIDTH-1:0] Ain [0:DEPTH-1];        //TODO: hook up Ain to the FIFOs
logic [DATA_WIDTH-1:0] Bin;        //TODO: hook up Bin[0] to its FIFO

logic [DATA_WIDTH-1:0] Bout [0:DEPTH-1]; 

//assign done = |Bout[7] && !En[7];


MAC mac0(.clk(clk), .rst_n(rst_n), .En(En[0]), .Clr(Clr), .Ain(Ain[0]), .Bin(Bin), .Bout(Bout[0]), .Cout(Cout[0]));
MAC mac1(.clk(clk), .rst_n(rst_n), .En(En[1]), .Clr(Clr), .Ain(Ain[1]), .Bin(Bout[0]), .Bout(Bout[1]), .Cout(Cout[1]));
MAC mac2(.clk(clk), .rst_n(rst_n), .En(En[2]), .Clr(Clr), .Ain(Ain[2]), .Bin(Bout[1]), .Bout(Bout[2]), .Cout(Cout[2]));
MAC mac3(.clk(clk), .rst_n(rst_n), .En(En[3]), .Clr(Clr), .Ain(Ain[3]), .Bin(Bout[2]), .Bout(Bout[3]), .Cout(Cout[3]));
MAC mac4(.clk(clk), .rst_n(rst_n), .En(En[4]), .Clr(Clr), .Ain(Ain[4]), .Bin(Bout[3]), .Bout(Bout[4]), .Cout(Cout[4]));
MAC mac5(.clk(clk), .rst_n(rst_n), .En(En[5]), .Clr(Clr), .Ain(Ain[5]), .Bin(Bout[4]), .Bout(Bout[5]), .Cout(Cout[5]));
MAC mac6(.clk(clk), .rst_n(rst_n), .En(En[6]), .Clr(Clr), .Ain(Ain[6]), .Bin(Bout[5]), .Bout(Bout[6]), .Cout(Cout[6]));
MAC mac7(.clk(clk), .rst_n(rst_n), .En(En[7]), .Clr(Clr), .Ain(Ain[7]), .Bin(Bout[6]), .Bout(Bout[7]), .Cout(Cout[7]));


assign sum = Cout;



////////////// fifo a //////////
genvar i;
generate
  for (i=0; i<8; i=i+1) begin : fifo_gen
     FIFO
     #(
     .DEPTH(DEPTH),
     .DATA_WIDTH(DATA_WIDTH)
     ) input_fifo
     (
     .clk(clk),
     .rst_n(rst_n),
     .rden(rden[i]),
     .wren(wren),
     .i_data(a_mat[i]),
     .o_data(Ain[i]),
     .full(full[i]),
     .empty(empty[i])
     );
  end
endgenerate


////////// fifo b /////////////
FIFO #(
     .DEPTH(DEPTH),
     .DATA_WIDTH(DATA_WIDTH)
     ) input_fifo
     (
     .clk(clk),
     .rst_n(rst_n),
     .rden(rden[0]),
     .wren(wren),
     .i_data(b_vec),
     .o_data(Bin),
     .full(full[8]),
     .empty(empty[8])
     );

endmodule