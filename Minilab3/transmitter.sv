module transmitter (
    input logic clk, 
    input logic rst_n,
    input logic en_16x,
    input logic wr_tx,
    input logic [7:0] wr_data,
    output logic txd,
    output logic tbr
);

    typedef enum logic [1:0] {IDLE, WAIT, SEND} state_t;
    state_t state, next_state;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= IDLE;
        else state <= next_state;
    end

    //baud tick stuff, divide by 16 to get 1 baud tick
    logic [3:0] tick16_cnt;
    logic baud_tick;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tick16_cnt <= 4'd0;
            baud_tick <= 1'b0;
        end else begin
            baud_tick <= 1'b0; // default low each cycle
            if (en_16x) begin
                if (tick16_cnt == 4'd15) begin
                    baud_tick <= 1'b1; // pulse on every 16th cycle
                    tick16_cnt <= 4'd0; // reset counter
                end else begin
                    tick16_cnt <= tick16_cnt + 4'd1;
                end
            end
        end
    end

    // Transmitter buffer control
    logic [7:0] tx_buf;
    logic buf_full;

    assign tbr = !buf_full;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_buf <= 8'h00;
            buf_full <= 1'b0;
        end else begin
            if (wr_tx && tbr) begin
                tx_buf <= wr_data;
                buf_full <= 1'b1;
            end

            if (state == WAIT && next_state == SEND) begin 
                buf_full <= 1'b0;
            end
        end
    end

    // shift reg and fsm
    logic [9:0] shreg; // start bit + 8 data bits + stop bit
    logic [3:0] bit_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shreg <= 10'b1111111111; // idle state of line is high
            bit_cnt <= 4'd0;
        end else begin
            if (state == WAIT && next_state == SEND) begin
                shreg <= {1'b1, tx_buf, 1'b0}; // stop bit, data bits, start bit
                bit_cnt <= 4'd0;
            end else if (state == SEND && baud_tick) begin
                shreg <= {1'b1, shreg[9:1]}; // shift right, fill with 1s for stop bits
                bit_cnt <= bit_cnt + 4'd1;
            end
        end
    end

    always_comb begin 
        next_state = state;
        txd = 1'b1; // default idle state
        case (state)
            IDLE: begin
                txd = 1'b1; // line is high when idle
                if (buf_full) next_state = WAIT;
            end

            WAIT: begin
                txd = 1'b1; // line is high while waiting to start
                if (baud_tick) next_state = SEND; // start immediately on next cycle
            end

            SEND: begin
                txd = shreg[0]; // output the LSB of the shift register

                if (baud_tick && bit_cnt == 4'd9) begin
                    next_state = IDLE; // done sending when we have shifted out all bits
                end
            end
        endcase
    end

endmodule
