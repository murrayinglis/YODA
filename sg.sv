module SG(
    input clk,
    input rst,
    input start,
    output reg done
);
reg [7:0] data [0:1023];
reg [7:0] data_out [0:1023];

parameter WINDOW_SIZE = 7;
parameter POLYNOMIAL_DEGREE = 3;
parameter len = 1000;

reg signed [15:0] data_window [0:WINDOW_SIZE-1];

integer i;

reg signed [31:0] sum = 0; // Extended size to avoid overflow
integer j;

int started;
int eof;
int idx;
int fart;
int file;

initial begin
    //Read in data
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

always @(posedge clk or posedge rst) begin
    if (rst) begin
        done <= 0;
        for (i = 0; i < WINDOW_SIZE; i = i + 1) begin
            data_window[i] <= 0;
        end
    end else begin
        if (started) begin
            // slide the window along the data_in array

        end


        file = $fopen("output.csv", "w"); // Open the file for writing
        for (int i = 0; i < len; i = i + 1) begin
            $fwrite(file, "%d\n", data_out[i]); // Write each element followed by a space separator
        end
        $fclose(file); // Close the file
        started = 0;
    end


end

endmodule
