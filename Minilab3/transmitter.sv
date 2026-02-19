module transmitter (
    input  logic       clk,
    input  logic       rst_n,        // active-low reset
    input  logic       baud_tick,    // 1-cycle pulse @ baud rate (1x per bit)
    input  logic [7:0] data_in,
    input  logic       data_valid,   // request to send (pulse or level)
    output logic       tx_out,        // UART TX line
    output logic       busy           // high while transmitting
);

    typedef enum logic [2:0] {
        IDLE,
        WAIT_TICK,   // align start bit to baud_tick
        START_BIT,
        DATA_BITS,
        STOP_BIT
    } state_t;

    state_t state, next_state;

    logic [7:0] shreg;
    logic [2:0] bit_count;

    // Prevent re-sending if data_valid is held high:
    // We "consume" one request per data_valid assertion.
    logic dv_seen;

    // ----------------------------
    // Sequential: state + registers
    // ----------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            shreg     <= 8'd0;
            bit_count <= 3'd0;
            dv_seen   <= 1'b0;
        end else begin
            state <= next_state;

            // Track whether we've already accepted this data_valid assertion.
            // Reason: if data_valid stays high (level), don't retransmit endlessly.
            if (!data_valid)
                dv_seen <= 1'b0;
            else if (state == IDLE && next_state == WAIT_TICK)
                dv_seen <= 1'b1;

            // Latch the byte exactly once when we accept a request
            if (state == IDLE && next_state == WAIT_TICK) begin
                shreg     <= data_in;
                bit_count <= 3'd0;
            end

            // Shift one bit per baud tick during DATA_BITS
            // Reason: UART sends LSB first, one bit per bit-time.
            if (state == DATA_BITS && baud_tick) begin
                shreg     <= {1'b0, shreg[7:1]};
                bit_count <= bit_count + 3'd1;
            end
        end
    end

    // ----------------------------
    // Combinational: outputs + next state
    // ----------------------------
    always_comb begin
        // Defaults
        next_state = state;
        tx_out     = 1'b1;              // idle high
        busy       = (state != IDLE);

        unique case (state)
            IDLE: begin
                busy   = 1'b0;
                tx_out = 1'b1;

                // Accept a new send request only if we haven't consumed
                // the current data_valid assertion yet.
                if (data_valid && !dv_seen)
                    next_state = WAIT_TICK;
            end

            WAIT_TICK: begin
                // Hold line high while waiting to align start bit.
                tx_out = 1'b1;
                if (baud_tick)
                    next_state = START_BIT;
            end

            START_BIT: begin
                // Drive start bit low for exactly one bit time.
                tx_out = 1'b0;
                if (baud_tick)
                    next_state = DATA_BITS;
            end

            DATA_BITS: begin
                // Drive current LSB
                tx_out = shreg[0];

                // After sending 8 bits (counts 0..7), go to stop bit.
                if (baud_tick && (bit_count == 3'd7))
                    next_state = STOP_BIT;
            end

            STOP_BIT: begin
                // Stop bit high for one bit time.
                tx_out = 1'b1;
                if (baud_tick)
                    next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
                tx_out     = 1'b1;
                busy       = 1'b0;
            end
        endcase
    end

endmodule
