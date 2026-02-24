module receiver (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en_16x,
    input  logic       rxd,
    input  logic       rd_rx,
    output logic [7:0] rx_data,
    output logic       rda
);

    typedef enum logic [1:0] { IDLE, RECV, HOLD } state_t;
    state_t state, next_state;

    // RXD metastability
    logic rxd_meta, rxd_s;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rxd_meta <= 1'b1;
            rxd_s    <= 1'b1;
        end else begin
            rxd_meta <= rxd;
            rxd_s    <= rxd_meta;
        end
    end

    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Datapath registers
    logic [3:0] sample_cnt;    // 0–15 (16x oversampling)
    logic [3:0] bit_cnt;       // counts 10 samples (start + 8 data + stop)
    logic [9:0] rx_shift;      // shift register for sampled bits

    // Sampling condition (mid-bit)
    logic rx_sample;
    assign rx_sample = (state == RECV) && en_16x && (sample_cnt == 4'd7);

    // Next-state logic
    always_comb begin
        next_state = state;

        case (state)
            IDLE: begin
                if (!rda && (rxd_s == 1'b0))
                    next_state = RECV;
            end

            RECV: begin
                if (rx_sample && (bit_cnt == 4'd9))
                    next_state = HOLD;
            end

            HOLD: begin
                if (rd_rx)
                    next_state = IDLE;
            end
        endcase
    end

    // Sample counter (free-running mod-16 while receiving)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_cnt <= 4'd0;
        end else begin
            if (state == IDLE)
                sample_cnt <= 4'd0;
            else if (state == RECV && en_16x)
                sample_cnt <= sample_cnt + 4'd1;
        end
    end

    // Bit counter (increments only on mid-bit samples)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_cnt <= 4'd0;
        end else begin
            if (state == IDLE)
                bit_cnt <= 4'd0;
            else if (rx_sample)
                bit_cnt <= bit_cnt + 4'd1;
        end
    end

    // Shift in sampled bits (start + 8 data + stop)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_shift <= 10'd0;
        end else begin
            if (state == IDLE)
                rx_shift <= 10'd0;
            else if (rx_sample)
                rx_shift <= {rxd_s, rx_shift[9:1]};
        end
    end

    // Output logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_data <= 8'h00;
            rda     <= 1'b0;
        end else begin
            // Clear RDA on read (priority)
            if (rd_rx)
                rda <= 1'b0;

            // Latch received byte on transition to HOLD
            if (state == RECV && next_state == HOLD) begin
                rx_data <= rx_shift[9:2]; // CORRECT slice
                rda     <= 1'b1;
            end
        end
    end

endmodule