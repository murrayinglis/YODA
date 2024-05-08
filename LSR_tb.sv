`timescale 1ns / 1ps

// Global Parameters
parameter DATA_SIZE = 7;  // Number of data points

module testbench;



// Inputs
reg signed [15:0] x_in [0:DATA_SIZE-1];
reg start;
reg rst;
reg [15:0] shift;

// Outputs
wire [15:0] x_out [0:DATA_SIZE-1];

LSR3 lsr (
    .data(x_in),
    .start(start),
    .rst(rst),
    .shift(shift)
);

integer eof;
integer idx;
integer fart;
integer file;

// Initialize inputs
initial begin
    // Load x values
    eof = 0;
    idx = 0;
    file = $fopen("data.csv", "r");
    if (file == 0) begin
        $display("Error opening file");
        $stop;
    end
    while (!eof) begin
      // Check for end of file
      if ($feof(file)) begin
        eof = 1;
      end else begin
        // Read integer from file
        fart = $fscanf(file, "%d", x_in[idx]);
        //$display("x: %d, y: %d", idx,x_in[idx]);
        idx = idx + 1;
      end
    end

    shift = 0;

    rst = 1;
    #100 rst = 0;

    start = 1;
    #1000000000 start = 0;
  



    #10000;
    $finish;
end



endmodule
