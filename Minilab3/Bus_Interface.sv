module bus_interface(
    input logic iocs,
    input logic iorw,
    input logic rda,
    input logic tbr,
    input logic [1:0] ioaddr,
    input logic [7:0] recieve_buffer,
    inout logic [7:0] databus,
    output logic [7:0] divisor_buffer
);

logic [7:0] status_reg;
logic [7:0] databus_rd;

// databus logic
assign status_reg =  {{6'b0}, tbr, rda};
assign databus_rd = ioaddr[0] ? status_ref : recieve_buffer;
assign databus = (iocs && iorw) ? databus_rd : 8'bz;

assign divisor_buffer = databus;

endmodule