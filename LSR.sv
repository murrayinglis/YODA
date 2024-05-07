module LSR (
    input [15:0] data [0:DATA_SIZE-1], // Input array of data points
    input wire rst,
    input wire start,
    output reg signed [15:0] m,         // gradient
    output reg signed [15:0] b          // y intercept
);

parameter SCALE_FACTOR = 10000;
reg signed [31:0] partial_b;
reg signed [31:0] partial_m;
integer sum;
reg [31:0] i; // Loop counter
reg started;
integer x;
integer y;

always @(posedge start) begin
    started = 1;
end

always @* begin
    if (rst) begin
        started <= 0;
        m <= 0;
        b <= 0;
    end else if (started) begin
        partial_b <= 0;
        partial_m <= 0;

        for (i = 0; i < DATA_SIZE; i = i + 1) begin
            x = (i)*SCALE_FACTOR;
            y = data[i]*SCALE_FACTOR;
            partial_b = 2*(b+m*x-y);
            partial_m = 2*x*(b+m*x-y);
            //partial_b = partial_b * SCALE_FACTOR;
            //partial_m = partial_m * SCALE_FACTOR;

            b = b - partial_b;
            m = m - partial_m;
            $display("b: %d",b);
            $display("m: %d",m);
        end

        started <= 0;

        b = b/SCALE_FACTOR;
        m = m/SCALE_FACTOR;
        $display("b: %d",b);
        $display("m: %d",m);
    end
end

endmodule
