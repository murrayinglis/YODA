module LSR2 (
    input signed [15:0] data [0:DATA_SIZE-1], // Input array of data points
    input reg [15:0] shift, // how much window is shifted by
    input wire rst,
    input wire start,
    output reg signed [15:0] val
);

parameter DATA_SIZE = 7;
parameter ITERATIONS = 1000;
parameter LEARNING_RATE = 16'h0001; //fixed point 2^-10

real b,m;
real partial_b = 0;
real partial_m = 0;
reg signed [15:0] x,y;
reg signed [15:0] pred = 0;

integer unsigned i; // Loop counter 1
integer unsigned j; // Loop counter 2
reg started;

always @(posedge start) begin
    started = 1;
end

always @* begin
    if (rst) begin
        started <= 0;
        i <= 0;
        j <= 0;
        partial_b <= 0;
        partial_m <= 0;
        pred <= 0;
        b <= 0;
        m <= 0;
    end else if (started) begin


        for (i = 0; i < ITERATIONS; i = i + 1) begin
            for (j = 0; j < DATA_SIZE; j = j + 1) begin
                //$display("pb: %d, pm: %d, it: %d", partial_b,partial_m,i);
                $display("x: %d, y: %d", x,y);
                x = j;
                y = data[j];
                pred = m*x + b;
                partial_b = partial_b + 2*(pred - y);
                partial_m = partial_m + 2*(pred - y)*x;
                
            end
            partial_b = partial_b / DATA_SIZE;
            partial_m = partial_m / DATA_SIZE;
            //$display("pb: %d, pm: %d", partial_b,partial_m);
            //$display("b: %d, m: %d", b,m);
            b = b - 0.0001*partial_b;
            m = m - 0.0001*partial_m;
            partial_m = 0;
            partial_b = 0;
            j = 0;
            
        end

        started <= 0;

        val = m*(DATA_SIZE/2)+b;
        $display("b: %d, m: %d, val: %d", b,m,val);
    end
end

endmodule
