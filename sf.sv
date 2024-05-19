`timescale 1ns / 1ps

module SF (
    input wire clk,
    input wire rst,
    input wire start,
    input reset,
    output reg [15:0] filtered_data [0:1023]
);

// Internal registers for filter
parameter reg [15:0] M = 51; //Size of filter
parameter reg [31:0] len = 1000;
int sum;
int started;
integer file;

// Internal registers for adc values
reg [7:0] data [0:1023];
reg eof = 0;
reg [31:0] idx = 0;
string s;

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
        $display("Applying filter");
        for(int i = 0; i < len; i = i + 1) begin
            sum = 0;
            //$display("%d",data[i]);
            for(int j = 0; j < M; j = j + 1) begin
                sum = sum + data[i+j];
                //$display("%d",sum);
            end
            filtered_data[i] = sum/M;         
        end
        eof = 0;
        started = 0;
        for (int i = 0; i < len; i = i + 1) begin
            s = {s, $sformatf("%h", filtered_data[i]), " "}; // Concatenate each element with a space separator
        end
        

        file = $fopen("output.csv", "w"); // Open the file for writing
        for (int i = 0; i < len-M; i = i + 1) begin
            $fwrite(file, "%f\n", filtered_data[i]); // Write each element followed by a space separator
        end
        $fclose(file); // Close the file
    end
end

endmodule