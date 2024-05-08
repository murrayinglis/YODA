module LSR3 (
    input signed [15:0] data [0:DATA_SIZE-1], // Input array of data points
    input reg [15:0] shift, // how much window is shifted by
    input wire rst,
    input wire start,
    output reg signed [15:0] val
);

parameter DATA_SIZE = 7;
parameter ITERATIONS = 1000;
parameter ALPHA = 0.000001;

real a0,a1,a2,a3;
real partial_a0 = 0;
real partial_a1 = 0;
real partial_a2 = 0;
real partial_a3 = 0;
reg signed [15:0] x,y;
reg signed [15:0] pred = 0;

integer unsigned i; // Loop counter 1
integer unsigned j; // Loop counter 2
int file_out;
reg started;

always @(posedge start) begin
    started = 1;
end

always @* begin
    if (rst) begin
        started <= 0;
        i <= 0;
        j <= 0;
        partial_a0 <= 0;
        partial_a1 <= 0;
        partial_a2 <= 0;
        partial_a3 <= 0;
        pred <= 0;
        a0 <= 100;
        a1 <= 0;
        a2 <= 0;
        a3 <= 0;
    end else if (started) begin


        for (i = 0; i < ITERATIONS; i = i + 1) begin
            for (j = 0; j < DATA_SIZE; j = j + 1) begin
                //$display("pb: %d, pm: %d, it: %d", partial_b,partial_m,i);
                //$display("x: %d, y: %d", x,y);
                x = j;
                y = data[j];
                pred = a0 + a1*x + a2*x**2 + a3*x**3;
                partial_a0 = partial_a0 + 2*(pred - y);
                partial_a1 = partial_a1 + 2*x*(pred - y);
                partial_a2 = partial_a2 + 2*(x**2)*(pred - y);
                partial_a3 = partial_a3 + 2*(x**3)*(pred - y);
                
            end
            partial_a0 = partial_a0 / DATA_SIZE;
            partial_a1 = partial_a1 / DATA_SIZE;
            partial_a2 = partial_a2 / DATA_SIZE;
            partial_a3 = partial_a3 / DATA_SIZE;
            //$display("pb: %d, pm: %d", partial_b,partial_m);
            //$display("b: %d, m: %d", b,m);
            a0 = a0 - ALPHA*partial_a0;
            a1 = a1 - ALPHA*partial_a1;
            a2 = a2 - ALPHA*partial_a2;
            a3 = a3 - ALPHA*partial_a3;
            partial_a0 = 0;
            partial_a1 = 0;
            partial_a2 = 0;
            partial_a3 = 0;
            j = 0;
            
        end

        started <= 0;

        x = DATA_SIZE/2;
        val = a0 + a1*x + a2*x**2 + a3*x**3;
        $display("a0: %f, a1: %f, a2: %f, a3: %f, val: %f", a0,a1,a2,a3,val);
        file_out = $fopen("coeffs.txt", "w");
        if (file_out == 0)
            $display("Error: Cannot open file for writing");
        else begin
            // Write variables to the file
            $fwrite(file_out, "%f\n%f\n%f\n%f", a0, a1, a2, a3);
            // Close the file
            $fclose(file_out);
        end
    end
end

endmodule
