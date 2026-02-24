module bus_interface (
    //bus signals
    inout wire [7:0] databus,
    input logic [1:0] ioaddr,
    input logic iocs,
    input logic iorw,

    //status signals
    input logic rda,
    input logic tbr,

    //data from receiver
    input logic [7:0] rx_data,

    //control signals to other modules
    output logic wr_tx,
    output logic [7:0] wr_data,  // directly the bus during write
    output logic wr_dbl,          // write low byte (IOADDR=2'b10 on write)
    output logic wr_dbh,          // write high byte (IOADDR=2'b11 on write)
    output logic rd_rx            // read from receiver (IOADDR=2'b00 on read)
);

    logic [7:0] status_reg;
    assign status_reg = {6'b0, tbr, rda};

    logic [7:0] databus_rd;

    always_comb begin 
        unique case (ioaddr)
            2'b00: databus_rd = rx_data;     // read from receiver
            2'b01: databus_rd = status_reg;  // read status
            default: databus_rd = 8'h00;
        endcase
    end

    assign databus = (iocs && iorw) ? databus_rd : 8'hZZ;

    assign wr_tx = (iocs && !iorw && ioaddr == 2'b00); // write to transmitter
    assign wr_dbl = (iocs && !iorw && ioaddr == 2'b10); // write low byte of divisor
    assign wr_dbh = (iocs && !iorw && ioaddr == 2'b11); // write high byte of divisor
    assign wr_data = databus; // data to write is directly from the bus
    assign rd_rx = (iocs && iorw && ioaddr == 2'b00); // read from receiver

endmodule