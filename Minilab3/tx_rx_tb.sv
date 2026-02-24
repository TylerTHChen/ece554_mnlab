module tb_uart();

    logic clk;
    logic rst_n;

    // BRG-style enable (we'll fake it in TB)
    logic en_16x;

    // TX signals
    logic wr_tx;
    logic [7:0] wr_data;
    logic txd;
    logic tbr;

    // RX signals
    logic rd_rx;
    logic [7:0] rx_data;
    logic rda;

    // DUTs
    transmitter tx (
        .clk(clk),
        .rst_n(rst_n),
        .en_16x(en_16x),
        .wr_tx(wr_tx),
        .wr_data(wr_data),
        .txd(txd),
        .tbr(tbr)
    );

    receiver rx (
        .clk(clk),
        .rst_n(rst_n),
        .en_16x(en_16x),
        .rxd(txd),     // loopback connection
        .rd_rx(rd_rx),
        .rx_data(rx_data),
        .rda(rda)
    );

    // Clock
    always #5 clk = ~clk;

    // Simple en_16x generator (pulse every clock for simplicity)
    // This makes baud very fast in simulation
    always @(posedge clk) begin
        en_16x <= 1'b1;
    end

    initial begin
        clk = 0;
        rst_n = 0;
        wr_tx = 0;
        wr_data = 8'h00;
        rd_rx = 0;
        en_16x = 0;

        #20;
        rst_n = 1;
        #20;

        //----------------------------------------------------------
        // Send one byte
        //----------------------------------------------------------
        wr_data = 8'hA5;   // test pattern
        wr_tx = 1'b1;
        @(posedge clk);
        wr_tx = 1'b0;

        //----------------------------------------------------------
        // Wait for receiver to assert rda
        //----------------------------------------------------------
        wait(rda == 1'b1);
        #1;

        if (rx_data != 8'hA5) begin
            $display("ERROR: Received %h expected A5", rx_data);
            $stop();
        end

        //----------------------------------------------------------
        // Clear rda
        //----------------------------------------------------------
        rd_rx = 1'b1;
        @(posedge clk);
        #1; 
        rd_rx = 1'b0;
        #1;

        if (rda != 1'b0) begin
            $display("ERROR: RDA did not clear");
            $stop();
        end

        $display("TX/RX loopback test passed!");
        $finish();
    end

endmodule