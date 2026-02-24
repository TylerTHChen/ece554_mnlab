// //////////////////////////////////////////////////////////////////////////////////
// // Company: 
// // Engineer: 
// // 
// // Create Date:    
// // Design Name: 
// // Module Name:    driver 
// // Project Name: 
// // Target Devices: 
// // Tool versions: 
// // Description: 
// //
// // Dependencies: 
// //
// // Revision: 
// // Revision 0.01 - File Created
// // Additional Comments: 
// //
// //////////////////////////////////////////////////////////////////////////////////
module driver(
    input  logic       clk,
    input  logic       rst,       // active-high reset
    input  logic [1:0] br_cfg,
    output logic       iocs,
    output logic       iorw,
    input  logic       rda,
    input  logic       tbr,
    output logic [1:0] ioaddr,
    inout  wire [7:0] databus
);

    typedef enum logic [2:0] {
        RECIEVE,
        TRANSMIT,
        STATUS_REC,
        STATUS_TRANS,
        DBLOW,
        DBHIGH
    } state_e;

    state_e state, next_state;

    // Need enough bits for 3,125,000 (50MHz/16)
    logic [21:0] constant;   // was [20:0]
    logic [15:0] db;         // divisor fits in 16 bits for these bauds

    logic [7:0] databus_o, databus_i;
    logic       db_out_en;
    logic [7:0] data;

    assign databus   = db_out_en ? databus_o : 8'hZZ;
    assign databus_i = databus;

    // Correct for a 50MHz system clock: 50_000_000 / 16 = 3_125_000
    assign constant = 22'd3125000;

    // Compute divisor from br_cfg (now matches the "correct" table)
    always_comb begin
        unique case (br_cfg)
            2'b00: db = constant / 16'd4800;   // -> 651 (0x028B)
            2'b01: db = constant / 16'd9600;   // -> 324 (0x0144)
            2'b10: db = constant / 16'd19200;  // -> 162 (0x00A2)
            2'b11: db = constant / 16'd38400;  // -> 81  (0x0051)
            default: db = constant / 16'd9600;
        endcase
    end

    // Drive bus value based on state (your style)
    always_comb begin
        databus_o = 8'h00;
        if (state == DBLOW)
            databus_o = db[7:0];
        else if (state == DBHIGH)
            databus_o = db[15:8];
        else if (state == TRANSMIT)
            databus_o = data;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= DBLOW;
        else
            state <= next_state;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            data <= 8'h00;
        else if (state == RECIEVE)
            data <= databus_i;
    end

    always_comb begin
        iocs       = 1'b0;
        iorw       = 1'b0;
        ioaddr     = 2'b00;
        db_out_en  = 1'b0;
        next_state = state;

        case (state)
            DBLOW: begin
                iocs      = 1'b1;
                iorw      = 1'b0;
                ioaddr    = 2'b10;      // DIV_LO
                db_out_en = 1'b1;
                next_state= DBHIGH;
            end

            DBHIGH: begin
                iocs      = 1'b1;
                iorw      = 1'b0;
                ioaddr    = 2'b11;      // DIV_HI
                db_out_en = 1'b1;
                next_state= STATUS_REC;
            end

            STATUS_REC: begin
                if (rda)
                    next_state = RECIEVE;
            end

            RECIEVE: begin
                iocs      = 1'b1;
                iorw      = 1'b1;       // read
                ioaddr    = 2'b00;      // DATA
                db_out_en = 1'b0;
                next_state= STATUS_TRANS;
            end

            STATUS_TRANS: begin
                if (tbr)
                    next_state = TRANSMIT;
            end

            TRANSMIT: begin
                iocs      = 1'b1;
                iorw      = 1'b0;       // write
                ioaddr    = 2'b00;      // DATA
                db_out_en = 1'b1;
                next_state= STATUS_REC;
            end

            default: next_state = DBLOW;
        endcase
    end

endmodule