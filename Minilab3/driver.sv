//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    driver 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module driver(
    input clk,
    input rst,
    input [1:0] br_cfg,
    output iocs,
    output iorw,
    input rda,
    input tbr,
    output [1:0] ioaddr,
    inout [7:0] databus
    );

    typedef enum logic[2:0] {
        RECIEVE, 
        TRANSMIT, 
        STATUS_REC, 
        STAUS_TRANS,
        DBLOW, 
        DBHIGH
    } state_e;

    state_e state, next_state;

    logic dblow_s, dbhigh_s, status_rec_s, status_trans_s, rec_s, trans_s;

    logic [20:0] constant;
    logic [16:0] db;
    logic [7:0] databus_o, databus_i;
    logic db_out_en;
    logic [7:0] data; // from/to SPART

    assign dblow_s = state = DBLOW; 
    assign dbhigh_s = state = DBHIGH; 
    assign status_rec_s = state = STATUS_REC; 
    assign status_trans_s = state = STATUS_TRANS; 
    assign rec_s = state = RECIEVE; 
    assign trans_s = state = TRANSMIT;

    assign databus = db_out_en ? databus_o : 'z;
    assign databus_i = databus;
    
    
    always_ff @(posedge clk)begin
        if(dblow_s)
            databus_o <= db[7:0];
        else if(dbhigh_s)
            databus_o <= db[15:8];
        else if(trans_s)
            databus_o <= data;
    end

    always_ff @(posedge clk) begin
        if(rec_s) 
            data <= databus_i;
    end


    always_ff @(posedge clk, negedge rst_n) begin
        if(rst_n) 
            state <= DBLOW;
        else
            state <= next_state;
    end

    always_comb begin
        iocs = 0;
        iorw = 0;
        ioaddr = 2'b0;
        db_out_en = 0;
        next_state = state;
        case(state)
            DBLOW: begin
                iocs = 1;
                ioaddr = 2'b10;
                db_out_en = 1;
                next_state = DBHIGH;
            end 
            DBHIGH: begin
                iocs = 1;
                ioaddr = 2'b11;
                db_out_en = 1;
                next_state = STATUS;
            end
            STATUS_REC: begin
                iocs = 1;
                ioaddr = 2'b01;
                if(databus_i[0])
                    next_state = RECIEVE;
            end 
            STATUS_TRANS: begin
                iocs = 1;
                ioaddr = 2'b01;
                if(databus_i[1])
                    next_state = TRANSMIT;
            end
            RECIEVE: begin
                iocs = 1;
                ioaddr = 2'b0;
                iorw = 1;
                next_state = STATUS_TRANS;
            end 
            TRANSMIT: begin
                iocs = 1;
                ioaddr = 2'b0;
                iorw = 0;
                db_out_en = 1;
                next_state = STATUS_REC;
            end 
            default begin
                next_state = DBLOW;
            end
        endcase
    end


    // DB logic
    assign constant = 21'b101111101011110000100;  // 25MHz / 16
    always_comb begin
        case(br_cfg)
            2'b00 : begin // 4800
                db = constant / 10'd4800;
            end

            2'b01 : begin // 9600
                db = constant / 14'd9600;
            end

            2'b10 : begin // 19200
                db = constant / 15'd19200;
            end

            2'b11 : begin // 38400
                db = constant / 16'd38400;
            end
        endcase
    end


endmodule
