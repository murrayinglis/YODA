module SG(
    input clk,
    input rst,
    input start,
    output reg done
);

parameter WINDOW_SIZE = 7;
parameter POLYNOMIAL_DEGREE = 3; // Using linear for now
parameter DATA_SIZE = 1000;
parameter DATA_STEP = 1/DATA_SIZE;
parameter ITERATIONS = 1000;
parameter ALPHA = 0.000001;

int data_y [0:1023];
int data_x [0:1023];
int data_out_x [0:1023];
real data_out_y [0:1023];


real data_window [0:WINDOW_SIZE-1];
real val;
real b,m;
real partial_b = 0;
real partial_m = 0;
real x,y;
real pred = 0;



int i;
int signed j;
int k;

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
        // Read real from file
        fart = $fscanf(file, "%d", data_y[idx]);
        //$display("%d",data_y[idx]);
        idx = idx + 1;
      end
    end
    $display("Data file read in");
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
        partial_b = 0;
        partial_m = 0;
        b = 0;
        m = 0;
    end else begin
        if (started) begin
            for (i = WINDOW_SIZE/2; i<DATA_SIZE-WINDOW_SIZE/2; i = i+1) begin
                // Setup data window
                for (j = -3; j<(WINDOW_SIZE-3); j=j+1) begin
                    data_window[j+3] = data_y[i+j];
                    //$display("%d",data_window[j+3]);
                end
                // Get coefficients for data window (fitting polynomial)
                for (k = 0; k < ITERATIONS; k = k + 1) begin
                    for (j = 0; j < WINDOW_SIZE; j = j + 1) begin
                        x = j;
                        y = data_y[j+i];
                        pred = m*x + b;
                        //$display("%f %f %f",x,y,pred);
                        partial_b = partial_b + 2*(pred - y);
                        partial_m = partial_m + 2*(pred - y)*x;     
                    end
                    partial_b = partial_b / WINDOW_SIZE;
                    partial_m = partial_m / WINDOW_SIZE;
                    b = b - ALPHA*partial_b;
                    m = m - ALPHA*partial_m;
                    partial_m = 0;
                    partial_b = 0;
                end
                //$display("x:%d %d",j+i);
                // Get value from coefficients
                val = m*3+b;
                data_out_y[i] = val;
                //$display("Fitted line: %fx + %f. %f",m,b,val);
                m = 0;
                b = 0;
            end

            // Pad before and after window size with values
            for(i = 0; i<WINDOW_SIZE/2; i=i+1) begin
                data_out_y[i] = data_out_y[WINDOW_SIZE/2];
            end
            for(i = DATA_SIZE - WINDOW_SIZE/2; i<DATA_SIZE; i=i+1) begin
                data_out_y[i] = data_out_y[DATA_SIZE - WINDOW_SIZE/2 -1];
            end
        end


        file = $fopen("output.csv", "w"); // Open the file for writing
        for (int i = 0; i < DATA_SIZE; i = i + 1) begin
            $fwrite(file, "%f\n", data_out_y[i]); // Write each element followed by a space separator
        end
        $fclose(file); // Close the file
        started = 0;
    end


end

endmodule
