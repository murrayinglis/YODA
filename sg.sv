module SG(
    input wire clk,
    input wire rst,
    input wire start,
    output reg done
);

parameter WINDOW_SIZE = 7;
parameter DATA_SIZE = 30;
parameter ITERATIONS = 1000;
parameter ALPHA = 0.000001; // Learning rate
parameter LAMBDA = 0.001; // Regularisation

int data_y [0:1023];
int data_x [0:1023];
int data_out_x [0:1023];
real data_out_y [0:1023];


real data_window [0:WINDOW_SIZE-1];
real val;
real a0,a1,a2,a3;
real partial_a0 = 0;
real partial_a1 = 0;
real partial_a2 = 0;
real partial_a3 = 0;
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
        partial_a0 = 0;
        partial_a1 = 0;
        partial_a2 = 0;
        partial_a3 = 0;
        a0 = 0;
        a1 = 0;
        a2 = 0;
        a3 = 0;
    end else begin
        if (started) begin
            for (i = WINDOW_SIZE/2; i<DATA_SIZE-WINDOW_SIZE/2; i = i+1) begin
                // Setup data window
                for (j = -(WINDOW_SIZE/2); j<(WINDOW_SIZE-WINDOW_SIZE/2); j=j+1) begin
                    data_window[j+WINDOW_SIZE/2] = data_y[i+j];
                    //$display("%d",data_window[j+3]);
                end
                a0 = data_window[0];
                // Get coefficients for data window (fitting polynomial)
                for (k = 0; k < ITERATIONS; k = k + 1) begin
                    for (j = 0; j < WINDOW_SIZE; j = j + 1) begin
                        x = j;
                        y = data_y[j+i];
                        pred = a0 + a1*x + a2*x**2 + a3*x**3;
                        //$display("%f %f %f",x,y,pred);
                        partial_a0 = partial_a0 + 2*(pred - y);
                        partial_a1 = partial_a1 + 2*x*(pred - y);
                        partial_a2 = partial_a2 + 2*(x**2)*(pred - y);
                        partial_a3 = partial_a3 + 2*(x**3)*(pred - y);
                    end
                    partial_a0 = partial_a0 / WINDOW_SIZE;
                    partial_a1 = partial_a1 / WINDOW_SIZE;
                    partial_a2 = partial_a2 / WINDOW_SIZE;
                    partial_a3 = partial_a3 / WINDOW_SIZE;

                    // Update prediction
                    a0 = a0 - ALPHA*partial_a0;
                    a1 = a1 - ALPHA*partial_a1;
                    a2 = a2 - ALPHA*partial_a2;
                    a3 = a3 - ALPHA*partial_a3;
                    partial_a0 = 0;
                    partial_a1 = 0;
                    partial_a2 = 0;
                    partial_a3 = 0;
                end
                //$display("x:%d %d",j+i);
                // Get value from coefficients
                x = WINDOW_SIZE/2;
                $display("a0:%d a1:%d a2:%d a3:%d",a0,a1,a2,a3);
                val = a0 + a1*x + a2*x**2 + a3*x**3;
                data_out_y[i] = val;

                //$display("Fitted line: %f + %fx + %fx^2 +%fx^3. %f",a0,a1,a2,a3,val);
                a0 = 0;
                a1 = 0;
                a2 = 0;
                a3 = 0;
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
