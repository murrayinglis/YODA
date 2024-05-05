module SG(
    input clk,
    input rst,
    input start,
    output reg done
);

parameter WINDOW_SIZE = 7;
parameter POLYNOMIAL_DEGREE = 3; // Using linear for now
parameter len = 1000;
parameter ITERATIONS = 1000;

reg [7:0] data [0:1023];
reg [7:0] data_out [0:1023];


reg signed [15:0] data_window [0:WINDOW_SIZE-1];
reg signed [15:0] val;
real b,m;
real partial_b = 0;
real partial_m = 0;
reg signed [15:0] x,y;
reg signed [15:0] pred = 0;



integer i;
integer signed j;
integer k;

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
            for (i = WINDOW_SIZE/2; i<len-WINDOW_SIZE/2; i = i+1) begin
                // Setup data window
                for (j = -3; j<WINDOW_SIZE; j=j+1) begin
                    data_window[j] = data[i+j];
                end
                // Get coefficients
                for (k = 0; k < ITERATIONS; k = k + 1) begin
                    for (j = 0; j < WINDOW_SIZE; j = j + 1) begin
                        x = j;
                        y = data[j];
                        pred = m*x + b;
                        partial_b = partial_b + 2*(pred - y);
                        partial_m = partial_m + 2*(pred - y)*x;     
                    end
                    partial_b = partial_b / WINDOW_SIZE;
                    partial_m = partial_m / WINDOW_SIZE;
                    b = b - 0.0001*partial_b;
                    m = m - 0.0001*partial_m;
                    partial_m = 0;
                    partial_b = 0;
                end
                // Get value from coefficients
                val = m*i+b;
                data_out[i] = val;
            end
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
