`timescale 1ns / 1ps

module sf_tb;

reg clk;         // Clock signal
reg adc_rst;         // Reset signal for ADC
reg sf_rst;   // Reset signal for SF
reg start;      // Start signal for SF
wire rdy;
wire [7:0] dat;
wire [7:0] len;


// Instantiate SF module
SF sf (
    .clk(clk),
    .rst(sf_rst),
    .start(start),
    .req(req),
    .rdy(rdy),
    .dat(dat),
    .len(len)
);


// Instantiate ADC module
ADC adc (
    .req(req),      
    .rst(adc_rst),     
    .rdy(rdy),      
    .dat(dat),
    .len(len)
);

// Clock generation
always #5 clk = ~clk;

// Initial stimulus
initial begin
    clk = 0;

    sf_rst = 1; // Reset SF
    #10 sf_rst = 0; // Release reset after 10 time units 

    // Reset ADC
    adc_rst = 1;
    #10; 
    adc_rst = 0;

    #10 start = 1; // Start SF
    #10 start = 0; 

    #500 $finish;
end

// Monitor for observing signals
always @(posedge clk) begin
    //$display("Time: %0t, req: %b, rdy: %b, dat: %h, start %d", $time, req, rdy, dat, start);
end


endmodule
