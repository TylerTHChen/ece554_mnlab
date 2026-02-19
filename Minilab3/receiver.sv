module receiver (
    input logic clk,
    input logic rst_n,
    input logic baud_rate, 
    input logic rx, 
    input logic clr_valid, 
    output logic [7:0] data_out,
    output logic valid
);

    typedef enum logic [1:0] {
        IDLE,
        START_BIT,
        DATA_BITS,
        STOP_BIT
    } state_t;

    state_t state, next_state;
    logic [2:0] bit_count; // To count the number of bits received
    logic [7:0] shift_reg; // Shift register to hold the incoming data

    // State transition logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            bit_count <= 0;
            shift_reg <= 0;
            valid <= 0;
        end else begin
            state <= next_state;
        end
    end

    // Next state logic
    always_comb begin
        next_state = state; // Default to stay in the current state
        case (state)
            IDLE: begin
                if (rx == 0) // Start bit detected
                    next_state = START_BIT;
            end
            START_BIT: begin
                if (baud_rate) // Wait for the baud rate signal to sample the start bit
                    next_state = DATA_BITS;
            end
            DATA_BITS: begin
                if (baud_rate) begin
                    shift_reg = {rx, shift_reg[7:1]}; // Shift in the received bit
                    bit_count++;
                    if (bit_count == 7) // After receiving 8 bits (0-7)
                        next_state = STOP_BIT;
                end
            end
            STOP_BIT: begin
                if (baud_rate) begin
                    valid = 1; // Data is valid after receiving stop bit
                    data_out = shift_reg; // Output the received data
                    next_state = IDLE; // Return to idle state for the next reception
                end
            end
        endcase

        if (clr_valid) begin
            valid = 0; // Clear valid signal when clr_valid is asserted
        end
    end

endmodule
