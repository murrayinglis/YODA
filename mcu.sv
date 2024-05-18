// RAM control unit
module ramcu (
 clk , // Clock Input
 address , // Address Input
 data , // Data bi-directional
 cs , // Chip Select
 we , // Write Enable/Read Enable
 oe // Output Enable
 );
 // Setup some parameters
 parameter DATA_WIDTH = 8; // word size of the memory
 parameter ADDR_WIDTH = 8; // number of memory words, e.g. 2^8-1
 parameter RAM_DEPTH = 1 << ADDR_WIDTH; // i.e. RAM_DEPTH = 2^ADDR_WIDTH

 // Define inputs
 input clk, cs, we, oe;
 input [ADDR_WIDTH-1:0] address;

 // data is bidirectional
 inout [DATA_WIDTH-1:0] data;
 // Private registers
 reg [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1]; // Set up the memory array
 reg [DATA_WIDTH-1:0] r_data; // copy of data value to return
 reg r_oe; // delayed oe, r_oe updates only when rdata updated

 // START OF OPERATION: ///////////////////////////////////////////////
 // Tri-State Buffer control:
 // The data item is defined as an inout, only when oe, output enabled
 // is high, should it send a value to data, otherwise it should keep
 // the data port linked to high impedence (z) so as not to drive a value.
 // i.e. output to data happens when oe = 1 & cs = 1 & we = 0

 // Write to memory when: we = 1 & cs = 1
 always@ (posedge clk) begin
    if (cs) begin
        if (we)
            mem[address] <= data;
        r_data <= mem[address];
        // $display("data %d", data);
    end
    r_oe <= oe;
end

    assign data = (oe && cs && !we)? r_data : 8'bz;
endmodule // end ramcu 