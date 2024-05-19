`timescale 1ns / 1ps

module SG (
    input wire clk,
    input wire rst,
    input wire start,
    input reset,
    output real filtered_data [0:1023]
);

// Internal registers for filter
parameter reg [15:0] WINDOW_SIZE = 7; //Size of filter
parameter reg [31:0] DATA_SIZE = 1000;
int sum;
int started;
integer file;

// Internal registers for adc values
reg [7:0] data [0:DATA_SIZE];
reg eof = 0;
reg [31:0] idx = 0;
string s;

real a0 = -0.07059;
real a1 = -0.01176;
real a2 = 0.03801;
real a3 = 0.07873;
real a4 = 0.11041;
real a5 = 0.13303;
real a6 = 0.14661;
real a7 = 0.15113;

// return for fscan
int fart = 0;

// Read in file on initialize
initial begin
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
        fart = $fscanf(file, "%d", data[idx]);
        idx = idx + 1;
      end
    end
    
end

always @(posedge start) begin
    started = 1;
end

always @* begin 
    if (rst) begin
        $display("SF module reset");
        sum <= 0;
        idx <= 0;
        eof <= 0;

    end else if (started) begin
        for (int i = WINDOW_SIZE/2; i<DATA_SIZE-WINDOW_SIZE/2; i = i+1) begin
            filtered_data[i] = a0*data[i-7] + a1*data[i-6] + a2*data[i-5] + a3*data[i-4] + a4*data[i-3] + a5*data[i-2] + a6*data[i-1]
                                + a7*data[i] + a6*data[i+1] + a5*data[i+2] + a4*data[i+3] + a3*data[i+4] + a2*data[i+5] + a1*data[i+6]
                                + a0*data[i+7];
            //$display(filtered_data[i]);
        end

        // Pad before and after window size with values
        for(int i = 0; i<WINDOW_SIZE/2; i=i+1) begin
            filtered_data[i] = filtered_data[WINDOW_SIZE/2];
        end
        for(int i = DATA_SIZE - WINDOW_SIZE/2; i<DATA_SIZE; i=i+1) begin
            filtered_data[i] = filtered_data[DATA_SIZE - WINDOW_SIZE/2 -1];
        end
    end


    file = $fopen("output.csv", "w"); // Open the file for writing
    for (int i = 0; i < DATA_SIZE; i = i + 1) begin
        $fwrite(file, "%f\n", filtered_data[i]); // Write each element followed by a space separator
    end
    $fclose(file); // Close the file
    started = 0;
end

endmodule