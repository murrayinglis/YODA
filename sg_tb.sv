`timescale 1ns / 1ps

module sg_tb;

reg clk;         // Clock signal
reg sg_rst;   // Reset signal for SF
reg start;      // Start signal for SF


// Instantiate SF module
SG2 sg1 (
    .clk(clk),
    .rst(sg_rst),
    .start(start)
);



// Clock generation
always #5 clk = ~clk;

// Initial stimulus
initial begin
    clk = 0;

    #100 sg_rst = 1; // Reset SF
    #10 sg_rst = 0; // Release reset after 10 time units 

    #100 start = 1; // Start SF
    #1000 start = 0; 

    #50000 $finish;
end

// Monitor for observing signals
always @(posedge clk) begin
    //$display("Time: %0t, req: %b, rdy: %b, dat: %h", $time, req, rdy, dat);
end


endmodule
