module Bus_Interface(
    input logic IOCS,
    input logic IORW,
    input logic RDA,
    input logic TBR,
    input logic [1:0] IOADDR,
    input logic [7:0] recieve_buffer,
    inout logic [7:0] DATABUS,
    output logic [7:0] divisor_buffer
);

logic [7:0] status_reg;
logic [7:0] databus_rd;

// DATABUS logic
assign status_reg =  {{6'b0}, TBR, RDA};
assign databus_rd = IOADDR[0] ? status_ref : recieve_buffer;
assign DATABUS = (IOCS && IORW) ? databus_rd : 8'bz;

assign divisor_buffer = DATABUS;

endmodule